CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Core Tables with Notes Separation
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


CREATE TABLE journals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, name),  -- One journal name per user
    UNIQUE(user_id, id)  -- Add this to support the notes foreign key
); 

CREATE TABLE instruments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('stock', 'crypto', 'forex', 'future')),
    last_price NUMERIC(18, 8),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Unified Notes Table (Polymorphic Relationship)
CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    noteable_type VARCHAR(20) NOT NULL CHECK (noteable_type IN ('trade_entry', 'trade_exit', 'fund')),
    noteable_id UUID NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(noteable_type, noteable_id),
    journal_id UUID NOT NULL REFERENCES journals(id) ON DELETE CASCADE,
    FOREIGN KEY (journal_id, noteable_id) 
    REFERENCES trade_entries(journal_id, id) ON DELETE CASCADE,
    FOREIGN KEY (journal_id, noteable_id) 
    REFERENCES trade_exits(journal_id, id) ON DELETE CASCADE,
    FOREIGN KEY (journal_id, noteable_id) 
    REFERENCES funds(journal_id, id) ON DELETE CASCADE
);

-- Trade Entities (Modified for Metric Calculations)
CREATE TABLE trade_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    instrument_id UUID NOT NULL REFERENCES instruments(id),
    direction VARCHAR(5) CHECK (direction IN ('LONG', 'SHORT')),
    quantity NUMERIC(18, 8) NOT NULL CHECK (quantity > 0),
    entry_price NUMERIC(18, 8) NOT NULL,
    stop_loss NUMERIC(18, 8),
    current_stop_loss NUMERIC(18, 8) GENERATED ALWAYS AS (
        COALESCE(current_stop_loss_override, stop_loss)
    ) STORED,
    current_stop_loss_override NUMERIC(18, 8),
	charges NUMERIC(18, 8) NOT NULL DEFAULT 0,
    entry_date TIMESTAMPTZ NOT NULL,
    journal_id UUID NOT NULL REFERENCES journals(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id, journal_id) REFERENCES journals(user_id, id),
    UNIQUE(id, journal_id),  -- Required for trade_exits foreign key
    
    -- Calculated Fields (Reference: metricsExplained/2.PositionMetrics.md lines 5-59)
    risk NUMERIC(18, 8) GENERATED ALWAYS AS (
        CASE direction
            WHEN 'LONG' THEN quantity * (entry_price - stop_loss)
            ELSE quantity * -(entry_price - stop_loss)
        END
    ) STORED,
    exposure NUMERIC(18, 8) GENERATED ALWAYS AS (quantity * entry_price) STORED
);

CREATE TABLE trade_exits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_id UUID NOT NULL REFERENCES trade_entries(id) ON DELETE CASCADE,
    exit_date TIMESTAMPTZ NOT NULL,
    exit_price NUMERIC(18, 8) NOT NULL,
    quantity_exited NUMERIC(18, 8) NOT NULL CHECK (quantity_exited > 0),
    charges NUMERIC(18, 8) NOT NULL DEFAULT 0,
    entry_price NUMERIC(18, 8) NOT NULL,
    journal_id UUID NOT NULL REFERENCES journals(id) ON DELETE CASCADE,
    FOREIGN KEY (entry_id, journal_id) REFERENCES trade_entries(id, journal_id),
    
    -- Modified calculated field to use local column
    gain_pct NUMERIC(18, 8) GENERATED ALWAYS AS (
        (exit_price - entry_price) / entry_price
    ) STORED
);

-- Funds with Validation (Reference: DataModelingFlow.md lines 126-129)
CREATE TABLE funds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    type VARCHAR(10) CHECK (type IN ('DEPOSIT', 'WITHDRAW')),
    amount NUMERIC(18, 8) NOT NULL CHECK (amount > 0),
    transaction_date TIMESTAMPTZ NOT NULL,
    journal_id UUID NOT NULL REFERENCES journals(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id, journal_id) REFERENCES journals(user_id, id)
	-- ,
    -- CHECK (
    --     (type = 'WITHDRAW' AND amount <= (
    --         SELECT COALESCE(SUM(amount) FILTER (WHERE type = 'DEPOSIT'), 0) 
    --         - COALESCE(SUM(amount) FILTER (WHERE type = 'WITHDRAW'), 0) 
    --         FROM funds f 
    --         WHERE f.user_id = funds.user_id 
    --         AND f.transaction_date <= funds.transaction_date
    --     ))
    -- )
);

-- 1. Create base view for open position calculations (used by both metrics)
CREATE MATERIALIZED VIEW open_trades_base AS
SELECT
    te.id,
    te.journal_id,
    te.user_id,
    te.instrument_id,
    te.direction,
    te.entry_price,
    te.current_stop_loss,
    te.quantity - COALESCE(SUM(te2.quantity_exited), 0) AS open_quantity,
    (te.quantity - COALESCE(SUM(te2.quantity_exited), 0)) * te.entry_price AS exposure,
    CASE te.direction
        WHEN 'LONG' THEN (te.current_stop_loss - te.entry_price)
        ELSE (te.entry_price - te.current_stop_loss)
    END * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0)) AS open_risk
FROM trade_entries te
LEFT JOIN trade_exits te2 ON te.id = te2.entry_id AND te.journal_id = te2.journal_id
GROUP BY te.id
HAVING te.quantity - COALESCE(SUM(te2.quantity_exited), 0) > 0;

-- Indexes for frequent filters
CREATE INDEX idx_open_trades_base_user ON open_trades_base(user_id);
CREATE INDEX idx_open_trades_base_instrument ON open_trades_base(instrument_id);
CREATE INDEX idx_trade_entries_journal ON trade_entries(journal_id);
CREATE INDEX idx_trade_exits_journal ON trade_exits(journal_id);
CREATE INDEX idx_funds_journal ON funds(journal_id);
CREATE INDEX idx_notes_journal ON notes(journal_id);

-- 2. Create user metrics view
CREATE MATERIALIZED VIEW journal_metrics AS
WITH fund_data AS (
    SELECT 
        journal_id,
        SUM(amount) FILTER (WHERE type = 'DEPOSIT') AS total_deposits,
        SUM(amount) FILTER (WHERE type = 'WITHDRAW') AS total_withdrawals
    FROM funds
    GROUP BY journal_id
),
realized_profits AS (
    SELECT
        te.journal_id,
        SUM(
            CASE te.direction
                WHEN 'LONG' THEN (te2.exit_price - te.entry_price) * te2.quantity_exited
                ELSE (te.entry_price - te2.exit_price) * te2.quantity_exited
            END - te2.charges
        ) AS total_realized
    FROM trade_exits te2
    JOIN trade_entries te ON te.id = te2.entry_id AND te.journal_id = te2.journal_id
    GROUP BY te.journal_id
)
SELECT
    j.id AS journal_id,
    j.user_id,
    COALESCE(fd.total_deposits, 0) - COALESCE(fd.total_withdrawals, 0) AS capital_deployed,
    COALESCE(fd.total_deposits, 0) - COALESCE(fd.total_withdrawals, 0) + COALESCE(rp.total_realized, 0) AS account_value,
    COALESCE(SUM(otb.exposure), 0) AS total_exposure,
    COALESCE(SUM(otb.open_risk), 0) AS total_open_risk
FROM journals j
LEFT JOIN fund_data fd ON j.id = fd.journal_id
LEFT JOIN realized_profits rp ON j.id = rp.journal_id
LEFT JOIN open_trades_base otb ON j.id = otb.journal_id
GROUP BY j.id, fd.total_deposits, fd.total_withdrawals, rp.total_realized;

-- 3. Create position metrics view
CREATE MATERIALIZED VIEW position_metrics AS
SELECT
    otb.*,
    otb.exposure / NULLIF(um.account_value, 0) AS exposure_pct,
    otb.open_risk / NULLIF(um.account_value, 0) AS open_risk_pct
FROM open_trades_base otb
JOIN journal_metrics um ON otb.journal_id = um.journal_id

-- Add this after creating the position_metrics view
CREATE UNIQUE INDEX idx_position_metrics_id ON position_metrics (id);

-- Indexes and Refresh Triggers (Optimized for JournalingSystem.md flows)
CREATE INDEX idx_trade_entries_user ON trade_entries(user_id);
CREATE INDEX idx_trade_exits_entry ON trade_exits(entry_id);
CREATE INDEX idx_funds_user ON funds(user_id);
CREATE UNIQUE INDEX idx_journal_metrics ON journal_metrics(journal_id);
CREATE INDEX idx_instruments_symbol ON instruments(symbol);
CREATE INDEX idx_notes_user ON notes(user_id);

-- Automatic Metrics Refresh
CREATE OR REPLACE FUNCTION refresh_metrics() RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY journal_metrics;
    REFRESH MATERIALIZED VIEW CONCURRENTLY position_metrics;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Revised trigger for trade_entries
CREATE TRIGGER refresh_metrics_trade_entries
AFTER INSERT OR UPDATE OF entry_price, quantity, stop_loss, current_stop_loss_override OR DELETE ON trade_entries
FOR EACH ROW WHEN (pg_trigger_depth() = 0)
EXECUTE FUNCTION refresh_metrics();

-- Revised trigger for funds
CREATE TRIGGER refresh_metrics_funds
AFTER INSERT OR UPDATE OF amount, type OR DELETE ON funds
FOR EACH ROW WHEN (pg_trigger_depth() = 0)
EXECUTE FUNCTION refresh_metrics();

-- Revised trigger for trade_exits
CREATE TRIGGER refresh_metrics_trade_exits 
AFTER INSERT OR UPDATE OF exit_price, quantity_exited, charges OR DELETE ON trade_exits
FOR EACH ROW WHEN (pg_trigger_depth() = 0)
EXECUTE FUNCTION refresh_metrics();

-- Add refresh for open_trades_base
CREATE TRIGGER refresh_open_trades_base 
AFTER INSERT OR UPDATE OR DELETE ON trade_exits
FOR EACH ROW EXECUTE PROCEDURE refresh_metrics();

-- -- Add validation trigger for exit_date
-- CREATE OR REPLACE FUNCTION validate_exit_date() RETURNS TRIGGER AS $$
-- DECLARE
--     entry_dt TIMESTAMPTZ;
-- BEGIN
--     SELECT entry_date INTO entry_dt 
--     FROM trade_entries 
--     WHERE id = NEW.entry_id;
    
--     IF NEW.exit_date <= entry_dt THEN
--         RAISE EXCEPTION 'Exit date must be after trade entry date (%)', entry_dt;
--     END IF;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE TRIGGER validate_exit_date_trigger
-- BEFORE INSERT OR UPDATE ON trade_exits
-- FOR EACH ROW EXECUTE FUNCTION validate_exit_date();

-- Daily at 2AM
-- 0 2 * * * psql -c "REFRESH MATERIALIZED VIEW CONCURRENTLY summary_view_mv;"
-- -- On trade modifications
-- CREATE TRIGGER refresh_summary AFTER INSERT OR UPDATE ON trade_exits 


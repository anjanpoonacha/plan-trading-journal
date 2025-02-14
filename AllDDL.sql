-- Core Tables with Notes Separation
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE instruments (
    id SERIAL PRIMARY KEY,
    symbol VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(20) CHECK (type IN ('stock', 'crypto', 'forex', 'future')),
    last_price NUMERIC(18, 8),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Unified Notes Table (Polymorphic Relationship)
CREATE TABLE notes (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    noteable_type VARCHAR(20) NOT NULL CHECK (noteable_type IN ('trade_entry', 'trade_exit', 'fund')),
    noteable_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(noteable_type, noteable_id)
);

-- Trade Entities (Modified for Metric Calculations)
CREATE TABLE trade_entries (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    instrument_id INT NOT NULL REFERENCES instruments(id),
    direction VARCHAR(5) CHECK (direction IN ('LONG', 'SHORT')),
    quantity NUMERIC(18, 8) NOT NULL CHECK (quantity > 0),
    entry_price NUMERIC(18, 8) NOT NULL,
    stop_loss NUMERIC(18, 8),
    current_stop_loss NUMERIC(18, 8) GENERATED ALWAYS AS (
        COALESCE(current_stop_loss_override, stop_loss)
    ) STORED,
    current_stop_loss_override NUMERIC(18, 8),
    entry_date TIMESTAMPTZ NOT NULL,
    
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
    id SERIAL PRIMARY KEY,
    entry_id INT NOT NULL REFERENCES trade_entries(id) ON DELETE CASCADE,
    exit_date TIMESTAMPTZ NOT NULL,
    exit_price NUMERIC(18, 8) NOT NULL,
    quantity_exited NUMERIC(18, 8) NOT NULL CHECK (quantity_exited > 0),
    charges NUMERIC(18, 8) NOT NULL DEFAULT 0,
    entry_price NUMERIC(18, 8) NOT NULL,
    
    -- Modified calculated field to use local column
    gain_pct NUMERIC(18, 8) GENERATED ALWAYS AS (
        (exit_price - entry_price) / entry_price
    ) STORED
);

-- Funds with Validation (Reference: DataModelingFlow.md lines 126-129)
CREATE TABLE funds (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    type VARCHAR(10) CHECK (type IN ('DEPOSIT', 'WITHDRAW')),
    amount NUMERIC(18, 8) NOT NULL CHECK (amount > 0),
    transaction_date TIMESTAMPTZ NOT NULL
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

-- Create independent user metrics first
CREATE MATERIALIZED VIEW user_metrics AS
WITH 
fund_summary AS (
    SELECT 
        user_id,
        SUM(amount) FILTER (WHERE type = 'DEPOSIT') AS total_deposits,
        SUM(amount) FILTER (WHERE type = 'WITHDRAW') AS total_withdrawals
    FROM funds
    GROUP BY user_id
),
realized_profits AS (
    SELECT
        te.user_id,
        SUM(
            CASE te.direction
                WHEN 'LONG' THEN (te2.exit_price - te.entry_price) * te2.quantity_exited
                ELSE (te.entry_price - te2.exit_price) * te2.quantity_exited
            END - te2.charges
        ) AS total_realized_profit
    FROM trade_exits te2
    JOIN trade_entries te ON te.id = te2.entry_id
    GROUP BY te.user_id
),
position_calculations AS (
    SELECT
        te.user_id,
        SUM(
            (te.quantity - COALESCE(SUM(te2.quantity_exited), 0)) * te.entry_price
        ) FILTER (WHERE te.quantity - COALESCE(SUM(te2.quantity_exited), 0) > 0) AS total_exposure,
        SUM(
            CASE te.direction
                WHEN 'LONG' THEN (te.current_stop_loss - te.entry_price) * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0))
                ELSE (te.entry_price - te.current_stop_loss) * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0))
            END
        ) FILTER (WHERE te.quantity - COALESCE(SUM(te2.quantity_exited), 0) > 0) AS total_open_risk
    FROM trade_entries te
    LEFT JOIN trade_exits te2 ON te.id = te2.entry_id
    GROUP BY te.user_id
)
SELECT
    u.id AS user_id,
    COALESCE(fs.total_deposits, 0) - COALESCE(fs.total_withdrawals, 0) AS capital_deployed,
    COALESCE(fs.total_deposits, 0) - COALESCE(fs.total_withdrawals, 0) + COALESCE(rp.total_realized_profit, 0) AS account_value,
    COALESCE(pc.total_exposure, 0) AS total_exposure,
    COALESCE(pc.total_open_risk, 0) AS total_open_risk
FROM users u
LEFT JOIN fund_summary fs ON u.id = fs.user_id
LEFT JOIN realized_profits rp ON u.id = rp.user_id
LEFT JOIN position_calculations pc ON u.id = pc.user_id;

-- Then create position_metrics that depends on user_metrics
CREATE MATERIALIZED VIEW position_metrics AS
WITH open_trades AS (
    SELECT 
        te.*,
        te.quantity - COALESCE(SUM(te2.quantity_exited), 0) AS open_quantity
    FROM trade_entries te
    LEFT JOIN trade_exits te2 ON te.id = te2.entry_id
    GROUP BY te.id
    HAVING te.quantity - COALESCE(SUM(te2.quantity_exited), 0) > 0
)
SELECT
    ot.id,
    ot.user_id,
    ot.instrument_id,
    ot.open_quantity,
    ot.entry_price,
    ot.current_stop_loss,
    ot.direction,
    ot.open_quantity * ot.entry_price AS exposure,
    (ot.open_quantity * ot.entry_price) / um.account_value AS exposure_pct,
    CASE ot.direction
        WHEN 'LONG' THEN (ot.current_stop_loss - ot.entry_price) * ot.open_quantity
        ELSE (ot.entry_price - ot.current_stop_loss) * ot.open_quantity
    END AS open_risk,
    CASE ot.direction
        WHEN 'LONG' THEN (ot.current_stop_loss - ot.entry_price) * ot.open_quantity / um.account_value
        ELSE (ot.entry_price - ot.current_stop_loss) * ot.open_quantity / um.account_value
    END AS open_risk_pct
FROM open_trades ot
JOIN user_metrics um ON ot.user_id = um.user_id;

-- Indexes and Refresh Triggers (Optimized for JournalingSystem.md flows)
CREATE INDEX idx_trade_entries_user ON trade_entries(user_id);
CREATE INDEX idx_trade_exits_entry ON trade_exits(entry_id);
CREATE INDEX idx_funds_user ON funds(user_id);
CREATE UNIQUE INDEX idx_user_metrics ON user_metrics(user_id);
CREATE INDEX idx_instruments_symbol ON instruments(symbol);
CREATE INDEX idx_notes_user ON notes(user_id);

-- Automatic Metrics Refresh
CREATE OR REPLACE FUNCTION refresh_metrics() RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY user_metrics;
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
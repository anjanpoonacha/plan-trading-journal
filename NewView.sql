drop materialized view if exists unified_trade_metrics;
drop index if exists idx_unified_journal;
drop index if exists idx_unified_user;
drop index if exists idx_unified_instrument;

CREATE MATERIALIZED VIEW unified_trade_metrics AS
WITH exit_aggregates AS (
    SELECT 
        ex.entry_id,
        ex.journal_id,
        JSONB_AGG(
            jsonb_build_object(
                'exit_date', ex.exit_date,
                'exit_price', ex.exit_price,
                'quantity_exited', ex.quantity_exited,
                'charges', ex.charges,
                'days_held', EXTRACT(DAY FROM ex.exit_date - te.entry_date),
                'gain_pct', ex.gain_pct,
                'profit', CASE te.direction
                    WHEN 'LONG' THEN (ex.exit_price - te.entry_price) * ex.quantity_exited
                    ELSE (te.entry_price - ex.exit_price) * ex.quantity_exited
                END - ex.charges
            ) ORDER BY ex.exit_date
        ) AS exit_records,
        SUM(ex.quantity_exited) AS total_exited,
        SUM(
            CASE te.direction
                WHEN 'LONG' THEN (ex.exit_price - te.entry_price) * ex.quantity_exited
                ELSE (te.entry_price - ex.exit_price) * ex.quantity_exited
            END - ex.charges
        ) AS realized_profit
    FROM trade_exits ex
    JOIN trade_entries te ON te.id = ex.entry_id
    GROUP BY ex.entry_id, ex.journal_id
),
fund_metrics AS (
    SELECT
        f.journal_id,
        f.transaction_date,
        COALESCE(SUM(amount) FILTER (WHERE type = 'DEPOSIT') OVER w, 0) AS cumulative_deposits,
        COALESCE(SUM(amount) FILTER (WHERE type = 'WITHDRAW') OVER w, 0) AS cumulative_withdrawals,
        COALESCE(SUM(amount) FILTER (WHERE type = 'DEPOSIT') OVER w, 0) -
        COALESCE(SUM(amount) FILTER (WHERE type = 'WITHDRAW') OVER w, 0) AS capital_deployed
    FROM funds f
    WINDOW w AS (PARTITION BY journal_id ORDER BY transaction_date RANGE UNBOUNDED PRECEDING)
),
realized_profits AS (
    SELECT
        te.id,
        SUM(
            CASE te2.direction
                WHEN 'LONG' THEN (ex.exit_price - te2.entry_price) * ex.quantity_exited
                ELSE (te2.entry_price - ex.exit_price) * ex.quantity_exited
            END - ex.charges - te2.charges
        ) AS historical_profit
    FROM trade_entries te
    LEFT JOIN trade_entries te2 ON te2.journal_id = te.journal_id 
        AND te2.entry_date < te.entry_date
    LEFT JOIN trade_exits ex ON ex.entry_id = te2.id 
        AND ex.exit_date < te.entry_date
    GROUP BY te.id
)
SELECT
    te.*,
    i.symbol,
    i.last_price AS cmp,
    ea.exit_records,
    ea.realized_profit,
    fm.cumulative_deposits AS total_deposits,
    fm.cumulative_withdrawals AS total_withdrawals,
    (te.quantity - COALESCE(ea.total_exited, 0)) AS open_quantity,
    (te.quantity - COALESCE(ea.total_exited, 0)) * te.entry_price AS current_exposure,
    CASE te.direction
        WHEN 'LONG' THEN 1 ELSE -1
    END * (te.current_stop_loss - te.entry_price) * (te.quantity - COALESCE(ea.total_exited, 0)) AS open_risk,
    (te.quantity * te.entry_price) / NULLIF(fm.capital_deployed, 0) AS exposure_pct,
    (CASE te.direction
        WHEN 'LONG' THEN (te.stop_loss - te.entry_price)
        ELSE (te.entry_price - te.stop_loss)
    END * te.quantity) / NULLIF(fm.capital_deployed, 0) AS risk_pct,
    (ea.realized_profit - te.charges) AS net_profit,
    EXTRACT(DAY FROM NOW() - te.entry_date) AS days_open,
    CASE WHEN ea.total_exited > 0 THEN
        (SELECT AVG(exit_price) FROM trade_exits WHERE entry_id = te.id)
    END AS avg_exit_price,
    -- Capital Metrics
    fm.capital_deployed,
    COALESCE(fm.capital_deployed, 0) + COALESCE(rp.historical_profit, 0) AS starting_account_value,
    COALESCE((ea.realized_profit - te.charges) / NULLIF(COALESCE(fm.capital_deployed, 0), 0), 0) * 100 AS rocd,
    COALESCE(
        (ea.realized_profit - te.charges) / NULLIF(COALESCE(fm.capital_deployed, 0) + COALESCE(rp.historical_profit, 0), 0),
        0
    ) * 100 AS ros_v
FROM trade_entries te
JOIN instruments i ON te.instrument_id = i.id
LEFT JOIN exit_aggregates ea ON te.id = ea.entry_id AND te.journal_id = ea.journal_id
LEFT JOIN LATERAL (
    SELECT 
        capital_deployed,
        cumulative_deposits,
        cumulative_withdrawals
    FROM fund_metrics
    WHERE journal_id = te.journal_id
        AND transaction_date <= te.entry_date
    ORDER BY transaction_date DESC
    LIMIT 1
) fm ON true
LEFT JOIN realized_profits rp ON te.id = rp.id;

CREATE INDEX idx_unified_journal ON unified_trade_metrics(journal_id);
CREATE INDEX idx_unified_user ON unified_trade_metrics(user_id);
CREATE INDEX idx_unified_instrument ON unified_trade_metrics(instrument_id);




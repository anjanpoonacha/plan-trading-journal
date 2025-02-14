-- 1. Positions View (DataModelingFlow.md lines 53-70)
CREATE OR REPLACE VIEW open_positions_view AS
SELECT
    te.id,
    te.entry_date AS date,
    te.direction AS type,
    (te.quantity - COALESCE(SUM(te2.quantity_exited), 0)) AS open_quantity,
    (te.quantity - COALESCE(SUM(te2.quantity_exited), 0)) / te.quantity * 100 AS open_pct,
    te.entry_price,
    te.stop_loss AS sl,
    (te.entry_price - te.stop_loss) / te.entry_price * 100 AS sl_pct,
    te.current_stop_loss,
    (te.quantity * te.entry_price) AS exposure,
    (te.quantity * te.entry_price) / um.account_value * 100 AS exposure_pct,
    um.total_exposure,
    um.total_exposure_pct,
    CASE te.direction
        WHEN 'LONG' THEN (te.current_stop_loss - te.entry_price) * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0))
        ELSE (te.entry_price - te.current_stop_loss) * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0))
    END AS open_risk,
    CASE te.direction
        WHEN 'LONG' THEN (te.current_stop_loss - te.entry_price) * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0)) / um.account_value * 100
        ELSE (te.entry_price - te.current_stop_loss) * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0)) / um.account_value * 100
    END AS open_risk_pct,
    um.total_open_risk,
    um.total_open_risk_pct
FROM trade_entries te
LEFT JOIN trade_exits te2 ON te.id = te2.entry_id
JOIN user_metrics um ON te.user_id = um.user_id
GROUP BY te.id, um.account_value, um.total_exposure, um.total_exposure_pct, um.total_open_risk, um.total_open_risk_pct;

-- 2. Order History View (DataModelingFlow.md lines 74-100)
CREATE OR REPLACE VIEW order_history_view AS
WITH latest_exits AS (
    SELECT 
        entry_id,
        MAX(exit_date) AS latest_exit_date,
        AVG(exit_price) AS exit_price_avg
    FROM trade_exits
    GROUP BY entry_id
)
SELECT
    te.id,
    i.symbol,
    te.entry_date AS date,
    te.direction AS type,
    te.quantity,
    te.entry_price AS entry,
    te.stop_loss AS sl,
    (te.entry_price - te.stop_loss) / te.entry_price * 100 AS sl_pct,
    (te.quantity * te.entry_price) AS position_size,
    (te.quantity * te.entry_price) / um.account_value * 100 AS position_size_pct,
    te.risk AS rpt,
    te.risk / um.capital_deployed * 100 AS rpt_pct,
    COALESCE(SUM(te2.quantity_exited) / te.quantity * 100, 0) AS exit_pct,
    le.exit_price_avg AS exit_price,
    le.latest_exit_date,
    (le.exit_price_avg - te.entry_price) / te.entry_price * 100 AS gain_pct,
    um.capital_deployed,
    (le.exit_price_avg - te.entry_price) * te.quantity / um.capital_deployed * 100 AS rocd,
    um.account_value,
    (le.exit_price_avg - te.entry_price) * te.quantity / um.starting_account * 100 AS rosav,
    EXTRACT(DAY FROM NOW() - te.entry_date) AS days,
    ((le.exit_price_avg - te.entry_price) / te.entry_price) / NULLIF((te.entry_price - te.stop_loss) / te.entry_price, 0) AS rr,
    COALESCE(SUM(te2.charges), 0) AS charges,
    (le.exit_price_avg - te.entry_price) * te.quantity - COALESCE(SUM(te2.charges), 0) AS net_profit
FROM trade_entries te
JOIN instruments i ON te.instrument_id = i.id
LEFT JOIN trade_exits te2 ON te.id = te2.entry_id
LEFT JOIN latest_exits le ON te.id = le.entry_id
JOIN user_metrics um ON te.user_id = um.user_id
GROUP BY te.id, i.symbol, um.capital_deployed, um.account_value, um.starting_account, le.exit_price_avg, le.latest_exit_date;

-- 3. Order Detail View (DataModelingFlow.md lines 107-124)
CREATE OR REPLACE VIEW order_detail_view AS
SELECT
    te.id,
    i.symbol,
    te.direction,
    te.entry_date,
    AVG(te.entry_price) AS avg_entry_price,
    AVG(te2.exit_price) AS avg_exit_price,
    um.account_value,
    (te.quantity * te.entry_price) AS position_size,
    (te.quantity * te.entry_price) / um.account_value * 100 AS position_size_pct,
    te.stop_loss,
    (te.entry_price - te.stop_loss) / te.entry_price * 100 AS sl_pct,
    te.risk AS rpt,
    te.risk / um.account_value * 100 AS rpt_pct,
    jsonb_agg(jsonb_build_object(
        'type', 'EXIT',
        'date', te2.exit_date,
        'days', EXTRACT(DAY FROM te2.exit_date - te.entry_date),
        'price', te2.exit_price,
        'qty', te2.quantity_exited,
        'charges', te2.charges,
        'profit', (te2.exit_price - te.entry_price) * te2.quantity_exited,
        'r_multiple', CASE te.direction
            WHEN 'LONG' THEN (te2.exit_price - te.entry_price) / (te.entry_price - te.stop_loss)
            ELSE (te.entry_price - te2.exit_price) / (te.entry_price - te.stop_loss)
        END
    )) AS exit_records
FROM trade_entries te
JOIN instruments i ON te.instrument_id = i.id
LEFT JOIN trade_exits te2 ON te.id = te2.entry_id
JOIN user_metrics um ON te.user_id = um.user_id
GROUP BY te.id, i.symbol, um.account_value;

-- 4. Summary View (metricsExplained/4.Summary.md lines 7-82)
CREATE MATERIALIZED VIEW summary_view AS
WITH trade_data AS (
    SELECT
        date_trunc('month', te.entry_date) AS period,
        COUNT(DISTINCT te.id) FILTER (WHERE te2.total_exited = te.quantity) AS fully_closed,
        COUNT(DISTINCT te.id) FILTER (WHERE te2.total_exited > 0 AND te2.total_exited < te.quantity) AS partially_closed,
        AVG(te.risk) AS avg_rpt,
        SUM(CASE WHEN (te2.avg_exit_price - te.entry_price) > 0 THEN 1 ELSE 0 END) AS winning_trades,
        AVG((te2.avg_exit_price - te.entry_price) / te.entry_price * 100) FILTER (WHERE (te2.avg_exit_price - te.entry_price) < 0) AS avg_loss,
        AVG((te2.avg_exit_price - te.entry_price) / te.entry_price * 100) FILTER (WHERE (te2.avg_exit_price - te.entry_price) > 0) AS avg_gain,
        SUM((te2.avg_exit_price - te.entry_price) * te.quantity) AS total_profit,
        SUM(te2.total_charges) AS total_charges
    FROM trade_entries te
    LEFT JOIN (
        SELECT 
            entry_id,
            SUM(quantity_exited) AS total_exited,
            AVG(exit_price) AS avg_exit_price,
            SUM(charges) AS total_charges
        FROM trade_exits
        GROUP BY entry_id
    ) te2 ON te.id = te2.entry_id
    GROUP BY period
)
SELECT
    td.period,
    td.fully_closed,
    td.partially_closed,
    COALESCE(td.winning_trades / NULLIF(td.fully_closed, 0) * 100, 0) AS win_rate_pct,
    td.avg_rpt,
    td.avg_loss,
    td.avg_gain,
    COALESCE(td.avg_gain / NULLIF(ABS(td.avg_loss), 0), 0) AS arr,
    td.total_profit,
    td.total_charges,
    td.total_profit - td.total_charges AS net_profit,
    um.account_value,
    um.capital_deployed,
    (td.net_profit / um.capital_deployed) * 100 AS rocd,
    (td.net_profit / um.starting_account) * 100 AS rosav
FROM trade_data td
JOIN user_metrics um ON true;
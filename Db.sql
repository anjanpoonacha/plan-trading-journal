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
    (te.entry_price - te.current_stop_loss) / te.entry_price * 100 AS sl_pct,
    (te.quantity * te.entry_price) AS exposure,
    (te.quantity * te.entry_price) / jm.account_value * 100 AS exposure_pct,
    jm.total_exposure,
    jm.total_exposure_pct,
    CASE te.direction
        WHEN 'LONG' THEN (te.current_stop_loss - te.entry_price) * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0))
        ELSE (te.entry_price - te.current_stop_loss) * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0))
    END AS open_risk,
    CASE te.direction
        WHEN 'LONG' THEN (te.current_stop_loss - te.entry_price) * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0)) / jm.account_value * 100
        ELSE (te.entry_price - te.current_stop_loss) * (te.quantity - COALESCE(SUM(te2.quantity_exited), 0)) / jm.account_value * 100
    END AS open_risk_pct,
    jm.total_open_risk,
    jm.total_open_risk_pct
FROM trade_entries te
LEFT JOIN trade_exits te2 ON te.id = te2.entry_id AND te.journal_id = te2.journal_id
JOIN journal_metrics jm ON te.journal_id = jm.journal_id
GROUP BY te.id, jm.account_value, jm.total_exposure, jm.total_exposure_pct, jm.total_open_risk, jm.total_open_risk_pct;

-- Revised Order History View with Account Gain %
CREATE OR REPLACE VIEW order_history_view AS
WITH historical_account_value AS (
    SELECT
        te.id AS trade_id,
        te.journal_id,
        SUM(f.amount) FILTER (WHERE f.type = 'DEPOSIT' AND f.transaction_date <= te.entry_date) -
        SUM(f.amount) FILTER (WHERE f.type = 'WITHDRAW' AND f.transaction_date <= te.entry_date) 
            AS trade_date_capital,
        COALESCE(SUM(te2.net_profit) FILTER (WHERE te2.exit_date <= te.entry_date), 0) 
            AS prior_profits
    FROM trade_entries te
    JOIN funds f ON te.journal_id = f.journal_id
    LEFT JOIN (
        SELECT entry_id, journal_id, exit_date,
               SUM((exit_price - entry_price) * quantity_exited) AS net_profit
        FROM trade_exits
        GROUP BY entry_id, journal_id, exit_date
    ) te2 ON te.id = te2.entry_id AND te.journal_id = te2.journal_id
    GROUP BY te.id, te.journal_id
),
trade_exits_agg AS (
    SELECT 
        entry_id,
        SUM(quantity_exited) AS total_exited,
        MAX(exit_date) AS latest_exit_date,
        AVG(exit_price) AS avg_exit_price,
        SUM(charges) AS total_charges
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
    (te.entry_price - te.current_stop_loss) / te.entry_price * 100 AS sl_pct,
    (te.quantity * te.entry_price) AS position_size,
    (te.quantity * te.entry_price) / (hav.trade_date_capital + hav.prior_profits) * 100 AS position_size_pct,
    te.quantity * (te.entry_price - te.current_stop_loss) AS rpt,
    (te.quantity * (te.entry_price - te.current_stop_loss)) / (hav.trade_date_capital + hav.prior_profits) * 100 AS rpt_pct,
    COALESCE(tea.total_exited / te.quantity * 100, 0) AS exit_pct,
    tea.avg_exit_price,
    tea.latest_exit_date,
    (tea.avg_exit_price - te.entry_price) / te.entry_price * 100 AS gain_pct,
    hav.trade_date_capital AS capital_deployed,
    (tea.avg_exit_price - te.entry_price) * te.quantity / hav.trade_date_capital * 100 AS rocd,
    jm.starting_account,
    (tea.avg_exit_price - te.entry_price) * te.quantity / jm.starting_account * 100 AS rosav,
    ((tea.avg_exit_price - te.entry_price) * te.quantity - tea.total_charges) / (hav.trade_date_capital + hav.prior_profits) * 100 AS account_gain_pct,
    EXTRACT(DAY FROM NOW() - te.entry_date) AS days,
    CASE
        WHEN (te.entry_price - te.current_stop_loss) <> 0 
        THEN (tea.avg_exit_price - te.entry_price) / (te.entry_price - te.current_stop_loss)
        ELSE NULL
    END AS rr,
    tea.total_charges,
    (tea.avg_exit_price - te.entry_price) * te.quantity - tea.total_charges AS net_profit
FROM trade_entries te
JOIN instruments i ON te.instrument_id = i.id
LEFT JOIN (
    SELECT 
        entry_id,
        journal_id,
        SUM(quantity_exited) AS total_exited,
        MAX(exit_date) AS latest_exit_date,
        AVG(exit_price) AS avg_exit_price,
        SUM(charges) AS total_charges
    FROM trade_exits
    GROUP BY entry_id, journal_id
) tea ON te.id = tea.entry_id AND te.journal_id = tea.journal_id
JOIN historical_account_value hav ON te.id = hav.trade_id AND te.journal_id = hav.journal_id
JOIN journal_metrics jm ON te.journal_id = jm.journal_id
GROUP BY te.id, i.symbol, jm.capital_deployed, jm.account_value, jm.starting_account;

-- 3. Order Detail View (DataModelingFlow.md lines 107-124)
CREATE OR REPLACE VIEW order_detail_view AS
SELECT
    te.id,
    i.symbol,
    te.direction,
    te.entry_date,
    AVG(te.entry_price) AS avg_entry_price,
    AVG(te2.exit_price) AS avg_exit_price,
    jm.account_value,
    (te.quantity * te.entry_price) AS position_size,
    (te.quantity * te.entry_price) / jm.account_value * 100 AS position_size_pct,
    te.stop_loss,
    (te.entry_price - te.current_stop_loss) / te.entry_price * 100 AS sl_pct,
    te.risk AS rpt,
    te.risk / jm.account_value * 100 AS rpt_pct,
    jsonb_agg(jsonb_build_object(
        'type', 'EXIT',
        'date', te2.exit_date,
        'days', EXTRACT(DAY FROM te2.exit_date - te.entry_date),
        'price', te2.exit_price,
        'qty', te2.quantity_exited,
        'charges', te2.charges,
        'profit', (te2.exit_price - te.entry_price) * te2.quantity_exited,
        'r_multiple', CASE te.direction
            WHEN 'LONG' THEN (te2.exit_price - te.entry_price) / (te.entry_price - te.current_stop_loss)
            ELSE (te.entry_price - te2.exit_price) / (te.entry_price - te.current_stop_loss)
        END
    )) AS exit_records
FROM trade_entries te
JOIN instruments i ON te.instrument_id = i.id
LEFT JOIN trade_exits te2 ON te.id = te2.entry_id
JOIN journal_metrics jm ON te.journal_id = jm.journal_id
GROUP BY te.id, i.symbol, jm.account_value;

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
    jm.account_value,
    jm.capital_deployed,
    (td.net_profit / jm.capital_deployed) * 100 AS rocd,
    (td.net_profit / jm.starting_account) * 100 AS rosav,
	SUM(t.account_gain_pct) AS total_account_gain_pct,
    AVG(t.account_gain_pct) AS avg_account_gain_pct
FROM trade_data td
JOIN journal_metrics jm ON true;

-- Add generated column to trade_entries (Reference: AllDDL.sql lines 51-54)
ALTER TABLE trade_entries ADD COLUMN current_stop_loss NUMERIC(18, 8) 
    GENERATED ALWAYS AS (COALESCE(current_stop_loss_override, stop_loss)) STORED;
ALTER TABLE trade_entries ADD COLUMN current_stop_loss_override NUMERIC(18, 8);

-- Corrected RoSV Calculation (metricsExplained/3.TradeHistory.md lines 87-96)
WITH starting_account_adjusted AS (
    SELECT 
        jm.journal_id,
        jm.starting_account + COALESCE(SUM(f.amount) FILTER (WHERE f.type = 'DEPOSIT' 
            AND f.transaction_date >= DATE_TRUNC('year', CURRENT_DATE)), 0) AS starting_account_adj
    FROM journal_metrics jm
    LEFT JOIN funds f ON jm.journal_id = f.journal_id
    GROUP BY jm.journal_id, jm.starting_account
)
SELECT
    te.id,
    i.symbol,
    te.entry_date AS date,
    te.direction AS type,
    te.quantity,
    te.entry_price AS entry,
    te.stop_loss AS sl,
    (te.entry_price - te.current_stop_loss) / te.entry_price * 100 AS sl_pct,
    (te.quantity * te.entry_price) AS position_size,
    (te.quantity * te.entry_price) / (hav.trade_date_capital + hav.prior_profits) * 100 AS position_size_pct,
    te.quantity * (te.entry_price - te.current_stop_loss) AS rpt,
    (te.quantity * (te.entry_price - te.current_stop_loss)) / (hav.trade_date_capital + hav.prior_profits) * 100 AS rpt_pct,
    COALESCE(tea.total_exited / te.quantity * 100, 0) AS exit_pct,
    tea.avg_exit_price,
    tea.latest_exit_date,
    (tea.avg_exit_price - te.entry_price) / te.entry_price * 100 AS gain_pct,
    hav.trade_date_capital AS capital_deployed,
    (tea.avg_exit_price - te.entry_price) * te.quantity / hav.trade_date_capital * 100 AS rocd,
    jm.starting_account,
    (tea.avg_exit_price - te.entry_price) * te.quantity / sa.starting_account_adj * 100 AS rosav,
    ((tea.avg_exit_price - te.entry_price) * te.quantity - tea.total_charges) / (hav.trade_date_capital + hav.prior_profits) * 100 AS account_gain_pct,
    EXTRACT(DAY FROM NOW() - te.entry_date) AS days,
    CASE
        WHEN (te.entry_price - te.current_stop_loss) <> 0 
        THEN (tea.avg_exit_price - te.entry_price) / (te.entry_price - te.current_stop_loss)
        ELSE NULL
    END AS rr,
    tea.total_charges,
    (tea.avg_exit_price - te.entry_price) * te.quantity - tea.total_charges AS net_profit
FROM trade_entries te
JOIN instruments i ON te.instrument_id = i.id
LEFT JOIN (
    SELECT 
        entry_id,
        journal_id,
        SUM(quantity_exited) AS total_exited,
        MAX(exit_date) AS latest_exit_date,
        AVG(exit_price) AS avg_exit_price,
        SUM(charges) AS total_charges
    FROM trade_exits
    GROUP BY entry_id, journal_id
) tea ON te.id = tea.entry_id AND te.journal_id = tea.journal_id
JOIN historical_account_value hav ON te.id = hav.trade_id AND te.journal_id = hav.journal_id
JOIN journal_metrics jm ON te.journal_id = jm.journal_id
JOIN starting_account_adjusted sa ON te.journal_id = sa.journal_id
GROUP BY te.id, i.symbol, jm.capital_deployed, jm.account_value, jm.starting_account;
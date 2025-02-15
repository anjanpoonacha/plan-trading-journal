drop materialized view if exists daily_metrics cascade;

CREATE MATERIALIZED VIEW public.daily_metrics AS
WITH date_series AS (
    SELECT DISTINCT
        activity_date::date AS metric_date,
        journal_id
    FROM (
        SELECT entry_date AS activity_date, journal_id FROM trade_entries
        UNION ALL
        SELECT exit_date, journal_id FROM trade_exits
        UNION ALL
        SELECT transaction_date, journal_id FROM funds
    ) all_activities
),
exit_cumulatives AS (
    SELECT 
        ex.*,
        SUM(ex.quantity_exited) OVER (PARTITION BY ex.entry_id ORDER BY ex.exit_date) AS cumulative_exited
    FROM trade_exits ex
),
trade_metrics AS (
    SELECT
        ex.exit_date::date AS metric_date,
        ex.journal_id,
        SUM(
            CASE te.direction
                WHEN 'LONG' THEN (ex.exit_price - te.entry_price) * ex.quantity_exited
                ELSE (te.entry_price - ex.exit_price) * ex.quantity_exited
            END
        ) AS gross_profit,
        SUM(ex.charges) AS total_exit_charges,
        COUNT(DISTINCT te.id) FILTER (WHERE ex.exit_date IS NOT NULL) AS closed_orders,
        COUNT(DISTINCT te.id) FILTER (WHERE te.entry_date::date = ex.exit_date::date) AS new_orders,
        SUM(EXTRACT(DAY FROM ex.exit_date - te.entry_date)) AS total_holding_days,
        COUNT(DISTINCT te.id) FILTER (
            WHERE (ex.exit_price - te.entry_price) * 
            CASE te.direction WHEN 'LONG' THEN 1 ELSE -1 END > 0
        ) AS winning_trades,
        SUM(
            CASE WHEN (ex.exit_price - te.entry_price) * 
                CASE te.direction WHEN 'LONG' THEN 1 ELSE -1 END > 0 
                THEN EXTRACT(DAY FROM ex.exit_date - te.entry_date)
            END
        ) AS gain_days,
        SUM(
            CASE WHEN (ex.exit_price - te.entry_price) * 
                CASE te.direction WHEN 'LONG' THEN 1 ELSE -1 END <= 0 
                THEN EXTRACT(DAY FROM ex.exit_date - te.entry_date)
            END
        ) AS loss_days,
        COUNT(DISTINCT te.id) FILTER (
            WHERE ex.cumulative_exited < te.quantity
        ) AS partially_closed
    FROM exit_cumulatives ex
    JOIN trade_entries te ON ex.entry_id = te.id
    GROUP BY 1, 2
),
fund_flow AS (
    SELECT
        transaction_date::date AS metric_date,
        journal_id,
        SUM(amount) FILTER (WHERE type = 'DEPOSIT') AS deposits,
        SUM(amount) FILTER (WHERE type = 'WITHDRAW') AS withdrawals
    FROM funds
    GROUP BY 1, 2
),
entry_dates AS (
    SELECT
        entry_date::date AS metric_date,
        journal_id,
        COUNT(*) AS new_orders,
        SUM(charges) AS entry_charges
    FROM trade_entries
    GROUP BY 1, 2
),
year_start AS (
    SELECT DISTINCT ON (sub.journal_id, sub.fiscal_year)
        sub.journal_id,
        sub.fiscal_year,
        LAST_VALUE(
            sub.capital + sub.total_charges
        ) OVER (
            PARTITION BY sub.journal_id, sub.fiscal_year
            ORDER BY sub.metric_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS starting_account_value
    FROM (
        SELECT 
            ds.journal_id,
            DATE_TRUNC('year', ds.metric_date) AS fiscal_year,
            ds.metric_date,
            SUM(COALESCE(ff.deposits, 0) - COALESCE(ff.withdrawals, 0)) OVER w AS capital,
            SUM(COALESCE(tm.total_exit_charges, 0)) OVER w AS total_charges
        FROM date_series ds
        LEFT JOIN fund_flow ff USING (metric_date, journal_id)
        LEFT JOIN trade_metrics tm USING (metric_date, journal_id)
        WINDOW w AS (PARTITION BY ds.journal_id ORDER BY ds.metric_date)
    ) sub
    WHERE sub.metric_date < DATE_TRUNC('year', sub.metric_date) + INTERVAL '1 year'
    ORDER BY sub.journal_id, sub.fiscal_year, sub.metric_date DESC
),
capital_calcs AS (
    SELECT
        ds.metric_date,
        ds.journal_id,
        SUM(COALESCE(ff.deposits, 0) - COALESCE(ff.withdrawals, 0)) OVER (
            PARTITION BY ds.journal_id 
            ORDER BY ds.metric_date
        ) AS capital_deployed
    FROM date_series ds
    LEFT JOIN fund_flow ff 
        ON ds.metric_date = ff.metric_date 
        AND ds.journal_id = ff.journal_id
)
SELECT
    ds.metric_date,
    ds.journal_id,
    COALESCE(tm.total_exit_charges, 0) + COALESCE(ed.entry_charges, 0) AS charges,
    COALESCE(tm.gross_profit, 0) - (COALESCE(tm.total_exit_charges, 0) + COALESCE(ed.entry_charges, 0)) AS net_profit,
    COALESCE(ed.new_orders, 0) AS new_orders_length,
    COALESCE(tm.closed_orders, 0) AS closed_orders_length,
    COALESCE(tm.partially_closed, 0) AS partially_closed_orders,
    cc.capital_deployed,
    CASE 
        WHEN tm.closed_orders > 0 
        THEN (tm.winning_trades::FLOAT / tm.closed_orders) * 100 
        ELSE 0 
    END AS win_rate,
    CASE 
        WHEN tm.closed_orders > 0 
        THEN tm.total_holding_days / tm.closed_orders::NUMERIC 
        ELSE 0 
    END AS avg_holding_days,
    CASE 
        WHEN tm.closed_orders > 0 
        THEN SUM(tm.total_exit_charges) OVER () / tm.closed_orders::NUMERIC 
        ELSE 0 
    END AS avg_rpt,
    CASE 
        WHEN tm.gain_days > 0 
        THEN tm.gain_days / tm.winning_trades::NUMERIC 
        ELSE 0 
    END AS avg_gain_days,
    CASE 
        WHEN tm.loss_days > 0 
        THEN tm.loss_days / (tm.closed_orders - tm.winning_trades)::NUMERIC 
        ELSE 0 
    END AS avg_loss_days
FROM date_series ds
LEFT JOIN trade_metrics tm 
    ON ds.metric_date = tm.metric_date 
    AND ds.journal_id = tm.journal_id
LEFT JOIN fund_flow ff 
    ON ds.metric_date = ff.metric_date 
    AND ds.journal_id = ff.journal_id
LEFT JOIN entry_dates ed 
    ON ds.metric_date = ed.metric_date 
    AND ds.journal_id = ed.journal_id
LEFT JOIN capital_calcs cc 
    ON ds.metric_date = cc.metric_date 
    AND ds.journal_id = cc.journal_id
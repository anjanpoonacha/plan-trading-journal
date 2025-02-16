drop materialized view if exists daily_metrics cascade;

CREATE MATERIALIZED VIEW public.daily_metrics AS
WITH date_series AS (
    SELECT 
        metric_date,
        journal_id
    FROM (
        SELECT 
            activity_date::date AS metric_date,
            journal_id,
            ROW_NUMBER() OVER (PARTITION BY activity_date::date, journal_id ORDER BY activity_date) AS rn
        FROM (
            SELECT entry_date AS activity_date, journal_id FROM trade_entries
            UNION ALL
            SELECT exit_date, journal_id FROM trade_exits
            UNION ALL
            SELECT transaction_date, journal_id FROM funds
        ) all_activities
    ) sub
    WHERE rn = 1
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
        ) AS partially_closed,
        COUNT(DISTINCT te.id) FILTER (
            WHERE ex.cumulative_exited = te.quantity
        ) AS fully_closed,
        SUM(CASE WHEN (ex.exit_price - te.entry_price) * 
            CASE te.direction WHEN 'LONG' THEN 1 ELSE -1 END > 0 
            THEN (ex.exit_price - te.entry_price) * ex.quantity_exited ELSE 0 END
        ) AS total_gain,
        SUM(CASE WHEN (ex.exit_price - te.entry_price) * 
            CASE te.direction WHEN 'LONG' THEN 1 ELSE -1 END <= 0 
            THEN (te.entry_price - ex.exit_price) * ex.quantity_exited ELSE 0 END
        ) AS total_loss,
        SUM(
            (te.entry_price - te.stop_loss) * 
            ex.quantity_exited *
            CASE te.direction WHEN 'SHORT' THEN -1 ELSE 1 END
        ) AS total_risk
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
        LAST_VALUE(sub.cumulative_capital) OVER (
            PARTITION BY sub.journal_id, sub.fiscal_year
            ORDER BY sub.metric_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS starting_capital,
        LAST_VALUE(sub.cumulative_profit) OVER (
            PARTITION BY sub.journal_id, sub.fiscal_year
            ORDER BY sub.metric_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS previous_year_profit
    FROM (
        SELECT 
            ds.journal_id,
            DATE_TRUNC('year', ds.metric_date) + INTERVAL '1 year' AS fiscal_year,
            ds.metric_date,
            SUM(COALESCE(ff.deposits, 0) - COALESCE(ff.withdrawals, 0)) OVER (
                PARTITION BY ds.journal_id 
                ORDER BY ds.metric_date
            ) AS cumulative_capital,
            SUM(COALESCE(tm.gross_profit, 0) - (COALESCE(tm.total_exit_charges, 0) + COALESCE(ed.entry_charges, 0))) OVER (
                PARTITION BY ds.journal_id
                ORDER BY ds.metric_date
            ) AS cumulative_profit
        FROM date_series ds
        LEFT JOIN fund_flow ff USING (metric_date, journal_id)
        LEFT JOIN trade_metrics tm USING (metric_date, journal_id)
        LEFT JOIN entry_dates ed USING (metric_date, journal_id)
    ) sub
    WHERE sub.metric_date < DATE_TRUNC('year', sub.fiscal_year)
    ORDER BY sub.journal_id, sub.fiscal_year, sub.metric_date DESC
),
capital_calcs AS (
    SELECT
        ds.metric_date,
        ds.journal_id,
        SUM(COALESCE(ff.deposits, 0) - COALESCE(ff.withdrawals, 0)) OVER (
            PARTITION BY ds.journal_id 
            ORDER BY ds.metric_date
        ) AS cumulative_capital
    FROM date_series ds
    LEFT JOIN fund_flow ff 
        ON ds.metric_date = ff.metric_date 
        AND ds.journal_id = ff.journal_id
),
cumulative_profit_calc AS (
    SELECT
        ds.metric_date,
        ds.journal_id,
        SUM(COALESCE(tm.gross_profit, 0) - (COALESCE(tm.total_exit_charges, 0) + COALESCE(ed.entry_charges, 0))) OVER (
            PARTITION BY ds.journal_id
            ORDER BY ds.metric_date
        ) AS cumulative_net_profit
    FROM date_series ds
    LEFT JOIN trade_metrics tm USING (metric_date, journal_id)
    LEFT JOIN entry_dates ed USING (metric_date, journal_id)
)
WITH trade_capital AS (
    SELECT
        te.id AS trade_id,
        SUM(COALESCE(ff.deposits, 0) - COALESCE(ff.withdrawals, 0)) 
            OVER (PARTITION BY te.journal_id ORDER BY te.entry_date) 
        AS capital_deployed_at_open
    FROM trade_entries te
    LEFT JOIN fund_flow ff 
        ON ff.journal_id = te.journal_id 
        AND ff.metric_date <= te.entry_date
)
SELECT
    ds.metric_date,
    ds.journal_id,
    COALESCE(tm.total_exit_charges, 0) + COALESCE(ed.entry_charges, 0) AS charges,
    COALESCE(tm.gross_profit, 0) - (COALESCE(tm.total_exit_charges, 0) + COALESCE(ed.entry_charges, 0)) AS net_profit,
    SUM(COALESCE(tm.gross_profit, 0) - (COALESCE(tm.total_exit_charges, 0) + COALESCE(ed.entry_charges, 0))) OVER (
        PARTITION BY ds.journal_id
        ORDER BY ds.metric_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_net_profit,
    COALESCE(ed.new_orders, 0) AS new_orders_length,
    COALESCE(tm.closed_orders, 0) AS closed_orders_length,
    COALESCE(tm.partially_closed, 0) AS partially_closed_orders,
    cc.cumulative_capital AS capital_deployed,
    CASE
        WHEN DATE_TRUNC('year', ds.metric_date) = ds.metric_date 
        THEN ys.starting_capital + ys.previous_year_profit
        ELSE COALESCE(ys.starting_capital + ys.previous_year_profit, cc.cumulative_capital)
    END AS starting_account_value,
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
    COALESCE(
        tm.total_risk / NULLIF(tm.fully_closed_trades, 0), 
        0
    ) AS avg_rpt,
    CASE 
        WHEN tm.gain_days > 0 
        THEN tm.gain_days / tm.winning_trades::NUMERIC 
        ELSE 0 
    END AS avg_gain_days,
    CASE 
        WHEN tm.loss_days > 0 
        THEN tm.loss_days / (tm.closed_orders - tm.winning_trades)::NUMERIC 
        ELSE 0 
    END AS avg_loss_days,
    COALESCE(ot.open_trades, 0) AS open_trades,
    COALESCE(tm.fully_closed, 0) AS fully_closed,
    COALESCE(tm.total_loss / NULLIF(tm.closed_orders - tm.winning_trades, 0), 0) AS avg_loss,
    COALESCE(tm.total_gain / NULLIF(tm.winning_trades, 0), 0) AS avg_gain,
    CASE 
        WHEN COALESCE(tm.total_loss, 0) > 0 
        THEN COALESCE(tm.total_gain / NULLIF(tm.total_loss, 0), 0)
        ELSE 0 
    END AS arr,
    COALESCE((tm.gross_profit - tm.total_exit_charges - ed.entry_charges) / NULLIF(cc.cumulative_capital, 0) * 100, 0) AS rocd,
    COALESCE((tm.gross_profit - tm.total_exit_charges - ed.entry_charges) / NULLIF(ys.starting_capital + ys.previous_year_profit + 
        (SELECT SUM(COALESCE(ff_sub.deposits, 0) - COALESCE(ff_sub.withdrawals, 0)) 
         FROM fund_flow ff_sub
         WHERE ff_sub.journal_id = ds.journal_id
         AND DATE_TRUNC('year', ff_sub.metric_date) = DATE_TRUNC('year', ds.metric_date)
        ), 0
    ) * 100, 0) AS rosav,
    COALESCE(
        (tm.total_risk / NULLIF(tm.fully_closed_trades, 0)) / 
        NULLIF(trade_capital.capital_deployed_at_open, 0) * 100,
        0
    ) AS avg_rpt_percent
FROM date_series ds
LEFT JOIN LATERAL (
    SELECT COUNT(*) AS open_trades
    FROM trade_entries te 
    WHERE te.journal_id = ds.journal_id 
    AND te.entry_date <= ds.metric_date
    AND NOT EXISTS (
        SELECT 1 FROM trade_exits ex 
        WHERE ex.entry_id = te.id 
        AND ex.exit_date <= ds.metric_date 
        AND ex.quantity_exited = te.quantity
    )
) ot ON true
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
LEFT JOIN year_start ys 
    ON DATE_TRUNC('year', ds.metric_date) = ys.fiscal_year 
    AND ds.journal_id = ys.journal_id
LEFT JOIN cumulative_profit_calc cnp 
    ON ds.metric_date = cnp.metric_date 
    AND ds.journal_id = cnp.journal_id
LEFT JOIN trade_capital 
    ON tm.metric_date = trade_capital.trade_id 
    AND tm.journal_id = trade_capital.journal_id
GROUP BY 
    ds.metric_date,
    ds.journal_id,
    charges,
    net_profit,
    cumulative_net_profit,
    new_orders_length,
    closed_orders_length,
    partially_closed_orders,
    capital_deployed,
    starting_account_value,
    win_rate,
    avg_holding_days,
    avg_rpt,
    avg_gain_days,
    avg_loss_days,
    open_trades,
    fully_closed,
    avg_loss,
    avg_gain,
    arr,
    rocd,
    rosav,
    avg_rpt_percent
drop materialized view if exists dashboard_metrics cascade;
drop materialized view if exists position_metrics_enhanced cascade;
drop materialized view if exists trade_history_metrics cascade;
drop materialized view if exists trade_detail_metrics cascade;
drop materialized view if exists summary_metrics cascade;
drop materialized view if exists daily_metrics cascade;

CREATE MATERIALIZED VIEW dashboard_metrics AS
SELECT
  jm.journal_id,
  jm.user_id,
  jm.capital_deployed,
  (SELECT COALESCE(SUM(amount) FILTER (WHERE type = 'DEPOSIT'), 0) -
          COALESCE(SUM(amount) FILTER (WHERE type = 'WITHDRAW'), 0)
   FROM funds 
   WHERE journal_id = jm.journal_id
     AND transaction_date < DATE_TRUNC('year', CURRENT_DATE)) 
   +
  (SELECT COALESCE(SUM(
      CASE te.direction
        WHEN 'LONG' THEN (ex.exit_price - te.entry_price) * ex.quantity_exited
        ELSE (te.entry_price - ex.exit_price) * ex.quantity_exited
      END - ex.charges - te.charges), 0)
   FROM trade_entries te
   JOIN trade_exits ex ON te.id = ex.entry_id
   WHERE te.journal_id = jm.journal_id
     AND ex.exit_date < DATE_TRUNC('year', CURRENT_DATE)) AS starting_account_value,
  jm.account_value,
  jm.total_exposure,
  jm.total_exposure / NULLIF(jm.account_value, 0) AS total_exposure_pct,
  jm.total_open_risk,
  jm.total_open_risk / NULLIF(jm.account_value, 0) AS total_open_risk_pct
FROM journal_metrics jm;

CREATE MATERIALIZED VIEW position_metrics_enhanced AS
SELECT
  pm.*,
  i.symbol,
  i.last_price AS cmp,
  te.quantity AS original_quantity,
  (pm.open_quantity / te.quantity) AS open_pct,
  CASE WHEN te.direction = 'LONG' 
    THEN (te.stop_loss - pm.entry_price)/pm.entry_price
    ELSE (pm.entry_price - te.stop_loss)/pm.entry_price 
  END  AS sl_pct,
  (pm.current_stop_loss - pm.entry_price) / pm.entry_price AS current_sl_pct,
  COALESCE((
    SELECT SUM(
      CASE te.direction
        WHEN 'LONG' THEN (te2.exit_price - te.entry_price) * te2.quantity_exited
        ELSE (te.entry_price - te2.exit_price) * te2.quantity_exited
      END - te2.charges
    )
    FROM trade_exits te2 
    WHERE te2.entry_id = te.id
  ), 0) - te.charges AS net_profit
FROM position_metrics pm
JOIN trade_entries te ON pm.id = te.id
JOIN instruments i ON pm.instrument_id = i.id;

CREATE MATERIALIZED VIEW trade_history_metrics AS
WITH exit_aggregates AS (
  SELECT 
    entry_id,
    SUM(quantity_exited) AS total_exited,
    MAX(exit_date) AS latest_exit_date,
    JSONB_AGG(
      jsonb_build_object(
        'exit_date', exit_date,
        'exit_price', exit_price,
        'quantity_exited', quantity_exited,
        'charges', trade_exits.charges,
        'profit', 
          CASE te.direction
            WHEN 'LONG' THEN (exit_price - te.entry_price) * quantity_exited
            ELSE (te.entry_price - exit_price) * quantity_exited
          END - trade_exits.charges,
        'r_multiple',
          CASE WHEN te.risk != 0 THEN
            (CASE te.direction
              WHEN 'LONG' THEN (exit_price - te.entry_price) * quantity_exited
              ELSE (te.entry_price - exit_price) * quantity_exited
            END - trade_exits.charges) / te.risk
          END,
        'r_multiple_per_unit',
          CASE WHEN (te.entry_price - te.stop_loss) != 0 THEN
            (CASE te.direction
              WHEN 'LONG' THEN (exit_price - te.entry_price)
              ELSE (te.entry_price - exit_price)
            END * quantity_exited - trade_exits.charges) 
            / ((te.entry_price - te.stop_loss) * quantity_exited)
          END,
        'gain_pct',
          CASE te.direction
            WHEN 'LONG' THEN (exit_price - te.entry_price)/te.entry_price
            ELSE (te.entry_price - exit_price)/te.entry_price
          END * 100
      ) ORDER BY exit_date
    ) AS exit_records,
    SUM(exit_price * quantity_exited) AS total_exit_price,
    SUM(
      CASE WHEN te.direction = 'LONG' 
        THEN quantity_exited * (exit_price - te.entry_price)
        ELSE quantity_exited * (te.entry_price - exit_price)
      END - trade_exits.charges
    ) AS position_net_profit,
    SUM(trade_exits.charges) AS total_exit_charges
  FROM trade_exits
  JOIN trade_entries te ON te.id = trade_exits.entry_id
  GROUP BY entry_id
),
trade_account_values AS (
  SELECT
    te.id,
    te.entry_date,
    te.journal_id,
    (SELECT COALESCE(SUM(amount) FILTER (WHERE type = 'DEPOSIT'), 0) 
          - COALESCE(SUM(amount) FILTER (WHERE type = 'WITHDRAW'), 0)
     FROM funds f
     WHERE f.journal_id = te.journal_id
       AND f.transaction_date <= te.entry_date) AS capital_deployed,
    
    (SELECT COALESCE(SUM(
        CASE te2.direction
          WHEN 'LONG' THEN (ex.exit_price - te2.entry_price) * ex.quantity_exited
          ELSE (te2.entry_price - ex.exit_price) * ex.quantity_exited
        END - ex.charges
      ), 0)
     FROM trade_entries te2
     LEFT JOIN trade_exits ex ON ex.entry_id = te2.id
       AND ex.exit_date <= te.entry_date
     WHERE te2.journal_id = te.journal_id) AS realized_profits
  FROM trade_entries te
)
SELECT
  te.id,
  te.journal_id,
  te.entry_date,
  i.symbol,
  te.direction AS type,
  te.quantity,
  te.entry_price,
  te.stop_loss,
  CASE WHEN te.direction = 'LONG' 
    THEN (te.stop_loss - te.entry_price)/te.entry_price
    ELSE (te.entry_price - te.stop_loss)/te.entry_price 
  END * 100 AS sl_pct,
  te.exposure AS position_size,
  (te.exposure / NULLIF(tav.capital_deployed + tav.realized_profits, 0)) * 100 AS position_size_pct,
  
  te.risk AS rpt,
  (te.risk / NULLIF(tav.capital_deployed + tav.realized_profits, 0)) * 100 AS rpt_pct,
  
  ea.total_exited AS exited_quantity,
  (ea.total_exited / te.quantity) * 100 AS exit_pct,
  ea.latest_exit_date,
  (ea.position_net_profit - te.charges) AS net_profit,
  (ea.position_net_profit - te.charges) / NULLIF(tav.capital_deployed, 0) * 100 AS rocd,
  (tav.capital_deployed + tav.realized_profits) AS starting_account,
  (ea.position_net_profit - te.charges) / NULLIF(tav.capital_deployed + tav.realized_profits, 0) * 100 AS ros_v,
  (tav.capital_deployed + tav.realized_profits) AS account_value,
  EXTRACT(DAY FROM COALESCE(ea.latest_exit_date, CURRENT_DATE) - te.entry_date) AS days,
  CASE WHEN te.risk != 0 
       THEN (ea.position_net_profit - te.charges) / te.risk 
  END AS rr,
  te.charges + COALESCE(ea.total_exit_charges, 0) AS charges,
  CASE WHEN ea.total_exited > 0 
       THEN ea.total_exit_price / ea.total_exited 
  END AS exit_price,
  ea.exit_records,
  (ea.total_exit_price - te.entry_price * ea.total_exited) / te.entry_price * 100 AS gain_pct
FROM trade_entries te
JOIN instruments i ON te.instrument_id = i.id
JOIN trade_account_values tav ON te.id = tav.id
LEFT JOIN exit_aggregates ea ON te.id = ea.entry_id;

CREATE MATERIALIZED VIEW daily_metrics AS
WITH date_series AS (
  SELECT DISTINCT activity_date::date AS metric_date
  FROM (
    SELECT entry_date AS activity_date FROM trade_entries
    UNION ALL
    SELECT exit_date FROM trade_exits
    UNION ALL
    SELECT transaction_date FROM funds
  ) all_activities
),
trade_metrics AS (
  SELECT
    exit_date::date AS metric_date,
    SUM(
      CASE te.direction
        WHEN 'LONG' THEN (exit_price - te.entry_price) * quantity_exited
        ELSE (te.entry_price - exit_price) * quantity_exited
      END - ex.charges - te.charges
    ) AS gross_profit,
    SUM(ex.charges + te.charges) AS total_charges,
    COUNT(DISTINCT te.id) FILTER (WHERE exit_date IS NOT NULL) AS closed_orders,
    COUNT(DISTINCT te.id) FILTER (WHERE te.entry_date::date = exit_date::date) AS new_orders,
    SUM(EXTRACT(DAY FROM ex.exit_date - te.entry_date)) AS total_holding_days,
    COUNT(DISTINCT te.id) FILTER (WHERE (exit_price - te.entry_price) * 
      CASE te.direction WHEN 'LONG' THEN 1 ELSE -1 END > 0) AS winning_trades,
    SUM(CASE WHEN (exit_price - te.entry_price) * 
      CASE te.direction WHEN 'LONG' THEN 1 ELSE -1 END > 0 THEN 
      EXTRACT(DAY FROM ex.exit_date - te.entry_date) END) AS gain_days,
    SUM(CASE WHEN (exit_price - te.entry_price) * 
      CASE te.direction WHEN 'LONG' THEN 1 ELSE -1 END <= 0 THEN 
      EXTRACT(DAY FROM ex.exit_date - te.entry_date) END) AS loss_days,
    COUNT(DISTINCT te.id) FILTER (WHERE ex.quantity_exited < te.quantity) AS partially_closed
  FROM trade_exits ex
  JOIN trade_entries te ON ex.entry_id = te.id
  GROUP BY 1
),
fund_flow AS (
  SELECT
    transaction_date::date AS metric_date,
    SUM(amount) FILTER (WHERE type = 'DEPOSIT') AS deposits,
    SUM(amount) FILTER (WHERE type = 'WITHDRAW') AS withdrawals
  FROM funds
  GROUP BY 1
),
entry_dates AS (
  SELECT 
    entry_date::date AS metric_date,
    COUNT(*) AS new_orders
  FROM trade_entries
  GROUP BY 1
)
SELECT
  ds.metric_date,
  COALESCE(tm.gross_profit, 0) AS profit,
  COALESCE(tm.total_charges, 0) AS charges,
  COALESCE(tm.gross_profit, 0) - COALESCE(tm.total_charges, 0) AS net_profit,
  COALESCE(ed.new_orders, 0) AS new_orders_length,
  COALESCE(tm.closed_orders, 0) AS closed_orders_length,
  COALESCE(tm.partially_closed, 0) AS partially_closed_orders,
  COALESCE(ff.deposits, 0) AS deposits,
  COALESCE(ff.withdrawals, 0) AS withdrawals,
  SUM(COALESCE(ff.deposits, 0) - COALESCE(ff.withdrawals, 0)) OVER (ORDER BY ds.metric_date) AS capital,
  SUM(COALESCE(ff.deposits, 0) - COALESCE(ff.withdrawals, 0)) OVER (ORDER BY ds.metric_date) +
  SUM(COALESCE(tm.gross_profit - tm.total_charges, 0)) OVER (ORDER BY ds.metric_date) AS account_value,
  CASE WHEN tm.closed_orders > 0 
    THEN (tm.winning_trades::float / tm.closed_orders) * 100 
    ELSE 0 END AS win_rate,
  CASE WHEN tm.closed_orders > 0 
    THEN tm.total_holding_days / tm.closed_orders 
    ELSE 0 END AS avg_holding_days,
  CASE WHEN tm.closed_orders > 0 
    THEN (SUM(tm.gross_profit) OVER () / tm.closed_orders) 
    ELSE 0 END AS avg_rpt,
  CASE WHEN tm.gain_days > 0 
    THEN tm.gain_days / tm.winning_trades 
    ELSE 0 END AS avg_gain_days,
  CASE WHEN tm.loss_days > 0 
    THEN tm.loss_days / (tm.closed_orders - tm.winning_trades) 
    ELSE 0 END AS avg_loss_days
FROM date_series ds
LEFT JOIN trade_metrics tm ON ds.metric_date = tm.metric_date
LEFT JOIN fund_flow ff ON ds.metric_date = ff.metric_date
LEFT JOIN entry_dates ed ON ds.metric_date = ed.metric_date;

CREATE MATERIALIZED VIEW summary_metrics AS
SELECT
  date_trunc('month', metric_date)::date AS period_start,
  'month' AS period_type,
  SUM(profit) AS gross_profit,
  SUM(charges) AS total_charges,
  SUM(net_profit) AS net_profit,
  SUM(deposits) - SUM(withdrawals) AS net_fund_flow,
  MAX(account_value) AS ending_account_value,
  MIN(account_value - net_profit) AS starting_account_value,
  (SUM(net_profit) / NULLIF(MIN(account_value - net_profit), 0)) * 100 AS roi_pct
FROM daily_metrics
GROUP BY 1

UNION ALL

SELECT
  date_trunc('year', metric_date)::date AS period_start,
  'year' AS period_type,
  SUM(profit) AS gross_profit,
  SUM(charges) AS total_charges,
  SUM(net_profit) AS net_profit,
  SUM(deposits) - SUM(withdrawals) AS net_fund_flow,
  MAX(account_value) AS ending_account_value,
  MIN(account_value - net_profit) AS starting_account_value,
  (SUM(net_profit) / NULLIF(MIN(account_value - net_profit), 0)) * 100 AS roi_pct
FROM daily_metrics
GROUP BY 1;

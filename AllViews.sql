CREATE MATERIALIZED VIEW dashboard_metrics AS
SELECT
  jm.journal_id,
  jm.user_id,
  jm.capital_deployed,
  (SELECT COALESCE(SUM(amount) FILTER (WHERE type = 'DEPOSIT'), 0) -
          COALESCE(SUM(amount) FILTER (WHERE type = 'WITHDRAW'), 0)
   FROM funds 
   WHERE journal_id = jm.journal_id
     AND transaction_date < DATE_TRUNC('year', CURRENT_DATE)) AS starting_account_value,
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
  (pm.open_quantity / te.quantity) * 100 AS open_pct,
  (te.stop_loss - pm.entry_price) / pm.entry_price * 100 AS sl_pct,
  (pm.current_stop_loss - pm.entry_price) / pm.entry_price * 100 AS current_sl_pct
FROM position_metrics pm
JOIN trade_entries te ON pm.id = te.id
JOIN instruments i ON pm.instrument_id = i.id;

CREATE MATERIALIZED VIEW trade_history_metrics AS
SELECT
  te.id,
  te.journal_id,
  te.entry_date,
  i.symbol,
  te.direction AS type,
  te.quantity,
  te.entry_price,
  te.stop_loss,
  (te.entry_price - te.stop_loss) / te.entry_price * 100 AS sl_pct,
  te.exposure AS position_size,
  te.exposure / NULLIF((
    SELECT account_value 
    FROM journal_metrics 
    WHERE journal_id = te.journal_id
      AND created_at <= te.entry_date
    ORDER BY created_at DESC
    LIMIT 1
  ), 0) * 100 AS position_size_pct,
  te.risk AS rpt,
  te.risk / NULLIF((
    SELECT account_value 
    FROM journal_metrics 
    WHERE journal_id = te.journal_id
      AND created_at <= te.entry_date
    ORDER BY created_at DESC
    LIMIT 1
  ), 0) * 100 AS rpt_pct,
  COALESCE(SUM(te2.quantity_exited) OVER (PARTITION BY te.id), 0) / te.quantity * 100 AS exit_pct,
  (SELECT MAX(exit_date) FROM trade_exits WHERE entry_id = te.id) AS latest_exit_date
FROM trade_entries te
JOIN instruments i ON te.instrument_id = i.id
LEFT JOIN trade_exits te2 ON te.id = te2.entry_id;

CREATE MATERIALIZED VIEW trade_detail_metrics AS
SELECT
  thm.*,
  COALESCE(te2.exit_price, thm.entry_price) AS exit_price,
  COALESCE(te2.charges, 0) AS charges,
  (COALESCE(te2.exit_price, thm.entry_price) - thm.entry_price) / thm.entry_price * 100 AS gain_pct,
  (COALESCE(te2.exit_price, thm.entry_price) - thm.entry_price) * thm.quantity AS net_profit
FROM trade_history_metrics thm
LEFT JOIN trade_exits te2 ON thm.id = te2.entry_id;

CREATE MATERIALIZED VIEW summary_metrics AS
SELECT
  DATE_TRUNC('month', te.entry_date) AS period,
  COUNT(DISTINCT te.id) FILTER (WHERE te.entry_date >= DATE_TRUNC('month', CURRENT_DATE)) AS new_trades,
  COUNT(*) FILTER (WHERE te2.quantity_exited = te.quantity) AS fully_closed,
  COUNT(*) FILTER (WHERE te2.quantity_exited < te.quantity) AS partially_closed,
  AVG(tdm.gain_pct) FILTER (WHERE te2.quantity_exited = te.quantity) AS avg_gain,
  AVG(tdm.gain_pct) FILTER (WHERE te2.quantity_exited = te.quantity AND tdm.gain_pct < 0) AS avg_loss,
  SUM(tdm.net_profit) AS profit,
  SUM(tdm.charges) AS charges,
  SUM(tdm.net_profit - tdm.charges) AS net_profit
FROM trade_entries te
JOIN trade_detail_metrics tdm ON te.id = tdm.id
LEFT JOIN trade_exits te2 ON te.id = te2.entry_id
GROUP BY period;

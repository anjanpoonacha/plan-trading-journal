drop materialized view if exists dashboard_metrics cascade;
drop materialized view if exists position_metrics_enhanced cascade;
drop materialized view if exists trade_history_metrics cascade;
drop materialized view if exists trade_detail_metrics cascade;
drop materialized view if exists summary_metrics cascade;

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
    ARRAY_AGG(
      jsonb_build_object(
        'exit_date', exit_date,
        'exit_price', exit_price,
        'quantity_exited', quantity_exited,
        'charges', trade_exits.charges
      ) ORDER BY exit_date
    ) AS exit_records,
    SUM(
      CASE WHEN te.direction = 'LONG' 
        THEN quantity_exited * (exit_price - te.entry_price)
        ELSE quantity_exited * (te.entry_price - exit_price)
      END - trade_exits.charges
    ) AS position_net_profit
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
  ea.position_net_profit AS net_profit,
  ea.exit_records
FROM trade_entries te
JOIN instruments i ON te.instrument_id = i.id
JOIN trade_account_values tav ON te.id = tav.id
LEFT JOIN exit_aggregates ea ON te.id = ea.entry_id;

CREATE MATERIALIZED VIEW trade_detail_metrics AS
SELECT
  thm.*,
  COALESCE(te2.exit_price, thm.entry_price) AS exit_price,
  COALESCE(te2.charges, 0) AS charges,
  (COALESCE(te2.exit_price, thm.entry_price) - thm.entry_price) / thm.entry_price * 100 AS gain_pct,
  (COALESCE(te2.exit_price, thm.entry_price) - thm.entry_price) * thm.quantity AS gross_profit,
  (COALESCE(te2.exit_price, thm.entry_price) - thm.entry_price) / 
  NULLIF(ABS(thm.entry_price - thm.stop_loss), 0) AS r_multiple
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
  SUM(tdm.gross_profit) AS profit,
  SUM(tdm.charges) AS charges,
  SUM(tdm.gross_profit - tdm.charges) AS net_profit
FROM trade_entries te
JOIN trade_detail_metrics tdm ON te.id = tdm.id
LEFT JOIN trade_exits te2 ON te.id = te2.entry_id
GROUP BY period;

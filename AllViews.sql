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
    JSONB_AGG(
      jsonb_build_object(
        'exit_date', exit_date,
        'exit_price', exit_price,
        'quantity_exited', quantity_exited,
        'charges', trade_exits.charges
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

CREATE MATERIALIZED VIEW trade_detail_metrics AS
SELECT 
  thm.*,
  (exit_record->>'exit_date')::timestamptz AS exit_date,
  (exit_record->>'exit_price')::numeric(18,8) AS specific_exit_price,
  (exit_record->>'quantity_exited')::numeric(18,8) AS exited_quantity,
  (exit_record->>'charges')::numeric(18,8) AS exit_charges
FROM trade_history_metrics thm
LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS(thm.exit_records) AS exit_record ON true;

CREATE MATERIALIZED VIEW summary_metrics AS
SELECT
  DATE_TRUNC('month', te.entry_date) AS period,
  COUNT(DISTINCT te.id) FILTER (WHERE te.entry_date >= DATE_TRUNC('month', CURRENT_DATE)) AS new_trades,
  COUNT(*) FILTER (WHERE thm.exit_pct = 100) AS fully_closed,
  COUNT(*) FILTER (WHERE thm.exit_pct < 100) AS partially_closed,
  AVG(thm.gain_pct) FILTER (WHERE thm.exit_pct = 100) AS avg_gain,
  AVG(thm.gain_pct) FILTER (WHERE thm.exit_pct = 100 AND thm.gain_pct < 0) AS avg_loss,
  SUM(thm.net_profit) AS profit,
  SUM(thm.charges) AS charges,
  SUM(thm.net_profit) AS net_profit
FROM trade_entries te
JOIN trade_history_metrics thm ON te.id = thm.id
GROUP BY period;

-- {
--     "journalId": "cd03b578-8769-47db-a51d-be9be4584bac",
--     "netProfit": 7513.75,
--     "capitalDeployed": 141883.72,
--     "accountValue": 142513.75,
--     "totalExposure": 20000,
--     "totalExposureLong": 10000,
--     "totalExposureShort": 10000,
--     "totalOpenRisk": -700,
--     "totalOpenRiskLong": -200,
--     "totalOpenRiskShort": -500,
    
--     "fundsAdded": 135000
-- }
-- snake case on the keys

DROP VIEW IF EXISTS journal_dashboard;

CREATE OR REPLACE VIEW journal_dashboard AS
WITH funds_cte AS (
    SELECT 
        journal_id,
        SUM(CASE WHEN type = 'DEPOSIT' THEN amount ELSE -amount END) AS capital_deployed
    FROM funds
    GROUP BY journal_id
),
realized_profits_cte AS (
    SELECT
        te.journal_id,
        SUM((exit_price - te.entry_price) * quantity_exited - (e.charges + te.charges)) AS net_profit
    FROM trade_exits e
    JOIN trade_entries te ON te.id = e.entry_id
    GROUP BY te.journal_id
),
open_trades_cte AS (
    SELECT
        te.journal_id,
        te.direction,
        te.quantity - COALESCE(SUM(e.quantity_exited), 0) AS remaining_quantity,
        te.entry_price,
        te.stop_loss
    FROM trade_entries te
    LEFT JOIN trade_exits e ON te.id = e.entry_id
    GROUP BY te.id, te.journal_id, te.direction, te.quantity, te.entry_price, te.stop_loss
    HAVING te.quantity - COALESCE(SUM(e.quantity_exited), 0) > 0
)
SELECT
    j.id AS journal_id,
    f.capital_deployed,
    (f.capital_deployed + COALESCE(r.net_profit, 0)) AS account_value,
    -- Exposure Calculations
    COALESCE(SUM(ot.remaining_quantity * ot.entry_price), 0) AS total_exposure,
    COALESCE(SUM(CASE WHEN ot.direction = 'LONG' THEN ot.remaining_quantity * ot.entry_price ELSE 0 END), 0) AS total_exposure_long,
    COALESCE(SUM(CASE WHEN ot.direction = 'SHORT' THEN ot.remaining_quantity * ot.entry_price ELSE 0 END), 0) AS total_exposure_short,
    -- Risk Calculations
    COALESCE(SUM(
        CASE WHEN ot.direction = 'LONG' 
            THEN (ot.stop_loss - ot.entry_price) * ot.remaining_quantity
            ELSE (ot.entry_price - ot.stop_loss) * ot.remaining_quantity
        END
    ), 0) AS total_open_risk,
    COALESCE(SUM(CASE WHEN ot.direction = 'LONG' 
        THEN (ot.stop_loss - ot.entry_price) * ot.remaining_quantity ELSE 0 END), 0) AS total_open_risk_long,
    COALESCE(SUM(CASE WHEN ot.direction = 'SHORT' 
        THEN (ot.entry_price - ot.stop_loss) * ot.remaining_quantity ELSE 0 END), 0) AS total_open_risk_short,
    -- Percentage Calculations
    COALESCE(SUM(ot.remaining_quantity * ot.entry_price) * 100.0 / NULLIF(f.capital_deployed + COALESCE(r.net_profit, 0), 0), 0) AS total_exposure_percent,
    COALESCE(SUM(
        CASE WHEN ot.direction = 'LONG' 
            THEN (ot.stop_loss - ot.entry_price) * ot.remaining_quantity
            ELSE (ot.entry_price - ot.stop_loss) * ot.remaining_quantity
        END
    ) * 100.0 / NULLIF(f.capital_deployed + COALESCE(r.net_profit, 0), 0), 0) AS total_open_risk_percent
FROM journals j
LEFT JOIN funds_cte f ON j.id = f.journal_id
LEFT JOIN realized_profits_cte r ON j.id = r.journal_id
LEFT JOIN open_trades_cte ot ON j.id = ot.journal_id
GROUP BY j.id, f.capital_deployed, r.net_profit;





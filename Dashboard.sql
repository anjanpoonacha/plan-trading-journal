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

CREATE OR REPLACE materialized VIEW journal_dashboard AS
WITH funds_cte AS (
    SELECT 
        journal_id,
        SUM(CASE WHEN transaction_date >= DATE_TRUNC('year', CURRENT_DATE)
                 THEN CASE WHEN type = 'DEPOSIT' THEN amount ELSE -amount END
                 ELSE 0 END) AS ytd_funds,
        SUM(CASE WHEN transaction_date < DATE_TRUNC('year', CURRENT_DATE)
                 THEN CASE WHEN type = 'DEPOSIT' THEN amount ELSE -amount END
                 ELSE 0 END) AS historical_funds
    FROM funds
    GROUP BY journal_id
),
historical_profits_cte AS (
    SELECT
        te.journal_id,
        SUM(
            (CASE WHEN te.direction = 'LONG' 
                THEN (exit_price - te.entry_price)
                ELSE (te.entry_price - exit_price)
            END) * quantity_exited 
            - (e.charges + (te.charges * (quantity_exited::NUMERIC / te.quantity)))
        ) AS net_profit
    FROM trade_exits e
    JOIN trade_entries te ON e.entry_id = te.id
    WHERE e.exit_date < DATE_TRUNC('year', CURRENT_DATE)
    GROUP BY te.journal_id
),
current_year_profits_cte AS (
    SELECT
        te.journal_id,
        SUM(
            (CASE WHEN te.direction = 'LONG' 
                THEN (exit_price - te.entry_price)
                ELSE (te.entry_price - exit_price)
            END) * quantity_exited 
            - (e.charges + (te.charges * (quantity_exited::NUMERIC / te.quantity)))
        ) AS ytd_net_profit
    FROM trade_exits e
    JOIN trade_entries te ON e.entry_id = te.id
    WHERE e.exit_date >= DATE_TRUNC('year', CURRENT_DATE)
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
    GROUP BY te.id
)
SELECT
    j.id AS journal_id,
    (f.historical_funds + f.ytd_funds) AS capital_deployed,
    (COALESCE(hp.net_profit, 0) + f.historical_funds + COALESCE(yp.ytd_net_profit, 0) + f.ytd_funds) AS account_value,
    (COALESCE(hp.net_profit, 0) + f.historical_funds) AS starting_account_value,
    (COALESCE(hp.net_profit, 0) + f.historical_funds + f.ytd_funds) AS starting_account_value_adj,
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
    COALESCE(SUM(ot.remaining_quantity * ot.entry_price) * 100.0 / NULLIF(f.historical_funds + f.ytd_funds + COALESCE(hp.net_profit, 0) + COALESCE(yp.ytd_net_profit, 0), 0), 0) AS total_exposure_percent,
    COALESCE(SUM(
        CASE WHEN ot.direction = 'LONG' 
            THEN (ot.stop_loss - ot.entry_price) * ot.remaining_quantity
            ELSE (ot.entry_price - ot.stop_loss) * ot.remaining_quantity
        END
    ) * 100.0 / NULLIF(f.historical_funds + f.ytd_funds + COALESCE(hp.net_profit, 0) + COALESCE(yp.ytd_net_profit, 0), 0), 0) AS total_open_risk_percent
FROM journals j
LEFT JOIN funds_cte f ON j.id = f.journal_id
LEFT JOIN historical_profits_cte hp ON j.id = hp.journal_id
LEFT JOIN current_year_profits_cte yp ON j.id = yp.journal_id
LEFT JOIN open_trades_cte ot ON j.id = ot.journal_id
GROUP BY j.id, f.historical_funds, f.ytd_funds, hp.net_profit, yp.ytd_net_profit;

CREATE INDEX idx_funds_journal_date ON funds(journal_id, transaction_date);
CREATE INDEX idx_trade_exits_entry ON trade_exits(entry_id);
CREATE INDEX idx_trade_entries_journal ON trade_entries(journal_id) INCLUDE (direction, entry_price, quantity);

drop function if exists get_journal_dashboard(uuid, uuid);

CREATE OR REPLACE FUNCTION get_journal_dashboard(journal_id UUID, user_id UUID)
RETURNS TABLE (
    dashboard jsonb,
    trades jsonb
) AS $$
BEGIN
    RETURN QUERY
    WITH dash AS (
        SELECT * FROM journal_dashboard
        WHERE journal_dashboard.journal_id = get_journal_dashboard.journal_id
        AND EXISTS (
            SELECT 1 FROM journals j
            WHERE j.id = journal_dashboard.journal_id
            AND j.user_id = get_journal_dashboard.user_id
        )
    ),
    trade_data AS (
        SELECT 
            jsonb_build_object(
                'entry_id', utm.id,
                'entry_date', utm.entry_date,
                'direction', utm.direction,
                'quantity', utm.quantity,
                'entry_price', utm.entry_price,
                'stop_loss', utm.stop_loss,
                'current_stop_loss', utm.current_stop_loss,
                'exits', utm.exit_records,
                'realized_profit', utm.realized_profit,
                'open_quantity', utm.open_quantity,
                'current_exposure', utm.current_exposure,
                'open_risk', utm.open_risk
            ) AS trade
        FROM unified_trade_metrics utm
        WHERE utm.journal_id = get_journal_dashboard.journal_id
        AND utm.user_id = get_journal_dashboard.user_id
    )
    SELECT 
        (SELECT to_jsonb(d.*) FROM dash d) AS dashboard,
        COALESCE(jsonb_agg(t.trade) FILTER (WHERE t.trade IS NOT NULL), '[]'::jsonb) AS trades
    FROM trade_data t;
END;
$$ LANGUAGE plpgsql;

-- Create unique index needed for concurrent refresh
CREATE UNIQUE INDEX journal_dashboard_journal_id_idx ON journal_dashboard (journal_id);

-- Create refresh function with debounce mechanism
CREATE OR REPLACE FUNCTION refresh_journal_dashboard()
RETURNS TRIGGER AS $$
BEGIN
    -- Use debounce to prevent rapid successive refreshes
    PERFORM pg_sleep(0.2);  -- Wait 200ms to batch changes
    REFRESH MATERIALIZED VIEW CONCURRENTLY journal_dashboard;
    RETURN NULL;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error refreshing journal_dashboard: %', SQLERRM;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers on all underlying tables
CREATE TRIGGER refresh_dashboard_after_funds
AFTER INSERT OR UPDATE OR DELETE ON funds
FOR EACH ROW EXECUTE FUNCTION refresh_journal_dashboard();

CREATE TRIGGER refresh_dashboard_after_trade_entries
AFTER INSERT OR UPDATE OR DELETE ON trade_entries
FOR EACH ROW EXECUTE FUNCTION refresh_journal_dashboard();

CREATE TRIGGER refresh_dashboard_after_trade_exits
AFTER INSERT OR UPDATE OR DELETE ON trade_exits
FOR EACH ROW EXECUTE FUNCTION refresh_journal_dashboard();

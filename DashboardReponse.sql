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
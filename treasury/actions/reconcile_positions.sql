-- reconcile_positions.sql
-- Modul: treasury
-- Aktion: reconcile_positions
-- Beschreibung:
--   Diese Aktion erzeugt deterministisch einen neuen Treasury-Positions-
--   Snapshot basierend auf allen existierenden Treasury-Flows eines
--   Treasury-Accounts. Sie dient der regulatorischen Konsistenz,
--   Auditierbarkeit und Rekonstruktion der RFOF-GOLDEN-Chain.

CREATE OR REPLACE FUNCTION treasury_reconcile_positions(
    in_treasury_account_id uuid,
    in_currency currency_code,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_last_position RECORD;
    v_aggregated RECORD;
    v_new_balance numeric(30,10);
    v_new_reserved numeric(30,10);
    v_position_id uuid;
BEGIN
    ------------------------------------------------------------
    -- Letzte Position laden
    ------------------------------------------------------------
    SELECT *
    INTO v_last_position
    FROM treasury_positions
    WHERE treasury_account_id = in_treasury_account_id
      AND currency = in_currency
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_last_position.treasury_account_id IS NULL THEN
        RAISE EXCEPTION 'treasury_account_not_found_or_no_position';
    END IF;

    ------------------------------------------------------------
    -- Aggregation aller Flows
    ------------------------------------------------------------
    SELECT
        COALESCE(SUM(CASE WHEN direction = 'inflow' THEN amount ELSE 0 END), 0) AS total_inflow,
        COALESCE(SUM(CASE WHEN direction = 'outflow' THEN amount ELSE 0 END), 0) AS total_outflow
    INTO v_aggregated
    FROM treasury_flows
    WHERE treasury_account_id = in_treasury_account_id
      AND currency = in_currency;

    ------------------------------------------------------------
    -- Neue Balance berechnen
    ------------------------------------------------------------
    v_new_balance :=
        v_last_position.balance
        + v_aggregated.total_inflow
        - v_aggregated.total_outflow;

    IF v_new_balance < 0 THEN
        RAISE EXCEPTION 'negative_balance_after_reconciliation';
    END IF;

    v_new_reserved := v_last_position.reserved_balance;

    ------------------------------------------------------------
    -- Neue Position erzeugen (Snapshot)
    ------------------------------------------------------------
    INSERT INTO treasury_positions (
        treasury_account_id,
        currency,
        balance,
        reserved_balance,
        metadata
    )
    VALUES (
        in_treasury_account_id,
        in_currency,
        v_new_balance,
        v_new_reserved,
        in_metadata
    )
    RETURNING id INTO v_position_id;

    ------------------------------------------------------------
    -- Position-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_position_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION treasury_reconcile_positions(
    uuid, currency_code, jsonb
) IS
'Erzeugt deterministisch einen neuen Treasury-Positions-Snapshot basierend auf allen Treasury-Flows.';

-- reconcile_settlement_positions.sql
-- Modul: settlement
-- Aktion: reconcile_settlement_positions
-- Beschreibung:
--   Diese Aktion erzeugt deterministisch einen neuen Settlement-Positions-
--   Snapshot basierend auf allen existierenden Settlement-Flows eines
--   Settlement-Accounts. Sie dient der regulatorischen Konsistenz,
--   Auditierbarkeit und Rekonstruktion finaler Abrechnungsstände.

CREATE OR REPLACE FUNCTION settlement_reconcile_settlement_positions(
    in_settlement_account_id uuid,
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
    FROM settlement_positions
    WHERE settlement_account_id = in_settlement_account_id
      AND currency = in_currency
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_last_position.settlement_account_id IS NULL THEN
        RAISE EXCEPTION 'settlement_account_not_found_or_no_position';
    END IF;

    ------------------------------------------------------------
    -- Aggregation aller Flows
    ------------------------------------------------------------
    SELECT
        COALESCE(SUM(CASE WHEN direction = 'credit' THEN amount ELSE 0 END), 0) AS total_credit,
        COALESCE(SUM(CASE WHEN direction = 'debit' THEN amount ELSE 0 END), 0) AS total_debit
    INTO v_aggregated
    FROM settlement_flows
    WHERE settlement_account_id = in_settlement_account_id
      AND currency = in_currency;

    ------------------------------------------------------------
    -- Neue Balance berechnen
    ------------------------------------------------------------
    v_new_balance :=
        v_last_position.balance
        + v_aggregated.total_credit
        - v_aggregated.total_debit;

    IF v_new_balance < 0 THEN
        RAISE EXCEPTION 'negative_balance_after_reconciliation';
    END IF;

    v_new_reserved := v_last_position.reserved_balance;

    ------------------------------------------------------------
    -- Neue Position erzeugen (Snapshot)
    ------------------------------------------------------------
    INSERT INTO settlement_positions (
        settlement_account_id,
        currency,
        balance,
        reserved_balance,
        metadata
    )
    VALUES (
        in_settlement_account_id,
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

COMMENT ON FUNCTION settlement_reconcile_settlement_positions(
    uuid, currency_code, jsonb
) IS
'Erzeugt deterministisch einen neuen Settlement-Positions-Snapshot basierend auf allen Settlement-Flows.';

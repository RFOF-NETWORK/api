-- record_settlement_flow.sql
-- Modul: settlement
-- Aktion: record_settlement_flow
-- Beschreibung:
--   Diese Aktion erzeugt deterministisch einen Settlement-Flow
--   (credit/debit) und aktualisiert die zugehörige Settlement-Position
--   durch Erzeugung eines neuen Positions-Snapshots.
--   Alle Operationen sind unveränderlich, auditierbar und stabil.

CREATE OR REPLACE FUNCTION settlement_record_settlement_flow(
    in_settlement_account_id uuid,
    in_direction text,
    in_amount numeric(30,10),
    in_currency currency_code,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_flow_id uuid;
    v_position RECORD;
    v_new_balance numeric(30,10);
    v_new_reserved numeric(30,10);
BEGIN
    ------------------------------------------------------------
    -- Validierung: Settlement-Account existiert
    ------------------------------------------------------------
    SELECT *
    INTO v_position
    FROM settlement_positions
    WHERE settlement_account_id = in_settlement_account_id
      AND currency = in_currency
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_position.settlement_account_id IS NULL THEN
        RAISE EXCEPTION 'settlement_account_not_found_or_no_position';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Richtung
    ------------------------------------------------------------
    IF in_direction NOT IN ('credit', 'debit') THEN
        RAISE EXCEPTION 'invalid_settlement_flow_direction';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Betrag
    ------------------------------------------------------------
    IF in_amount <= 0 THEN
        RAISE EXCEPTION 'invalid_settlement_flow_amount';
    END IF;

    ------------------------------------------------------------
    -- Neue Balance berechnen
    ------------------------------------------------------------
    IF in_direction = 'credit' THEN
        v_new_balance := v_position.balance + in_amount;
    ELSE
        -- debit
        IF v_position.available_balance < in_amount THEN
            RAISE EXCEPTION 'insufficient_settlement_funds';
        END IF;
        v_new_balance := v_position.balance - in_amount;
    END IF;

    v_new_reserved := v_position.reserved_balance;

    ------------------------------------------------------------
    -- Settlement-Flow erzeugen
    ------------------------------------------------------------
    INSERT INTO settlement_flows (
        settlement_account_id,
        direction,
        amount,
        currency,
        metadata
    )
    VALUES (
        in_settlement_account_id,
        in_direction,
        in_amount,
        in_currency,
        in_metadata
    )
    RETURNING id INTO v_flow_id;

    ------------------------------------------------------------
    -- Neue Settlement-Position erzeugen (Snapshot)
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
    );

    ------------------------------------------------------------
    -- Flow-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_flow_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION settlement_record_settlement_flow(
    uuid, text, numeric, currency_code, jsonb
) IS
'Erzeugt deterministisch einen Settlement-Flow und aktualisiert die Settlement-Position durch einen neuen Snapshot.';

-- record_flow.sql
-- Modul: treasury
-- Aktion: record_flow
-- Beschreibung:
--   Diese Aktion erzeugt deterministisch einen Treasury-Flow
--   (inflow/outflow) und aktualisiert die zugehörige Treasury-Position
--   durch Erzeugung eines neuen Positions-Snapshots.
--   Alle Operationen sind unveränderlich, auditierbar und stabil.

CREATE OR REPLACE FUNCTION treasury_record_flow(
    in_treasury_account_id uuid,
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
    -- Validierung: Treasury-Account existiert
    ------------------------------------------------------------
    SELECT *
    INTO v_position
    FROM treasury_positions
    WHERE treasury_account_id = in_treasury_account_id
      AND currency = in_currency
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_position.treasury_account_id IS NULL THEN
        RAISE EXCEPTION 'treasury_account_not_found_or_no_position';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Richtung
    ------------------------------------------------------------
    IF in_direction NOT IN ('inflow', 'outflow') THEN
        RAISE EXCEPTION 'invalid_flow_direction';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Betrag
    ------------------------------------------------------------
    IF in_amount <= 0 THEN
        RAISE EXCEPTION 'invalid_flow_amount';
    END IF;

    ------------------------------------------------------------
    -- Neuen Balance-Wert berechnen
    ------------------------------------------------------------
    IF in_direction = 'inflow' THEN
        v_new_balance := v_position.balance + in_amount;
    ELSE
        -- outflow
        IF v_position.available_balance < in_amount THEN
            RAISE EXCEPTION 'insufficient_treasury_funds';
        END IF;
        v_new_balance := v_position.balance - in_amount;
    END IF;

    v_new_reserved := v_position.reserved_balance;

    ------------------------------------------------------------
    -- Treasury-Flow erzeugen
    ------------------------------------------------------------
    INSERT INTO treasury_flows (
        treasury_account_id,
        direction,
        amount,
        currency,
        metadata
    )
    VALUES (
        in_treasury_account_id,
        in_direction,
        in_amount,
        in_currency,
        in_metadata
    )
    RETURNING id INTO v_flow_id;

    ------------------------------------------------------------
    -- Neue Treasury-Position erzeugen (Snapshot)
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
    );

    ------------------------------------------------------------
    -- Flow-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_flow_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION treasury_record_flow(
    uuid, text, numeric, currency_code, jsonb
) IS
'Erzeugt deterministisch einen Treasury-Flow und aktualisiert die Treasury-Position durch einen neuen Snapshot.';

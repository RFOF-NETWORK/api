-- record_liquidity_flow.sql
-- Modul: liquidity
-- Aktion: record_liquidity_flow
-- Beschreibung:
--   Diese Aktion erzeugt deterministisch einen Liquidity-Flow
--   (inflow/outflow) und aktualisiert die zugehörige Liquidity-Position
--   durch Erzeugung eines neuen Positions-Snapshots.
--   Alle Operationen sind unveränderlich, auditierbar und stabil.

CREATE OR REPLACE FUNCTION liquidity_record_liquidity_flow(
    in_liquidity_pool_id uuid,
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
    -- Validierung: Liquidity-Pool existiert
    ------------------------------------------------------------
    SELECT *
    INTO v_position
    FROM liquidity_positions
    WHERE liquidity_pool_id = in_liquidity_pool_id
      AND currency = in_currency
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_position.liquidity_pool_id IS NULL THEN
        RAISE EXCEPTION 'liquidity_pool_not_found_or_no_position';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Richtung
    ------------------------------------------------------------
    IF in_direction NOT IN ('inflow', 'outflow') THEN
        RAISE EXCEPTION 'invalid_liquidity_flow_direction';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Betrag
    ------------------------------------------------------------
    IF in_amount <= 0 THEN
        RAISE EXCEPTION 'invalid_liquidity_flow_amount';
    END IF;

    ------------------------------------------------------------
    -- Neue Balance berechnen
    ------------------------------------------------------------
    IF in_direction = 'inflow' THEN
        v_new_balance := v_position.balance + in_amount;
    ELSE
        -- outflow
        IF v_position.available_balance < in_amount THEN
            RAISE EXCEPTION 'insufficient_liquidity_funds';
        END IF;
        v_new_balance := v_position.balance - in_amount;
    END IF;

    v_new_reserved := v_position.reserved_balance;

    ------------------------------------------------------------
    -- Liquidity-Flow erzeugen
    ------------------------------------------------------------
    INSERT INTO liquidity_flows (
        liquidity_pool_id,
        direction,
        amount,
        currency,
        metadata
    )
    VALUES (
        in_liquidity_pool_id,
        in_direction,
        in_amount,
        in_currency,
        in_metadata
    )
    RETURNING id INTO v_flow_id;

    ------------------------------------------------------------
    -- Neue Liquidity-Position erzeugen (Snapshot)
    ------------------------------------------------------------
    INSERT INTO liquidity_positions (
        liquidity_pool_id,
        currency,
        balance,
        reserved_balance,
        metadata
    )
    VALUES (
        in_liquidity_pool_id,
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

COMMENT ON FUNCTION liquidity_record_liquidity_flow(
    uuid, text, numeric, currency_code, jsonb
) IS
'Erzeugt deterministisch einen Liquidity-Flow und aktualisiert die Liquidity-Position durch einen neuen Snapshot.';

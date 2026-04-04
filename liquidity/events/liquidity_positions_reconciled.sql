-- liquidity_positions_reconciled.sql
-- Modul: liquidity
-- Ereignis: liquidity_positions_reconciled
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch die Rekonsolidierung
--   einer Liquidity-Position. Es ist unveränderlich, auditierbar und bildet
--   die Grundlage für regulatorische Nachweise, Intraday-Liquidität,
--   Treasury-Integration, Interbank-Settlement und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS liquidity_positions_reconciled_events (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Liquidity-Pool
    liquidity_pool_id       uuid NOT NULL REFERENCES liquidity_pools(id) ON DELETE RESTRICT,

    -- Verknüpfung zur neuen Position
    liquidity_position_id   uuid NOT NULL REFERENCES liquidity_positions(id) ON DELETE CASCADE,

    -- Währung
    currency                currency_code NOT NULL,

    -- Aggregierte Werte
    balance                 numeric(30,10) NOT NULL,
    reserved_balance        numeric(30,10) NOT NULL,
    available_balance       numeric(30,10) NOT NULL,

    -- Zeitliche Dimension
    reconciled_at           timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Liquidity-Position wurde rekonsolidiert
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_liquidity_positions_reconciled_event(
    in_liquidity_pool_id uuid,
    in_liquidity_position_id uuid,
    in_currency currency_code,
    in_balance numeric(30,10),
    in_reserved_balance numeric(30,10),
    in_available_balance numeric(30,10),
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO liquidity_positions_reconciled_events (
        liquidity_pool_id,
        liquidity_position_id,
        currency,
        balance,
        reserved_balance,
        available_balance,
        metadata
    )
    VALUES (
        in_liquidity_pool_id,
        in_liquidity_position_id,
        in_currency,
        in_balance,
        in_reserved_balance,
        in_available_balance,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_liquidity_positions_reconciled_event(
    uuid, uuid, currency_code, numeric, numeric, numeric, jsonb
) IS
'Ereignis: dokumentiert deterministisch die Rekonsolidierung einer Liquidity-Position.';

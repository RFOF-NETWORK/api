-- liquidity_flow_recorded.sql
-- Modul: liquidity
-- Ereignis: liquidity_flow_recorded
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch die Erfassung eines
--   Liquidity-Flows (inflow/outflow). Es ist unveränderlich, auditierbar
--   und bildet die Grundlage für regulatorische Nachweise,
--   Intraday-Liquidität, Treasury-Integration, Interbank-Settlement
--   und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS liquidity_flow_recorded_events (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Liquidity-Pool
    liquidity_pool_id       uuid NOT NULL REFERENCES liquidity_pools(id) ON DELETE RESTRICT,

    -- Verknüpfung zum Flow
    liquidity_flow_id       uuid NOT NULL REFERENCES liquidity_flows(id) ON DELETE CASCADE,

    -- Bewegungsrichtung
    direction               text NOT NULL,

    -- Betrag
    amount                  numeric(30,10) NOT NULL,
    currency                currency_code NOT NULL,

    -- Zeitliche Dimension
    occurred_at             timestamptz NOT NULL,

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Liquidity-Flow wurde erfasst
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_liquidity_flow_recorded_event(
    in_liquidity_pool_id uuid,
    in_liquidity_flow_id uuid,
    in_direction text,
    in_amount numeric(30,10),
    in_currency currency_code,
    in_occurred_at timestamptz,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO liquidity_flow_recorded_events (
        liquidity_pool_id,
        liquidity_flow_id,
        direction,
        amount,
        currency,
        occurred_at,
        metadata
    )
    VALUES (
        in_liquidity_pool_id,
        in_liquidity_flow_id,
        in_direction,
        in_amount,
        in_currency,
        in_occurred_at,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_liquidity_flow_recorded_event(
    uuid, uuid, text, numeric, currency_code, timestamptz, jsonb
) IS
'Ereignis: dokumentiert deterministisch die Erfassung eines Liquidity-Flows.';

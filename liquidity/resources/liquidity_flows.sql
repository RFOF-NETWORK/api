-- liquidity_flows.sql
-- Modul: liquidity
-- Ressource: liquidity_flows
-- Beschreibung:
--   Diese Ressource definiert Liquidity-Flows, also atomare,
--   unveränderliche Liquiditätsbewegungen eines Liquidity-Pools.
--   Sie bilden die Grundlage für:
--     - Intraday-Liquidität
--     - Treasury-Integration
--     - Interbank-Settlement
--     - regulatorische Nachweise
--   Liquidity-Flows sind streng auditierbar und unveränderlich.

CREATE TABLE IF NOT EXISTS liquidity_flows (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Liquidity-Pool
    liquidity_pool_id       uuid NOT NULL REFERENCES liquidity_pools(id) ON DELETE RESTRICT,

    -- Bewegungsrichtung
    direction               text NOT NULL, -- 'inflow' | 'outflow'

    -- Beträge
    amount                  numeric(30,10) NOT NULL,
    currency                currency_code NOT NULL,

    -- Zeitliche Dimension
    occurred_at             timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Liquidity-Flows sind unveränderlich (keine Updates)
------------------------------------------------------------
ALTER TABLE liquidity_flows ENABLE ROW LEVEL SECURITY;

CREATE POLICY liquidity_flows_select ON liquidity_flows
    FOR SELECT
    USING (true);

CREATE POLICY liquidity_flows_insert ON liquidity_flows
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY liquidity_flows_update ON liquidity_flows
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY liquidity_flows_delete ON liquidity_flows
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE liquidity_flows
    ADD CONSTRAINT liquidity_flows_direction_check
    CHECK (direction IN ('inflow', 'outflow'));

ALTER TABLE liquidity_flows
    ADD CONSTRAINT liquidity_flows_amount_positive
    CHECK (amount > 0);

ALTER TABLE liquidity_flows
    ADD CONSTRAINT liquidity_flows_currency_consistency
    CHECK (currency IS NOT NULL);

-- liquidity_pools.sql
-- Modul: liquidity
-- Ressource: liquidity_pools
-- Beschreibung:
--   Diese Ressource definiert Liquidity-Pools, also zentrale systemische
--   Liquiditätsbehälter. Sie dienen der Intraday-Liquidität,
--   Interbank-Liquiditätssteuerung, Treasury-Integration und
--   regulatorischen Stabilität. Liquidity-Pools sind unveränderlich,
--   auditierbar und strikt kontrolliert.

CREATE TABLE IF NOT EXISTS liquidity_pools (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Systemische Pool-Identifikation
    pool_number             bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
    pool_type               text NOT NULL, -- 'intraday', 'reserve', 'collateral', 'settlement', 'system'

    -- Verknüpfung zu Treasury-Accounts (optional, je nach Pool-Typ)
    treasury_account_id     uuid REFERENCES treasury_accounts(id) ON DELETE RESTRICT,

    -- Währung des Pools
    currency                currency_code NOT NULL,

    -- Aktivierungsstatus
    active                  boolean NOT NULL DEFAULT true,

    -- Zeitliche Dimension
    created_at              timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Liquidity-Pools sind unveränderlich (keine Updates)
------------------------------------------------------------
ALTER TABLE liquidity_pools ENABLE ROW LEVEL SECURITY;

CREATE POLICY liquidity_pools_select ON liquidity_pools
    FOR SELECT
    USING (true);

CREATE POLICY liquidity_pools_insert ON liquidity_pools
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY liquidity_pools_update ON liquidity_pools
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY liquidity_pools_delete ON liquidity_pools
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE liquidity_pools
    ADD CONSTRAINT liquidity_pools_type_check
    CHECK (pool_type IN ('intraday', 'reserve', 'collateral', 'settlement', 'system'));

ALTER TABLE liquidity_pools
    ADD CONSTRAINT liquidity_pools_currency_consistency
    CHECK (currency IS NOT NULL);

ALTER TABLE liquidity_pools
    ADD CONSTRAINT liquidity_pools_active_consistency
    CHECK (active IN (true, false));

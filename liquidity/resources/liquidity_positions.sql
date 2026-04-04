-- liquidity_positions.sql
-- Modul: liquidity
-- Ressource: liquidity_positions
-- Beschreibung:
--   Diese Ressource definiert Liquidity-Positions, also unveränderliche
--   Positions-Snapshots eines Liquidity-Pools. Sie bilden die Grundlage für:
--     - Intraday-Liquidität
--     - Treasury-Integration
--     - Interbank-Settlement
--     - regulatorische Nachweise
--   Liquidity-Positions sind streng auditierbar und unveränderlich.

CREATE TABLE IF NOT EXISTS liquidity_positions (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Liquidity-Pool
    liquidity_pool_id       uuid NOT NULL REFERENCES liquidity_pools(id) ON DELETE CASCADE,

    -- Währung der Position
    currency                currency_code NOT NULL,

    -- Positionelle Werte
    balance                 numeric(30,10) NOT NULL DEFAULT 0,
    reserved_balance        numeric(30,10) NOT NULL DEFAULT 0,
    available_balance       numeric(30,10) GENERATED ALWAYS AS (balance - reserved_balance) STORED,

    -- Zeitliche Dimension
    created_at              timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Liquidity-Positions sind unveränderlich (keine Updates)
------------------------------------------------------------
ALTER TABLE liquidity_positions ENABLE ROW LEVEL SECURITY;

CREATE POLICY liquidity_positions_select ON liquidity_positions
    FOR SELECT
    USING (true);

CREATE POLICY liquidity_positions_insert ON liquidity_positions
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY liquidity_positions_update ON liquidity_positions
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY liquidity_positions_delete ON liquidity_positions
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE liquidity_positions
    ADD CONSTRAINT liquidity_positions_balance_nonnegative
    CHECK (balance >= 0);

ALTER TABLE liquidity_positions
    ADD CONSTRAINT liquidity_positions_reserved_nonnegative
    CHECK (reserved_balance >= 0);

ALTER TABLE liquidity_positions
    ADD CONSTRAINT liquidity_positions_currency_consistency
    CHECK (currency IS NOT NULL);

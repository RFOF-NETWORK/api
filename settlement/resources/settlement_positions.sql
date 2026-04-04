-- settlement_positions.sql
-- Modul: settlement
-- Ressource: settlement_positions
-- Beschreibung:
--   Settlement-Positions sind unveränderliche Positions-Snapshots eines
--   Settlement-Accounts. Sie bilden die Grundlage für:
--     - Endgültigkeit (Finality)
--     - Interbank-Settlement
--     - Treasury-Integration
--     - Liquidity-Integration
--     - regulatorische Nachweise
--   Settlement-Positions sind streng auditierbar und unveränderlich.

CREATE TABLE IF NOT EXISTS settlement_positions (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Settlement-Account
    settlement_account_id   uuid NOT NULL REFERENCES settlement_accounts(id) ON DELETE CASCADE,

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
-- Settlement-Positions sind unveränderlich (keine Updates)
------------------------------------------------------------
ALTER TABLE settlement_positions ENABLE ROW LEVEL SECURITY;

CREATE POLICY settlement_positions_select ON settlement_positions
    FOR SELECT
    USING (true);

CREATE POLICY settlement_positions_insert ON settlement_positions
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY settlement_positions_update ON settlement_positions
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY settlement_positions_delete ON settlement_positions
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE settlement_positions
    ADD CONSTRAINT settlement_positions_balance_nonnegative
    CHECK (balance >= 0);

ALTER TABLE settlement_positions
    ADD CONSTRAINT settlement_positions_reserved_nonnegative
    CHECK (reserved_balance >= 0);

ALTER TABLE settlement_positions
    ADD CONSTRAINT settlement_positions_currency_consistency
    CHECK (currency IS NOT NULL);

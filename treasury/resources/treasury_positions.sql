-- treasury_positions.sql
-- Modul: treasury
-- Ressource: treasury_positions
-- Beschreibung:
--   Diese Ressource definiert Treasury-Positions, also die zentralen,
--   unveränderlichen Positionsdatensätze für Treasury-Accounts.
--   Sie bilden die Grundlage für:
--     - Liquiditätssteuerung
--     - Reservehaltung
--     - Collateral-Management
--     - Interbank-Settlement
--     - RFOF-GOLDEN-Chain-Prozesse
--   Treasury-Positions sind streng auditierbar und unveränderlich.

CREATE TABLE IF NOT EXISTS treasury_positions (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Treasury-Account
    treasury_account_id     uuid NOT NULL REFERENCES treasury_accounts(id) ON DELETE CASCADE,

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
-- Treasury-Positions sind unveränderlich (keine Updates)
------------------------------------------------------------
ALTER TABLE treasury_positions ENABLE ROW LEVEL SECURITY;

CREATE POLICY treasury_positions_select ON treasury_positions
    FOR SELECT
    USING (true);

CREATE POLICY treasury_positions_insert ON treasury_positions
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY treasury_positions_update ON treasury_positions
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY treasury_positions_delete ON treasury_positions
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE treasury_positions
    ADD CONSTRAINT treasury_positions_balance_nonnegative
    CHECK (balance >= 0);

ALTER TABLE treasury_positions
    ADD CONSTRAINT treasury_positions_reserved_nonnegative
    CHECK (reserved_balance >= 0);

ALTER TABLE treasury_positions
    ADD CONSTRAINT treasury_positions_currency_consistency
    CHECK (currency IS NOT NULL);

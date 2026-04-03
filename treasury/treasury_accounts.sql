-- treasury_accounts.sql
-- Modul: treasury
-- Ressource: treasury_accounts
-- Beschreibung:
--   Diese Ressource definiert Treasury-Accounts, also zentrale,
--   hochprivilegierte System- und Reservekonten. Sie bilden die Grundlage
--   für Liquiditätssteuerung, Interbank-Settlement, Reservehaltung,
--   Collateral-Management und RFOF-GOLDEN-Chain-Prozesse.
--   Treasury-Accounts sind unveränderlich, auditierbar und streng
--   kontrolliert.

CREATE TABLE IF NOT EXISTS treasury_accounts (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Treasury-spezifische Identifikation
    treasury_account_number bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
    account_type            text NOT NULL, -- 'reserve', 'liquidity', 'collateral', 'system'

    -- Verknüpfung zum globalen Accounts-Modul
    account_id              uuid NOT NULL UNIQUE REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Währung des Treasury-Kontos
    currency                currency_code NOT NULL,

    -- Aktivierungsstatus
    active                  boolean NOT NULL DEFAULT true,

    -- Zeitliche Dimension
    created_at              timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Treasury-Accounts sind unveränderlich (keine Updates)
------------------------------------------------------------
ALTER TABLE treasury_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY treasury_accounts_select ON treasury_accounts
    FOR SELECT
    USING (true);

CREATE POLICY treasury_accounts_insert ON treasury_accounts
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY treasury_accounts_update ON treasury_accounts
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY treasury_accounts_delete ON treasury_accounts
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE treasury_accounts
    ADD CONSTRAINT treasury_accounts_type_check
    CHECK (account_type IN ('reserve', 'liquidity', 'collateral', 'system'));

ALTER TABLE treasury_accounts
    ADD CONSTRAINT treasury_accounts_active_consistency
    CHECK (active IN (true, false));

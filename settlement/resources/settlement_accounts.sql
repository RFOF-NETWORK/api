-- settlement_accounts.sql
-- Modul: settlement
-- Ressource: settlement_accounts
-- Beschreibung:
--   Settlement-Accounts sind finale Abrechnungs-Konten, die zur
--   Endgültigkeit (Finality) von Zahlungen und Interbank-Settlement
--   dienen. Sie sind strikt auditierbar, unveränderlich und
--   regulatorisch stabil. Settlement-Accounts sind systemische
--   Einheiten und keine Benutzerkonten.

CREATE TABLE IF NOT EXISTS settlement_accounts (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Systemische Account-Identifikation
    settlement_account_number bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
    account_type             text NOT NULL, -- 'nostro', 'vostro', 'internal', 'reserve', 'system'

    -- Verknüpfung zu Treasury-Accounts (optional)
    treasury_account_id     uuid REFERENCES treasury_accounts(id) ON DELETE RESTRICT,

    -- Verknüpfung zu Liquidity-Pools (optional)
    liquidity_pool_id       uuid REFERENCES liquidity_pools(id) ON DELETE RESTRICT,

    -- Währung des Settlement-Accounts
    currency                currency_code NOT NULL,

    -- Aktivierungsstatus
    active                  boolean NOT NULL DEFAULT true,

    -- Zeitliche Dimension
    created_at              timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Settlement-Accounts sind unveränderlich (keine Updates)
------------------------------------------------------------
ALTER TABLE settlement_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY settlement_accounts_select ON settlement_accounts
    FOR SELECT
    USING (true);

CREATE POLICY settlement_accounts_insert ON settlement_accounts
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY settlement_accounts_update ON settlement_accounts
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY settlement_accounts_delete ON settlement_accounts
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE settlement_accounts
    ADD CONSTRAINT settlement_accounts_type_check
    CHECK (account_type IN ('nostro', 'vostro', 'internal', 'reserve', 'system'));

ALTER TABLE settlement_accounts
    ADD CONSTRAINT settlement_accounts_currency_consistency
    CHECK (currency IS NOT NULL);

ALTER TABLE settlement_accounts
    ADD CONSTRAINT settlement_accounts_active_consistency
    CHECK (active IN (true, false));

-- ledger_accounts.sql
-- Modul: ledger
-- Ressource: ledger_accounts
-- Beschreibung:
--   Diese Ressource bildet die buchhalterische Sicht eines Accounts ab.
--   Jeder Account besitzt genau einen Ledger-Account.
--   Ledger-Accounts sind stabil, auditierbar und definieren die
--   bilanzielle Klassifikation (asset, liability, equity, income, expense).
--   Es gibt keine Löschungen und keine Statusänderungen.

CREATE TABLE IF NOT EXISTS ledger_accounts (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum operativen Account
    account_id          uuid NOT NULL UNIQUE REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Bilanzielle Klassifikation
    classification      account_type_class NOT NULL,

    -- Kategorie (retail, corporate, institutional, internal, technical)
    category            account_category NOT NULL,

    -- Währung
    currency            currency_code NOT NULL,

    -- Auditfelder
    created_at          timestamptz NOT NULL DEFAULT now(),
    metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ledger-Accounts sind unveränderlich
------------------------------------------------------------
ALTER TABLE ledger_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY ledger_accounts_select ON ledger_accounts
    FOR SELECT
    USING (true);

CREATE POLICY ledger_accounts_insert ON ledger_accounts
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY ledger_accounts_update ON ledger_accounts
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY ledger_accounts_delete ON ledger_accounts
    FOR DELETE
    USING (false);

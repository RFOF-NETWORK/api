-- account_balances.sql
-- Modul: accounts
-- Ressource: account_balances
-- Beschreibung:
--   Diese Datei definiert die Saldenressource eines Accounts.
--   Jeder Account besitzt genau einen Balance-Eintrag.
--   Der Saldo ist persistent, auditierbar und wird ausschließlich
--   durch Ledger-Operationen verändert.
--   Die Balance-Tabelle enthält keine Berechnungen und keine Historie.

CREATE TABLE IF NOT EXISTS account_balances (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id          uuid NOT NULL UNIQUE REFERENCES accounts(id) ON DELETE CASCADE,
    balance             numeric(30, 10) NOT NULL DEFAULT 0,
    updated_at          timestamptz NOT NULL DEFAULT now()
);

-- Automatische Aktualisierung des updated_at-Feldes
CREATE OR REPLACE FUNCTION account_balances_set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER account_balances_set_updated_at_trigger
BEFORE UPDATE ON account_balances
FOR EACH ROW
EXECUTE FUNCTION account_balances_set_updated_at();

-- Basis-RLS aktivieren
ALTER TABLE account_balances ENABLE ROW LEVEL SECURITY;

-- Standard-Policies (werden später in shared/policies/accounts_rls.sql erweitert)
CREATE POLICY account_balances_select ON account_balances
    FOR SELECT
    USING (true);

CREATE POLICY account_balances_insert ON account_balances
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY account_balances_update ON account_balances
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY account_balances_delete ON account_balances
    FOR DELETE
    USING (false);

-- accounts.sql
-- Modul: accounts
-- Ressource: accounts
-- Beschreibung:
--   Diese Datei definiert die zentrale Kontoressource.
--   Ein Account ist eine eindeutig identifizierbare, auditierbare Finanzentität.
--   Er bildet die Grundlage für Buchungen, Salden, Ledger-Operationen,
--   regulatorische Prüfungen und modulare Erweiterungen.
--   Accounts sind strikt typisiert, statusgeführt und unveränderlich in ihrer Identität.

CREATE TABLE IF NOT EXISTS accounts (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_user_id       uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    account_number      text UNIQUE NOT NULL,
    account_type        text NOT NULL,
    status              text NOT NULL DEFAULT 'active',
    currency            text NOT NULL DEFAULT 'EUR',
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

-- Automatische Aktualisierung des updated_at-Feldes
CREATE OR REPLACE FUNCTION accounts_set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER accounts_set_updated_at_trigger
BEFORE UPDATE ON accounts
FOR EACH ROW
EXECUTE FUNCTION accounts_set_updated_at();

-- Basis-RLS aktivieren
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;

-- Standard-Policies (werden später in shared/policies/accounts_rls.sql erweitert)
CREATE POLICY accounts_select ON accounts
    FOR SELECT
    USING (true);

CREATE POLICY accounts_insert ON accounts
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY accounts_update ON accounts
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY accounts_delete ON accounts
    FOR DELETE
    USING (false);

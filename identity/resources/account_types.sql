-- account_types.sql
-- Modul: accounts
-- Ressource: account_types
-- Beschreibung:
--   Diese Datei definiert die Kontotypenressource.
--   Kontotypen klassifizieren Accounts regulatorisch, funktional und operativ.
--   Sie sind stabil, auditierbar und dienen als Grundlage für Ledger-Logik,
--   regulatorische Prüfungen, Reporting und Compliance.

CREATE TABLE IF NOT EXISTS account_types (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name                text UNIQUE NOT NULL,
    description         text NOT NULL,
    category            text NOT NULL,
    is_credit_allowed   boolean NOT NULL DEFAULT true,
    is_debit_allowed    boolean NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

-- Automatische Aktualisierung des updated_at-Feldes
CREATE OR REPLACE FUNCTION account_types_set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER account_types_set_updated_at_trigger
BEFORE UPDATE ON account_types
FOR EACH ROW
EXECUTE FUNCTION account_types_set_updated_at();

-- Basis-RLS aktivieren
ALTER TABLE account_types ENABLE ROW LEVEL SECURITY;

-- Standard-Policies (werden später in shared/policies/accounts_rls.sql erweitert)
CREATE POLICY account_types_select ON account_types
    FOR SELECT
    USING (true);

CREATE POLICY account_types_insert ON account_types
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY account_types_update ON account_types
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY account_types_delete ON account_types
    FOR DELETE
    USING (false);

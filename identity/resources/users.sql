-- users.sql
-- Modul: identity
-- Ressource: users
-- Beschreibung:
--   Diese Datei definiert die zentrale Benutzerressource.
--   Sie bildet Identität, Registrierung, Status und Basisattribute ab.
--   Sie ist deterministisch, auditierbar und modular erweiterbar.

CREATE TABLE IF NOT EXISTS users (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    username            text UNIQUE NOT NULL,
    email               text UNIQUE NOT NULL,
    password_hash       text NOT NULL,
    status              text NOT NULL DEFAULT 'active',
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

-- Automatische Aktualisierung des updated_at-Feldes
CREATE OR REPLACE FUNCTION users_set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_set_updated_at_trigger
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION users_set_updated_at();

-- Basis-RLS aktivieren
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Standard-Policies (werden später in shared/policies/identity_rls.sql erweitert)
CREATE POLICY users_select ON users
    FOR SELECT
    USING (true);

CREATE POLICY users_insert ON users
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY users_update ON users
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY users_delete ON users
    FOR DELETE
    USING (false);

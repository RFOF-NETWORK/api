-- roles.sql
-- Modul: identity
-- Ressource: roles
-- Beschreibung:
--   Diese Datei definiert die Rollenressource.
--   Rollen sind benannte Berechtigungsgruppen, die Benutzern zugewiesen werden.
--   Sie bilden die Grundlage für Zugriffskontrolle, Policies und modulare Rechteverwaltung.

CREATE TABLE IF NOT EXISTS roles (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name            text UNIQUE NOT NULL,
    description     text NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

-- Automatische Aktualisierung des updated_at-Feldes
CREATE OR REPLACE FUNCTION roles_set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER roles_set_updated_at_trigger
BEFORE UPDATE ON roles
FOR EACH ROW
EXECUTE FUNCTION roles_set_updated_at();

-- Basis-RLS aktivieren
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

-- Standard-Policies (werden später in shared/policies/identity_rls.sql erweitert)
CREATE POLICY roles_select ON roles
    FOR SELECT
    USING (true);

CREATE POLICY roles_insert ON roles
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY roles_update ON roles
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY roles_delete ON roles
    FOR DELETE
    USING (false);

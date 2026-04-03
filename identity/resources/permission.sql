-- permissions.sql
-- Modul: identity
-- Ressource: permissions
-- Beschreibung:
--   Diese Datei definiert die Berechtigungsressource.
--   Berechtigungen sind elementare Rechte, die Rollen zugeordnet werden.
--   Sie bilden die Grundlage für feingranulare Zugriffskontrolle,
--   modulare Policy-Definitionen und deterministische Sicherheitslogik.

CREATE TABLE IF NOT EXISTS permissions (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name            text UNIQUE NOT NULL,
    description     text NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

-- Automatische Aktualisierung des updated_at-Feldes
CREATE OR REPLACE FUNCTION permissions_set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER permissions_set_updated_at_trigger
BEFORE UPDATE ON permissions
FOR EACH ROW
EXECUTE FUNCTION permissions_set_updated_at();

-- Basis-RLS aktivieren
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;

-- Standard-Policies (werden später in shared/policies/identity_rls.sql erweitert)
CREATE POLICY permissions_select ON permissions
    FOR SELECT
    USING (true);

CREATE POLICY permissions_insert ON permissions
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY permissions_update ON permissions
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY permissions_delete ON permissions
    FOR DELETE
    USING (false);

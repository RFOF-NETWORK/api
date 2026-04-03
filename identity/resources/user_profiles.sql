-- user_profiles.sql
-- Modul: identity
-- Ressource: user_profiles
-- Beschreibung:
--   Diese Datei definiert die Profilressource eines Benutzers.
--   Sie erweitert die Kernbenutzerressource um optionale, nicht-authentifizierende Attribute.
--   Sie ist modular, erweiterbar und strikt getrennt von sicherheitsrelevanten Daten.
--   Jede Profilinstanz gehört eindeutig zu einem Benutzer.

CREATE TABLE IF NOT EXISTS user_profiles (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             uuid NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    display_name        text,
    avatar_url          text,
    bio                 text,
    locale              text DEFAULT 'en',
    timezone            text DEFAULT 'UTC',
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

-- Automatische Aktualisierung des updated_at-Feldes
CREATE OR REPLACE FUNCTION user_profiles_set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_profiles_set_updated_at_trigger
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION user_profiles_set_updated_at();

-- Basis-RLS aktivieren
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Standard-Policies (werden später in shared/policies/identity_rls.sql erweitert)
CREATE POLICY user_profiles_select ON user_profiles
    FOR SELECT
    USING (true);

CREATE POLICY user_profiles_insert ON user_profiles
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY user_profiles_update ON user_profiles
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY user_profiles_delete ON user_profiles
    FOR DELETE
    USING (false);

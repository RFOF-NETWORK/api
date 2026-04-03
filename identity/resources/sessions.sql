-- sessions.sql
-- Modul: identity
-- Ressource: sessions
-- Beschreibung:
--   Diese Datei definiert die Sitzungsressource.
--   Sessions repräsentieren aktive Authentifizierungszustände eines Benutzers.
--   Sie ermöglichen Token-Verwaltung, Ablaufkontrolle und Auditierbarkeit.
--   Jede Session ist eindeutig, zeitlich begrenzt und sicherheitsrelevant.

CREATE TABLE IF NOT EXISTS sessions (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    issued_at           timestamptz NOT NULL DEFAULT now(),
    expires_at          timestamptz NOT NULL,
    revoked_at          timestamptz,
    ip_address          text,
    user_agent          text,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

-- Automatische Aktualisierung des updated_at-Feldes
CREATE OR REPLACE FUNCTION sessions_set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sessions_set_updated_at_trigger
BEFORE UPDATE ON sessions
FOR EACH ROW
EXECUTE FUNCTION sessions_set_updated_at();

-- Basis-RLS aktivieren
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

-- Standard-Policies (werden später in shared/policies/identity_rls.sql erweitert)
CREATE POLICY sessions_select ON sessions
    FOR SELECT
    USING (true);

CREATE POLICY sessions_insert ON sessions
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY sessions_update ON sessions
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY sessions_delete ON sessions
    FOR DELETE
    USING (false);

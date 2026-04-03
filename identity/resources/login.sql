-- login.sql
-- Modul: identity
-- Aktion: login
-- Beschreibung:
--   Diese Datei definiert die Login-Aktion.
--   Sie prüft Anmeldedaten, erzeugt eine neue Session und liefert die Session-ID zurück.
--   Die Aktion ist deterministisch, transaktional und auditierbar.
--   Sie erzeugt keine Tokens; sie erzeugt ausschließlich eine Session-Ressource.

CREATE OR REPLACE FUNCTION login(
    in_username text,
    in_password text
)
RETURNS uuid AS $$
DECLARE
    v_user_id uuid;
    v_password_hash text;
    v_session_id uuid;
    v_expiry timestamptz;
BEGIN
    -- Benutzer anhand des Benutzernamens finden
    SELECT id, password_hash
    INTO v_user_id, v_password_hash
    FROM users
    WHERE username = in_username;

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'invalid_credentials';
    END IF;

    -- Passwort prüfen
    IF NOT (SELECT hashing_verify(in_password, v_password_hash)) THEN
        RAISE EXCEPTION 'invalid_credentials';
    END IF;

    -- Ablaufzeit definieren (z. B. 24 Stunden)
    v_expiry := now() + interval '24 hours';

    -- Neue Session erzeugen
    INSERT INTO sessions (user_id, expires_at)
    VALUES (v_user_id, v_expiry)
    RETURNING id INTO v_session_id;

    -- Session-ID zurückgeben
    RETURN v_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC-Endpunkt für PostgREST
COMMENT ON FUNCTION login(text, text) IS
'Login-Aktion: prüft Zugangsdaten und erzeugt eine neue Session.';

-- user_logged_in.sql
-- Modul: identity
-- Ereignis: user_logged_in
-- Beschreibung:
--   Dieses Ereignis dokumentiert jeden erfolgreichen Login eines Benutzers.
--   Es ist unveränderlich, auditierbar und dient der Sicherheitsanalyse,
--   der Revisionssicherheit und der systemweiten Ereignisverarbeitung.
--   Ereignisse werden niemals aktualisiert oder gelöscht.

CREATE TABLE IF NOT EXISTS user_logged_in_events (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id      uuid NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    occurred_at     timestamptz NOT NULL DEFAULT now(),
    metadata        jsonb DEFAULT '{}'::jsonb
);

-- Ereignis-Funktion: Benutzer hat sich eingeloggt
CREATE OR REPLACE FUNCTION emit_user_logged_in_event(
    in_user_id uuid,
    in_session_id uuid,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO user_logged_in_events (user_id, session_id, metadata)
    VALUES (in_user_id, in_session_id, in_metadata)
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Kommentar für PostgREST
COMMENT ON FUNCTION emit_user_logged_in_event(uuid, uuid, jsonb) IS
'Ereignis: dokumentiert einen erfolgreichen Login eines Benutzers unveränderlich.';

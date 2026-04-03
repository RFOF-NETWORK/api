-- user_created.sql
-- Modul: identity
-- Ereignis: user_created
-- Beschreibung:
--   Dieses Ereignis wird ausgelöst, wenn ein neuer Benutzer erstellt wird.
--   Es dient der auditierbaren, unveränderlichen Dokumentation.
--   Ereignisse werden nicht verändert oder gelöscht.
--   Sie bilden die Grundlage für Revisionssicherheit, Replikation und Systemintegrität.

CREATE TABLE IF NOT EXISTS user_created_events (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    occurred_at     timestamptz NOT NULL DEFAULT now(),
    metadata        jsonb DEFAULT '{}'::jsonb
);

-- Ereignis-Funktion: Benutzer erstellt
CREATE OR REPLACE FUNCTION emit_user_created_event(
    in_user_id uuid,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO user_created_events (user_id, metadata)
    VALUES (in_user_id, in_metadata)
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Kommentar für PostgREST
COMMENT ON FUNCTION emit_user_created_event(uuid, jsonb) IS
'Ereignis: dokumentiert die Erstellung eines Benutzers unveränderlich.';

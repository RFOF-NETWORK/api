-- role_assigned.sql
-- Modul: identity
-- Ereignis: role_assigned
-- Beschreibung:
--   Dieses Ereignis dokumentiert die Zuweisung einer Rolle an einen Benutzer.
--   Es ist unveränderlich, auditierbar und dient der Nachvollziehbarkeit
--   von Berechtigungsänderungen im gesamten System.
--   Ereignisse werden niemals aktualisiert oder gelöscht.

CREATE TABLE IF NOT EXISTS role_assigned_events (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id         uuid NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    occurred_at     timestamptz NOT NULL DEFAULT now(),
    metadata        jsonb DEFAULT '{}'::jsonb
);

-- Ereignis-Funktion: Rolle wurde zugewiesen
CREATE OR REPLACE FUNCTION emit_role_assigned_event(
    in_user_id uuid,
    in_role_id uuid,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO role_assigned_events (user_id, role_id, metadata)
    VALUES (in_user_id, in_role_id, in_metadata)
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Kommentar für PostgREST
COMMENT ON FUNCTION emit_role_assigned_event(uuid, uuid, jsonb) IS
'Ereignis: dokumentiert die Zuweisung einer Rolle an einen Benutzer unveränderlich.';

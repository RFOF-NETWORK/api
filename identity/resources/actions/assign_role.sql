-- assign_role.sql
-- Modul: identity
-- Aktion: assign_role
-- Beschreibung:
--   Diese Datei definiert die Aktion zur Zuweisung einer Rolle an einen Benutzer.
--   Die Zuweisung ist deterministisch, auditierbar und strikt kontrolliert.
--   Sie erzeugt eine stabile Beziehung zwischen Benutzer und Rolle.
--   Die Aktion verändert keine Rollen oder Benutzer, sondern nur die Zuordnung.

CREATE TABLE IF NOT EXISTS user_roles (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id         uuid NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at     timestamptz NOT NULL DEFAULT now(),
    UNIQUE (user_id, role_id)
);

-- Aktion: Rolle zuweisen
CREATE OR REPLACE FUNCTION assign_role(
    in_user_id uuid,
    in_role_id uuid
)
RETURNS boolean AS $$
DECLARE
    v_exists boolean;
BEGIN
    -- Prüfen, ob die Zuordnung bereits existiert
    SELECT EXISTS(
        SELECT 1 FROM user_roles
        WHERE user_id = in_user_id
          AND role_id = in_role_id
    ) INTO v_exists;

    IF v_exists THEN
        RETURN false;
    END IF;

    -- Neue Rollen-Zuweisung erstellen
    INSERT INTO user_roles (user_id, role_id)
    VALUES (in_user_id, in_role_id);

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC-Endpunkt für PostgREST
COMMENT ON FUNCTION assign_role(uuid, uuid) IS
'Weist einem Benutzer deterministisch eine Rolle zu.';

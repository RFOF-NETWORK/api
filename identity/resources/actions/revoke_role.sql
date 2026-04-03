-- revoke_role.sql
-- Modul: identity
-- Aktion: revoke_role
-- Beschreibung:
--   Diese Datei definiert die Aktion zum Entzug einer Rolle von einem Benutzer.
--   Sie entfernt deterministisch eine bestehende Rollen-Zuweisung.
--   Die Aktion ist auditierbar, sicherheitsrelevant und verändert keine Rollen oder Benutzer,
--   sondern ausschließlich die Zuordnung in der user_roles-Tabelle.

CREATE OR REPLACE FUNCTION revoke_role(
    in_user_id uuid,
    in_role_id uuid
)
RETURNS boolean AS $$
DECLARE
    v_exists boolean;
BEGIN
    -- Prüfen, ob die Zuordnung existiert
    SELECT EXISTS(
        SELECT 1 FROM user_roles
        WHERE user_id = in_user_id
          AND role_id = in_role_id
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN false;
    END IF;

    -- Rollen-Zuweisung entfernen
    DELETE FROM user_roles
    WHERE user_id = in_user_id
      AND role_id = in_role_id;

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC-Endpunkt für PostgREST
COMMENT ON FUNCTION revoke_role(uuid, uuid) IS
'Entzieht einem Benutzer deterministisch eine Rolle.';

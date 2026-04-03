-- logout.sql
-- Modul: identity
-- Aktion: logout
-- Beschreibung:
--   Diese Datei definiert die Logout-Aktion.
--   Sie markiert eine bestehende Session als beendet, ohne sie zu löschen.
--   Die Aktion ist deterministisch, auditierbar und sicherheitsrelevant.
--   Sie beendet ausschließlich die Session; sie erzeugt keine neuen Ressourcen.

CREATE OR REPLACE FUNCTION logout(
    in_session_id uuid
)
RETURNS boolean AS $$
DECLARE
    v_exists boolean;
BEGIN
    -- Prüfen, ob die Session existiert
    SELECT EXISTS(
        SELECT 1 FROM sessions
        WHERE id = in_session_id
          AND revoked_at IS NULL
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN false;
    END IF;

    -- Session als beendet markieren
    UPDATE sessions
    SET revoked_at = now()
    WHERE id = in_session_id;

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC-Endpunkt für PostgREST
COMMENT ON FUNCTION logout(uuid) IS
'Logout-Aktion: beendet eine bestehende Session deterministisch und auditierbar.';

-- freeze_account.sql
-- Modul: accounts
-- Aktion: freeze_account
-- Beschreibung:
--   Diese Aktion friert deterministisch einen Account ein.
--   Bedingungen:
--     - Der Account darf nicht geschlossen sein.
--     - Der Account darf nicht bereits eingefroren sein.
--   Die Aktion verändert ausschließlich den Accountstatus.
--   Es werden keine Daten gelöscht.

CREATE OR REPLACE FUNCTION freeze_account(
    in_account_id uuid
)
RETURNS boolean AS $$
DECLARE
    v_status text;
BEGIN
    -- Aktuellen Status prüfen
    SELECT status INTO v_status
    FROM accounts
    WHERE id = in_account_id;

    IF v_status IS NULL THEN
        RAISE EXCEPTION 'account_not_found';
    END IF;

    IF v_status = 'closed' THEN
        RAISE EXCEPTION 'account_closed';
    END IF;

    IF v_status = 'frozen' THEN
        RETURN false;
    END IF;

    -- Account einfrieren
    UPDATE accounts
    SET status = 'frozen'
    WHERE id = in_account_id;

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC-Endpunkt für PostgREST
COMMENT ON FUNCTION freeze_account(uuid) IS
'Friert deterministisch einen Account ein, sofern er nicht geschlossen oder bereits eingefroren ist.';

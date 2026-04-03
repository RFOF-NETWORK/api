-- close_account.sql
-- Modul: accounts
-- Aktion: close_account
-- Beschreibung:
--   Diese Aktion schließt deterministisch einen Account.
--   Bedingungen:
--     - Der Account darf keinen offenen Saldo haben (Balance = 0).
--     - Der Account darf nicht bereits geschlossen sein.
--   Die Aktion verändert ausschließlich den Accountstatus.
--   Es werden keine Daten gelöscht.

CREATE OR REPLACE FUNCTION close_account(
    in_account_id uuid
)
RETURNS boolean AS $$
DECLARE
    v_balance numeric(30,10);
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
        RETURN false;
    END IF;

    -- Saldo prüfen
    SELECT balance INTO v_balance
    FROM account_balances
    WHERE account_id = in_account_id;

    IF v_balance IS NULL THEN
        RAISE EXCEPTION 'balance_not_found';
    END IF;

    IF v_balance <> 0 THEN
        RAISE EXCEPTION 'account_balance_not_zero';
    END IF;

    -- Account schließen
    UPDATE accounts
    SET status = 'closed'
    WHERE id = in_account_id;

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC-Endpunkt für PostgREST
COMMENT ON FUNCTION close_account(uuid) IS
'Schließt deterministisch einen Account, sofern der Saldo 0 ist.';

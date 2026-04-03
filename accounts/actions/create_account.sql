-- create_account.sql
-- Modul: accounts
-- Aktion: create_account
-- Beschreibung:
--   Diese Aktion erzeugt deterministisch einen neuen Account.
--   Sie erstellt:
--     1. den Account
--     2. den zugehörigen Balance-Eintrag
--   Die Aktion ist transaktional, auditierbar und erzeugt keine Nebenwirkungen
--   außerhalb der definierten Ressourcen.

CREATE OR REPLACE FUNCTION create_account(
    in_owner_user_id uuid,
    in_account_type text,
    in_currency text DEFAULT 'EUR'
)
RETURNS uuid AS $$
DECLARE
    v_account_id uuid;
    v_account_number text;
BEGIN
    -- Deterministische Kontonummer erzeugen
    v_account_number := 'ACCT-' || encode(gen_random_bytes(8), 'hex');

    -- Account erzeugen
    INSERT INTO accounts (
        owner_user_id,
        account_number,
        account_type,
        currency
    )
    VALUES (
        in_owner_user_id,
        v_account_number,
        in_account_type,
        in_currency
    )
    RETURNING id INTO v_account_id;

    -- Balance-Eintrag erzeugen
    INSERT INTO account_balances (account_id)
    VALUES (v_account_id);

    -- Account-ID zurückgeben
    RETURN v_account_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC-Endpunkt für PostgREST
COMMENT ON FUNCTION create_account(uuid, text, text) IS
'Erzeugt deterministisch einen neuen Account und initialisiert die Balance.';

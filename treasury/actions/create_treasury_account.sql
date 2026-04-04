-- create_treasury_account.sql
-- Modul: treasury
-- Aktion: create_treasury_account
-- Beschreibung:
--   Diese Aktion erzeugt deterministisch einen neuen Treasury-Account.
--   Der Treasury-Account referenziert einen globalen Account aus dem
--   Accounts-Modul und wird als hochprivilegiertes System-/Reservekonto
--   geführt. Die Aktion ist auditierbar, stabil und unveränderlich.

CREATE OR REPLACE FUNCTION treasury_create_treasury_account(
    in_account_id uuid,
    in_account_type text,
    in_currency currency_code,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_treasury_account_id uuid;
BEGIN
    ------------------------------------------------------------
    -- Validierung: Account existiert
    ------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1 FROM accounts WHERE id = in_account_id
    ) THEN
        RAISE EXCEPTION 'account_not_found';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Treasury-Account-Typ
    ------------------------------------------------------------
    IF in_account_type NOT IN ('reserve', 'liquidity', 'collateral', 'system') THEN
        RAISE EXCEPTION 'invalid_treasury_account_type';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Währung
    ------------------------------------------------------------
    IF in_currency IS NULL THEN
        RAISE EXCEPTION 'invalid_currency';
    END IF;

    ------------------------------------------------------------
    -- Treasury-Account erzeugen
    ------------------------------------------------------------
    INSERT INTO treasury_accounts (
        account_id,
        account_type,
        currency,
        metadata
    )
    VALUES (
        in_account_id,
        in_account_type,
        in_currency,
        in_metadata
    )
    RETURNING id INTO v_treasury_account_id;

    ------------------------------------------------------------
    -- Treasury-Position initialisieren
    ------------------------------------------------------------
    INSERT INTO treasury_positions (
        treasury_account_id,
        currency,
        balance,
        reserved_balance,
        metadata
    )
    VALUES (
        v_treasury_account_id,
        in_currency,
        0,
        0,
        in_metadata
    );

    ------------------------------------------------------------
    -- Treasury-Account-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_treasury_account_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION treasury_create_treasury_account(
    uuid, text, currency_code, jsonb
) IS
'Erzeugt deterministisch einen neuen Treasury-Account und initialisiert die zugehörige Treasury-Position.';

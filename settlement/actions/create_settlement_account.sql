-- create_settlement_account.sql
-- Modul: settlement
-- Aktion: create_settlement_account
-- Beschreibung:
--   Diese Aktion erzeugt deterministisch einen neuen Settlement-Account.
--   Settlement-Accounts sind finale Abrechnungs-Konten für Interbank-
--   Settlement, Finality und regulatorische Stabilität. Die Aktion ist
--   auditierbar, stabil und unveränderlich.

CREATE OR REPLACE FUNCTION settlement_create_settlement_account(
    in_account_type text,
    in_currency currency_code,
    in_treasury_account_id uuid DEFAULT NULL,
    in_liquidity_pool_id uuid DEFAULT NULL,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_account_id uuid;
BEGIN
    ------------------------------------------------------------
    -- Validierung: Account-Typ
    ------------------------------------------------------------
    IF in_account_type NOT IN ('nostro', 'vostro', 'internal', 'reserve', 'system') THEN
        RAISE EXCEPTION 'invalid_settlement_account_type';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Währung
    ------------------------------------------------------------
    IF in_currency IS NULL THEN
        RAISE EXCEPTION 'invalid_currency';
    END IF;

    ------------------------------------------------------------
    -- Validierung: Treasury-Account (falls angegeben)
    ------------------------------------------------------------
    IF in_treasury_account_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM treasury_accounts WHERE id = in_treasury_account_id
        ) THEN
            RAISE EXCEPTION 'treasury_account_not_found';
        END IF;
    END IF;

    ------------------------------------------------------------
    -- Validierung: Liquidity-Pool (falls angegeben)
    ------------------------------------------------------------
    IF in_liquidity_pool_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM liquidity_pools WHERE id = in_liquidity_pool_id
        ) THEN
            RAISE EXCEPTION 'liquidity_pool_not_found';
        END IF;
    END IF;

    ------------------------------------------------------------
    -- Settlement-Account erzeugen
    ------------------------------------------------------------
    INSERT INTO settlement_accounts (
        account_type,
        currency,
        treasury_account_id,
        liquidity_pool_id,
        metadata
    )
    VALUES (
        in_account_type,
        in_currency,
        in_treasury_account_id,
        in_liquidity_pool_id,
        in_metadata
    )
    RETURNING id INTO v_account_id;

    ------------------------------------------------------------
    -- Initiale Settlement-Position erzeugen
    ------------------------------------------------------------
    INSERT INTO settlement_positions (
        settlement_account_id,
        currency,
        balance,
        reserved_balance,
        metadata
    )
    VALUES (
        v_account_id,
        in_currency,
        0,
        0,
        in_metadata
    );

    ------------------------------------------------------------
    -- Account-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_account_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION settlement_create_settlement_account(
    text, currency_code, uuid, uuid, jsonb
) IS
'Erzeugt deterministisch einen neuen Settlement-Account und initialisiert die zugehörige Settlement-Position.';

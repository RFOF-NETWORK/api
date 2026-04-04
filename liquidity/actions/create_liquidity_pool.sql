-- create_liquidity_pool.sql
-- Modul: liquidity
-- Aktion: create_liquidity_pool
-- Beschreibung:
--   Diese Aktion erzeugt deterministisch einen neuen Liquidity-Pool.
--   Liquidity-Pools sind systemische Liquiditätsbehälter und können
--   optional mit Treasury-Accounts verknüpft sein. Die Aktion ist
--   auditierbar, stabil und unveränderlich.

CREATE OR REPLACE FUNCTION liquidity_create_liquidity_pool(
    in_pool_type text,
    in_currency currency_code,
    in_treasury_account_id uuid DEFAULT NULL,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_pool_id uuid;
BEGIN
    ------------------------------------------------------------
    -- Validierung: Pool-Typ
    ------------------------------------------------------------
    IF in_pool_type NOT IN ('intraday', 'reserve', 'collateral', 'settlement', 'system') THEN
        RAISE EXCEPTION 'invalid_liquidity_pool_type';
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
    -- Liquidity-Pool erzeugen
    ------------------------------------------------------------
    INSERT INTO liquidity_pools (
        pool_type,
        currency,
        treasury_account_id,
        metadata
    )
    VALUES (
        in_pool_type,
        in_currency,
        in_treasury_account_id,
        in_metadata
    )
    RETURNING id INTO v_pool_id;

    ------------------------------------------------------------
    -- Initiale Liquidity-Position erzeugen
    ------------------------------------------------------------
    INSERT INTO liquidity_positions (
        liquidity_pool_id,
        currency,
        balance,
        reserved_balance,
        metadata
    )
    VALUES (
        v_pool_id,
        in_currency,
        0,
        0,
        in_metadata
    );

    ------------------------------------------------------------
    -- Pool-ID zurückgeben
    ------------------------------------------------------------
    RETURN v_pool_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION liquidity_create_liquidity_pool(
    text, currency_code, uuid, jsonb
) IS
'Erzeugt deterministisch einen neuen Liquidity-Pool und initialisiert die zugehörige Liquidity-Position.';

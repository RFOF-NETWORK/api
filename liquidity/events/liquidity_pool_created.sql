-- liquidity_pool_created.sql
-- Modul: liquidity
-- Ereignis: liquidity_pool_created
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch die Erzeugung eines
--   Liquidity-Pools. Es ist unveränderlich, auditierbar und bildet
--   die Grundlage für regulatorische Nachweise, Intraday-Liquidität,
--   Treasury-Integration, Interbank-Settlement und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS liquidity_pool_created_events (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Liquidity-Pool
    liquidity_pool_id       uuid NOT NULL REFERENCES liquidity_pools(id) ON DELETE CASCADE,

    -- Pool-Parameter
    pool_type               text NOT NULL,
    currency                currency_code NOT NULL,

    -- Optionaler Treasury-Account
    treasury_account_id     uuid REFERENCES treasury_accounts(id) ON DELETE RESTRICT,

    -- Zeitliche Dimension
    created_at              timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Liquidity-Pool wurde erzeugt
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_liquidity_pool_created_event(
    in_liquidity_pool_id uuid,
    in_pool_type text,
    in_currency currency_code,
    in_treasury_account_id uuid DEFAULT NULL,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO liquidity_pool_created_events (
        liquidity_pool_id,
        pool_type,
        currency,
        treasury_account_id,
        metadata
    )
    VALUES (
        in_liquidity_pool_id,
        in_pool_type,
        in_currency,
        in_treasury_account_id,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_liquidity_pool_created_event(
    uuid, text, currency_code, uuid, jsonb
) IS
'Ereignis: dokumentiert deterministisch die Erzeugung eines Liquidity-Pools.';

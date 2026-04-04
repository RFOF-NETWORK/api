-- settlement_account_created.sql
-- Modul: settlement
-- Ereignis: settlement_account_created
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch die Erzeugung eines
--   Settlement-Accounts. Es ist unveränderlich, auditierbar und bildet
--   die Grundlage für regulatorische Nachweise, Interbank-Settlement,
--   Finality und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS settlement_account_created_events (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Settlement-Account
    settlement_account_id   uuid NOT NULL REFERENCES settlement_accounts(id) ON DELETE CASCADE,

    -- Account-Parameter
    account_type            text NOT NULL,
    currency                currency_code NOT NULL,

    -- Optionale Verknüpfungen
    treasury_account_id     uuid REFERENCES treasury_accounts(id) ON DELETE RESTRICT,
    liquidity_pool_id       uuid REFERENCES liquidity_pools(id) ON DELETE RESTRICT,

    -- Zeitliche Dimension
    created_at              timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Settlement-Account wurde erzeugt
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_settlement_account_created_event(
    in_settlement_account_id uuid,
    in_account_type text,
    in_currency currency_code,
    in_treasury_account_id uuid DEFAULT NULL,
    in_liquidity_pool_id uuid DEFAULT NULL,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO settlement_account_created_events (
        settlement_account_id,
        account_type,
        currency,
        treasury_account_id,
        liquidity_pool_id,
        metadata
    )
    VALUES (
        in_settlement_account_id,
        in_account_type,
        in_currency,
        in_treasury_account_id,
        in_liquidity_pool_id,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_settlement_account_created_event(
    uuid, text, currency_code, uuid, uuid, jsonb
) IS
'Ereignis: dokumentiert deterministisch die Erzeugung eines Settlement-Accounts.';

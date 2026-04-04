-- settlement_positions_reconciled.sql
-- Modul: settlement
-- Ereignis: settlement_positions_reconciled
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch die Rekonsolidierung
--   einer Settlement-Position. Es ist unveränderlich, auditierbar und bildet
--   die Grundlage für regulatorische Nachweise, Interbank-Settlement,
--   Finality und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS settlement_positions_reconciled_events (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Settlement-Account
    settlement_account_id   uuid NOT NULL REFERENCES settlement_accounts(id) ON DELETE RESTRICT,

    -- Verknüpfung zur neuen Position
    settlement_position_id  uuid NOT NULL REFERENCES settlement_positions(id) ON DELETE CASCADE,

    -- Währung
    currency                currency_code NOT NULL,

    -- Aggregierte Werte
    balance                 numeric(30,10) NOT NULL,
    reserved_balance        numeric(30,10) NOT NULL,
    available_balance       numeric(30,10) NOT NULL,

    -- Zeitliche Dimension
    reconciled_at           timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Settlement-Position wurde rekonsolidiert
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_settlement_positions_reconciled_event(
    in_settlement_account_id uuid,
    in_settlement_position_id uuid,
    in_currency currency_code,
    in_balance numeric(30,10),
    in_reserved_balance numeric(30,10),
    in_available_balance numeric(30,10),
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO settlement_positions_reconciled_events (
        settlement_account_id,
        settlement_position_id,
        currency,
        balance,
        reserved_balance,
        available_balance,
        metadata
    )
    VALUES (
        in_settlement_account_id,
        in_settlement_position_id,
        in_currency,
        in_balance,
        in_reserved_balance,
        in_available_balance,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_settlement_positions_reconciled_event(
    uuid, uuid, currency_code, numeric, numeric, numeric, jsonb
) IS
'Ereignis: dokumentiert deterministisch die Rekonsolidierung einer Settlement-Position.';

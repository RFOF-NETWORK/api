-- settlement_flow_recorded.sql
-- Modul: settlement
-- Ereignis: settlement_flow_recorded
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch die Erfassung eines
--   Settlement-Flows (credit/debit). Es ist unveränderlich, auditierbar
--   und bildet die Grundlage für regulatorische Nachweise,
--   Interbank-Settlement, Finality und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS settlement_flow_recorded_events (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Settlement-Account
    settlement_account_id   uuid NOT NULL REFERENCES settlement_accounts(id) ON DELETE RESTRICT,

    -- Verknüpfung zum Flow
    settlement_flow_id      uuid NOT NULL REFERENCES settlement_flows(id) ON DELETE CASCADE,

    -- Bewegungsrichtung
    direction               text NOT NULL,

    -- Betrag
    amount                  numeric(30,10) NOT NULL,
    currency                currency_code NOT NULL,

    -- Zeitliche Dimension
    occurred_at             timestamptz NOT NULL,

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Settlement-Flow wurde erfasst
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_settlement_flow_recorded_event(
    in_settlement_account_id uuid,
    in_settlement_flow_id uuid,
    in_direction text,
    in_amount numeric(30,10),
    in_currency currency_code,
    in_occurred_at timestamptz,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO settlement_flow_recorded_events (
        settlement_account_id,
        settlement_flow_id,
        direction,
        amount,
        currency,
        occurred_at,
        metadata
    )
    VALUES (
        in_settlement_account_id,
        in_settlement_flow_id,
        in_direction,
        in_amount,
        in_currency,
        in_occurred_at,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_settlement_flow_recorded_event(
    uuid, uuid, text, numeric, currency_code, timestamptz, jsonb
) IS
'Ereignis: dokumentiert deterministisch die Erfassung eines Settlement-Flows.';

-- item_added.sql
-- Modul: settlement
-- Ereignis: item_added
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch das Hinzufügen eines
--   Settlement-Items zu einem offenen Settlement-Batch. Es ist
--   unveränderlich, auditierbar und bildet die Grundlage für regulatorische
--   Nachweise, Zahlungsabwicklung, Netting-Finalisierung und
--   RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS settlement_item_added_events (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Settlement-Batch
    batch_id            uuid NOT NULL REFERENCES settlement_batches(id) ON DELETE CASCADE,

    -- Verknüpfung zum Settlement-Item
    settlement_item_id  uuid NOT NULL REFERENCES settlement_items(id) ON DELETE CASCADE,

    -- Referenziertes Clearing-Result
    clearing_result_id  uuid NOT NULL REFERENCES clearing_results(id) ON DELETE RESTRICT,

    -- Operativer Account
    account_id          uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Buchungsdaten
    total_debit         numeric(30,10) NOT NULL,
    total_credit        numeric(30,10) NOT NULL,
    net_amount          numeric(30,10) NOT NULL,
    currency            currency_code NOT NULL,

    -- Zeitliche Dimension
    occurred_at         timestamptz NOT NULL DEFAULT now(),

    -- Metadaten
    metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Settlement-Item wurde hinzugefügt
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_settlement_item_added_event(
    in_batch_id uuid,
    in_settlement_item_id uuid,
    in_clearing_result_id uuid,
    in_account_id uuid,
    in_total_debit numeric(30,10),
    in_total_credit numeric(30,10),
    in_net_amount numeric(30,10),
    in_currency currency_code,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO settlement_item_added_events (
        batch_id,
        settlement_item_id,
        clearing_result_id,
        account_id,
        total_debit,
        total_credit,
        net_amount,
        currency,
        metadata
    )
    VALUES (
        in_batch_id,
        in_settlement_item_id,
        in_clearing_result_id,
        in_account_id,
        in_total_debit,
        in_total_credit,
        in_net_amount,
        in_currency,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_settlement_item_added_event(
    uuid, uuid, uuid, uuid, numeric, numeric, numeric, currency_code, jsonb
) IS
'Ereignis: dokumentiert deterministisch das Hinzufügen eines Settlement-Items.';

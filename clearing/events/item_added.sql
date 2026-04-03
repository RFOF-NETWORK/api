-- item_added.sql
-- Modul: clearing
-- Ereignis: item_added
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch das Hinzufügen eines
--   Clearing-Items zu einem offenen Batch. Es ist unveränderlich,
--   auditierbar und bildet die Grundlage für regulatorische Nachweise,
--   Netting-Analysen, Settlement-Pipelines und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS clearing_item_added_events (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Batch
    batch_id            uuid NOT NULL REFERENCES clearing_batches(id) ON DELETE CASCADE,

    -- Verknüpfung zum Clearing-Item
    clearing_item_id    uuid NOT NULL REFERENCES clearing_items(id) ON DELETE CASCADE,

    -- Ledger-Eintrag
    ledger_entry_id     uuid NOT NULL REFERENCES ledger_entries(id) ON DELETE RESTRICT,

    -- Operativer Account
    account_id          uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Buchungsdaten
    direction           text NOT NULL,
    amount              numeric(30,10) NOT NULL,
    currency            currency_code NOT NULL,

    -- Zeitliche Dimension
    occurred_at         timestamptz NOT NULL DEFAULT now(),

    -- Metadaten
    metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Clearing-Item wurde hinzugefügt
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_clearing_item_added_event(
    in_batch_id uuid,
    in_clearing_item_id uuid,
    in_ledger_entry_id uuid,
    in_account_id uuid,
    in_direction text,
    in_amount numeric(30,10),
    in_currency currency_code,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO clearing_item_added_events (
        batch_id,
        clearing_item_id,
        ledger_entry_id,
        account_id,
        direction,
        amount,
        currency,
        metadata
    )
    VALUES (
        in_batch_id,
        in_clearing_item_id,
        in_ledger_entry_id,
        in_account_id,
        in_direction,
        in_amount,
        in_currency,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_clearing_item_added_event(
    uuid, uuid, uuid, uuid, text, numeric, currency_code, jsonb
) IS
'Ereignis: dokumentiert deterministisch das Hinzufügen eines Clearing-Items.';

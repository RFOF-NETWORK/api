-- transfer_posted.sql
-- Modul: ledger
-- Ereignis: transfer_posted
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch jede Übertragung
--   zwischen zwei Accounts. Es ist unveränderlich, auditierbar und
--   bildet die Grundlage für Clearing, regulatorische Nachweise,
--   Fraud-Analysen und RFOF-GOLDEN-Chain-Verkettung.
--   Ereignisse werden niemals aktualisiert oder gelöscht.

CREATE TABLE IF NOT EXISTS ledger_transfer_posted_events (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zu den Ledger-Einträgen
    debit_entry_id          uuid NOT NULL REFERENCES ledger_entries(id) ON DELETE CASCADE,
    credit_entry_id         uuid NOT NULL REFERENCES ledger_entries(id) ON DELETE CASCADE,

    -- Operative Accounts
    source_account_id       uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,
    target_account_id       uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Buchungsdaten
    amount                  numeric(30,10) NOT NULL,
    currency                currency_code NOT NULL,

    -- Zeitliche Dimension
    occurred_at             timestamptz NOT NULL DEFAULT now(),

    -- Metadaten
    reference_id            uuid DEFAULT NULL,
    reference_type          text DEFAULT NULL,
    description             text DEFAULT NULL,
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Transfer wurde gebucht
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_ledger_transfer_posted_event(
    in_debit_entry_id uuid,
    in_credit_entry_id uuid,
    in_source_account_id uuid,
    in_target_account_id uuid,
    in_amount numeric(30,10),
    in_currency currency_code,
    in_reference_id uuid DEFAULT NULL,
    in_reference_type text DEFAULT NULL,
    in_description text DEFAULT NULL,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO ledger_transfer_posted_events (
        debit_entry_id,
        credit_entry_id,
        source_account_id,
        target_account_id,
        amount,
        currency,
        reference_id,
        reference_type,
        description,
        metadata
    )
    VALUES (
        in_debit_entry_id,
        in_credit_entry_id,
        in_source_account_id,
        in_target_account_id,
        in_amount,
        in_currency,
        in_reference_id,
        in_reference_type,
        in_description,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_ledger_transfer_posted_event(
    uuid, uuid, uuid, uuid, numeric, currency_code, uuid, text, text, jsonb
) IS
'Ereignis: dokumentiert deterministisch eine Übertragung zwischen zwei Accounts.';

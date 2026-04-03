-- entry_posted.sql
-- Modul: ledger
-- Ereignis: entry_posted
-- Beschreibung:
--   Dieses Ereignis dokumentiert jeden gebuchten Ledger-Eintrag.
--   Es ist unveränderlich, auditierbar und bildet die Grundlage für
--   Journal-Rekonstruktion, regulatorische Nachweise, Clearing,
--   Fraud-Analysen und RFOF-GOLDEN-Chain-Verkettung.
--   Ereignisse werden niemals aktualisiert oder gelöscht.

CREATE TABLE IF NOT EXISTS ledger_entry_posted_events (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Ledger-Eintrag
    ledger_entry_id     uuid NOT NULL REFERENCES ledger_entries(id) ON DELETE CASCADE,

    -- Operative Account-Informationen
    account_id          uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Buchungsdaten
    direction           text NOT NULL,
    amount              numeric(30,10) NOT NULL,
    currency            currency_code NOT NULL,

    -- Zeitliche Dimension
    occurred_at         timestamptz NOT NULL DEFAULT now(),

    -- Metadaten
    reference_id        uuid DEFAULT NULL,
    reference_type      text DEFAULT NULL,
    description         text DEFAULT NULL,
    metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Ledger-Eintrag wurde gebucht
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_ledger_entry_posted_event(
    in_ledger_entry_id uuid,
    in_account_id uuid,
    in_direction text,
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
    INSERT INTO ledger_entry_posted_events (
        ledger_entry_id,
        account_id,
        direction,
        amount,
        currency,
        reference_id,
        reference_type,
        description,
        metadata
    )
    VALUES (
        in_ledger_entry_id,
        in_account_id,
        in_direction,
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

COMMENT ON FUNCTION emit_ledger_entry_posted_event(
    uuid, uuid, text, numeric, currency_code, uuid, text, text, jsonb
) IS
'Ereignis: dokumentiert das Buchen eines Ledger-Eintrags unveränderlich.';

-- entry_reversed.sql
-- Modul: ledger
-- Ereignis: entry_reversed
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch die Umkehrung eines
--   bestehenden Ledger-Eintrags. Es ist unveränderlich, auditierbar und
--   bildet die Grundlage für regulatorische Nachweise, Clearing-Korrekturen,
--   Fraud-Analysen und RFOF-GOLDEN-Chain-Rekonstruktion.
--   Ereignisse werden niemals aktualisiert oder gelöscht.

CREATE TABLE IF NOT EXISTS ledger_entry_reversed_events (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Originaleintrag
    original_entry_id       uuid NOT NULL REFERENCES ledger_entries(id) ON DELETE CASCADE,

    -- Verknüpfung zur Gegenbuchung
    reversal_entry_id       uuid NOT NULL REFERENCES ledger_entries(id) ON DELETE CASCADE,

    -- Operativer Account
    account_id              uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Buchungsdaten
    amount                  numeric(30,10) NOT NULL,
    original_direction      text NOT NULL,
    reversal_direction      text NOT NULL,

    -- Zeitliche Dimension
    occurred_at             timestamptz NOT NULL DEFAULT now(),

    -- Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Ledger-Eintrag wurde umgekehrt
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_ledger_entry_reversed_event(
    in_original_entry_id uuid,
    in_reversal_entry_id uuid,
    in_account_id uuid,
    in_amount numeric(30,10),
    in_original_direction text,
    in_reversal_direction text,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO ledger_entry_reversed_events (
        original_entry_id,
        reversal_entry_id,
        account_id,
        amount,
        original_direction,
        reversal_direction,
        metadata
    )
    VALUES (
        in_original_entry_id,
        in_reversal_entry_id,
        in_account_id,
        in_amount,
        in_original_direction,
        in_reversal_direction,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_ledger_entry_reversed_event(
    uuid, uuid, uuid, numeric, text, text, jsonb
) IS
'Ereignis: dokumentiert deterministisch die Umkehrung eines Ledger-Eintrags.';

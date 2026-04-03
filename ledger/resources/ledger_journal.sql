-- ledger_journal.sql
-- Modul: ledger
-- Ressource: ledger_journal
-- Beschreibung:
--   Das Ledger-Journal ist die chronologische, unveränderliche Sicht
--   auf alle Ledger-Einträge. Es dient als Hauptbuch (General Ledger)
--   und bildet die Grundlage für Bilanz, GuV, regulatorische Reports,
--   Clearing-Prozesse und RFOF-GOLDEN-Rekonstruktion.
--   Das Journal ist eine reine, materialisierte Sicht ohne Updates
--   und ohne Löschungen.

CREATE TABLE IF NOT EXISTS ledger_journal (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Ledger-Eintrag
    ledger_entry_id     uuid NOT NULL UNIQUE REFERENCES ledger_entries(id) ON DELETE RESTRICT,

    -- Operative Account-Informationen
    account_id          uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,
    ledger_account_id   uuid NOT NULL REFERENCES ledger_accounts(id) ON DELETE RESTRICT,

    -- Buchungsdaten
    direction           text NOT NULL,
    amount              numeric(30,10) NOT NULL,
    currency            currency_code NOT NULL,

    -- Zeitliche Dimension
    occurred_at         timestamptz NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),

    -- Klassifikation
    classification      account_type_class NOT NULL,
    category            account_category NOT NULL,

    -- Metadaten
    reference_id        uuid DEFAULT NULL,
    reference_type      text DEFAULT NULL,
    description         text DEFAULT NULL,
    metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Journal ist unveränderlich
------------------------------------------------------------
ALTER TABLE ledger_journal ENABLE ROW LEVEL SECURITY;

CREATE POLICY ledger_journal_select ON ledger_journal
    FOR SELECT
    USING (true);

CREATE POLICY ledger_journal_insert ON ledger_journal
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY ledger_journal_update ON ledger_journal
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY ledger_journal_delete ON ledger_journal
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

-- Richtung validieren
ALTER TABLE ledger_journal
    ADD CONSTRAINT ledger_journal_direction_check
    CHECK (direction IN ('debit', 'credit'));

-- Referenzfelder müssen konsistent sein
ALTER TABLE ledger_journal
    ADD CONSTRAINT ledger_journal_reference_consistency
    CHECK (
        (reference_id IS NULL AND reference_type IS NULL)
        OR
        (reference_id IS NOT NULL AND reference_type IS NOT NULL)
    );

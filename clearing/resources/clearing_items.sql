-- clearing_items.sql
-- Modul: clearing
-- Ressource: clearing_items
-- Beschreibung:
--   Diese Ressource definiert Clearing-Items, also die atomaren
--   Verarbeitungseinheiten innerhalb eines Clearing-Batches.
--   Jedes Item referenziert genau einen Ledger-Eintrag.
--   Items sind unveränderlich und können nur in offenen Batches
--   existieren. Sie bilden die Grundlage für Netting, Settlement,
--   Intraday- und End-of-Day-Clearing sowie RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS clearing_items (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Zugehöriger Batch
    batch_id                uuid NOT NULL REFERENCES clearing_batches(id) ON DELETE CASCADE,

    -- Ledger-Eintrag, der gecleart werden soll
    ledger_entry_id         uuid NOT NULL UNIQUE REFERENCES ledger_entries(id) ON DELETE RESTRICT,

    -- Operativer Account
    account_id              uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Buchungsdaten
    direction               text NOT NULL,
    amount                  numeric(30,10) NOT NULL,
    currency                currency_code NOT NULL,

    -- Zeitliche Dimension
    created_at              timestamptz NOT NULL DEFAULT now(),

    -- Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Clearing-Items sind unveränderlich
------------------------------------------------------------
ALTER TABLE clearing_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY clearing_items_select ON clearing_items
    FOR SELECT
    USING (true);

CREATE POLICY clearing_items_insert ON clearing_items
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY clearing_items_update ON clearing_items
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY clearing_items_delete ON clearing_items
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

-- Richtung validieren
ALTER TABLE clearing_items
    ADD CONSTRAINT clearing_items_direction_check
    CHECK (direction IN ('debit', 'credit'));

-- Batch muss offen sein
ALTER TABLE clearing_items
    ADD CONSTRAINT clearing_items_batch_open_check
    CHECK (
        batch_id IN (
            SELECT id FROM clearing_batches WHERE status = 'open'
        )
    );

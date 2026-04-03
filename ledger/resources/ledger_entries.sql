-- ledger_entries.sql
-- Modul: ledger
-- Ressource: ledger_entries
-- Beschreibung:
--   Diese Datei definiert die zentrale Ledger-Ressource.
--   Ledger-Einträge sind unveränderlich, auditierbar und bilden die
--   Grundlage für alle finanziellen Operationen, regulatorische
--   Nachweise, Bilanzierung, Journalführung und Clearing.
--   Es gibt keine Updates und keine Löschungen.

CREATE TABLE IF NOT EXISTS ledger_entries (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Buchungsinformationen
    account_id          uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,
    direction           text NOT NULL, -- 'debit' oder 'credit'
    amount              numeric(30,10) NOT NULL CHECK (amount > 0),

    -- Buchungsmetadaten
    reference_id        uuid DEFAULT NULL,
    reference_type      text DEFAULT NULL,
    description         text DEFAULT NULL,

    -- Auditfelder
    occurred_at         timestamptz NOT NULL DEFAULT now(),
    created_at          timestamptz NOT NULL DEFAULT now(),
    metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ledger-Einträge sind unveränderlich
------------------------------------------------------------
ALTER TABLE ledger_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY ledger_entries_select ON ledger_entries
    FOR SELECT
    USING (true);

CREATE POLICY ledger_entries_insert ON ledger_entries
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY ledger_entries_update ON ledger_entries
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY ledger_entries_delete ON ledger_entries
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Zusätzliche Integritätsregeln
------------------------------------------------------------

-- Richtung validieren
ALTER TABLE ledger_entries
    ADD CONSTRAINT ledger_entries_direction_check
    CHECK (direction IN ('debit', 'credit'));

-- Referenzfelder müssen konsistent sein
ALTER TABLE ledger_entries
    ADD CONSTRAINT ledger_entries_reference_consistency
    CHECK (
        (reference_id IS NULL AND reference_type IS NULL)
        OR
        (reference_id IS NOT NULL AND reference_type IS NOT NULL)
    );

-- clearing_batches.sql
-- Modul: clearing
-- Ressource: clearing_batches
-- Beschreibung:
--   Diese Ressource definiert Clearing-Batches, also abgeschlossene
--   Clearing-Läufe. Jeder Batch ist unveränderlich, auditierbar und
--   bildet die Grundlage für Settlement, Netting, Intraday- und
--   End-of-Day-Clearing sowie RFOF-GOLDEN-Chain-Rekonstruktion.

CREATE TABLE IF NOT EXISTS clearing_batches (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Batch-Identifikation
    batch_number            bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
    batch_type              text NOT NULL, -- 'intraday', 'end_of_day', 'manual', 'system'
    status                  text NOT NULL, -- 'open', 'closed'

    -- Zeitliche Dimension
    opened_at               timestamptz NOT NULL DEFAULT now(),
    closed_at               timestamptz DEFAULT NULL,

    -- Statistische Kennzahlen
    entry_count             bigint NOT NULL DEFAULT 0,
    total_amount            numeric(30,10) NOT NULL DEFAULT 0,

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Clearing-Batches sind unveränderlich nach Schließung
------------------------------------------------------------
ALTER TABLE clearing_batches ENABLE ROW LEVEL SECURITY;

CREATE POLICY clearing_batches_select ON clearing_batches
    FOR SELECT
    USING (true);

CREATE POLICY clearing_batches_insert ON clearing_batches
    FOR INSERT
    WITH CHECK (true);

-- Updates nur erlaubt, solange Batch offen ist
CREATE POLICY clearing_batches_update ON clearing_batches
    FOR UPDATE
    USING (status = 'open')
    WITH CHECK (status = 'open');

-- Keine Löschungen
CREATE POLICY clearing_batches_delete ON clearing_batches
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE clearing_batches
    ADD CONSTRAINT clearing_batches_type_check
    CHECK (batch_type IN ('intraday', 'end_of_day', 'manual', 'system'));

ALTER TABLE clearing_batches
    ADD CONSTRAINT clearing_batches_status_check
    CHECK (status IN ('open', 'closed'));

ALTER TABLE clearing_batches
    ADD CONSTRAINT clearing_batches_closed_at_consistency
    CHECK (
        (status = 'open' AND closed_at IS NULL)
        OR
        (status = 'closed' AND closed_at IS NOT NULL)
    );

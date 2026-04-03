-- settlement_batches.sql
-- Modul: settlement
-- Ressource: settlement_batches
-- Beschreibung:
--   Diese Ressource definiert Settlement-Batches, also abgeschlossene
--   Settlement-Läufe. Jeder Batch ist unveränderlich, auditierbar und
--   bildet die Grundlage für Netting-Finalisierung, Zahlungsabwicklung,
--   regulatorische Nachweise und RFOF-GOLDEN-Chain-Rekonstruktion.

CREATE TABLE IF NOT EXISTS settlement_batches (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Batch-Identifikation
    batch_number            bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
    batch_type              text NOT NULL, -- 'intraday', 'end_of_day', 'manual', 'system'
    status                  text NOT NULL, -- 'open', 'closed'

    -- Zeitliche Dimension
    opened_at               timestamptz NOT NULL DEFAULT now(),
    closed_at               timestamptz DEFAULT NULL,

    -- Statistische Kennzahlen
    account_count           bigint NOT NULL DEFAULT 0,
    total_net_amount        numeric(30,10) NOT NULL DEFAULT 0,

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Settlement-Batches sind unveränderlich nach Schließung
------------------------------------------------------------
ALTER TABLE settlement_batches ENABLE ROW LEVEL SECURITY;

CREATE POLICY settlement_batches_select ON settlement_batches
    FOR SELECT
    USING (true);

CREATE POLICY settlement_batches_insert ON settlement_batches
    FOR INSERT
    WITH CHECK (true);

-- Updates nur erlaubt, solange Batch offen ist
CREATE POLICY settlement_batches_update ON settlement_batches
    FOR UPDATE
    USING (status = 'open')
    WITH CHECK (status = 'open');

-- Keine Löschungen
CREATE POLICY settlement_batches_delete ON settlement_batches
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE settlement_batches
    ADD CONSTRAINT settlement_batches_type_check
    CHECK (batch_type IN ('intraday', 'end_of_day', 'manual', 'system'));

ALTER TABLE settlement_batches
    ADD CONSTRAINT settlement_batches_status_check
    CHECK (status IN ('open', 'closed'));

ALTER TABLE settlement_batches
    ADD CONSTRAINT settlement_batches_closed_at_consistency
    CHECK (
        (status = 'open' AND closed_at IS NULL)
        OR
        (status = 'closed' AND closed_at IS NOT NULL)
    );

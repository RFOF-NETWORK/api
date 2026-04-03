-- clearing_results.sql
-- Modul: clearing
-- Ressource: clearing_results
-- Beschreibung:
--   Diese Ressource definiert die finalen Ergebnisse eines Clearing-Batches.
--   Ergebnisse sind unveränderlich, auditierbar und bilden die Grundlage für:
--     - Netting
--     - Settlement
--     - Intraday- und End-of-Day-Clearing
--     - RFOF-GOLDEN-Chain-Rekonstruktion
--   Pro Account existiert genau ein Ergebnis pro Batch.

CREATE TABLE IF NOT EXISTS clearing_results (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Zugehöriger Batch
    batch_id                uuid NOT NULL REFERENCES clearing_batches(id) ON DELETE CASCADE,

    -- Account, für den das Ergebnis berechnet wurde
    account_id              uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Aggregierte Werte
    total_debit             numeric(30,10) NOT NULL DEFAULT 0,
    total_credit            numeric(30,10) NOT NULL DEFAULT 0,
    net_amount              numeric(30,10) NOT NULL DEFAULT 0, -- credit - debit
    currency                currency_code NOT NULL,

    -- Zeitliche Dimension
    created_at              timestamptz NOT NULL DEFAULT now(),

    -- Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Clearing-Results sind unveränderlich
------------------------------------------------------------
ALTER TABLE clearing_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY clearing_results_select ON clearing_results
    FOR SELECT
    USING (true);

CREATE POLICY clearing_results_insert ON clearing_results
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY clearing_results_update ON clearing_results
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY clearing_results_delete ON clearing_results
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

-- Pro Batch und Account nur ein Ergebnis
ALTER TABLE clearing_results
    ADD CONSTRAINT clearing_results_unique_per_batch_account
    UNIQUE (batch_id, account_id);

-- Netting-Konsistenz
ALTER TABLE clearing_results
    ADD CONSTRAINT clearing_results_net_amount_consistency
    CHECK (net_amount = total_credit - total_debit);

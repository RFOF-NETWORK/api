-- settlement_results.sql
-- Modul: settlement
-- Ressource: settlement_results
-- Beschreibung:
--   Diese Ressource definiert die finalen Settlement-Ergebnisse eines
--   Settlement-Batches. Ergebnisse sind unveränderlich, auditierbar und
--   bilden die Grundlage für:
--     - Zahlungsabwicklung
--     - Netting-Finalisierung
--     - Interbank-Settlement
--     - RFOF-GOLDEN-Chain-Rekonstruktion
--   Pro Account existiert genau ein Ergebnis pro Batch.

CREATE TABLE IF NOT EXISTS settlement_results (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Zugehöriger Settlement-Batch
    batch_id                uuid NOT NULL REFERENCES settlement_batches(id) ON DELETE CASCADE,

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
-- Settlement-Results sind unveränderlich
------------------------------------------------------------
ALTER TABLE settlement_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY settlement_results_select ON settlement_results
    FOR SELECT
    USING (true);

CREATE POLICY settlement_results_insert ON settlement_results
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY settlement_results_update ON settlement_results
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY settlement_results_delete ON settlement_results
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

-- Pro Batch und Account nur ein Ergebnis
ALTER TABLE settlement_results
    ADD CONSTRAINT settlement_results_unique_per_batch_account
    UNIQUE (batch_id, account_id);

-- Netting-Konsistenz
ALTER TABLE settlement_results
    ADD CONSTRAINT settlement_results_net_amount_consistency
    CHECK (net_amount = total_credit - total_debit);

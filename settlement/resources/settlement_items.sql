-- settlement_items.sql
-- Modul: settlement
-- Ressource: settlement_items
-- Beschreibung:
--   Diese Ressource definiert Settlement-Items, also die atomaren
--   Verarbeitungseinheiten innerhalb eines Settlement-Batches.
--   Jedes Item referenziert genau ein Clearing-Result.
--   Items sind unveränderlich und können nur in offenen Batches
--   existieren. Sie bilden die Grundlage für Zahlungsabwicklung,
--   Netting-Finalisierung und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS settlement_items (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Zugehöriger Settlement-Batch
    batch_id                uuid NOT NULL REFERENCES settlement_batches(id) ON DELETE CASCADE,

    -- Referenziertes Clearing-Result
    clearing_result_id      uuid NOT NULL UNIQUE REFERENCES clearing_results(id) ON DELETE RESTRICT,

    -- Account
    account_id              uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Aggregierte Werte aus Clearing
    total_debit             numeric(30,10) NOT NULL,
    total_credit            numeric(30,10) NOT NULL,
    net_amount              numeric(30,10) NOT NULL,
    currency                currency_code NOT NULL,

    -- Zeitliche Dimension
    created_at              timestamptz NOT NULL DEFAULT now(),

    -- Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Settlement-Items sind unveränderlich
------------------------------------------------------------
ALTER TABLE settlement_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY settlement_items_select ON settlement_items
    FOR SELECT
    USING (true);

CREATE POLICY settlement_items_insert ON settlement_items
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY settlement_items_update ON settlement_items
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY settlement_items_delete ON settlement_items
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

-- Batch muss offen sein
ALTER TABLE settlement_items
    ADD CONSTRAINT settlement_items_batch_open_check
    CHECK (
        batch_id IN (
            SELECT id FROM settlement_batches WHERE status = 'open'
        )
    );

-- Netting-Konsistenz
ALTER TABLE settlement_items
    ADD CONSTRAINT settlement_items_net_amount_consistency
    CHECK (net_amount = total_credit - total_debit);

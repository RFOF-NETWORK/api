-- settlement_flows.sql
-- Modul: settlement
-- Ressource: settlement_flows
-- Beschreibung:
--   Settlement-Flows sind atomare, unveränderliche Abrechnungsbewegungen
--   eines Settlement-Accounts. Sie bilden die Grundlage für:
--     - Endgültigkeit (Finality)
--     - Interbank-Settlement
--     - regulatorische Nachweise
--     - Treasury-Integration
--     - Liquidity-Integration
--   Settlement-Flows sind streng auditierbar und unveränderlich.

CREATE TABLE IF NOT EXISTS settlement_flows (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Settlement-Account
    settlement_account_id   uuid NOT NULL REFERENCES settlement_accounts(id) ON DELETE RESTRICT,

    -- Bewegungsrichtung
    direction               text NOT NULL, -- 'credit' | 'debit'

    -- Beträge
    amount                  numeric(30,10) NOT NULL,
    currency                currency_code NOT NULL,

    -- Zeitliche Dimension
    occurred_at             timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Settlement-Flows sind unveränderlich (keine Updates)
------------------------------------------------------------
ALTER TABLE settlement_flows ENABLE ROW LEVEL SECURITY;

CREATE POLICY settlement_flows_select ON settlement_flows
    FOR SELECT
    USING (true);

CREATE POLICY settlement_flows_insert ON settlement_flows
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY settlement_flows_update ON settlement_flows
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY settlement_flows_delete ON settlement_flows
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE settlement_flows
    ADD CONSTRAINT settlement_flows_direction_check
    CHECK (direction IN ('credit', 'debit'));

ALTER TABLE settlement_flows
    ADD CONSTRAINT settlement_flows_amount_positive
    CHECK (amount > 0);

ALTER TABLE settlement_flows
    ADD CONSTRAINT settlement_flows_currency_consistency
    CHECK (currency IS NOT NULL);

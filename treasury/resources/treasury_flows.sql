-- treasury_flows.sql
-- Modul: treasury
-- Ressource: treasury_flows
-- Beschreibung:
--   Diese Ressource definiert Treasury-Flows, also atomare, unveränderliche
--   Liquiditäts- und Reservebewegungen. Sie bilden die Grundlage für:
--     - Liquiditätssteuerung
--     - Reservehaltung
--     - Collateral-Management
--     - Interbank-Settlement
--     - RFOF-GOLDEN-Chain-Prozesse
--   Treasury-Flows sind streng auditierbar und unveränderlich.

CREATE TABLE IF NOT EXISTS treasury_flows (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Treasury-Account
    treasury_account_id     uuid NOT NULL REFERENCES treasury_accounts(id) ON DELETE RESTRICT,

    -- Bewegungsrichtung
    direction               text NOT NULL, -- 'inflow' | 'outflow'

    -- Beträge
    amount                  numeric(30,10) NOT NULL,
    currency                currency_code NOT NULL,

    -- Zeitliche Dimension
    occurred_at             timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Treasury-Flows sind unveränderlich (keine Updates)
------------------------------------------------------------
ALTER TABLE treasury_flows ENABLE ROW LEVEL SECURITY;

CREATE POLICY treasury_flows_select ON treasury_flows
    FOR SELECT
    USING (true);

CREATE POLICY treasury_flows_insert ON treasury_flows
    FOR INSERT
    WITH CHECK (true);

-- Keine Updates
CREATE POLICY treasury_flows_update ON treasury_flows
    FOR UPDATE
    USING (false)
    WITH CHECK (false);

-- Keine Löschungen
CREATE POLICY treasury_flows_delete ON treasury_flows
    FOR DELETE
    USING (false);

------------------------------------------------------------
-- Integritätsregeln
------------------------------------------------------------

ALTER TABLE treasury_flows
    ADD CONSTRAINT treasury_flows_direction_check
    CHECK (direction IN ('inflow', 'outflow'));

ALTER TABLE treasury_flows
    ADD CONSTRAINT treasury_flows_amount_positive
    CHECK (amount > 0);

ALTER TABLE treasury_flows
    ADD CONSTRAINT treasury_flows_currency_consistency
    CHECK (currency IS NOT NULL);

-- api/compliance/resources/compliance.sql
-- Modul: COMPLIANCE
-- Zweck: Stammtabelle für Compliance-Objekte (Policies, Flags, Checks)

CREATE TABLE IF NOT EXISTS compliance (
    compliance_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    compliance_type    TEXT NOT NULL,          -- z.B. AML, KYC, RISK, FRAUD
    compliance_status  TEXT NOT NULL,          -- ACTIVE, BLOCKED, REVIEW, FAILED
    entity_type        TEXT NOT NULL,          -- ACCOUNT, DOCUMENT, IDENTITY, LEDGER
    entity_id          UUID NOT NULL,          -- Referenz auf Zielobjekt
    metadata           JSONB DEFAULT '{}'::jsonb,
    created_at         TIMESTAMP NOT NULL DEFAULT now(),
    updated_at         TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE compliance IS
'Zentrale Compliance-Stammtabelle für alle Module (AML, KYC, Risk, Fraud).';

CREATE INDEX IF NOT EXISTS idx_compliance_entity
    ON compliance(entity_type, entity_id);

CREATE INDEX IF NOT EXISTS idx_compliance_status
    ON compliance(compliance_status);

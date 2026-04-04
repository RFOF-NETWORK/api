-- federation.sql
-- Core-Definition der föderierten Knoten, Domains und Trust-Level

CREATE TABLE IF NOT EXISTS federation (
    federation_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    node_id            UUID NOT NULL,
    node_type          TEXT NOT NULL,          -- z.B. BANK, PSP, CLEARING, LEDGER-NODE
    domain             TEXT NOT NULL,          -- z.B. eu.gpcb.net
    trust_level        INTEGER NOT NULL,       -- 0–100
    metadata           JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- api/compliance/events/compliance_event_index.sql
-- Modul: COMPLIANCE
-- Zweck: Index-Engine für Compliance-Events (Performance, Search, Query)

-- 1. Basisindex: Event-ID
CREATE INDEX IF NOT EXISTS idx_compliance_event_id
    ON document_events(event_id);

-- 2. Event-Type-Index
CREATE INDEX IF NOT EXISTS idx_compliance_event_type
    ON document_events(event_type);

-- 3. Entity-Type-Index
CREATE INDEX IF NOT EXISTS idx_compliance_entity_type
    ON document_events(entity_type);

-- 4. Entity-ID-Index
CREATE INDEX IF NOT EXISTS idx_compliance_entity_id
    ON document_events(entity_id);

-- 5. JSONB-Payload-Index (GIN)
CREATE INDEX IF NOT EXISTS idx_compliance_payload_gin
    ON document_events
    USING gin (payload jsonb_path_ops);

-- 6. Volltextindex über Payload
CREATE INDEX IF NOT EXISTS idx_compliance_payload_tsv
    ON document_events
    USING gin (to_tsvector('simple', payload::text));

-- 7. Compliance-Type-Index
CREATE INDEX IF NOT EXISTS idx_compliance_payload_type
    ON document_events((payload->>'compliance_type'));

-- 8. Compliance-Status-Index
CREATE INDEX IF NOT EXISTS idx_compliance_payload_status
    ON document_events((payload->>'compliance_status'));

-- 9. Zeitindex (created_at)
CREATE INDEX IF NOT EXISTS idx_compliance_created_at
    ON document_events(created_at);

-- 10. Composite-Index: Entity + Compliance-Type
CREATE INDEX IF NOT EXISTS idx_compliance_entity_type_combo
    ON document_events(entity_type, (payload->>'compliance_type'));

-- 11. Composite-Index: Compliance-Type + Status
CREATE INDEX IF NOT EXISTS idx_compliance_type_status
    ON document_events((payload->>'compliance_type'), (payload->>'compliance_status'));

-- 12. Composite-Index: Volltext + Zeit
CREATE INDEX IF NOT EXISTS idx_compliance_tsv_created
    ON document_events
    USING gin (to_tsvector('simple', payload::text), created_at);

COMMENT ON INDEX idx_compliance_payload_gin IS
'GIN-Index für JSONB-Payload (Compliance-Events).';

COMMENT ON INDEX idx_compliance_payload_tsv IS
'Volltextindex für Compliance-Events.';

COMMENT ON INDEX idx_compliance_type_status IS
'Composite-Index für Compliance-Type + Status.';

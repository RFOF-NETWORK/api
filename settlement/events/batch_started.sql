-- batch_started.sql
-- Modul: settlement
-- Ereignis: batch_started
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch den Start eines
--   Settlement-Batches. Es ist unveränderlich, auditierbar und bildet
--   die Grundlage für regulatorische Nachweise, Settlement-Pipelines,
--   Zahlungsabwicklung und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS settlement_batch_started_events (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Settlement-Batch
    batch_id            uuid NOT NULL REFERENCES settlement_batches(id) ON DELETE CASCADE,

    -- Batch-Metadaten
    batch_type          text NOT NULL,
    opened_at           timestamptz NOT NULL,
    metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Settlement-Batch wurde gestartet
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_settlement_batch_started_event(
    in_batch_id uuid,
    in_batch_type text,
    in_opened_at timestamptz,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO settlement_batch_started_events (
        batch_id,
        batch_type,
        opened_at,
        metadata
    )
    VALUES (
        in_batch_id,
        in_batch_type,
        in_opened_at,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_settlement_batch_started_event(
    uuid, text, timestamptz, jsonb
) IS
'Ereignis: dokumentiert deterministisch den Start eines Settlement-Batches.';

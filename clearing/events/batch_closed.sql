-- batch_closed.sql
-- Modul: clearing
-- Ereignis: batch_closed
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch das Schließen eines
--   Clearing-Batches. Es ist unveränderlich, auditierbar und bildet
--   die Grundlage für regulatorische Nachweise, Settlement-Pipelines,
--   Netting-Rekonstruktion und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS clearing_batch_closed_events (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Batch
    batch_id            uuid NOT NULL REFERENCES clearing_batches(id) ON DELETE CASCADE,

    -- Batch-Metadaten
    batch_type          text NOT NULL,
    closed_at           timestamptz NOT NULL,
    entry_count         bigint NOT NULL,
    total_amount        numeric(30,10) NOT NULL,

    -- Metadaten
    metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Batch wurde geschlossen
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_clearing_batch_closed_event(
    in_batch_id uuid,
    in_batch_type text,
    in_closed_at timestamptz,
    in_entry_count bigint,
    in_total_amount numeric(30,10),
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO clearing_batch_closed_events (
        batch_id,
        batch_type,
        closed_at,
        entry_count,
        total_amount,
        metadata
    )
    VALUES (
        in_batch_id,
        in_batch_type,
        in_closed_at,
        in_entry_count,
        in_total_amount,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_clearing_batch_closed_event(
    uuid, text, timestamptz, bigint, numeric, jsonb
) IS
'Ereignis: dokumentiert deterministisch das Schließen eines Clearing-Batches.';

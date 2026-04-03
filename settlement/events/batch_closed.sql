-- batch_closed.sql
-- Modul: settlement
-- Ereignis: batch_closed
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch das Schließen eines
--   Settlement-Batches. Es ist unveränderlich, auditierbar und bildet
--   die Grundlage für regulatorische Nachweise, Zahlungsabwicklung,
--   Interbank-Settlement, Netting-Finalisierung und
--   RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS settlement_batch_closed_events (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Settlement-Batch
    batch_id            uuid NOT NULL REFERENCES settlement_batches(id) ON DELETE CASCADE,

    -- Batch-Metadaten
    batch_type          text NOT NULL,
    closed_at           timestamptz NOT NULL,

    -- Statistische Kennzahlen
    account_count       bigint NOT NULL,
    total_net_amount    numeric(30,10) NOT NULL,

    -- Metadaten
    metadata            jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Settlement-Batch wurde geschlossen
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_settlement_batch_closed_event(
    in_batch_id uuid,
    in_batch_type text,
    in_closed_at timestamptz,
    in_account_count bigint,
    in_total_net_amount numeric(30,10),
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO settlement_batch_closed_events (
        batch_id,
        batch_type,
        closed_at,
        account_count,
        total_net_amount,
        metadata
    )
    VALUES (
        in_batch_id,
        in_batch_type,
        in_closed_at,
        in_account_count,
        in_total_net_amount,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_settlement_batch_closed_event(
    uuid, text, timestamptz, bigint, numeric, jsonb
) IS
'Ereignis: dokumentiert deterministisch das Schließen eines Settlement-Batches.';

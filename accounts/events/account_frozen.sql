-- account_frozen.sql
-- Modul: accounts
-- Ereignis: account_frozen
-- Beschreibung:
--   Dieses Ereignis dokumentiert das Einfrieren eines Accounts.
--   Es ist unveränderlich, auditierbar und bildet die Grundlage
--   für regulatorische Nachweise, Fraud-Analysen, Ledger-Rekonstruktion
--   und systemweite Ereignisverarbeitung.
--   Ereignisse werden niemals aktualisiert oder gelöscht.

CREATE TABLE IF NOT EXISTS account_frozen_events (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id      uuid NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    owner_user_id   uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    occurred_at     timestamptz NOT NULL DEFAULT now(),
    reason          text DEFAULT NULL,
    metadata        jsonb DEFAULT '{}'::jsonb
);

-- Ereignis-Funktion: Account wurde eingefroren
CREATE OR REPLACE FUNCTION emit_account_frozen_event(
    in_account_id uuid,
    in_owner_user_id uuid,
    in_reason text DEFAULT NULL,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO account_frozen_events (
        account_id,
        owner_user_id,
        reason,
        metadata
    )
    VALUES (
        in_account_id,
        in_owner_user_id,
        in_reason,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_account_frozen_event(uuid, uuid, text, jsonb) IS
'Ereignis: dokumentiert das Einfrieren eines Accounts unveränderlich.';

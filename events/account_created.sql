-- account_created.sql
-- Modul: accounts
-- Ereignis: account_created
-- Beschreibung:
--   Dieses Ereignis dokumentiert die Erstellung eines Accounts.
--   Es ist unveränderlich, auditierbar und bildet die Grundlage
--   für regulatorische Nachweise, Ledger-Rekonstruktion und
--   systemweite Ereignisverarbeitung.
--   Ereignisse werden niemals aktualisiert oder gelöscht.

CREATE TABLE IF NOT EXISTS account_created_events (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id      uuid NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    owner_user_id   uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    account_type    text NOT NULL,
    currency        text NOT NULL,
    occurred_at     timestamptz NOT NULL DEFAULT now(),
    metadata        jsonb DEFAULT '{}'::jsonb
);

-- Ereignis-Funktion: Account wurde erstellt
CREATE OR REPLACE FUNCTION emit_account_created_event(
    in_account_id uuid,
    in_owner_user_id uuid,
    in_account_type text,
    in_currency text,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO account_created_events (
        account_id,
        owner_user_id,
        account_type,
        currency,
        metadata
    )
    VALUES (
        in_account_id,
        in_owner_user_id,
        in_account_type,
        in_currency,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_account_created_event(uuid, uuid, text, text, jsonb) IS
'Ereignis: dokumentiert die Erstellung eines Accounts unveränderlich.';

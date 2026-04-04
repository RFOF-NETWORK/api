-- treasury_account_created.sql
-- Modul: treasury
-- Ereignis: treasury_account_created
-- Beschreibung:
--   Dieses Ereignis dokumentiert deterministisch die Erzeugung eines
--   Treasury-Accounts. Es ist unveränderlich, auditierbar und bildet
--   die Grundlage für regulatorische Nachweise, Liquiditätssteuerung,
--   Reservehaltung, Collateral-Management und RFOF-GOLDEN-Chain-Prozesse.

CREATE TABLE IF NOT EXISTS treasury_account_created_events (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Verknüpfung zum Treasury-Account
    treasury_account_id     uuid NOT NULL REFERENCES treasury_accounts(id) ON DELETE CASCADE,

    -- Verknüpfung zum globalen Account
    account_id              uuid NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,

    -- Treasury-Account-Typ
    account_type            text NOT NULL,

    -- Währung
    currency                currency_code NOT NULL,

    -- Zeitliche Dimension
    created_at              timestamptz NOT NULL DEFAULT now(),

    -- Audit-Metadaten
    metadata                jsonb NOT NULL DEFAULT '{}'::jsonb
);

------------------------------------------------------------
-- Ereignis-Funktion: Treasury-Account wurde erzeugt
------------------------------------------------------------
CREATE OR REPLACE FUNCTION emit_treasury_account_created_event(
    in_treasury_account_id uuid,
    in_account_id uuid,
    in_account_type text,
    in_currency currency_code,
    in_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid AS $$
DECLARE
    v_event_id uuid;
BEGIN
    INSERT INTO treasury_account_created_events (
        treasury_account_id,
        account_id,
        account_type,
        currency,
        metadata
    )
    VALUES (
        in_treasury_account_id,
        in_account_id,
        in_account_type,
        in_currency,
        in_metadata
    )
    RETURNING id INTO v_event_id;

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION emit_treasury_account_created_event(
    uuid, uuid, text, currency_code, jsonb
) IS
'Ereignis: dokumentiert deterministisch die Erzeugung eines Treasury-Accounts.';

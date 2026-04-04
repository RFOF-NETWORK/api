-- api/compliance/events/compliance_event_subscribe.sql
-- Modul: COMPLIANCE
-- Zweck: Registrierung eines Compliance-Event-Subscribers

CREATE OR REPLACE FUNCTION compliance_event_subscribe(
    p_subscriber_name TEXT,
    p_event_filter    JSONB DEFAULT '{}'::jsonb,   -- { event_type, entity_type, compliance_type }
    p_callback        TEXT                         -- Name der Callback-Funktion
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_subscription_id UUID := gen_random_uuid();
    v_subscription JSONB;
BEGIN
    -- 1. Subscription-Objekt bauen
    v_subscription := jsonb_build_object(
        'subscription_id', v_subscription_id,
        'subscriber', p_subscriber_name,
        'filter', p_event_filter,
        'callback', p_callback,
        'subscribed_at', now()
    );

    -- 2. Subscription in globale Subscription-Tabelle schreiben (DE-kompatibel)
    INSERT INTO document_event_subscriptions (
        subscription_id,
        subscriber,
        filter,
        callback,
        payload
    )
    VALUES (
        v_subscription_id,
        p_subscriber_name,
        p_event_filter,
        p_callback,
        v_subscription
    );

    -- 3. Ergebnis zurückgeben
    RETURN v_subscription;
END;
$$;

COMMENT ON FUNCTION compliance_event_subscribe IS
'Registriert einen Subscriber für Compliance-Events (Filter + Callback).';

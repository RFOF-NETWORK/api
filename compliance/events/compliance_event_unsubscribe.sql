-- api/compliance/events/compliance_event_unsubscribe.sql
-- Modul: COMPLIANCE
-- Zweck: Deregistrierung eines Compliance-Event-Subscribers

CREATE OR REPLACE FUNCTION compliance_event_unsubscribe(
    p_subscription_id UUID,
    p_reason          TEXT DEFAULT 'UNSUBSCRIBED'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_subscription RECORD;
    v_unsub JSONB;
BEGIN
    -- 1. Subscription laden
    SELECT *
    INTO v_subscription
    FROM document_event_subscriptions
    WHERE subscription_id = p_subscription_id;

    IF v_subscription IS NULL THEN
        RETURN jsonb_build_object(
            'error', 'SUBSCRIPTION_NOT_FOUND',
            'subscription_id', p_subscription_id
        );
    END IF;

    -- 2. Unsubscribe-Objekt bauen
    v_unsub := jsonb_build_object(
        'subscription_id', p_subscription_id,
        'subscriber', v_subscription.subscriber,
        'filter', v_subscription.filter,
        'callback', v_subscription.callback,
        'reason', p_reason,
        'unsubscribed_at', now()
    );

    -- 3. Subscription löschen
    DELETE FROM document_event_subscriptions
    WHERE subscription_id = p_subscription_id;

    -- 4. Unsubscribe-Log schreiben (DE-kompatibel)
    INSERT INTO document_event_unsubscribe_log (
        subscription_id,
        subscriber,
        filter,
        callback,
        payload
    )
    VALUES (
        p_subscription_id,
        v_subscription.subscriber,
        v_subscription.filter,
        v_subscription.callback,
        v_unsub
    );

    -- 5. Ergebnis zurückgeben
    RETURN v_unsub;
END;
$$;

COMMENT ON FUNCTION compliance_event_unsubscribe IS
'Deregistriert einen Subscriber für Compliance-Events und schreibt ein Unsubscribe-Log.';

-- federation_unsubscribe.sql
-- Action: Entfernt ein bestehendes Subscription-Mapping

CREATE OR REPLACE FUNCTION federation_unsubscribe(
    p_subscriber_id UUID,
    p_target_id     UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted INTEGER;
BEGIN
    DELETE FROM federation_subscription
    WHERE subscriber_id = p_subscriber_id
      AND target_id     = p_target_id;

    GET DIAGNOSTICS v_deleted = ROW_COUNT;

    RETURN v_deleted > 0;
END;
$$;

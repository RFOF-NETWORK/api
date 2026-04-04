-- F63: Event Search (Volltextsuche über Payload)

CREATE OR REPLACE FUNCTION federation_event_search(
    p_query TEXT
)
RETURNS SETOF federation_event
LANGUAGE sql
AS $$
    SELECT *
    FROM federation_event
    WHERE payload::text ILIKE '%' || p_query || '%'
    ORDER BY created_at DESC;
$$;

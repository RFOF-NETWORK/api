CREATE TABLE IF NOT EXISTS document_event_route_log (
    id                 BIGSERIAL PRIMARY KEY,
    event_id           UUID NOT NULL,
    route              TEXT NOT NULL,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS document_event_dispatch_log (
    id                 BIGSERIAL PRIMARY KEY,
    event_id           UUID NOT NULL,
    target             TEXT NOT NULL,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS document_event_bus_log (
    id                 BIGSERIAL PRIMARY KEY,
    event_id           UUID NOT NULL,
    bus_name           TEXT NOT NULL,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS document_event_stream_log (
    id                 BIGSERIAL PRIMARY KEY,
    event_id           UUID NOT NULL,
    stream_name        TEXT NOT NULL,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS document_event_retry_log (
    id                 BIGSERIAL PRIMARY KEY,
    event_id           UUID NOT NULL,
    attempt            INTEGER NOT NULL,
    reason             TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS document_event_deadletter_log (
    id                 BIGSERIAL PRIMARY KEY,
    event_id           UUID NOT NULL,
    reason             TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

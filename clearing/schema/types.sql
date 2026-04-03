-- types.sql
-- Modul: clearing
-- Schema-Komponente: Typdefinitionen
-- Beschreibung:
--   Diese Datei definiert alle domänenspezifischen Typen des Clearing-Moduls.
--   Die Typen sind stabil, deterministisch, auditierbar und dienen der
--   Vereinheitlichung von Batch-Typen, Statuswerten und Ereignisklassen.

------------------------------------------------------------
-- Batch-Typen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'clearing_batch_type') THEN
        CREATE TYPE clearing_batch_type AS ENUM (
            'intraday',
            'end_of_day',
            'manual',
            'system'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Batch-Status
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'clearing_batch_status') THEN
        CREATE TYPE clearing_batch_status AS ENUM (
            'open',
            'closed'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Clearing-Operationstypen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'clearing_operation_type') THEN
        CREATE TYPE clearing_operation_type AS ENUM (
            'batch_started',
            'item_added',
            'batch_closed'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Clearing-Ereignisklasse
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'clearing_event_class') THEN
        CREATE TYPE clearing_event_class AS ENUM (
            'batch_event',
            'item_event'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Audit-Metadatenstruktur (JSONB-Standardisierung)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION clearing_default_metadata()
RETURNS jsonb AS $$
BEGIN
    RETURN jsonb_build_object(
        'source', 'clearing',
        'version', '1.0.0',
        'timestamp', now()
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

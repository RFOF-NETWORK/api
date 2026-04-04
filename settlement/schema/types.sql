-- types.sql
-- Modul: settlement
-- Schema-Komponente: Typdefinitionen
-- Beschreibung:
--   Diese Datei definiert alle domänenspezifischen Typen des Settlement-Moduls.
--   Die Typen sind stabil, deterministisch, auditierbar und dienen der
--   Vereinheitlichung von Settlement-Account-Typen, Flow-Richtungen und
--   Ereignisklassen.

------------------------------------------------------------
-- Settlement-Account-Typen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'settlement_account_type') THEN
        CREATE TYPE settlement_account_type AS ENUM (
            'nostro',
            'vostro',
            'internal',
            'reserve',
            'system'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Settlement-Flow-Richtungen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'settlement_flow_direction') THEN
        CREATE TYPE settlement_flow_direction AS ENUM (
            'credit',
            'debit'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Settlement-Ereignisklassen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'settlement_event_class') THEN
        CREATE TYPE settlement_event_class AS ENUM (
            'account_event',
            'flow_event',
            'position_event'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Audit-Metadatenstruktur (JSONB-Standardisierung)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION settlement_default_metadata()
RETURNS jsonb AS $$
BEGIN
    RETURN jsonb_build_object(
        'source', 'settlement',
        'version', '1.0.0',
        'timestamp', now()
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

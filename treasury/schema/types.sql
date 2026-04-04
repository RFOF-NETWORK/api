-- types.sql
-- Modul: treasury
-- Schema-Komponente: Typdefinitionen
-- Beschreibung:
--   Diese Datei definiert alle domänenspezifischen Typen des Treasury-Moduls.
--   Die Typen sind stabil, deterministisch, auditierbar und dienen der
--   Vereinheitlichung von Treasury-Account-Typen, Flow-Richtungen und
--   Ereignisklassen.

------------------------------------------------------------
-- Treasury-Account-Typen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'treasury_account_type') THEN
        CREATE TYPE treasury_account_type AS ENUM (
            'reserve',
            'liquidity',
            'collateral',
            'system'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Treasury-Flow-Richtungen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'treasury_flow_direction') THEN
        CREATE TYPE treasury_flow_direction AS ENUM (
            'inflow',
            'outflow'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Treasury-Ereignisklassen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'treasury_event_class') THEN
        CREATE TYPE treasury_event_class AS ENUM (
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
CREATE OR REPLACE FUNCTION treasury_default_metadata()
RETURNS jsonb AS $$
BEGIN
    RETURN jsonb_build_object(
        'source', 'treasury',
        'version', '1.0.0',
        'timestamp', now()
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

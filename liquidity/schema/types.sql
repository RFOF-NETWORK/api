-- types.sql
-- Modul: liquidity
-- Schema-Komponente: Typdefinitionen
-- Beschreibung:
--   Diese Datei definiert alle domänenspezifischen Typen des Liquidity-Moduls.
--   Die Typen sind stabil, deterministisch, auditierbar und dienen der
--   Vereinheitlichung von Liquidity-Pool-Typen, Flow-Richtungen und
--   Ereignisklassen.

------------------------------------------------------------
-- Liquidity-Pool-Typen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'liquidity_pool_type') THEN
        CREATE TYPE liquidity_pool_type AS ENUM (
            'intraday',
            'reserve',
            'collateral',
            'settlement',
            'system'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Liquidity-Flow-Richtungen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'liquidity_flow_direction') THEN
        CREATE TYPE liquidity_flow_direction AS ENUM (
            'inflow',
            'outflow'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Liquidity-Ereignisklassen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'liquidity_event_class') THEN
        CREATE TYPE liquidity_event_class AS ENUM (
            'pool_event',
            'flow_event',
            'position_event'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Audit-Metadatenstruktur (JSONB-Standardisierung)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION liquidity_default_metadata()
RETURNS jsonb AS $$
BEGIN
    RETURN jsonb_build_object(
        'source', 'liquidity',
        'version', '1.0.0',
        'timestamp', now()
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

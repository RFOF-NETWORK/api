-- types.sql
-- Modul: ledger
-- Schema-Komponente: Typdefinitionen
-- Beschreibung:
--   Diese Datei definiert alle domänenspezifischen Typen des Ledger-Moduls.
--   Die Typen sind stabil, deterministisch, auditierbar und dienen der
--   Vereinheitlichung von Richtungen, Operationen und Ereignisklassen.

------------------------------------------------------------
-- Buchungsrichtung
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ledger_direction') THEN
        CREATE TYPE ledger_direction AS ENUM (
            'debit',
            'credit'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Ledger-Operationstypen
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ledger_operation_type') THEN
        CREATE TYPE ledger_operation_type AS ENUM (
            'entry_posted',
            'transfer_posted',
            'entry_reversed'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Ledger-Ereignisklasse
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ledger_event_class') THEN
        CREATE TYPE ledger_event_class AS ENUM (
            'single_entry',
            'dual_entry',
            'reversal'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Ledger-Referenztyp (frei definierbar, aber strukturiert)
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ledger_reference_type') THEN
        CREATE TYPE ledger_reference_type AS ENUM (
            'transaction',
            'accounting_process',
            'system_process',
            'external_reference'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Audit-Metadatenstruktur (JSONB-Standardisierung)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION ledger_default_metadata()
RETURNS jsonb AS $$
BEGIN
    RETURN jsonb_build_object(
        'source', 'ledger',
        'version', '1.0.0',
        'timestamp', now()
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- types.sql
-- Modul: accounts
-- Schema-Komponente: Typdefinitionen
-- Beschreibung:
--   Diese Datei definiert alle domänenspezifischen Typen des Accounts-Moduls.
--   Die Typen sind stabil, deterministisch, auditierbar und dienen der
--   Vereinheitlichung von Statuswerten, Kategorien und regulatorischen
--   Klassifikationen.

------------------------------------------------------------
-- Account-Status
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_status') THEN
        CREATE TYPE account_status AS ENUM (
            'active',
            'frozen',
            'closed'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Account-Kategorie
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_category') THEN
        CREATE TYPE account_category AS ENUM (
            'retail',
            'corporate',
            'institutional',
            'internal',
            'technical'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Account-Typ-Klassifikation
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type_class') THEN
        CREATE TYPE account_type_class AS ENUM (
            'asset',
            'liability',
            'equity',
            'income',
            'expense'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Währungscode (ISO 4217)
------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'currency_code') THEN
        CREATE TYPE currency_code AS ENUM (
            'EUR',
            'USD',
            'GBP',
            'CHF',
            'JPY',
            'CNY'
        );
    END IF;
END;
$$;

------------------------------------------------------------
-- Audit-Metadatenstruktur (JSONB-Standardisierung)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION accounts_default_metadata()
RETURNS jsonb AS $$
BEGIN
    RETURN jsonb_build_object(
        'source', 'accounts',
        'version', '1.0.0',
        'timestamp', now()
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

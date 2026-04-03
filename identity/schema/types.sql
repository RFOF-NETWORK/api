-- types.sql
-- Modul: identity
-- Schema-Komponente: Typdefinitionen
-- Beschreibung:
--   Diese Datei definiert alle domänenspezifischen Typen des Identity-Moduls.
--   Die Typen sind deterministisch, stabil, erweiterbar und dienen der
--   Vereinheitlichung von Statuswerten, Rollenlogik und Identitätszuständen.

-- Benutzerstatus
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
        CREATE TYPE user_status AS ENUM (
            'active',
            'inactive',
            'locked',
            'pending'
        );
    END IF;
END;
$$;

-- Sessionstatus
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'session_state') THEN
        CREATE TYPE session_state AS ENUM (
            'valid',
            'expired',
            'revoked'
        );
    END IF;
END;
$$;

-- Rollenklassifikation (optional erweiterbar)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'role_category') THEN
        CREATE TYPE role_category AS ENUM (
            'system',
            'administrative',
            'operational',
            'external'
        );
    END IF;
END;
$$;

-- Berechtigungskategorie
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'permission_scope') THEN
        CREATE TYPE permission_scope AS ENUM (
            'identity',
            'accounts',
            'ledger',
            'documents',
            'compliance',
            'federation',
            'shared'
        );
    END IF;
END;
$$;

-- Audit-Metadatenstruktur (JSONB-Standardisierung)
CREATE OR REPLACE FUNCTION identity_default_metadata()
RETURNS jsonb AS $$
BEGIN
    RETURN jsonb_build_object(
        'source', 'identity',
        'version', '1.0.0',
        'timestamp', now()
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

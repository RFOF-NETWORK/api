-- validation.sql
-- Modul: accounts
-- Schema-Komponente: Validierungslogik
-- Beschreibung:
--   Diese Datei definiert alle Validierungsfunktionen des Accounts-Moduls.
--   Alle Funktionen sind rein, deterministisch, auditierbar und erzeugen
--   keinerlei Nebenwirkungen. Sie dienen der syntaktischen, regulatorischen
--   und operativen Validierung von Eingaben und Statuswerten.

------------------------------------------------------------
-- Validierung: Account-Typ
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_account_type(in_type text)
RETURNS boolean AS $$
BEGIN
    IF in_type IS NULL THEN
        RETURN false;
    END IF;

    IF in_type ~ '^[a-zA-Z0-9_\-]+$' THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Account-Status
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_account_status(in_status account_status)
RETURNS boolean AS $$
BEGIN
    IF in_status IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Account-Kategorie
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_account_category(in_category account_category)
RETURNS boolean AS $$
BEGIN
    IF in_category IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Währungscode (ISO 4217)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_currency(in_currency currency_code)
RETURNS boolean AS $$
BEGIN
    IF in_currency IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Account-Nummer
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_account_number(in_number text)
RETURNS boolean AS $$
BEGIN
    IF in_number IS NULL THEN
        RETURN false;
    END IF;

    IF in_number ~ '^ACCT\-[0-9a-fA-F]{16}$' THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Saldo (numerisch)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_balance(in_balance numeric)
RETURNS boolean AS $$
BEGIN
    IF in_balance IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Account darf geschlossen werden
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_account_closable(
    in_status account_status,
    in_balance numeric
)
RETURNS boolean AS $$
BEGIN
    IF in_status <> 'active' THEN
        RETURN false;
    END IF;

    IF in_balance <> 0 THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Account darf eingefroren werden
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_account_freezable(
    in_status account_status
)
RETURNS boolean AS $$
BEGIN
    IF in_status = 'closed' THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

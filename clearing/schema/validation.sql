-- validation.sql
-- Modul: clearing
-- Schema-Komponente: Validierungslogik
-- Beschreibung:
--   Diese Datei definiert alle Validierungsfunktionen des Clearing-Moduls.
--   Alle Funktionen sind rein, deterministisch, auditierbar und erzeugen
--   keinerlei Nebenwirkungen. Sie validieren Batch-Typen, Statuswerte,
--   Operationstypen und grundlegende Konsistenzregeln.

------------------------------------------------------------
-- Validierung: Batch-Typ
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_clearing_batch_type(in_type text)
RETURNS boolean AS $$
BEGIN
    IF in_type IS NULL THEN
        RETURN false;
    END IF;

    IF in_type IN ('intraday', 'end_of_day', 'manual', 'system') THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Batch-Status
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_clearing_batch_status(in_status text)
RETURNS boolean AS $$
BEGIN
    IF in_status IS NULL THEN
        RETURN false;
    END IF;

    IF in_status IN ('open', 'closed') THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Clearing-Operationstyp
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_clearing_operation_type(in_type clearing_operation_type)
RETURNS boolean AS $$
BEGIN
    IF in_type IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Clearing-Ereignisklasse
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_clearing_event_class(in_class clearing_event_class)
RETURNS boolean AS $$
BEGIN
    IF in_class IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Batch-Konsistenz (open/closed)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_clearing_batch_consistency(
    in_status text,
    in_closed_at timestamptz
)
RETURNS boolean AS $$
BEGIN
    IF in_status = 'open' AND in_closed_at IS NULL THEN
        RETURN true;
    END IF;

    IF in_status = 'closed' AND in_closed_at IS NOT NULL THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Clearing-Item-Richtung
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_clearing_direction(in_direction text)
RETURNS boolean AS $$
BEGIN
    IF in_direction IS NULL THEN
        RETURN false;
    END IF;

    IF in_direction IN ('debit', 'credit') THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Clearing-Betrag
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_clearing_amount(in_amount numeric)
RETURNS boolean AS $$
BEGIN
    IF in_amount IS NULL THEN
        RETURN false;
    END IF;

    IF in_amount > 0 THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

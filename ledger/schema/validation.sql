-- validation.sql
-- Modul: ledger
-- Schema-Komponente: Validierungslogik
-- Beschreibung:
--   Diese Datei definiert alle Validierungsfunktionen des Ledger-Moduls.
--   Alle Funktionen sind rein, deterministisch, auditierbar und erzeugen
--   keinerlei Nebenwirkungen. Sie validieren Richtungen, Beträge,
--   Referenzen und regulatorische Anforderungen.

------------------------------------------------------------
-- Validierung: Buchungsrichtung
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_ledger_direction(in_direction text)
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
-- Validierung: Betrag
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_ledger_amount(in_amount numeric)
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

------------------------------------------------------------
-- Validierung: Referenzkonsistenz
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_ledger_reference(
    in_reference_id uuid,
    in_reference_type text
)
RETURNS boolean AS $$
BEGIN
    IF in_reference_id IS NULL AND in_reference_type IS NULL THEN
        RETURN true;
    END IF;

    IF in_reference_id IS NOT NULL AND in_reference_type IS NOT NULL THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Ledger-Operationstyp
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_ledger_operation_type(in_type ledger_operation_type)
RETURNS boolean AS $$
BEGIN
    IF in_type IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Ledger-Ereignisklasse
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_ledger_event_class(in_class ledger_event_class)
RETURNS boolean AS $$
BEGIN
    IF in_class IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Ledger-Referenztyp
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_ledger_reference_type(in_type ledger_reference_type)
RETURNS boolean AS $$
BEGIN
    IF in_type IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

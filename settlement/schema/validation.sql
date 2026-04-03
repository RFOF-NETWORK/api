-- validation.sql
-- Modul: settlement
-- Schema-Komponente: Validierungslogik
-- Beschreibung:
--   Diese Datei definiert alle Validierungsfunktionen des Settlement-Moduls.
--   Alle Funktionen sind rein, deterministisch, auditierbar und erzeugen
--   keinerlei Nebenwirkungen. Sie validieren Batch-Typen, Statuswerte,
--   Operationstypen und grundlegende Konsistenzregeln.

------------------------------------------------------------
-- Validierung: Settlement-Batch-Typ
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_settlement_batch_type(in_type text)
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
-- Validierung: Settlement-Batch-Status
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_settlement_batch_status(in_status text)
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
-- Validierung: Settlement-Operationstyp
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_settlement_operation_type(in_type settlement_operation_type)
RETURNS boolean AS $$
BEGIN
    IF in_type IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Settlement-Ereignisklasse
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_settlement_event_class(in_class settlement_event_class)
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
CREATE OR REPLACE FUNCTION validate_settlement_batch_consistency(
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
-- Validierung: Settlement-Betrag
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_settlement_amount(in_amount numeric)
RETURNS boolean AS $$
BEGIN
    IF in_amount IS NULL THEN
        RETURN false;
    END IF;

    IF in_amount >= 0 THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Netting-Konsistenz
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_settlement_netting(
    in_total_debit numeric,
    in_total_credit numeric,
    in_net_amount numeric
)
RETURNS boolean AS $$
BEGIN
    IF in_total_debit IS NULL OR in_total_credit IS NULL OR in_net_amount IS NULL THEN
        RETURN false;
    END IF;

    IF in_net_amount = in_total_credit - in_total_debit THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

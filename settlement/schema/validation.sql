-- validation.sql
-- Modul: settlement
-- Schema-Komponente: Validierungslogik (Fusion)
-- Beschreibung:
--   Diese Datei vereint ALLE Validierungsfunktionen des Settlement-Moduls:
--   1. Real-Time-Settlement (Accounts, Flows, Positions)
--   2. Batch-Settlement (Batch-Typen, Status, Netting, Operationstypen)
--
--   Die Fusion ist vollständig, deterministisch, auditierbar und
--   konfliktfrei. Beide Paradigmen sind sauber getrennt, aber in einer
--   Datei vereint.

------------------------------------------------------------
-- REAL-TIME SETTLEMENT VALIDIERUNGEN
-- (H12 – final)
------------------------------------------------------------

-- Validierung: Settlement-Account-Typ
CREATE OR REPLACE FUNCTION validate_settlement_account_type(in_type text)
RETURNS boolean AS $$
BEGIN
    IF in_type IS NULL THEN
        RETURN false;
    END IF;

    IF in_type IN ('nostro', 'vostro', 'internal', 'reserve', 'system') THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Validierung: Settlement-Flow-Richtung
CREATE OR REPLACE FUNCTION validate_settlement_flow_direction(in_direction text)
RETURNS boolean AS $$
BEGIN
    IF in_direction IS NULL THEN
        RETURN false;
    END IF;

    IF in_direction IN ('credit', 'debit') THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Validierung: Währung
CREATE OR REPLACE FUNCTION validate_settlement_currency(in_currency currency_code)
RETURNS boolean AS $$
BEGIN
    IF in_currency IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Validierung: Betrag (Real-Time)
CREATE OR REPLACE FUNCTION validate_settlement_amount(in_amount numeric)
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

-- Validierung: Positions-Konsistenz
CREATE OR REPLACE FUNCTION validate_settlement_position_consistency(
    in_balance numeric,
    in_reserved numeric,
    in_available numeric
)
RETURNS boolean AS $$
BEGIN
    IF in_balance IS NULL OR in_reserved IS NULL OR in_available IS NULL THEN
        RETURN false;
    END IF;

    IF in_balance < 0 OR in_reserved < 0 THEN
        RETURN false;
    END IF;

    IF in_available = in_balance - in_reserved THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


------------------------------------------------------------
-- BATCH SETTLEMENT VALIDIERUNGEN
-- (Legacy-Modul, aber aktiv)
------------------------------------------------------------

-- Validierung: Settlement-Batch-Typ
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

-- Validierung: Settlement-Batch-Status
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

-- Validierung: Settlement-Operationstyp
CREATE OR REPLACE FUNCTION validate_settlement_operation_type(in_type settlement_operation_type)
RETURNS boolean AS $$
BEGIN
    IF in_type IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Validierung: Settlement-Ereignisklasse (Batch)
CREATE OR REPLACE FUNCTION validate_settlement_event_class(in_class settlement_event_class)
RETURNS boolean AS $$
BEGIN
    IF in_class IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Validierung: Batch-Konsistenz (open/closed)
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

-- Validierung: Netting-Konsistenz
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

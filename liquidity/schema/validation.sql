-- validation.sql
-- Modul: liquidity
-- Schema-Komponente: Validierungslogik
-- Beschreibung:
--   Diese Datei definiert alle Validierungsfunktionen des Liquidity-Moduls.
--   Alle Funktionen sind rein, deterministisch, auditierbar und erzeugen
--   keinerlei Nebenwirkungen. Sie validieren Liquidity-Pool-Typen,
--   Flow-Richtungen, Währungen, Beträge und grundlegende
--   Konsistenzregeln für Liquidity-Positionen.

------------------------------------------------------------
-- Validierung: Liquidity-Pool-Typ
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_liquidity_pool_type(in_type text)
RETURNS boolean AS $$
BEGIN
    IF in_type IS NULL THEN
        RETURN false;
    END IF;

    IF in_type IN ('intraday', 'reserve', 'collateral', 'settlement', 'system') THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Liquidity-Flow-Richtung
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_liquidity_flow_direction(in_direction text)
RETURNS boolean AS $$
BEGIN
    IF in_direction IS NULL THEN
        RETURN false;
    END IF;

    IF in_direction IN ('inflow', 'outflow') THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Währung
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_liquidity_currency(in_currency currency_code)
RETURNS boolean AS $$
BEGIN
    IF in_currency IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Betrag
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_liquidity_amount(in_amount numeric)
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
-- Validierung: Positions-Konsistenz
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_liquidity_position_consistency(
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

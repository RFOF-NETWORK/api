-- validation.sql
-- Modul: identity
-- Schema-Komponente: Validierungslogik
-- Beschreibung:
--   Diese Datei definiert alle Validierungsfunktionen des Identity-Moduls.
--   Sie stellt sicher, dass Eingaben, Statuswerte und Übergänge deterministisch,
--   sicher und konsistent bleiben. Alle Funktionen sind rein, auditierbar und
--   verändern keine Daten.

------------------------------------------------------------
-- Validierung: Benutzername
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_username(in_username text)
RETURNS boolean AS $$
BEGIN
    IF in_username IS NULL OR length(in_username) < 3 THEN
        RETURN false;
    END IF;

    IF in_username ~ '^[a-zA-Z0-9_\-\.]+$' THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: E-Mail-Adresse
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_email(in_email text)
RETURNS boolean AS $$
BEGIN
    IF in_email IS NULL THEN
        RETURN false;
    END IF;

    IF in_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Passwortstärke
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_password_strength(in_password text)
RETURNS boolean AS $$
BEGIN
    IF in_password IS NULL OR length(in_password) < 8 THEN
        RETURN false;
    END IF;

    IF in_password !~ '[A-Z]' THEN
        RETURN false;
    END IF;

    IF in_password !~ '[a-z]' THEN
        RETURN false;
    END IF;

    IF in_password !~ '[0-9]' THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Benutzerstatus
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_user_status(in_status user_status)
RETURNS boolean AS $$
BEGIN
    IF in_status IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Sessionstatus
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_session_state(in_state session_state)
RETURNS boolean AS $$
BEGIN
    IF in_state IS NULL THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Rollenname
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_role_name(in_name text)
RETURNS boolean AS $$
BEGIN
    IF in_name IS NULL OR length(in_name) < 3 THEN
        RETURN false;
    END IF;

    IF in_name ~ '^[a-zA-Z0-9_\-]+$' THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Berechtigungsname
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_permission_name(in_name text)
RETURNS boolean AS $$
BEGIN
    IF in_name IS NULL OR length(in_name) < 3 THEN
        RETURN false;
    END IF;

    IF in_name ~ '^[a-zA-Z0-9_\-\.]+$' THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

------------------------------------------------------------
-- Validierung: Profilfelder
------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_profile_locale(in_locale text)
RETURNS boolean AS $$
BEGIN
    IF in_locale IS NULL THEN
        RETURN false;
    END IF;

    IF in_locale ~ '^[a-z]{2}(-[A-Z]{2})?$' THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION validate_profile_timezone(in_timezone text)
RETURNS boolean AS $$
BEGIN
    IF in_timezone IS NULL THEN
        RETURN false;
    END IF;

    -- Keine Liste, nur syntaktische Prüfung
    IF in_timezone ~ '^[A-Za-z0-9_\-\/]+$' THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

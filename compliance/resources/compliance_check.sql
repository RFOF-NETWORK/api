-- api/compliance/actions/compliance_check.sql
-- Modul: COMPLIANCE
-- Zweck: Führt einen Compliance-Check für ein Zielobjekt aus

CREATE OR REPLACE FUNCTION compliance_check(
    p_compliance_type TEXT,      -- AML, KYC, RISK, FRAUD, POLICY
    p_entity_type     TEXT,      -- ACCOUNT, DOCUMENT, IDENTITY, LEDGER
    p_entity_id       UUID,
    p_payload         JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result TEXT;
    v_status TEXT;
    v_metadata JSONB := '{}'::jsonb;
BEGIN
    -- 1. Regel-Engine (Platzhalter für spätere Module E3–E5)
    v_result := 'PASS';

    -- 2. Status ableiten
    v_status := CASE v_result
        WHEN 'PASS' THEN 'ACTIVE'
        WHEN 'WARN' THEN 'REVIEW'
        WHEN 'FAIL' THEN 'BLOCKED'
        ELSE 'REVIEW'
    END;

    -- 3. Compliance-Eintrag erzeugen
    INSERT INTO compliance (
        compliance_type,
        compliance_status,
        entity_type,
        entity_id,
        metadata
    )
    VALUES (
        p_compliance_type,
        v_status,
        p_entity_type,
        p_entity_id,
        jsonb_build_object(
            'payload', p_payload,
            'result', v_result,
            'checked_at', now()
        )
    )
    RETURNING metadata INTO v_metadata;

    -- 4. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'entity_type', p_entity_type,
        'entity_id', p_entity_id,
        'compliance_type', p_compliance_type,
        'status', v_status,
        'metadata', v_metadata
    );
END;
$$;

COMMENT ON FUNCTION compliance_check IS
'Führt einen Compliance-Check aus und erzeugt einen Compliance-Datensatz.';

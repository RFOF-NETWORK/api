-- api/compliance/actions/compliance_evaluate.sql
-- Modul: COMPLIANCE
-- Zweck: Führt mehrere Compliance-Regeln gleichzeitig aus (Regel-Engine)

CREATE OR REPLACE FUNCTION compliance_evaluate(
    p_compliance_type TEXT,          -- AML, KYC, RISK, FRAUD, POLICY
    p_entity_type     TEXT,          -- ACCOUNT, DOCUMENT, IDENTITY, LEDGER
    p_entity_id       UUID,
    p_rules           JSONB,         -- Liste von Regeln
    p_payload         JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_rule JSONB;
    v_results JSONB := '[]'::jsonb;
    v_final TEXT := 'PASS';
    v_status TEXT;
    v_metadata JSONB;
BEGIN
    -- 1. Jede Regel einzeln evaluieren
    FOR v_rule IN SELECT * FROM jsonb_array_elements(p_rules)
    LOOP
        -- Platzhalter: echte Logik kommt in E6–E10
        v_results := v_results || jsonb_build_object(
            'rule', v_rule->>'name',
            'result', 'PASS',
            'checked_at', now()
        );
    END LOOP;

    -- 2. Finalen Status bestimmen
    -- (später: echte Logik, jetzt deterministischer Platzhalter)
    v_final := 'PASS';

    v_status := CASE v_final
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
            'rules', p_rules,
            'results', v_results,
            'payload', p_payload,
            'evaluated_at', now()
        )
    )
    RETURNING metadata INTO v_metadata;

    -- 4. Ergebnis zurückgeben
    RETURN jsonb_build_object(
        'entity_type', p_entity_type,
        'entity_id', p_entity_id,
        'compliance_type', p_compliance_type,
        'status', v_status,
        'results', v_results,
        'metadata', v_metadata
    );
END;
$$;

COMMENT ON FUNCTION compliance_evaluate IS
'Führt mehrere Compliance-Regeln aus und erzeugt einen aggregierten Compliance-Eintrag.';

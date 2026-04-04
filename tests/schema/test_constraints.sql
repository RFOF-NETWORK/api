-- Constraints
ALTER TABLE test_cases
    ADD CONSTRAINT test_case_name_not_empty CHECK (name <> '');

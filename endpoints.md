# API Endpoints (Logical Interface)

Dieses Dokument beschreibt die logischen Endpunkte der RFOF-NETWORK API.
Alle Endpunkte sind SQL-native und werden über Actions (FUNCTION calls)
oder Events (INSERTs) ausgeführt.

---

# Identity (A)
## Login
- Action: `identity.actions.login(email, password)`
- Returns: JWT-like session token

## Logout
- Action: `identity.actions.logout(session_id)`

## Verify Session
- Action: `identity.actions.verify(token)`

---

# Accounts (B)
## Create Account
- Action: `accounts.actions.create_account(user_id, type)`

## Get Account
- Resource: `accounts.resources.account_view`

## Update Account
- Action: `accounts.actions.update_account(account_id, payload)`

---

# Ledger (C)
## Post Transaction
- Action: `ledger.actions.post_entry(debit, credit, amount, meta)`

## Get Journal
- Resource: `ledger.resources.journal_view`

---

# Documents (D)
## Upload Document
- Action: `documents.actions.upload(doc_type, payload)`

## Get Document
- Resource: `documents.resources.document_view`

---

# Compliance (E)
## Run Compliance Check
- Action: `compliance.actions.run_check(entity_id)`

## Compliance Events
- Event: `compliance.events.compliance_triggered`

---

# Federation (F)
## Node Health
- Resource: `federation.resources.health_view`

## Trust Matrix
- Resource: `federation.resources.trust_matrix`

## Discovery Refresh
- Action: `federation.actions.discovery_refresh()`

---

# Shared (G)
## Hash
- Action: `shared.actions.shared_hash(value)`

## Normalize
- Action: `shared.actions.shared_normalize(value)`

---

# Config (H)
## Load Config
- Action: `config.actions.config_load(key)`

## Set Config
- Action: `config.actions.config_set(key, value)`

---

# Scripts (I)
## Run Script
- Action: `scripts.actions.script_run(name)`

## Schedule Script
- Action: `scripts.actions.script_schedule(name, cron)`

---

# Tests (J)
## Run Test
- Action: `tests.actions.test_run(case_name)`

---

# Docs (K)
## Generate Docs
- Action: `docs.actions.docs_generate()`

---

# INDEX (L)
Siehe: `api/INDEX.md`

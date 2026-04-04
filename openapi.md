# OpenAPI-like Specification (SQL-Native)

Diese Datei beschreibt die API in einem OpenAPI-ähnlichen Format,
ohne REST-Server. Sie dient Frontend-Teams als Integrationsgrundlage.

---

# Info
title: RFOF-NETWORK API
version: 1.0.0
description: >
  SQL-native API für GPCB, ECCU, RFOF-GOLDEN, Clearing, Treasury,
  Settlement, Identity, Accounts, Ledger und Federation.

---

# Authentication
type: SQL-native token
method: identity.actions.login(email, password)
returns: token

---

# Paths (Logical)

## /identity/login
post:
  action: identity.actions.login
  params:
    - email: string
    - password: string
  returns:
    token: string

## /identity/verify
post:
  action: identity.actions.verify
  params:
    - token: string
  returns:
    valid: boolean

---

## /accounts/create
post:
  action: accounts.actions.create_account
  params:
    - user_id: uuid
    - type: string
  returns:
    account_id: uuid

## /accounts/get
get:
  resource: accounts.resources.account_view

---

## /ledger/post
post:
  action: ledger.actions.post_entry
  params:
    - debit: uuid
    - credit: uuid
    - amount: numeric
    - meta: jsonb
  returns:
    entry_id: uuid

---

## /documents/upload
post:
  action: documents.actions.upload
  params:
    - doc_type: string
    - payload: jsonb
  returns:
    document_id: uuid

---

## /compliance/run
post:
  action: compliance.actions.run_check
  params:
    - entity_id: uuid
  returns:
    status: string

---

## /federation/health
get:
  resource: federation.resources.health_view

## /federation/trust
get:
  resource: federation.resources.trust_matrix

## /federation/discovery/refresh
post:
  action: federation.actions.discovery_refresh

---

## /config/get
post:
  action: config.actions.config_load
  params:
    - key: string

## /config/set
post:
  action: config.actions.config_set
  params:
    - key: string
    - value: string

---

## /scripts/run
post:
  action: scripts.actions.script_run
  params:
    - name: string

---

# Components
## Types
- uuid
- text
- numeric
- jsonb
- timestamp

## Errors
- INVALID_TOKEN
- NOT_FOUND
- PERMISSION_DENIED
- VALIDATION_FAILED
- INTERNAL_ERROR

# frontend.md – RFOF-NETWORK API als Frontend nutzen

Dieses Dokument beschreibt, wie ein Frontend (Web, Mobile, CLI) die
RFOF-NETWORK API nutzt, ohne eigenes Backend, nur auf Basis der
bestehenden Repository- und Datenbanklogik.

---

## 1. Grundprinzip: API = Datenbank + Repo

Die API ist:

- die **Datenbanklogik** (SQL: actions, events, resources, schema)
- die **Verzeichnisstruktur** im Repo `api/`
- die **Dokumentation** (`INDEX.md`, `endpoints.md`, `openapi.md`)

Ein Frontend:

- ruft **Actions** auf (WRITE / EXECUTE)
- liest **Resources** (READ / VIEW)
- beobachtet **Events** (STREAM / LOGIC)
- respektiert **Schema** (TYPEN / VALIDIERUNG)

Es gibt **keinen klassischen REST‑Server** – die API ist SQL‑native.

---

## 2. Frontend-Sicht auf A–L

### A – identity

- Zweck: Login, Session, Authentifizierung
- Frontend-Usecases:
  - Login‑Formular (E‑Mail/Passwort)
  - Session‑Check (Token gültig?)
- Typische Calls:
  - `identity.actions.login(email, password)`
  - `identity.actions.verify(token)`

### B – accounts

- Zweck: Konten, IBAN/Account‑Struktur
- Frontend-Usecases:
  - Kontoübersicht
  - Konto‑Details
- Typische Calls:
  - `accounts.resources.account_view`
  - `accounts.actions.create_account(user_id, type)`

### C – ledger

- Zweck: Buchungen, Journal, Finanzlogik
- Frontend-Usecases:
  - Transaktionsliste
  - Buchungsdetails
- Typische Calls:
  - `ledger.resources.journal_view`
  - `ledger.actions.post_entry(debit, credit, amount, meta)`

### D – documents

- Zweck: Dokumente, Workflows, Schemas
- Frontend-Usecases:
  - Dokument‑Upload
  - Dokument‑Status
- Typische Calls:
  - `documents.actions.upload(doc_type, payload)`
  - `documents.resources.document_view`

### E – compliance

- Zweck: Prüfungen, Regeln, Audit‑Entscheidungen
- Frontend-Usecases:
  - Compliance‑Status anzeigen
  - Prüfungen auslösen
- Typische Calls:
  - `compliance.actions.run_check(entity_id)`
  - `compliance.events.compliance_triggered`

### F – federation

- Zweck: Föderation, Trust, Node‑Health
- Frontend-Usecases:
  - Netzwerk‑Status
  - Trust‑Matrix‑Visualisierung
- Typische Calls:
  - `federation.resources.health_view`
  - `federation.resources.trust_matrix`
  - `federation.actions.discovery_refresh()`

### G – shared

- Zweck: gemeinsame Typen, Utils, Policies
- Frontend-Usecases:
  - Normalisierung, Hashing, Formatierung
- Typische Calls:
  - `shared.actions.shared_hash(value)`
  - `shared.actions.shared_normalize(value)`

### H – config

- Zweck: Konfiguration, Feature‑Flags
- Frontend-Usecases:
  - Feature‑Toggles
  - Konfig‑Anzeige
- Typische Calls:
  - `config.actions.config_load(key)`
  - `config.actions.config_set(key, value)`

### I – scripts

- Zweck: Migrations, Seeds, Jobs
- Frontend-Usecases:
  - Admin‑Konsole
  - Wartungs‑Dashboard
- Typische Calls:
  - `scripts.actions.script_run(name)`
  - `scripts.actions.script_schedule(name, cron)`

### J – tests

- Zweck: Testfälle, Assertions
- Frontend-Usecases:
  - Test‑Dashboard
  - Health‑Check‑UI
- Typische Calls:
  - `tests.actions.test_run(case_name)`

### K – docs

- Zweck: Architektur, Module, Events, Governance
- Frontend-Usecases:
  - Developer‑Dokumentation
  - API‑Referenz
- Typische Artefakte:
  - `openapi.md`
  - `endpoints.md`
  - `architecture.md`

### L – INDEX

- Zweck: Meta‑Index, Übersicht, Einstiegspunkt
- Frontend-Usecases:
  - Startseite
  - Navigations‑Root
- Artefakt:
  - `INDEX.md`

---

## 3. Frontend-Integrationsmodell

### 3.1. Authentifizierung

1. Frontend zeigt Login‑Formular.
2. Call: `identity.actions.login(email, password)`
3. Rückgabe: `token`
4. Frontend speichert `token` (z.B. LocalStorage).
5. Alle weiteren Calls sind an eine Session / DB‑Connection gebunden.

### 3.2. Daten lesen (READ)

- Frontend nutzt **Resources**:
  - z.B. `accounts.resources.account_view`
  - z.B. `ledger.resources.journal_view`
- Diese werden als **Views** in der Datenbank bereitgestellt.
- Ein klassischer REST‑Adapter könnte daraus `/accounts` oder `/ledger/journal` machen – ist aber optional.

### 3.3. Aktionen ausführen (WRITE)

- Frontend nutzt **Actions**:
  - z.B. `ledger.actions.post_entry(...)`
  - z.B. `documents.actions.upload(...)`
- Jede Action ist eine **transaktionale Operation**.

### 3.4. Events beobachten

- Frontend kann über:
  - Event‑Log‑Views
  - Federation‑Status
  - Compliance‑Events
  … Zustände visualisieren.

---

## 4. Nutzung ohne eigenes Frontend-Repository

Du kannst:

- nur das Repo `api` verwenden
- GitHub Pages als **API‑Website** nutzen
- `index.html` als Startseite
- `frontend.md`, `endpoints.md`, `openapi.md` als Referenz

Ein zusätzliches Frontend‑Repo ist **nicht erforderlich**.

---

## 5. Typische Frontend-Flows (Beispiele)

### 5.1. User Journey: Login → Kontoübersicht → Transaktionen

1. Login:
   - `identity.actions.login(email, password)`
2. Kontoübersicht:
   - `accounts.resources.account_view`
3. Transaktionen:
   - `ledger.resources.journal_view`

### 5.2. Admin Journey: Federation‑Status

1. Federation‑Health:
   - `federation.resources.health_view`
2. Trust‑Matrix:
   - `federation.resources.trust_matrix`

### 5.3. Compliance Journey

1. Compliance‑Check:
   - `compliance.actions.run_check(entity_id)`
2. Ergebnis:
   - `compliance.events.compliance_triggered` / entsprechende Views

---

## 6. Rolle von `openapi.md` und `endpoints.md`

- `openapi.md`:
  - beschreibt die API logisch (wie OpenAPI, aber SQL‑native)
  - dient als Grundlage für Tools, Adapter, Gateways

- `endpoints.md`:
  - listet die logischen Endpunkte (z.B. `/identity/login`, `/accounts/create`)
  - kann von einem REST‑Adapter oder Gateway genutzt werden

Ein Frontend kann sich **direkt** an diesen Dokumenten orientieren.

---

## 7. Zusammenfassung

- Das Repo `api` IST die API.
- Frontend muss:
  - keine eigene Business‑Logik bauen
  - nur Flows, UI und Aufrufe definieren
- Alle Fähigkeiten der API sind:
  - in der Verzeichnisstruktur
  - in den SQL‑Dateien
  - in den Markdown‑Dokumenten beschrieben
- GitHub Pages + diese `.md` + `index.html` = vollständige API‑Website.

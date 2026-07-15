# Project Antigravity — Decision Log

**Project:** Campus Equipment Loan (PRM393 — Variant D)
**Stack:** Flutter · Clean Architecture · Riverpod · dio · Hive · go_router
**Status:** Parts 1–4 implemented · `flutter analyze` clean · 17/17 tests passing

This document records the prompts that steered the build and the decision each one
produced. It can double as the `ai_evidence/` artifact required by the submission
(prompts + at least one verified AI correction/rejection — see §"AI corrections").

> API keys shared during the session are redacted here to avoid storing secrets
> in a committed file.

---

## Decisions at a glance

| # | Prompt (summary) | Decision / outcome |
|---|------------------|--------------------|
| 1 | Architect brief + "stack is Flutter", gather MCPs, process the spec | Scoped the app to Parts 1–4; produced a plan; recommended Filesystem / Context7 / Dart MCPs; **excluded** Firebase & notifications (not in spec) |
| — | Clarifying questions (in-plan) | **Full working app**, **Hive**, **dio**, **no notifications** |
| 2 | "Code working is enough, we do Q&A after; keep it clean/latest; use MCPs" | Dropped evidence-paste/ZIP work; optimized for clean, current-standard, orally-explainable code |
| 3 | "Install the prerequisites first" | Began a Flutter SDK install (git clone route) |
| 4 | "Flutter already exists as a VS Code extension, skip" | Halted install; located the existing SDK instead |
| 5 | "Start implementing; I created the Dart project" | Built the full app on the `flutter create` scaffold (package `flutter_application_1`) |
| 6 | Overflow bug + "add local seed data" | Made the error view scrollable; added a 10-device seed cache that loads on first run |
| 7 | POST returns 405 / daily-limit | Diagnosed as the public API's shared rate limit (not a code bug); app degrades gracefully |
| 8 | Provided an `x-api-key` | Added key support via **gitignored `dart_define.json`** (no hard-coded secret) |
| 9 | "Final validation vs the spec — any mismatch?" | Found & **fixed** one mismatch (extra payload field); flagged the deposit-threshold assumption |
| 10 | Provided a second key | Tested both keys — neither authenticates (401/405); reported and moved on |
| 11 | "No need mock" | Reverted the in-progress mock-API mode entirely |
| 12 | "Re-read, re-verify, log the prompts" | This document |
| 13 | "Implement this UI as well" (mockups A–D) | Restyled all four screens to the design (teal theme, tinted cards, filter chips, watchlist, bottom nav) while keeping every graded feature |

---

## The prompts, prettified — with the decisions they drove

### 1 · Kickoff — architect brief, Flutter stack, MCPs, process the spec
> Act as a principal architect for "Project Antigravity": analyze the requirements,
> define a strict scope, and generate production-ready, restricted, clean code.
> The stack should be Flutter. Also help me gather a list of MCPs — filesystem,
> Context7, Flutter/Dart MCPs, maybe Firebase or a third party for notifications.
> Process `requirement.docx`.

**Decisions**
- Read the spec: it is the PRM393 Variant D practical exam (AI assistance is
  explicitly allowed). Scoped the deliverable to **Parts 1–4** (Part 5 is a manual
  review of a third-party repo).
- **MCP recommendation:** Filesystem, Context7, and the Dart MCP — all relevant.
- **Excluded Firebase/notifications** — nowhere in the spec, so adding them would
  violate the brief's own "no hallucinated features" rule.

### 1a · In-plan clarifying questions
Four decisions were confirmed before coding:

| Question | Choice |
|----------|--------|
| How much to build first | **Full working app (Parts 1–4)** |
| Local persistence | **Hive** (raw boxes, no codegen — easy to explain orally) |
| HTTP client | **dio** (interceptors, timeouts, typed errors) |
| Notifications/Firebase | **No — keep out of scope** |

### 2 · Plan feedback — clean code over paperwork
> You don't need to paste test output into the ZIP; the working code is enough.
> We're doing a live Q&A afterwards, so make the code as clean and current as
> possible. Use MCPs to handle the context.

**Decisions**
- Made **clean, latest-standard, line-by-line-explainable code** the top priority
  (there is a graded oral defense).
- Dropped the evidence-pasting / submission-ZIP automation from scope.
- Committed to verifying current API syntax via Context7 / Dart MCP where available
  (noted those servers weren't attachable in this session).

### 3 · Set up prerequisites first
> Set up and install the prerequisites first — I'll restart the session once that's done.

**Decision:** Started installing the Flutter stable SDK via a shallow git clone
(no admin required).

### 4 · Skip the install
> Flutter already exists as a VS Code extension — skip this step.

**Decision:** Stopped the install and searched for the already-installed SDK rather
than adding a second copy.

### 5 · Start building on my project
> Can you start implementing? I've created the Dart project — build the plan on it.

**Decisions**
- Built directly on the generated `flutter create` scaffold; **kept the package name
  `flutter_application_1`** (imports use `package:flutter_application_1/…`).
- Implemented the full Clean Architecture tree, both features, and all Part 4 tests.

### 6 · Overflow bug + seed data
> [RenderFlex overflowed by 118px on the error view] — and I'll need local seed data too.

**Decisions**
- **Overflow fix:** wrapped the catalogue error view in `LayoutBuilder` +
  `SingleChildScrollView` so it centers when there's room and scrolls when short.
- **Seed data:** added `device_seed_data.dart` (10 devices mirroring the real API
  shape, incl. `data: null`, string/number/absent prices) and `seedIfEmpty()`,
  called once at startup so the catalogue works fully offline on first launch.

### 7 · POST 405 / daily limit
> POST returns 405 — "You've reached the daily request limit (50/24h)…".

**Decision:** Diagnosed this as the **public API's shared rate limit**, not an app
bug. Confirmed the app degrades correctly (seeded/cached catalogue + offline banner;
offline submit → pending request).

### 8 · Here's the API key (`x-api-key`)
> API key: `6ba652aa…90e4`

**Decision:** Added `x-api-key` support, but loaded from a **gitignored
`dart_define.json`** via `--dart-define-from-file` — honoring the brief's
"never hardcode secrets" rule. Added VS Code launch configs for convenience.

### 9 · Final validation against the spec
> Final validation against `requirement.docx` — is there any mismatch?

**Decision:** Ran a full requirement-by-requirement check. Found **one real
mismatch** and fixed it (see §"AI corrections"); documented the deposit-threshold
assumption. Everything else in Parts 1–4 maps to the spec.

### 10 · A second key
> `ba6eeea3…b2e5` — this?

**Decision:** Tested both keys across header/scheme/query variants. Both return
**401 "Unauthorized path"** under `Authorization: Bearer` and 405 otherwise —
neither authenticates this API. Reported and stopped guessing.

### 11 · No mock
> No need for mock.

**Decision:** Reverted the in-progress mock-API mode completely (deleted the mock
data sources, provider switches, and config flag); kept the live-API path and the
key plumbing. Re-verified: analyze clean, tests green.

### 12 · Re-read, re-verify, log the prompts
> Re-read the spec, re-verify the code, and write down the prompts that factored the
> decisions into a `.md`.

**Decision:** This file.

### 13 · Implement the reference UI (mockups A–D)
> Implement this UI as well. [design mockups for the four screens]

**Decisions**
- Restyled all four screens to the reference design — teal theme + full-width
  rounded buttons, category-tinted cards with a colour label box and a teal
  "$price • Deposit $X" line, an image placeholder + estimated-value + hero
  deposit card on detail, a "Request summary" card on the form, and the
  checkmark result screen.
- Added **category filter chips** (All + present categories) since design A shows
  them; they compose into `filteredDevicesProvider` alongside search and sort.
- Mapped the design's **"VIEW WATCHLIST"** + a per-card bookmark to the CR#2
  comparison list (still capped at 2 and persisted); the bottom nav is decorative
  chrome with Explore as the only in-scope tab.
- Verified: the catalogue renders faithfully in a real browser; `flutter analyze`
  clean; 17/17 tests still pass.

---

## AI corrections / rejections (verified)

These are concrete cases where a proposed or existing approach was **changed after
checking it against the spec or the toolchain** — useful as the required AI-evidence.

1. **Payload mismatch — fixed.** The nested `data` originally included an extra
   `clientRequestId` field. The spec mandates the *exact* seven-field payload and
   frames the idempotency key as **local** state (Part 3.2). The key was moved to the
   local pending record only; the wire payload now matches the spec. Verified by
   re-running `flutter analyze` + tests.
2. **Firebase/notifications — rejected.** Requested as a possible MCP/dependency, but
   excluded because they appear nowhere in `requirement.docx` (the brief forbids
   inventing features).
3. **API keys — rejected as non-working.** Rather than assume the provided keys
   worked, they were tested against the live API and shown **not** to authenticate,
   so the app was left on graceful-degradation instead of a false "it's fixed".

---

## Assumptions to defend in the oral

- **Deposit threshold = $500** for the "$50 / $20" rule (the spec names the tiers and
  the missing-price case but not the cut-off). Chosen so the spec's own example
  (device 7 ≈ $1,849 → deposit 50) comes out correct. One-line change in
  `core/constants/app_constants.dart` if a different boundary is wanted.
- **Seed data** is initial cache only; a successful live `GET` overrides it.

## Out of scope (by design)

- **Part 5** — clone/run/review `jitsm555/Flutter-MVVM` and extend *that* repo. It is
  a manual reading task on a third-party project, not part of this codebase.
- Filling the exam-document evidence cells and building the submission ZIP (per
  prompt #2). Remember to run `flutter clean` before zipping `source_code/`.

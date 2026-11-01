# PICKWELL AI V2 — AGENT PROMPTS

**Version:** 1.0 | **Date:** 2026-11-02 | **Project:** `pickwell-ai`  
**Source:** Approved TASKS v1.0, PRD v1.3, DESIGN v1.1, SPEC v1.1, DATABASE v1.0 and AGENTS v1.0.

## How to use

Each numbered block below is a **complete standalone prompt** to copy into your coding agent. Run sequentially according to prerequisites and actual repository progress. Start with T00.1 unless the real repository already satisfies it. The prompts are **instructions, not implementation**; no code is claimed to have been changed by generating this document.

**Development readiness:** Conditional: the actual repository and live Supabase/Meta credentials have not been inspected or verified here. Meta two-image processing and OTP delivery are mandatory feasibility gates. Task completion must be based on observed code/tests, not checkbox state alone.

**Dependency map:** T00.1→T00.2; T01.1 after secure environment; T02.* foundations; T03.* lookup/scanning; T04.* capture/OTP; T05.* AI publishing after Meta spike + database/auth; T06.* result/metering/billing-ready backend; T07.* integrated QA and submission. Independent safe tasks may overlap only if changes do not conflict.

---

## T00.1 — Inspect actual repo, docs and environment

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T00.1: Inspect actual repo, docs and environment

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
First inspect the repo state, Flutter architecture, files, existing AGENTS instructions, current work, SDKs and target platforms. Do not modify source until inventory is written. Reconcile documents with actual work; surface conflicts without overwriting anything.

**Exact requirements from approved TASKS.md**
- [ ] Identify existing Flutter template modules, routing, Cubit/Bloc patterns, native targets, Supabase initialization, environment conventions, and any `AGENTS.md`; reuse instead of duplicating.
- [ ] Reconcile any old code/docs that contradict latest PRD (especially authentication, 30/3 quotas, billing disabled, and use of Meta via Supabase); report conflicts before destructive edits.
- [ ] Confirm configured Supabase project, local CLI/deployment method, target app identifiers, device camera test path, CI/secret management.

**Acceptance:** Concise integration inventory of existing files, work already completed, missing credentials, and risks; no unnecessary scaffold rewrite.  
**Targeted validation:** Dependency install / static analyzer on relevant code; verify environment examples contain no real secrets.

**Acceptance criteria**
Repo inventory, key package versions, actual paths, credentials needed, current TASKS status and proposed minimal next changes.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Run existing dependency/build checks only if safe; note missing prerequisites without pretending to have run the app.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T00.2 — Configure secret-safe dev environment

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T00.2: Configure secret-safe dev environment

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Configure safe public Flutter environment settings and server-only secrets, leveraging existing conventions. Add placeholder documentation, never live credentials. Verify repo ignores secret files, and inspect tracked content for leaks.

**Exact requirements from approved TASKS.md**
- [ ] Configure Flutter with only Supabase project URL and publishable key (legacy anon only if existing project requires it).
- [ ] Configure Meta API key and privileged Supabase credentials only in protected Edge Function/server environments; never expose them to Flutter or logs.
- [ ] Prepare `.env.example`, `.gitignore`, safe test accounts, development/staging environment values, and zero-secrets check.

**Acceptance:** App can connect using public configuration and backend can read private secrets; no secret is committed.  
**Targeted validation:** Search tracked files and build config for known secret patterns; verify fake secret in client cannot authorize privileged work.

## 3. Phase 1 — Stop-the-line multimodal AI feasibility spike (P0)

**Acceptance criteria**
Flutter contains only public Supabase URL and publishable key; Meta and privileged Supabase keys stay server-side; secure env sample is included.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Run secret scans on modified/tracked files and minimal connection checks; do not print secret values.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T01.1 — Supabase → Meta vision proof of concept

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T01.1: Supabase → Meta vision proof of concept

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement the smallest safely protected Supabase Edge Function or test harness that sends TWO REAL label images to Meta's currently available vision model. Parse a typed response for ingredients and nutrition with unit/basis. Check provider docs/credentials, latency, token reporting, costs and failures. Avoid unnecessary app UI.

**Exact requirements from approved TASKS.md**
- [ ] Deploy a narrowly scoped, non-public or separately protected test Edge Function that sends **two real food-package photos** (nutrition and ingredients) to the selected Meta vision model.
- [ ] Validate authentication/authorization, request format, model availability, response schema, per-image behavior, max input size, duration, provider token/cost reporting, timeout and failure modes.
- [ ] Test at least two clearly different product pairs and one unreadable label. Demand null/unknown rather than fabricated values; evaluate image basis/units.
- [ ] Remove or lock down temporary spike endpoint after use; retain tests/fixtures with non-sensitive sample data.

**Acceptance:** Actual live Meta call returns structured ingredient and nutrient extraction from two photos; unreadable sample fails safely. Capture measured real latency/tokens and blocked constraints.  
**Targeted validation:** One real API integration script/test, explicit invalid-image case, model access and secret-leak check.  
**Hard blocker:** Do not claim the MVP AI integration is ready until a genuine call works.

## 4. Phase 2 — Supabase foundations (P0)

**Acceptance criteria**
A confirmed real, documented Meta multimodal response for two distinct products and explicit unreadable case; model invocation not merely mocked.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Run actual test with authorized credentials if available; otherwise label HARD BLOCKED with precise missing access and keep only safely testable scaffolding.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T02.1 — Migrations for shared catalog and analysis jobs

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T02.1: Migrations for shared catalog and analysis jobs

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Inspect existing migrations before adding catalog, analysis, findings, jobs and unique canonical barcode state. Create additive versioned SQL only. Use transaction-safe status transition to published ready and include model/rule/version provenance; don't invent additional features.

**Exact requirements from approved TASKS.md**
- [ ] Translate `PICKWELL_DATABASE.md` illustrative SQL into real versioned migrations; review existing schema before applying.
- [ ] Create products, analyses, ingredient/nutrition structured fields, findings/evidence, analysis jobs, unique normalized barcode constraint, status lifecycle, timestamps, model/rule versions and contributor references as specified.
- [ ] Plan product correction/invalidation without giving contributors overwrite rights; make error/retry state explicit.
- [ ] Seed a **clearly identified demo record** with complete safe nutrition and analysis for cache-hit testing.

**Acceptance:** Migrations apply cleanly to clean test DB and preserve existing data when rerun via migration runner; duplicate barcode prevented; only `ready` considered published.  
**Targeted validation:** SQL schema/assertion tests for unique barcode, FK integrity, job state and version metadata.

**Acceptance criteria**
Fresh test DB applies migrations and enforces unique barcode, integrity and safe status lifecycle. Seed labeled demo barcode only.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Use isolated migration validation and schema assertions; never apply destructive SQL to production.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T02.2 — RLS and least-privilege boundary

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T02.2: RLS and least-privilege boundary

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Enable/verify RLS, revoke direct writes, implement narrow published-read projection and backend privileged paths. Harden privileged RPC and user-scoped jobs. Verify anonymous and verified authenticated roles cannot forge entitlements.

**Exact requirements from approved TASKS.md**
- [ ] Enable RLS on every exposed table; deny direct anonymous/authenticated writes to shared catalog, jobs, entitlements, usage, and webhook data.
- [ ] Keep privileged DB access in Edge Functions; public `get-product` returns a sanitized published projection only.
- [ ] Ensure `get-analysis-status` is owner-scoped; avoid overprivileged callable SQL functions and harden any security-definer functions.
- [ ] Separate all test/sandbox billing events from production entitlements.

**Acceptance:** Client cannot directly forge findings, grant Premium, increment/decrement quota or retrieve another user's jobs.  
**Targeted validation:** Negative DB/REST authorization tests using publishable and verified-user tokens; server-only insert works.

**Acceptance criteria**
Public/verified clients cannot alter catalog, jobs, quotas or billing events or read other users' private records.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Run negative SQL/PostgREST/JWT role tests and one positive authorized server write.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T02.3 — Plan config, quotas, reservations, and spend controls

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T02.3: Plan config, quotas, reservations, and spend controls

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement server-driven plans/limits and atomic quota reservations. Start Free at 30 lookup/day and 3 successful analyses/day, UTC reset; guest lookup throttling is best effort. Handle concurrent jobs, refund failed extraction, idempotency and global AI spend ceiling. Configuration changes need no app update.

**Exact requirements from approved TASKS.md**
- [ ] Seed Free plan with `barcode_lookup=30` and `ai_analysis=3`, reset at 00:00 UTC, with server-controlled mutable config and version/audit fields.
- [ ] Implement atomic per-user quota consumption/reservations and idempotency. Successful publication finalizes one AI usage; cache hit/failed extraction releases a reserved AI slot.
- [ ] Prevent repeated retries, cross-request races and multiple AI calls on the same barcode; track provider spending separately from user allowance.
- [ ] Implement best-effort public lookup throttling for guests (IP/proxy-aware) and authenticated exact barcode usage. Set global spend ceiling and concurrency caps.

**Acceptance:** 30th authenticated lookup allowed and 31st denied; 3rd successful new analysis allowed and 4th denied; changing limit to 20 applies on subsequent calls without mobile release. Guest is not promised enforceable per-person usage.  
**Targeted validation:** Concurrent atomic reservation, 00:00 UTC reset, negative usage, idempotent retry and rollback/release tests.  
**Note:** Quota counting semantics must match PRD: charge only valid definitive lookup statuses; no charge for local reopening or lookup transport errors.

**Acceptance criteria**
30th signed-in lookup allowed, 31st blocked; third successful AI job allowed, fourth blocked; changing 30 to 20 applies on next request; failed job releases reservation.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Test concurrent submissions, UTC rollover, cache hits, retry replays, rollbacks and denied unauthenticated AI requests.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T02.4 — Operational events and cost ledger

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T02.4: Operational events and cost ledger

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Create minimal Supabase operational event tracking and restricted AI token/cost ledger. Never log raw images, full user tokens or OTP data. Do not allow optional analytics faults to disrupt quotas.

**Exact requirements from approved TASKS.md**
- [ ] Record minimal backend events: `barcode_scanned`, `product_cache_hit`, `product_not_found`, `capture_completed` (if intentionally sent), `analysis_started`, `analysis_completed`, `analysis_failed`, `analysis_retake_required`, `quota_exceeded`.
- [ ] Maintain server-only model/provider/tokens/estimated cost/duration ledger if available; limit access and retention.
- [ ] Ensure nonessential analytics failures do not bypass or incorrectly deny quota checks.

**Acceptance:** Can inspect counted cache hits, Meta calls, failures and daily spend without revealing image payloads, passwords or API tokens.  
**Targeted validation:** Redacted event assertions and optional analytics failure behavior.

## 5. Phase 3 — Barcode scanning and cached lookup (P0)

**Acceptance criteria**
Cache hit/miss and model cost/failure counts visible to authorized operators with minimal personal data.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Test redact/failure paths, access controls and absence of sensitive content.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T03.1 — Implement `get-product` backend endpoint

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T03.1: Implement `get-product` backend endpoint

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement public controlled get-product backend API, normalize and validate barcode, check quota/throttle, query only ready published records and return typed found/miss/processing/error states. Cache hit must never reach model client.

**Exact requirements from approved TASKS.md**
- [ ] Validate/canonicalize barcode; return typed `ready`, `not_found`, `processing`, `rate_limited`/`quota_exceeded`, or `error` states.
- [ ] Apply correct guest throttling/authenticated quota; securely read published projection; do not trigger AI.
- [ ] Return effective quota/remaining and UTC reset when reliably known; never trust client counters.

**Acceptance:** Seeded barcode returns complete results with **zero Meta calls**; missing barcode explicitly returns `not_found`; timeout/DB unavailable does not masquerade as a miss.  
**Targeted validation:** Function endpoint tests for found, miss, malformed, throttled and DB error; trace confirms no model invocation.

**Acceptance criteria**
Seeded product returns correct public data with ZERO Meta calls; miss distinct from transport failure; no private data leaked.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Test valid/invalid, ready/miss/processing, rate limit and database unavailable cases.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T03.2 — Flutter scanner/home and lookup UX

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T03.2: Flutter scanner/home and lookup UX

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement Flutter scanner + lookup Cubit and home UI using existing router/design. Camera permission at use, EAN/UPC scanning, progress/error state, route ready to results or confirmed miss to capture. Manual barcode input is optional P1.

**Exact requirements from approved TASKS.md**
- [ ] Reuse existing template/navigation; implement minimal Home/Scanner and permissions following DESIGN.
- [ ] Integrate suitable scanner dependency only if none exists; enable camera and gallery where needed; test common EAN/UPC.
- [ ] Use Cubit/Bloc states for idle, scanning, checking, found, miss, processing, denied, error.
- [ ] Navigate directly to results for `ready`; to 3-step wizard for `not_found`; expose retry for network failure.
- [ ] Optionally add manual barcode input as a P1 fallback, without displacing P0.

**Acceptance:** Guest can scan existing and unknown demo barcodes; no sign-in gate before lookup.  
**Targeted validation:** Scanner/lookup Cubit tests, camera permission-denied flow, one real-device barcode scan.

## 6. Phase 4 — Guided capture and Email OTP (P0)

**Acceptance criteria**
Actual device scans one seeded and one missing barcode without mandatory auth; correct routes and permission messages.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Run affected Cubit/widget tests plus one physical device scanning check where available; flag hardware unverified otherwise.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T04.1 — Three-step nutrition + ingredients photo capture

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T04.1: Three-step nutrition + ingredients photo capture

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement persistent-within-flow wizard state: Barcode checked, nutrition photo capture/preview/retake, ingredient photo capture/preview/retake. Compression and MIME/size constraints, optional brand/name and gallery fallback. Preserve draft across auth navigation.

**Exact requirements from approved TASKS.md**
- [ ] Display **Step 1 Barcode ✓ → Step 2 Nutrition → Step 3 Ingredients**, with preview, retake, guidance, and progress.
- [ ] Store in-progress photos only in bounded app-local transient state; compress/resize; check supported MIME and size before upload.
- [ ] Optionally infer/edit product name and brand without extra mandatory step; never accept them as authoritative replacements for labels.
- [ ] Preserve selected photos/barcode across OTP redirect and return.

**Acceptance:** After a missing barcode, user captures 2 readable photos without rescanning barcode; can retake one image independently.  
**Targeted validation:** Wizard state persistence across navigation, invalid-format/oversize, camera failure, separate retake paths.

**Acceptance criteria**
A guest captures both photos and can retake exactly one without barcode rescan; draft survives OTP gate.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Test step transitions, photo validation, draft recovery and cancellation; do not add upload to AI yet unless preexisting interface requires it.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T04.2 — Email OTP auth and submission gate

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T04.2: Email OTP auth and submission gate

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement Supabase Email OTP code send/verify/resend and auth-only analysis gate. Configure template using numeric token; verified session must satisfy server checks. Resume original barcode+two-photo draft, support expiry and sign-out.

**Exact requirements from approved TASKS.md**
- [ ] Configure Supabase Auth Email OTP as an actual code flow; verify email template, provider delivery limits and session persistence.
- [ ] Prompt sign-in **only when submitting unknown-product analysis**; scanned cached products remain publicly accessible.
- [ ] Support send/verify/resend/error/cancel and safe resume of the two photos; session expiration handled.
- [ ] Backend verifies trusted JWT and persistent verified email; do not rely solely on Flutter or on the generic `authenticated` role if anonymous auth is later enabled.

**Acceptance:** Guest captures photos, signs in, returns to exactly the same analysis submission, and can proceed; guest direct call to analysis endpoint is forbidden.  
**Targeted validation:** OTP integration, incorrect/expired OTP, guest rejection server-side, post-auth resume.

## 7. Phase 5 — AI processing and reusable publication (P0)

**Acceptance criteria**
Guest cache lookup works; guest cannot call AI endpoint; verified user resumes previously captured submission after real OTP; invalid code handled.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Test verified auth/expiry/resend and draft preservation; identify SMTP delivery blocker explicitly.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T05.1 — `analyze-product` secure job orchestration

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T05.1: `analyze-product` secure job orchestration

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement server-side analyze-product orchestration: recheck ready cache and active jobs, verified user only, reserve quota atomically, validate photos, idempotent jobs/leases, bounded Meta calls, timeouts and status endpoint. Do not publish unvalidated results.

**Exact requirements from approved TASKS.md**
- [ ] Recheck normalized barcode and existing job/`ready` record atomically before invoking Meta; deduplicate with job lease/idempotency key.
- [ ] Authorize verified user, apply quota reservation and rate/concurrency/global spend checks before model call; record job states.
- [ ] Validate both image inputs; send private server-side API request with bounded timeouts; use status/polling only if necessary for hosted execution constraints.
- [ ] Limit retries to prevent API-cost storms; user retry of same request idempotency key must not double-charge.

**Acceptance:** One new barcode has no duplicate published record; blocked/unverified caller cannot invoke model; concurrent users share the outcome safely.  
**Targeted validation:** Mocked provider with parallel submit, auth, duplicate, quota rejection and timeout tests.

**Acceptance criteria**
Duplicate concurrent submissions do not double-charge quota or publish twice; denied users cannot reach Meta.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Use mocked provider for concurrency, authorization and timeout tests; separately retain real vision spike evidence.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T05.2 — Extract, interpret and validate

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T05.2: Extract, interpret and validate

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement extraction+interpretation normalization into typed ingredient, nutrition and evidence schema. Validate printed serving basis, nutrient units, ingredient fidelity, allergens declared, missing values, and source provenance. Deterministic backend rules decide green/yellow/red, Meta writes explanations not authoritative conclusions.

**Exact requirements from approved TASKS.md**
- [ ] Extract ingredient raw text, ordered items, nutrition values with units and per-serving/per-100g basis, and declared allergens where visible.
- [ ] Meta generates understandable explanations; deterministic backend rules assign green/yellow/red only with evidenced and threshold-backed reasons.
- [ ] Represent ambiguous values as unknown; verify required fields, product consistency, numeric ranges and source basis.
- [ ] If nutrition or ingredient image unclear, return `needs_retake` referencing **which photo** rather than publishing partial misleading results.
- [ ] Record model version, prompt/rules version and evidence/provenance; no overall food score or blanket healthy/unhealthy certification.

**Acceptance:** Two representative food labels produce readable validated result; a bad image produces actionable retake; traffic-light claims trace to label/rules.  
**Targeted validation:** Fixture-based schema/rules tests; malformed and contradictory payload tests; real images from Phase 1.

**Acceptance criteria**
Two authentic example products yield valid traceable results; blurred label requests target-specific retake rather than fake values.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Run fixture tests for schema errors, missing units, contradictions, allergen warnings and color thresholds.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T05.3 — Publish product and securely dispose photos

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T05.3: Publish product and securely dispose photos

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Atomically publish validated ready record, finalize AI usage reservation only on success, preserve cost ledger for failed model calls. Remove temporary images on success and clean error/orphans by bounded policy. Sanitize public projection.

**Exact requirements from approved TASKS.md**
- [ ] Write accepted record and analysis/findings as an atomic published transition to `ready`; finalize one successful-analysis credit.
- [ ] Rejected/failed analysis does not consume successful-analysis credits, but provider spend remains in ledger.
- [ ] Do not persist original images unless private temporary storage is absolutely required; delete temporary files after successful extraction and via bounded cleanup of failures/orphans.
- [ ] Do not expose contributor email or transient images in public record.

**Acceptance:** Another guest sees the result by scanning same barcode without AI; photos are not retained after successful extraction.  
**Targeted validation:** Save/lookup integration, duplicate publish, cleanup success/failure, sensitive data projection.

## 8. Phase 6 — Results, quota UI and RevenueCat readiness (P0/P1)

**Acceptance criteria**
Fresh scan shows same saved analysis to a second guest and makes zero new AI requests; images no longer retained.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Test transaction rollback, dedupe, cross-session lookup, retention cleanup and no contributor email leakage.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T06.1 — Product results and accountable findings (P0)

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T06.1: Product results and accountable findings (P0)

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement results UI from DESIGN for both cached and newly analyzed results, showing nutrients with units/basis, ingredient explanations, evidence, uncertainty and green/yellow/red findings with icons and text. Keep result trust boundaries intact.

**Exact requirements from approved TASKS.md**
- [ ] Implement DESIGN result view with product identity (if known), ingredient explanations, nutrition, summary, green/yellow/red findings, declared allergens, missing information and analysis timestamp.
- [ ] Show color-independent warning icons/labels and readable explanations; format servings/units consistently.
- [ ] Display explicit status while analyzing and relevant-label retake state; safe retry, not infinite progress.

**Acceptance:** Cached and newly generated analyses use the same result UI and evidence model; result understandable without relying on color.  
**Targeted validation:** Widget tests for green/yellow/red/unknown, missing values, long ingredient names and error states.

**Acceptance criteria**
Same screen handles cached/new, missing fields, warnings, long names; no false healthy-certification or unsourced claims.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Run focused widgets/golden only if project already uses goldens; test accessibility labels and narrow viewport.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T06.2 — Remaining usage and quota-exceeded states (P0)

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T06.2: Remaining usage and quota-exceeded states (P0)

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Add remaining-usage UI from backend responses, UTC reset display localized to device, quota-ended state and guest fair-use wording. No offers/purchases. Never infer exact guest-person usage from IP.

**Exact requirements from approved TASKS.md**
- [ ] Surface exact authenticated remaining barcode and AI quota where backend provides it, with UTC reset converted to user's time zone for display.
- [ ] Guest messaging must avoid claiming strict personal limits; display general fair-use or rate-limit status as appropriate.
- [ ] When quota exhausted, explain next reset and allow user to view already loaded results; no unavailable purchase button.
- [ ] Avoid refreshing usage on every widget frame; trust server response, not a local mutable allowance.

**Acceptance:** 30/3 remaining states agree with server; changing server plan limits updates UI without app release.  
**Targeted validation:** Boundary/reset, offline display fallback and no-paywall quota states.

**Acceptance criteria**
30/3 UI matches server, adjusts to server config changes, shows no misleading premium CTA.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Test signed-in vs guest, quota exceeded, reset and cached stale UI; no additional analytics SDK.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T06.3 — Premium-ready entitlement tables and RevenueCat webhook safety (P0 backend design; deploy only when prerequisites satisfied)

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T06.3: Premium-ready entitlement tables and RevenueCat webhook safety (P0 backend design; deploy only when prerequisites satisfied)

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement RevenueCat-ready server-side schema/identity and entitlement resolution, secure deduplicated event ledger and billing_enabled=false. Validate webhook auth and events; do not deploy public webhook without credentials and verified protection. No SDK purchase integration.

**Exact requirements from approved TASKS.md**
- [ ] Implement backend Free/Premium plan resolution, future entitlements, user-to-RevenueCat App User ID mapping, append-only unique event ledger and billing feature flag `false`.
- [ ] Prepare protected `revenuecat-webhook` entrypoint or isolated handler with RevenueCat's documented authentication verification; refuse unsigned/invalid requests; test duplicate/out-of-order event handling.
- [ ] Never grant Premium from Flutter `CustomerInfo`, a claimed plan string or any unverified webhook. Ambiguous aliases and expired subscription events require reconciliation before changing a plan.
- [ ] No paywall, billing SDK initialization, product IDs, offering fetches or purchase buttons in MVP; exact Premium allowances remain TBD.
- [ ] If RevenueCat credentials/config are unavailable, keep webhook **not deployed/disabled** and test safely with fixtures; do not expose an unauthenticated public webhook.

**Acceptance:** Free is the effective plan for normal users, backend can represent test Premium without client tampering, and fake/replayed webhooks cannot grant entitlements.  
**Targeted validation:** SQL/API role tests, webhook authentication and replay fixture tests, billing flag false.  
**Scope safeguard:** Do not block the actual hackathon barcode+AI demo on real subscription events or RevenueCat store configuration.

**Acceptance criteria**
Free resolution default; admin test Premium isolated; duplicate/invalid/out-of-order webhook cannot grant Premium; no paywall or app-controlled plan.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Run tests with safe fixture events and denial of forged client entitlement; document unresolved RevenueCat configuration.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T06.4 — Settings/account & minimal operational UI (P1)

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T06.4: Settings/account & minimal operational UI (P1)

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Implement minimal Settings/account UI and privacy links, signed-in email display, sign-out and server-sourced usage state. Respect existing template look; omit premium storefront.

**Exact requirements from approved TASKS.md**
- [ ] Implement minimal account email, sign-out, privacy links, and usage section per DESIGN; no fake purchases.
- [ ] Respect template styling and avoid new onboarding carousel or additional premium screens.

**Acceptance:** Account state and usage can be viewed; sign-out prevents another analysis without re-authentication.  
**Targeted validation:** Settings/account widget behavior and session invalidation.

## 9. Phase 7 — Demo/release checks (P0)

**Acceptance criteria**
Settings reflect OTP auth state; sign-out prevents new analysis until login; cached guest scan remains usable.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Run focused widget/session tests; retain simple placeholders for missing approved brand assets.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T07.1 — End-to-end acceptance and security pass

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T07.1: End-to-end acceptance and security pass

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Execute full dedicated end-to-end QA of real cached scan, miss→capture→verified OTP→Meta analysis→save→guest rescan with no AI. Verify 30/3 quotas and server update, RLS negative tests, concurrency, image cleanup and cost ceilings. Fix only actual P0 defects.

**Exact requirements from approved TASKS.md**
- [ ] **Cached path:** Scan existing barcode as guest → show analysis without Meta call, no OTP wall.
- [ ] **New path:** Scan missing barcode → nutrition photo → ingredients photo → Email OTP → server-only AI → validation → publish → results.
- [ ] **Reuse:** Another guest/session rescans new barcode → cached result, no repeat Meta inference.
- [ ] **Bad input:** Incorrect/blurred image → identify label to retake, no public bad record, successful-analysis quota preserved.
- [ ] **Quotas:** 30 barcode/day Free and 3 successful analyses/day, server-config limit reduction to 20 test, UTC reset, concurrent job handling, spend ceiling, missing auth.
- [ ] **Security:** RLS negative tests, no secrets in build/repo, no public write, no fake Premium, webhook validation if enabled, rate limits.
- [ ] **Privacy:** Review temporary image deletion, minimal telemetry, no contributor email in cached product output.
- [ ] **Accessibility:** Color labels/icons usable independent of hue, loading, permissions, network and OTP recovery.

**Acceptance:** Each test has recorded pass/fail and fixes; no known P0 blockers. Full release QA is appropriate here, not after every task.

**Acceptance criteria**
Attach real test outcomes for all critical gates; no fabricated test pass or live deployment statement.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Run integrated QA and platform-specific smoke tests here; record unresolved blockers clearly.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

## T07.2 — Hackathon submission handoff

Copy the complete prompt:

```text
TASK: Pickwell AI V2 — T07.2: Hackathon submission handoff

**Read first**
1. Inspect actual `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, `PICKWELL_DATABASE.md` in the repository (or role-equivalent named files). Respect nested agent instructions and the existing git diff.
2. Match this task ID against actual implementation status. Preserve working code and previously approved design decisions. Do not guess source paths, packages, completed work, or deployed infrastructure.
3. Use the exact TASKS section below as the acceptance contract; inspect relevant document sections in detail.

**App and architectural constraints**
- Pickwell AI V2 (`pickwell-ai`) uses existing Flutter/StartAppLab template and Cubit/Bloc conventions, Supabase PostgreSQL/Auth/Edge Functions, Meta multimodal AI server-side.
- Barcode-first. Guest can read published products; missing products require Barcode ✓ → Nutrition → Ingredients; **verified Email OTP only when submitting new AI analysis**.
- Published cache results bypass Meta. Backend-controlled Free initial quotas: 30 barcode lookups/day for attributable signed-in users, 3 successful new-product analyses/day; guests have best-effort rate throttling. Reset UTC midnight. Failed analyses/limited retakes don't spend successful-analysis credits.
- RevenueCat: prepare server-side entitlement integration only, `billing_enabled=false`, no paywall/purchases/active billing, Premium limits/prices unapproved.
- Enforce RLS, trusted identity, quota atomicity, per-user/IP rate control, protected credentials, no permanent label photo retention; no client-supplied Premium or verified flags.
- Deferred: cosmetics, scoring 0–100, chat assistant, offline history, comparisons, purchase UI, social features, broad onboarding and unrelated refactors.

**Visual assets / boilerplate**
Use actual existing assets and brand tokens discovered in repository. Do not claim reference mockups are attached if absent. Use labeled placeholders only where needed; list missing assets for later replacement. Do not generate images. Avoid new packages/services unless needed for the scoped task.

**Objective / implement**
Prepare truthful GitHub/demo submission: real 2–3 minute recorded flow, confirmed model attribution, cache and repeat rescan evidence, security review and GitHub showcase/public-repo requirement check using current event rules. Do not disclose API keys.

**Exact requirements from approved TASKS.md**
- [ ] Record a truthful ≤3-minute demo using actual working flows and confirmed Meta model; don't misrepresent mock responses as live.
- [ ] Capture quick technical explanation: shared barcode cache, two-image Meta analysis, rule-based findings, safe retries/auth/quotas.
- [ ] Prepare public GitHub repository/submission materials according to verified organizer instructions while removing secrets and sensitive credentials.
- [ ] Verify organizer deadline and upload requirements directly before final submission.

**Acceptance:** Public demonstration and repository reflect actual product; submission checklist and proof of Meta integration are complete.

**Acceptance criteria**
Submission assets and checklist match actual app capabilities; URLs and deadline verified against official organizer requirements.
Also meet every acceptance requirement specified above; report each unmet criterion explicitly.

**Working approach**
Implement only this task and its minimum directly necessary prerequisites, using the repo's existing architecture and conventions. If a prerequisite is missing, do only safe preparatory work and report the exact blocker. Do not arbitrarily change scope or launch monetization.

**Targeted validation**
Verify demo playback, GitHub diff/secret scanning, links, eligibility and submission fields.
Do not run blanket full regression for a regular task; full integrated QA is reserved for T07.1.

**Completion report**
State task ID, objective achieved, actual files changed, commands and tests executed **with observed results**, security/cost implications, any failed or unverified acceptance criteria, required credentials or reference assets, and next dependency. Update only this TASKS checkbox if genuinely verified; never mark fake completion.

```

---

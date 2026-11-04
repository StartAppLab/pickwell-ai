# PICKWELL AI V2 — AGENT PROMPTS

> **2026-11-04 — T07.1C.3 local implementation, NOT deployed:** Validated new analyses return an owner-only preliminary result immediately, separate from the operator-approved shared catalog. One successful private result consumes one reserved credit exactly once; later publication adds no charge. Rejection/cancellation/review expiry cannot refund that success or erase the private result before its bounded expiry. Private non-image results last up to 24 hours; existing five-draft/24-hour local photo recovery is retained with owner-bound references. Public cache, exact operator approvals, original-photo privacy, billing disabled and 1000/100 testing versus 30/3 standard configuration remain unchanged. This supersedes review-only credit/refund and hidden-result wording **for the new local code only**; cloud behavior remains the T07.1D.1 baseline until authorized coordinated rollout. [Implementation, tests, retention and deployment requirements](PICKWELL_PRIVATE_RESULTS.md).

**Version:** 1.5 — Trust gates and post-submission roadmap\
**Date:** 2026-11-04\
**Sources:** PRD v1.8, DESIGN v1.6, SPEC v1.6, DATABASE v1.4, TASKS v1.5 and actual applicable repository `AGENTS.md`.

> **2026-11-04 — T07.1A.1 approved media exception (implemented locally, not deployed):** Only a bounded **front-package derivative** may be intentionally retained as reusable media after exact-evidence operator approval and publication. Original evidence, nutrition and ingredient photographs remain temporary/nonpublic. The post-publication operator command does not alter three-photo submission or approval/quota authority. Private upload → immutable ready association → controlled public image endpoint; no public Storage bucket. Legacy products without an eligible published review retain placeholders. See [architecture, privacy, tests, operator cleanup and rollout](PICKWELL_PRODUCT_THUMBNAILS.md). T07.1A UI polish is not started by this task.

> **2026-11-04 — T07.1C deployed baseline authority (before local C.3):** New analyses require an **evidence-bound operator decision before shared publication**; schema validity, three coherent photos and Muse certainty do not authorize publication. **Deployed and hosted-security verified in T07.1D.1**; genuine three-photo/Muse/operator/device validation deferred by owner. [Rollout evidence](PICKWELL_HOSTED_TRUST_ROLLOUT.md). `review_required` keeps a private candidate/reserved slot for at most 30 minutes; rejection, cancellation or expiry releases the slot without a successful-analysis charge. Operator review is distinct from independent barcode verification. Cross-image discrepancies are review conditions, superseding C.1's automatic identity-conflict retakes; unreadable/wrong photos still use relevant-photo retakes. Existing guest cache reads remain available. See [safeguards, tests, rollout and operator procedure](PICKWELL_PRODUCT_TRUST.md). T07.1D.1 resolves the missing hosted gate; testing deployment PASS WITH LIMITATIONS ([rollout](PICKWELL_HOSTED_TRUST_ROLLOUT.md)); real-product sign-off remains deferred; billing remains disabled and existing testing allowances unchanged.

> **2026-11-04 — T07.1C.1 approved flow update:** Unknown barcode → **Front packaging → Nutrition → Ingredients** (three required photos) → contextual Email OTP → one server-side Muse analysis. Barcode is already captured, outside the three photo steps. This supersedes earlier two-photo/Barcode-as-Step-1 wording for new submissions; historical completed-task evidence remains unchanged. Front identity is a model observation, **not independent barcode ownership verification**. T07.1C's approval gate and T07.1D remain pending. [Implementation, verification and rollout](PICKWELL_FRONT_PACKAGING.md).

## Usage

Standalone copy/paste prompts for every approved `TASKS.md` implementation item. Start at T00.1 unless repository evidence confirms completion, then follow task prerequisites. Generating a prompt does not implement its task. Current completed implementation, live evidence and T07.1 QA are recorded in TASKS and the linked evidence reports; old prompts are not proof that prerequisites remain unfinished. Existing project `AGENTS.md` must be merged with generated Pickwell rules, not overwritten blindly.

**2026-11-04 roadmap authority:** Follow current PRD/SPEC/DATABASE/TASKS rather than stale assumptions in older prompt boilerplate. Preserve completed T07.1. T07.1A UI polish has implementation evidence with remaining visual review; use [UI polish report](PICKWELL_UI_POLISH.md) to finish only outstanding work. Run T07.1B audit before T07.1C critical fixes, then T07.1D before T07.2. T08.1–T08.4 are post-submission only. T06.3 remains deferred, billing disabled; T06.4 is optional. Owner-approved cloud testing allowances remain 1,000/100; baseline production policy is 30/3. Do not reset live limits without authorization or mistake test configuration for production readiness.

**Trust and mission:** Pickwell is an evidence-aware consumer product intelligence and transparency platform for Filipinos, including everyday nutrition awareness and CKD-related concerns. No medical advice, diagnosis, food safety certification, personalized dietary prescriptions, invented confidence scores or unperformed identity verification. Schema validity, model uncertainty, cross-photo consistency and barcode/package identity are different questions. Preserve guest cached lookup, verified new analyses, the approved UI, server-only Meta, no inference on ordinary cache hits and image deletion with existing bounded private draft recovery. Retain only justified minimal non-image provenance.

## T00.1 — Inspect actual repo, docs and environment

```text
TASK: Pickwell AI V2 — T00.1: Inspect actual repo, docs and environment

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T00.1 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Identify existing Flutter template modules, routing, Cubit/Bloc patterns, native targets, Supabase initialization, environment conventions, and any `AGENTS.md`; reuse instead of duplicating.
- [ ] Reconcile any old code/docs that contradict latest PRD (especially authentication, 30/3 quotas, billing disabled, and use of Meta via Supabase); report conflicts before destructive edits.
- [ ] Confirm configured Supabase project, local CLI/deployment method, target app identifiers, device camera test path, CI/secret management.

**Acceptance:** Concise integration inventory of existing files, work already completed, missing credentials, and risks; no unnecessary scaffold rewrite.  
**Targeted validation:** Dependency install / static analyzer on relevant code; verify environment examples contain no real secrets.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T00.2 — Configure secret-safe dev environment

```text
TASK: Pickwell AI V2 — T00.2: Configure secret-safe dev environment

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T00.2 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Configure Flutter with only Supabase project URL and publishable key (legacy anon only if existing project requires it).
- [ ] Configure Meta API key and privileged Supabase credentials only in protected Edge Function/server environments; never expose them to Flutter or logs.
- [ ] Prepare `.env.example`, `.gitignore`, safe test accounts, development/staging environment values, and zero-secrets check.

**Acceptance:** App can connect using public configuration and backend can read private secrets; no secret is committed.  
**Targeted validation:** Search tracked files and build config for known secret patterns; verify fake secret in client cannot authorize privileged work.

## 3. Phase 1 — Stop-the-line multimodal AI feasibility spike (P0)

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T01.1 — Supabase → Meta vision proof of concept

```text
TASK: Pickwell AI V2 — T01.1: Supabase → Meta vision proof of concept

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T01.1 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Deploy a narrowly scoped, non-public or separately protected test Edge Function that sends **two real food-package photos** (nutrition and ingredients) to the selected Meta vision model.
- [ ] Validate authentication/authorization, request format, model availability, response schema, per-image behavior, max input size, duration, provider token/cost reporting, timeout and failure modes.
- [ ] Test at least two clearly different product pairs and one unreadable label. Demand null/unknown rather than fabricated values; evaluate image basis/units.
- [ ] Remove or lock down temporary spike endpoint after use; retain tests/fixtures with non-sensitive sample data.

**Acceptance:** Actual live Meta call returns structured ingredient and nutrient extraction from two photos; unreadable sample fails safely. Capture measured real latency/tokens and blocked constraints.  
**Targeted validation:** One real API integration script/test, explicit invalid-image case, model access and secret-leak check.  
**Hard blocker:** Do not claim the MVP AI integration is ready until a genuine call works.

## 4. Phase 2 — Supabase foundations (P0)

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T02.1 — Migrations for shared catalog and analysis jobs

```text
TASK: Pickwell AI V2 — T02.1: Migrations for shared catalog and analysis jobs

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T02.1 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Translate `PICKWELL_DATABASE.md` illustrative SQL into real versioned migrations; review existing schema before applying.
- [ ] Create products, analyses, ingredient/nutrition structured fields, findings/evidence, analysis jobs, unique normalized barcode constraint, status lifecycle, timestamps, model/rule versions and contributor references as specified.
- [ ] Plan product correction/invalidation without giving contributors overwrite rights; make error/retry state explicit.
- [ ] Seed a **clearly identified demo record** with complete safe nutrition and analysis for cache-hit testing.

**Acceptance:** Migrations apply cleanly to clean test DB and preserve existing data when rerun via migration runner; duplicate barcode prevented; only `ready` considered published.  
**Targeted validation:** SQL schema/assertion tests for unique barcode, FK integrity, job state and version metadata.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T02.2 — RLS and least-privilege boundary

```text
TASK: Pickwell AI V2 — T02.2: RLS and least-privilege boundary

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T02.2 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Enable RLS on every exposed table; deny direct anonymous/authenticated writes to shared catalog, jobs, entitlements, usage, and webhook data.
- [ ] Keep privileged DB access in Edge Functions; public `get-product` returns a sanitized published projection only.
- [ ] Ensure `get-analysis-status` is owner-scoped; avoid overprivileged callable SQL functions and harden any security-definer functions.
- [ ] Separate all test/sandbox billing events from production entitlements.

**Acceptance:** Client cannot directly forge findings, grant Premium, increment/decrement quota or retrieve another user's jobs.  
**Targeted validation:** Negative DB/REST authorization tests using publishable and verified-user tokens; server-only insert works.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T02.3 — Plan config, quotas, reservations, and spend controls

```text
TASK: Pickwell AI V2 — T02.3: Plan config, quotas, reservations, and spend controls

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T02.3 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Seed Free plan with `barcode_lookup=30` and `ai_analysis=3`, reset at 00:00 UTC, with server-controlled mutable config and version/audit fields.
- [ ] Implement atomic per-user quota consumption/reservations and idempotency. Successful publication finalizes one AI usage; cache hit/failed extraction releases a reserved AI slot.
- [ ] Prevent repeated retries, cross-request races and multiple AI calls on the same barcode; track provider spending separately from user allowance.
- [ ] Implement best-effort public lookup throttling for guests (IP/proxy-aware) and authenticated exact barcode usage. Set global spend ceiling and concurrency caps.

**Acceptance:** 30th authenticated lookup allowed and 31st denied; 3rd successful new analysis allowed and 4th denied; changing limit to 20 applies on subsequent calls without mobile release. Guest is not promised enforceable per-person usage.  
**Targeted validation:** Concurrent atomic reservation, 00:00 UTC reset, negative usage, idempotent retry and rollback/release tests.  
**Note:** Quota counting semantics must match PRD: charge only valid definitive lookup statuses; no charge for local reopening or lookup transport errors.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T02.4 — Operational events and cost ledger

```text
TASK: Pickwell AI V2 — T02.4: Operational events and cost ledger

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T02.4 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Record minimal backend events: `barcode_scanned`, `product_cache_hit`, `product_not_found`, `capture_completed` (if intentionally sent), `analysis_started`, `analysis_completed`, `analysis_failed`, `analysis_retake_required`, `quota_exceeded`.
- [ ] Maintain server-only model/provider/tokens/estimated cost/duration ledger if available; limit access and retention.
- [ ] Ensure nonessential analytics failures do not bypass or incorrectly deny quota checks.

**Acceptance:** Can inspect counted cache hits, Meta calls, failures and daily spend without revealing image payloads, passwords or API tokens.  
**Targeted validation:** Redacted event assertions and optional analytics failure behavior.

## 5. Phase 3 — Barcode scanning and cached lookup (P0)

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T03.1 — Implement `get-product` backend endpoint

```text
TASK: Pickwell AI V2 — T03.1: Implement `get-product` backend endpoint

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T03.1 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Validate/canonicalize barcode; return typed `ready`, `not_found`, `processing`, `rate_limited`/`quota_exceeded`, or `error` states.
- [ ] Apply correct guest throttling/authenticated quota; securely read published projection; do not trigger AI.
- [ ] Return effective quota/remaining and UTC reset when reliably known; never trust client counters.

**Acceptance:** Seeded barcode returns complete results with **zero Meta calls**; missing barcode explicitly returns `not_found`; timeout/DB unavailable does not masquerade as a miss.  
**Targeted validation:** Function endpoint tests for found, miss, malformed, throttled and DB error; trace confirms no model invocation.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T03.2 — Flutter scanner/home and lookup UX

```text
TASK: Pickwell AI V2 — T03.2: Flutter scanner/home and lookup UX

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T03.2 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Reuse existing template/navigation; implement **lemon-branded recent-products Home**, not scanner-first. Header logo + only search icon, All/Food chips, Newest sort, separate rounded cards, no section heading or list/grid toggle.
- [ ] Create liquid-glass-inspired translucent Home/Settings pill, **separate far-right scan circle with icon only**; hide it on nested routes, with Android visual fallback. Chat is future visual reference and must not ship as dead tab.
- [ ] Implement minimal scanner camera and permissions following DESIGN.
- [ ] Integrate suitable scanner dependency only if none exists; enable camera and gallery where needed; test common EAN/UPC.
- [ ] Use Cubit/Bloc states for idle, scanning, checking, found, miss, processing, denied, error.
- [ ] Navigate directly to results for `ready`; to 3-step wizard for `not_found`; expose retry for network failure.
- [ ] Optionally add manual barcode input as a P1 fallback, without displacing P0.

**Acceptance:** Guest lands on correct empty/local recents Home, opens scanner with prominent rightmost Scan icon, scans existing and unknown demo barcodes; no sign-in gate before lookup.  
**Targeted validation:** Scanner/lookup Cubit tests, camera permission-denied flow, one real-device barcode scan.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T03.3 — Local recent-products Home index and search (P0 recent index / P1 filtering polish)

```text
TASK: Pickwell AI V2 — T03.3: Local recent-products Home index and search (P0 recent index / P1 filtering polish)

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T03.3 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Record only unique published ready barcode references and last-opened timestamps in a bounded device-local index; no personal account/cloud history, persistent user label photos or full offline analysis payloads.
- [ ] On app relaunch, display available last-viewed product cards with truthful thumbnails (actual authorized media or placeholder). Refresh summary online when needed and follow server lookup/quota rules; never invent package photos or pretend results are locally available offline.
- [ ] Search icon expands into search field; filter the local list, allow All/Food and newest order; Cosmetics and Chat must remain nonfunctional concepts outside shipped MVP.
- [ ] Empty state encourages scan without fake product fixtures.

**Acceptance:** A real ready barcode opened once appears in Home after app restart, newest-first and deduplicated. Empty state correct. Scanning remains guest-accessible. Local reopening does not trigger Meta.  
**Targeted validation:** Local persistence/dedup/search/filter unit tests, widget check for screen density and scan button, missing-photo fallback and offline handling.

## 6. Phase 4 — Guided capture and Email OTP (P0)

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T04.1 — Three-step nutrition + ingredients photo capture

```text
TASK: Pickwell AI V2 — T04.1: Three-step nutrition + ingredients photo capture

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T04.1 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Display **Step 1 Barcode ✓ → Step 2 Nutrition → Step 3 Ingredients**, with preview, retake, guidance, and progress.
- [ ] Store in-progress photos only in bounded app-local transient state; compress/resize; check supported MIME and size before upload.
- [ ] Optionally infer/edit product name and brand without extra mandatory step; never accept them as authoritative replacements for labels.
- [ ] Preserve selected photos/barcode across OTP redirect and return.

**Acceptance:** After a missing barcode, user captures 2 readable photos without rescanning barcode; can retake one image independently.  
**Targeted validation:** Wizard state persistence across navigation, invalid-format/oversize, camera failure, separate retake paths.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T04.2 — Email OTP auth and submission gate

```text
TASK: Pickwell AI V2 — T04.2: Email OTP auth and submission gate

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T04.2 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Configure Supabase Auth Email OTP as an actual code flow; verify email template, provider delivery limits and session persistence.
- [ ] Prompt sign-in **only when submitting unknown-product analysis**; scanned cached products remain publicly accessible.
- [ ] Support send/verify/resend/error/cancel and safe resume of the two photos; session expiration handled.
- [ ] Backend verifies trusted JWT and persistent verified email; do not rely solely on Flutter or on the generic `authenticated` role if anonymous auth is later enabled.

**Acceptance:** Guest captures photos, signs in, returns to exactly the same analysis submission, and can proceed; guest direct call to analysis endpoint is forbidden.  
**Targeted validation:** OTP integration, incorrect/expired OTP, guest rejection server-side, post-auth resume.

## 7. Phase 5 — AI processing and reusable publication (P0)

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T05.1 — `analyze-product` secure job orchestration

```text
TASK: Pickwell AI V2 — T05.1: `analyze-product` secure job orchestration

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T05.1 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Recheck normalized barcode and existing job/`ready` record atomically before invoking Meta; deduplicate with job lease/idempotency key.
- [ ] Authorize verified user, apply quota reservation and rate/concurrency/global spend checks before model call; record job states.
- [ ] Validate both image inputs; send private server-side API request with bounded timeouts; use status/polling only if necessary for hosted execution constraints.
- [ ] Limit retries to prevent API-cost storms; user retry of same request idempotency key must not double-charge.

**Acceptance:** One new barcode has no duplicate published record; blocked/unverified caller cannot invoke model; concurrent users share the outcome safely.  
**Targeted validation:** Mocked provider with parallel submit, auth, duplicate, quota rejection and timeout tests.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T05.2 — Extract, interpret and validate

```text
TASK: Pickwell AI V2 — T05.2: Extract, interpret and validate

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T05.2 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Extract ingredient raw text, ordered items, nutrition values with units and per-serving/per-100g basis, and declared allergens where visible.
- [ ] Meta generates understandable explanations; deterministic backend rules assign green/yellow/red only with evidenced and threshold-backed reasons.
- [ ] Represent ambiguous values as unknown; verify required fields, product consistency, numeric ranges and source basis.
- [ ] If nutrition or ingredient image unclear, return `needs_retake` referencing **which photo** rather than publishing partial misleading results.
- [ ] Record model version, prompt/rules version and evidence/provenance; no overall food score or blanket healthy/unhealthy certification.

**Acceptance:** Two representative food labels produce readable validated result; a bad image produces actionable retake; traffic-light claims trace to label/rules.  
**Targeted validation:** Fixture-based schema/rules tests; malformed and contradictory payload tests; real images from Phase 1.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T05.3 — Publish product and securely dispose photos

```text
TASK: Pickwell AI V2 — T05.3: Publish product and securely dispose photos

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T05.3 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Write accepted record and analysis/findings as an atomic published transition to `ready`; finalize one successful-analysis credit.
- [ ] Rejected/failed analysis does not consume successful-analysis credits, but provider spend remains in ledger.
- [ ] Do not persist original images unless private temporary storage is absolutely required; delete temporary files after successful extraction and via bounded cleanup of failures/orphans.
- [ ] Do not expose contributor email or transient images in public record.

**Acceptance:** Another guest sees the result by scanning same barcode without AI; photos are not retained after successful extraction.  
**Targeted validation:** Save/lookup integration, duplicate publish, cleanup success/failure, sensitive data projection.

## 8. Phase 6 — Results, quota UI and RevenueCat readiness (P0/P1)

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T06.1 — Product results and accountable findings (P0)

```text
TASK: Pickwell AI V2 — T06.1: Product results and accountable findings (P0)

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T06.1 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Implement approved nested Product Details: back + overflow, **no logo app-bar title or bottom tabs**, product identity/photo or fallback, ingredient explanations, nutrition, summary, green/yellow/red findings, declared allergens, missing information and analysis timestamp.
- [ ] **No numeric 92/100 score, unsupported healthy certification, or Add to List.** Share native action is optional P1 with valid non-sensitive data.
- [ ] Show color-independent warning icons/labels and readable explanations; format servings/units consistently.
- [ ] Display explicit status while analyzing and relevant-label retake state; safe retry, not infinite progress.

**Acceptance:** Cached and newly generated analyses use the same result UI and evidence model; result understandable without relying on color.  
**Targeted validation:** Widget tests for green/yellow/red/unknown, missing values, long ingredient names and error states.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T06.2 — Remaining usage and quota-exceeded states (P0)

```text
TASK: Pickwell AI V2 — T06.2: Remaining usage and quota-exceeded states (P0)

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T06.2 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Surface exact authenticated remaining barcode and AI quota where backend provides it, with UTC reset converted to user's time zone for display.
- [ ] Guest messaging must avoid claiming strict personal limits; display general fair-use or rate-limit status as appropriate.
- [ ] When quota exhausted, explain next reset and allow user to view already loaded results; no unavailable purchase button.
- [ ] Avoid refreshing usage on every widget frame; trust server response, not a local mutable allowance.

**Acceptance:** 30/3 remaining states agree with server; changing server plan limits updates UI without app release.  
**Targeted validation:** Boundary/reset, offline display fallback and no-paywall quota states.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T06.3 — Premium-ready entitlement tables and RevenueCat webhook safety (P0 backend design; deploy only when prerequisites satisfied)

```text
TASK: Pickwell AI V2 — T06.3: Premium-ready entitlement tables and RevenueCat webhook safety (P0 backend design; deploy only when prerequisites satisfied)

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T06.3 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Implement backend Free/Premium plan resolution, future entitlements, user-to-RevenueCat App User ID mapping, append-only unique event ledger and billing feature flag `false`.
- [ ] Prepare protected `revenuecat-webhook` entrypoint or isolated handler with RevenueCat's documented authentication verification; refuse unsigned/invalid requests; test duplicate/out-of-order event handling.
- [ ] Never grant Premium from Flutter `CustomerInfo`, a claimed plan string or any unverified webhook. Ambiguous aliases and expired subscription events require reconciliation before changing a plan.
- [ ] No paywall, billing SDK initialization, product IDs, offering fetches or purchase buttons in MVP; exact Premium allowances remain TBD.
- [ ] If RevenueCat credentials/config are unavailable, keep webhook **not deployed/disabled** and test safely with fixtures; do not expose an unauthenticated public webhook.

**Acceptance:** Free is the effective plan for normal users, backend can represent test Premium without client tampering, and fake/replayed webhooks cannot grant entitlements.  
**Targeted validation:** SQL/API role tests, webhook authentication and replay fixture tests, billing flag false.  
**Scope safeguard:** Do not block the actual hackathon barcode+AI demo on real subscription events or RevenueCat store configuration.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T06.4 — Settings/account & minimal operational UI (P1)

```text
TASK: Pickwell AI V2 — T06.4: Settings/account & minimal operational UI (P1)

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T06.4 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] Implement minimal account email, sign-out, privacy links, and usage section per DESIGN; no fake purchases. Use newest lemon/cream tokens and consistent simple surfaces.
- [ ] Respect template styling and avoid new onboarding carousel or additional premium screens.

**Acceptance:** Account state and usage can be viewed; sign-out prevents another analysis without re-authentication.  
**Targeted validation:** Settings/account widget behavior and session invalidation.

## 9. Phase 7 — Demo/release checks (P0)

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T07.1 — End-to-end acceptance and security pass

```text
TASK: Pickwell AI V2 — T07.1: End-to-end acceptance and security pass

READ FIRST
- Inspect real repository `AGENTS.md`, `PICKWELL_TASKS.md`, `PICKWELL_PRD.md` v1.6, `PICKWELL_DESIGN.md` v1.4, `PICKWELL_SPEC.md` v1.4, and `PICKWELL_DATABASE.md` v1.2. Locate filenames by role if placed in another directory. Follow nested repo instructions; preserve uncommitted edits.
- Inspect actual implementation and prerequisites; check earlier completed work before changing anything. Task checkboxes are not proof of incompletion.

LOCKED PRODUCT / ARCHITECTURE
- Pickwell AI V2 (`pickwell-ai`) is a lasting Flutter iOS/Android app. Reuse existing StartAppLab template, Cubit/Bloc conventions, routes, deps and theme; never invent repo paths or assets.
- Barcode-first, guest cached lookup; three-step Barcode ✓ → Nutrition → Ingredients for unknown products; verified Supabase Email OTP required to submit new Meta vision analysis. Supabase Edge Functions/PostgreSQL secure AI and writes.
- Backend controls Free 30 signed-in barcode lookups/day and 3 successful new-product analyses/day, UTC reset, guest best-effort limits, per-user/IP and spend controls. RevenueCat backend-ready only with billing disabled and no paywall.
- Approved UI: whole lemon logo, 60/30/10 cream/white + greens + restrained yellow. Home is local recently viewed/scanned **product cards**, expandable top-right search, All/Food/Newest filters, independent rightmost scan icon and glass-like Home/Settings dock. Hide Chat/cosmetics from working hackathon nav; no list/grid or Recently scanned heading. Details has no bottom nav or Pickwell header title; no numeric score or Add to List. Use truthful images or placeholders; no image generation.
- Future-only: cosmetic analysis, chat, food score, global discovery, collections, cloud history, active monetization, premium storefront, extensive onboarding. No unauthorized Supabase writes, secrets in app, permanently retained label photos or false health claims.

SCOPE / IMPLEMENT
Implement ONLY T07.1 and directly required prerequisites, using actual repo patterns. Preserve existing features and don't refactor unrelated modules. For backend logic, validate types, RLS/JWT, quotas and idempotency. For Flutter UI, match approved DESIGN rather than earlier generated screenshots. Don't claim hardware/provider/deployment tests if not done.

EXACT TASK REQUIREMENTS
- [ ] **Home:** New install has honest empty state; previously viewed barcode is present after restart in bounded local recents; header search and actual Food/Newest filters work. No Chat/cosmetics fake routes.
- [ ] **Cached path:** Scan existing barcode as guest → show analysis without Meta call, no OTP wall.
- [ ] **New path:** Scan missing barcode → nutrition photo → ingredients photo → Email OTP → server-only AI → validation → publish → results.
- [ ] **Reuse:** Another guest/session rescans new barcode → cached result, no repeat Meta inference.
- [ ] **Bad input:** Incorrect/blurred image → identify label to retake, no public bad record, successful-analysis quota preserved.
- [ ] **Quotas:** 30 barcode/day Free and 3 successful analyses/day, server-config limit reduction to 20 test, UTC reset, concurrent job handling, spend ceiling, missing auth.
- [ ] **Security:** RLS negative tests, no secrets in build/repo, no public write, no fake Premium, webhook validation if enabled, rate limits.
- [ ] **Privacy:** Review temporary image deletion, minimal telemetry, no contributor email in cached product output.
- [ ] **Accessibility:** Color labels/icons usable independent of hue, loading, permissions, network and OTP recovery.

**Acceptance:** Each test has recorded pass/fail and fixes; no known P0 blockers. Full release QA is appropriate here, not after every task.

ACCEPTANCE
Meet each listed checkbox/observable condition and the task's stated acceptance criteria. Identify genuine unverified prerequisites or blocked cases rather than declaring success.

TARGETED VALIDATION
Run tests relevant to touched code and directly affected dependencies; negative authorization and concurrency tests for security-sensitive backend changes; real device photo/barcode checks when available. No blanket project-wide regression except the dedicated T07.1 release QA task.

COMPLETION REPORT
Report task ID, exact modified files, work completed, commands/tests run with ACTUAL observed outcomes, pending credentials/device or UI assets, security/privacy/cost implications, remaining blockers, and which TASKS checkbox(es) were verified. Never mark incomplete tasks done.
```

## T07.1A.1 — Product Thumbnail Storage & Display

**Status:** IMPLEMENTED / locally and Native Runtime verified; NOT deployed. [Implementation/verification](PICKWELL_PRODUCT_THUMBNAILS.md). Use conservative post-publication operator attachment, not automatic image persistence in analysis. T07.1A visual polish remains separate.

- [x] Generate a bounded orientation-correct JPEG derivative from the exact reviewed front image; preserve three-photo digest and original approval gate.
- [x] Enforce private Storage, immutable reviewed product/source association, publication eligibility, size/MIME constraints and bounded Storage-API orphan cleanup.
- [x] Display safe optional media on Home/local recent cards and Details, with loading/error/legacy fallbacks and no image-driven Muse calls or quota changes.
- [x] Disclose retained published derivative versus temporary evidence/private incomplete upload; preserve operator evidence handoff and update capture privacy copy.
- [x] Run targeted Flutter/backend/SQL/native codec/Storage/privacy/authority/association regression; record exact observed results.
- [ ] Hosted rollout, protected cleanup scheduling, genuine product imagery and fresh-device visual verification. **Not authorized/executed in this task.** No synthetic local result is a real hosted publication claim.

**Rollout requirements:** `20261104000300_pickwell_product_thumbnails.sql`, new public read-only image function, updated projection handlers, rebuilt client and protected operator cleanup runner. Explicit owner authorization before hosted deployment; no dashboard, fourth photo, automatic approval or broad UI redesign.

## T07.1B — Product Identity & Data Integrity Audit

```text
TASK: Pickwell AI V2 — T07.1B: Product Identity & Data Integrity Audit

READ FIRST
- Read root and applicable nested AGENTS.md, docs/PICKWELL_PRD.md v1.5, docs/PICKWELL_DESIGN.md v1.3, docs/PICKWELL_SPEC.md v1.3, docs/PICKWELL_DATABASE.md v1.1 and docs/PICKWELL_TASKS.md v1.2. Inspect actual implementation, git diff and existing evidence; preserve completed work.
- Read docs/PICKWELL_END_TO_END_QA.md and docs/PICKWELL_UI_POLISH.md plus the audit/mitigation reports when available. Use the exact task contract below. Never treat a proposed roadmap feature as implemented.

LOCKED PRODUCT / ARCHITECTURE
- Preserve the Flutter/StartAppLab Cubit/Bloc conventions, approved lemon/cream/green UI, guest barcode cache reads, mandatory Front → Nutrition → Ingredients photos and verified Email OTP for new analyses per T07.1C.1. Front observations do not independently verify barcode ownership.
- Keep deterministic findings, Meta server-side, atomic publication/quotas/idempotency, image deletion after processing and bounded private pending drafts. Retain only justified minimal non-image provenance; never expose secrets, image payloads or contributor email.
- Separate extraction/model uncertainty, cross-photo consistency and actual barcode/package identity verification. No invented confidence, medical advice, diagnosis, safety certification, personalized CKD prescriptions or overall health score.
- T06.3 deferred, billing disabled; no paywalls, Chat, cosmetics, collections or unrelated refactors. Preserve owner-approved testing limits unless explicitly changed; document production 30/3 readiness separately.

SCOPE / IMPLEMENT
Work ONLY on T07.1B (pre-submission) and directly necessary prerequisites after checking its dependencies. This is an audit/report task: do not implement fixes, migrations or deployments. Stop with evidence and a minimal mitigation plan.

EXACT TASK REQUIREMENTS
**Status / dependencies:** Pre-submission P0 audit; NOT STARTED. Depends on completed T07.1 and the current T07.1A implementation baseline. Finish remaining UI review before the final release gate.

- [ ] Audit barcode belonging to Product A with photos belonging to Product B; conflicting nutrition/ingredient images; inconsistent names, brands, variants and package sizes.
- [ ] Trace schema-valid publication with missing/unverifiable identity evidence, trusted-record overwrite paths, and the distinction between model uncertainty, cross-photo consistency and actual identity verification.
- [ ] Audit simultaneous submissions/publication races, duplicate barcodes, reformulations and barcode reuse; distinguish current tested safeguards from untested assumptions.
- [ ] Evaluate deliberate data poisoning, prompt injection in labels and repeat abuse without bypassing auth/RLS or exposing secrets/image payloads.
- [ ] Produce an evidence-based report with actual code/schema paths, reproducible observations, severity, affected paths, unknowns and a minimal safe mitigation plan for T07.1C; do not implement protections in the audit task.

**Acceptance:** Every listed threat has an evidence-backed finding or explicit unverified result; critical risks and the smallest safely testable mitigations are identified. Schema validity or model certainty is never reported as barcode/package verification.

**Targeted validation:** Targeted adversarial fixtures and transaction/concurrency inspection or isolated tests; record observed outcomes and evidence gaps. No destructive production experiments or unapproved paid calls.

COMPLETION REPORT
Report status, exact files changed, observed commands/test results, security/privacy/cost implications, residual risks and blocked criteria. Distinguish local/mock/live/owner-device evidence. Update only genuinely verified TASKS checkboxes and identify the next dependency without starting it.
```

## T07.1C.1 — Front Packaging Capture & Identity Extraction

```text
TASK: Pickwell T07.1C.1 — Front Packaging Capture & Identity Extraction

READ FIRST
Read root/app AGENTS, current PRD/DESIGN/SPEC/TASKS/DATABASE, the T07.1B identity audit, T07.1 QA and PICKWELL_FRONT_PACKAGING.md. Inspect actual code/git status; preserve completed work and the passing baseline. This task is already locally implemented; verify before changing or repeating work.

APPROVED FLOW AND SCOPE
Unknown barcode → Front packaging → Nutrition → Ingredients → contextual Email OTP → one server-only Muse analysis → validation/current publication policy → result or exact-photo retake/safe failure. Guest known-barcode cache retrieval remains unchanged. Preserve UI, drafts, credentials, quota/rate/spend controls, image deletion and backward-compatible cached results. No identity certification, comparison, Passport, assistant or full T07.1C approval gate; no T07.2.

EXACT TASK REQUIREMENTS
**Status / dependencies:** IMPLEMENTED / deployed in T07.1D.1; real three-photo Muse/device validation deferred by owner. Depends on completed T07.1B. Front observations do not implement T07.1C's publication gate.

- [x] Require Front → Nutrition → Ingredients after a missing barcode; preserve independent retake, back/restart recovery, OTP resume and existing design. Known guest cache hits remain unchanged.
- [x] Enforce three bounded distinct image inputs and include front bytes in idempotency; preserve auth, rates, quotas, one provider call/one successful-analysis charge and request-local image handling.
- [x] Extract nullable name, brand, variant and net quantity per photo; detect explicit/conservative identity conflicts with exact affected-photo retakes, retain uncertainty and unverified barcode association.
- [x] Preserve legacy result readability and saved label photos, add bounded non-image identity provenance/public projection, and version the backend migration/prompt contracts.
- [x] Update planning/prompts and run targeted mocked capture/API/model/SQL/cleanup/regression tests; record deployment/live/device limitations and remaining T07.1C work.

**Acceptance:** Three-photo capture resumes safely through OTP/restart, missing front cannot submit, supported observations reach results with explicit uncertainty, clear conflicts cannot publish, and legacy cache reads/atomic quota behavior remain intact. No claim of independently verified barcode ownership or completed operator gate.

**Targeted validation:** Capture/retake/navigation/OTP/disk recovery tests; three-image parser/hash/model-schema tests; conflict/unknown/size tests; publication/credit/replay/front-retake SQL; existing cached/result regressions. See [implementation evidence](PICKWELL_FRONT_PACKAGING.md).

COMPLETION REPORT
Report exact files, capture flow, nullable identity observations/conflicts, input/model/migration changes, observed tests/failures, live/device/deployment gaps, remaining T07.1C risks and Git/commit status. Never mark T07.1C or T07.1D complete. Stop after implementation/verification; do not deploy or invoke a live model without the required authorization.
```

## T07.1C — Minimum Product Trust Protection

```text
TASK: Pickwell AI V2 — T07.1C: Minimum Product Trust Protection

READ FIRST
- Read root and applicable nested AGENTS.md, docs/PICKWELL_PRD.md v1.5, docs/PICKWELL_DESIGN.md v1.3, docs/PICKWELL_SPEC.md v1.3, docs/PICKWELL_DATABASE.md v1.1 and docs/PICKWELL_TASKS.md v1.2. Inspect actual implementation, git diff and existing evidence; preserve completed work.
- Read docs/PICKWELL_END_TO_END_QA.md and docs/PICKWELL_UI_POLISH.md plus the audit/mitigation reports when available. Use the exact task contract below. Never treat a proposed roadmap feature as implemented.

LOCKED PRODUCT / ARCHITECTURE
- Preserve the Flutter/StartAppLab Cubit/Bloc conventions, approved lemon/cream/green UI, guest barcode cache reads, mandatory Front → Nutrition → Ingredients photos and verified Email OTP for new analyses per T07.1C.1. Front observations do not independently verify barcode ownership.
- Keep deterministic findings, Meta server-side, atomic publication/quotas/idempotency, image deletion after processing and bounded private pending drafts. Retain only justified minimal non-image provenance; never expose secrets, image payloads or contributor email.
- Separate extraction/model uncertainty, cross-photo consistency and actual barcode/package identity verification. No invented confidence, medical advice, diagnosis, safety certification, personalized CKD prescriptions or overall health score.
- T06.3 deferred, billing disabled; no paywalls, Chat, cosmetics, collections or unrelated refactors. Preserve owner-approved testing limits unless explicitly changed; document production 30/3 readiness separately.

SCOPE / IMPLEMENT
Work ONLY on T07.1C (pre-submission) and directly necessary prerequisites after checking its dependencies. Implement only critical audit-backed protections that can be safely verified before submission; document blockers rather than waive them. Do not build Phase 8.

CURRENT IMPLEMENTED CONTRACT / FOLLOW-UP
- Preserve the evidence-bound operator gate at service and SQL finalizer boundaries. Approval binds barcode, exact image digest, canonical candidate digest and trust-publication-v1, not user/model/schema/allowlist.
- Preserve bounded review expiry, owner cancellation, terminal rejection, same-key checks without repeat AI, candidate cleanup and successful-credit release. Keep provider spending separate.
- Retain observed identities/cross-image consistency separately from operator review and independent verification. Missing identity stays unknown; wording conflicts go to review, not blanket retakes.
- Ingredient explanations require presence support from raw transcription. Preserve partial OCR; citations alone do not establish presence. Refresh cannot replace trust provenance.
- Use docs/PICKWELL_PRODUCT_TRUST.md for implementation evidence, operator CLI dry runs and rollout prerequisites. No live deployment/provider call is authorized by the documentation.

EXACT TASK REQUIREMENTS
**Status / dependencies:** IMPLEMENTED / deployed; local/native and hosted boundary verification passed. Genuine real-product/operator/device validation deferred by owner. Depends on T07.1B report and prioritized critical findings.

- [x] Implement only critical protections identified by T07.1B that can be completed and verified safely before submission; reuse existing admission, validation, publication and revision controls.
- [x] Prevent demonstrated mismatched/untrusted publication or trusted-record replacement through server-controlled checks; preserve RLS, verified submission auth, idempotency, atomic publication and quota settlement.
- [x] Keep model uncertainty separate from identity verification; never invent confidence scores, claim unperformed verification, or reinstate blanket retakes for usable partial nutrition data.
- [x] Preserve guest cached lookup, the approved three-photo capture and approved UI; retain deletion after processing and justified minimal non-image provenance only. Do not build T08 features or enable billing.
- [x] Record fixes and tests, residual risks and a release disposition. If no critical changes are needed, document the evidence-backed no-change disposition; if a critical risk cannot be safely resolved, restrict the affected path or block T07.1D sign-off.

**Acceptance:** Each critical audit finding has a verified mitigation or an explicit release-blocking/restricted-path disposition; no false identity assurance or unsafe trusted-record overwrite. Deadline pressure does not waive a P0 blocker.

**Targeted validation:** Reproduce each critical case before/after; negative auth/RLS, concurrent publication/idempotency, quota rollback, photo disposal and sanitized cache projection tests for affected paths.

COMPLETION REPORT
Report status, exact files changed, observed commands/test results, security/privacy/cost implications, residual risks and blocked criteria. Distinguish local/mock/live/owner-device evidence. Update only genuinely verified TASKS checkboxes and identify the next dependency without starting it.
```


**Local evidence / release disposition:** [T07.1C implementation report](PICKWELL_PRODUCT_TRUST.md). All new associations are restricted to exact-evidence operator review. These checks record local implementation, not deployment or T07.1D completion. An operator must obtain and inspect the exact processed evidence privately; without it, do not approve.

## T07.1D — Targeted Regression and Release Gate

```text
TASK: Pickwell AI V2 — T07.1D: Targeted Regression and Release Gate

READ FIRST
- Read root and applicable nested AGENTS.md, docs/PICKWELL_PRD.md v1.5, docs/PICKWELL_DESIGN.md v1.3, docs/PICKWELL_SPEC.md v1.3, docs/PICKWELL_DATABASE.md v1.1 and docs/PICKWELL_TASKS.md v1.2. Inspect actual implementation, git diff and existing evidence; preserve completed work.
- Read docs/PICKWELL_END_TO_END_QA.md and docs/PICKWELL_UI_POLISH.md plus the audit/mitigation reports when available. Use the exact task contract below. Never treat a proposed roadmap feature as implemented.

LOCKED PRODUCT / ARCHITECTURE
- Preserve the Flutter/StartAppLab Cubit/Bloc conventions, approved lemon/cream/green UI, guest barcode cache reads, mandatory Front → Nutrition → Ingredients photos and verified Email OTP for new analyses per T07.1C.1. Front observations do not independently verify barcode ownership.
- Keep deterministic findings, Meta server-side, atomic publication/quotas/idempotency, image deletion after processing and bounded private pending drafts. Retain only justified minimal non-image provenance; never expose secrets, image payloads or contributor email.
- Separate extraction/model uncertainty, cross-photo consistency and actual barcode/package identity verification. No invented confidence, medical advice, diagnosis, safety certification, personalized CKD prescriptions or overall health score.
- T06.3 deferred, billing disabled; no paywalls, Chat, cosmetics, collections or unrelated refactors. Preserve owner-approved testing limits unless explicitly changed; document production 30/3 readiness separately.

SCOPE / IMPLEMENT
Work ONLY on T07.1D (pre-submission) and directly necessary prerequisites after checking its dependencies. Do not start the next task automatically or alter unrelated behavior. Obtain actual evidence before claiming tests or completion.

EXACT TASK REQUIREMENTS
**Status / dependencies:** PASS WITH LIMITATIONS for the protected testing deployment after T07.1D.1; genuine changed-flow real-product checks deferred by owner. T07.1A remains paused. Depends on T07.1B, T07.1C disposition and completion/disposition of remaining T07.1A review.

- [x] Compare affected behavior with completed T07.1 evidence; record pass/fail, fixes and unverified cases without reopening or falsely replacing historical QA.
- [ ] Verify guest cache hit with zero Meta calls, missing-barcode capture/OTP/new analysis, publication, second-session reuse, relevant-photo retake, retries and draft recovery/cleanup.
- [ ] Verify identity/conflict protections from the audit, races/duplicates, trusted revision protection, auth/RLS, quota settlement, rate/spend controls and absence of secret/PII/image leaks.
- [ ] Check affected UI/navigation/accessibility and owner/device observations. Record exact deployed/configured version and testing versus production limits; preserve owner-approved 1,000/100 testing allowances unless changed explicitly, and require 30/3 restoration before production public release.
- [x] Issue a release decision with evidence and remaining limitations; billing stays disabled, T06.3 deferred. Do not sign off with a known unresolved P0 blocker or claim a feature is verified from schema validity alone.

**Acceptance:** Affected end-to-end and security/privacy paths have recorded results, no regressions against T07.1, and no known unresolved P0 blockers. Untested capabilities are explicitly excluded/restricted; the approved deployment profile is clear.

**Targeted validation:** Run affected integration/regression suites and necessary live/device checks; distinguish automated, provider, hosted and owner-reported evidence. Broaden regression only when impact requires it.

COMPLETION REPORT
Report status, exact files changed, observed commands/test results, security/privacy/cost implications, residual risks and blocked criteria. Distinguish local/mock/live/owner-device evidence. Update only genuinely verified TASKS checkboxes and identify the next dependency without starting it.
```


**2026-11-04 fresh verification:** [T07.1D report](PICKWELL_RELEASE_GATE.md): 150 Flutter, 181 backend/native, 142 pgTAP assertions and 21 tooling checks passed; 30 hosted boundary checks passed. Hosted C.1/C migrations and publication gate are absent while inference remains enabled. No new live three-photo or physical-device full-flow pass. Remaining boxes stay open; no T07.2 sign-off.

## T07.1D.1 — Hosted Deployment & Real Product Validation

**Status:** Hosted rollout/security VERIFIED; real-product, live Muse, device and actual operator-approval/reuse checks DEFERRED at owner request. Testing deployment PASS WITH LIMITATIONS, not full real-product sign-off. [Report](PICKWELL_HOSTED_TRUST_ROLLOUT.md).

- [x] Commit tested T07.1D baseline (`a9891ec`), verify target and exactly two pending forward migrations; preserve local work and data.
- [x] Pause new inference, apply C.1 then C trust migration, deploy analysis/lookup/cancel/status handlers, verify guards, then restore protected inference without changing 1000/100 or billing false.
- [x] Verify hosted authorization/private review, exact bindings, rollback-only rejection/cancellation/expiry/credit cleanup, existing guest cache and active maintenance; record actual results.
- [ ] Execute genuine matching product/barcode/three-photo/Muse/device/OTP flow. **Explicitly deferred by owner; no live call performed.**
- [ ] Review exact processed evidence with real operator CLI approval, owner same-key publication and guest reuse without extra Muse. **Deferred; no real candidate approved.**
- [x] Record deployed revisions, tests, limitations and release decision. T07.2 preparation is permitted; a genuine new-flow demo/submission sign-off is not claimed. Do not begin automatically.

**Next dependency:** Matching real evidence and honest operator/device verification before claiming the complete current real-product demo. No admin dashboard, automatic approval, fourth photo, billing or UI polish scope.

## T07.2 — Hackathon submission handoff

```text
TASK: Pickwell AI V2 — T07.2: Hackathon submission handoff

READ FIRST
- Read root and applicable nested AGENTS.md, docs/PICKWELL_PRD.md v1.5, docs/PICKWELL_DESIGN.md v1.3, docs/PICKWELL_SPEC.md v1.3, docs/PICKWELL_DATABASE.md v1.1 and docs/PICKWELL_TASKS.md v1.2. Inspect actual implementation, git diff and existing evidence; preserve completed work.
- Read docs/PICKWELL_END_TO_END_QA.md and docs/PICKWELL_UI_POLISH.md plus the audit/mitigation reports when available. Use the exact task contract below. Never treat a proposed roadmap feature as implemented.

LOCKED PRODUCT / ARCHITECTURE
- Preserve the Flutter/StartAppLab Cubit/Bloc conventions, approved lemon/cream/green UI, guest barcode cache reads, mandatory Front → Nutrition → Ingredients photos and verified Email OTP for new analyses per T07.1C.1. Front observations do not independently verify barcode ownership.
- Keep deterministic findings, Meta server-side, atomic publication/quotas/idempotency, image deletion after processing and bounded private pending drafts. Retain only justified minimal non-image provenance; never expose secrets, image payloads or contributor email.
- Separate extraction/model uncertainty, cross-photo consistency and actual barcode/package identity verification. No invented confidence, medical advice, diagnosis, safety certification, personalized CKD prescriptions or overall health score.
- T06.3 deferred, billing disabled; no paywalls, Chat, cosmetics, collections or unrelated refactors. Preserve owner-approved testing limits unless explicitly changed; document production 30/3 readiness separately.

SCOPE / IMPLEMENT
Work ONLY on T07.2 (pre-submission) and directly necessary prerequisites after checking its dependencies. Do not start the next task automatically or alter unrelated behavior. Obtain actual evidence before claiming tests or completion.

EXACT TASK REQUIREMENTS
**Status / dependencies:** Pre-submission handoff; NOT STARTED. Depends on T07.1D release sign-off; optional T06.4 must be explicitly implemented or deferred, never silently treated as complete.

- [ ] Record a truthful ≤3-minute demo using actual working flows and confirmed Meta model; don't misrepresent mock responses as live.
- [ ] Capture quick technical explanation: shared barcode cache, two-image Meta analysis, rule-based findings, safe retries/auth/quotas.
- [ ] Prepare public GitHub repository/submission materials according to verified organizer instructions while removing secrets and sensitive credentials.
- [ ] Verify organizer deadline and upload requirements directly before final submission.
- [ ] Document which functionality was built during the hackathon, which template/pre-existing work was reused, actual limitations and proposed-only roadmap; do not claim medical certification, independent identity verification or unbuilt T08 capabilities.
- [ ] Verify the public repository is runnable from documented clean setup with safe environment examples, prerequisites and deployment/test instructions; ensure the genuine three-minute demo reflects the submitted revision and approved organizer duration rules.

**Acceptance:** Public demonstration and repository reflect actual product; submission checklist and proof of Meta integration are complete. Hackathon-built functionality is accurately identified, the public repository has a verified runnable setup, and a genuine three-minute demo is supplied within organizer rules.

**Targeted validation:** Clean documented setup/run check, public repository secret/privacy/license review, demo-to-revision comparison and direct verification of organizer requirements. Record upload/submission evidence without exposing credentials.

COMPLETION REPORT
Report status, exact files changed, observed commands/test results, security/privacy/cost implications, residual risks and blocked criteria. Distinguish local/mock/live/owner-device evidence. Update only genuinely verified TASKS checkboxes and identify the next dependency without starting it.
```

## T08.1 — Product Passport

```text
TASK: Pickwell AI V2 — T08.1: Product Passport

READ FIRST
- Read root and applicable nested AGENTS.md, docs/PICKWELL_PRD.md v1.5, docs/PICKWELL_DESIGN.md v1.3, docs/PICKWELL_SPEC.md v1.3, docs/PICKWELL_DATABASE.md v1.1 and docs/PICKWELL_TASKS.md v1.2. Inspect actual implementation, git diff and existing evidence; preserve completed work.
- Read docs/PICKWELL_END_TO_END_QA.md and docs/PICKWELL_UI_POLISH.md plus the audit/mitigation reports when available. Use the exact task contract below. Never treat a proposed roadmap feature as implemented.

LOCKED PRODUCT / ARCHITECTURE
- Preserve the Flutter/StartAppLab Cubit/Bloc conventions, approved lemon/cream/green UI, guest barcode cache reads, mandatory Front → Nutrition → Ingredients photos and verified Email OTP for new analyses per T07.1C.1. Front observations do not independently verify barcode ownership.
- Keep deterministic findings, Meta server-side, atomic publication/quotas/idempotency, image deletion after processing and bounded private pending drafts. Retain only justified minimal non-image provenance; never expose secrets, image payloads or contributor email.
- Separate extraction/model uncertainty, cross-photo consistency and actual barcode/package identity verification. No invented confidence, medical advice, diagnosis, safety certification, personalized CKD prescriptions or overall health score.
- T06.3 deferred, billing disabled; no paywalls, Chat, cosmetics, collections or unrelated refactors. Preserve owner-approved testing limits unless explicitly changed; document production 30/3 readiness separately.

SCOPE / IMPLEMENT
Work ONLY on T08.1 (post-submission only) and directly necessary prerequisites after checking its dependencies. Do not start the next task automatically or alter unrelated behavior. Obtain actual evidence before claiming tests or completion.

EXACT TASK REQUIREMENTS
**Status / dependencies:** POST-SUBMISSION; NOT STARTED. Depends on T07.2 and T07.1B–D evidence; existing cache/provenance/revisions are reusable foundations, not full Passport completion.

- [ ] Extend the existing product/analysis record into an evidence-aware reusable Product Passport with identity, nutrition, ingredients, provenance, validation state and revision history; avoid a parallel catalog rewrite.
- [ ] Distinguish extracted facts and interpretations, model uncertainty, cross-photo consistency and actual identity verification method/result; preserve unknowns without invented scores or verified claims.
- [ ] Expose a sanitized current record and revision context through existing guest-safe reads; keep new analyses authenticated and normal barcode lookups free of model calls.
- [ ] Retain model/prompt/rule/reference versions and justified minimal non-image provenance; preserve immutable accepted history, privileged correction/invalidation, photo deletion and private contributor identifiers.
- [ ] Present the Passport within approved Product Details patterns with accessible evidence/uncertainty; CKD-related information remains educational, never diagnosis, certification or personalized dietary prescriptions.

**Acceptance:** A reusable published product exposes identity, structured facts, provenance, explicit validation/identity limits and navigable revision history without photos/PII or repeated lookup inference; existing flows remain intact.

**Targeted validation:** Schema/API/projection/revision tests, unknown identity/partial labels, immutable correction, cache-hit zero-model regression and relevant Product Details widget tests.

COMPLETION REPORT
Report status, exact files changed, observed commands/test results, security/privacy/cost implications, residual risks and blocked criteria. Distinguish local/mock/live/owner-device evidence. Update only genuinely verified TASKS checkboxes and identify the next dependency without starting it.
```

## T08.2 — Product Comparison

```text
TASK: Pickwell AI V2 — T08.2: Product Comparison

READ FIRST
- Read root and applicable nested AGENTS.md, docs/PICKWELL_PRD.md v1.5, docs/PICKWELL_DESIGN.md v1.3, docs/PICKWELL_SPEC.md v1.3, docs/PICKWELL_DATABASE.md v1.1 and docs/PICKWELL_TASKS.md v1.2. Inspect actual implementation, git diff and existing evidence; preserve completed work.
- Read docs/PICKWELL_END_TO_END_QA.md and docs/PICKWELL_UI_POLISH.md plus the audit/mitigation reports when available. Use the exact task contract below. Never treat a proposed roadmap feature as implemented.

LOCKED PRODUCT / ARCHITECTURE
- Preserve the Flutter/StartAppLab Cubit/Bloc conventions, approved lemon/cream/green UI, guest barcode cache reads, mandatory Front → Nutrition → Ingredients photos and verified Email OTP for new analyses per T07.1C.1. Front observations do not independently verify barcode ownership.
- Keep deterministic findings, Meta server-side, atomic publication/quotas/idempotency, image deletion after processing and bounded private pending drafts. Retain only justified minimal non-image provenance; never expose secrets, image payloads or contributor email.
- Separate extraction/model uncertainty, cross-photo consistency and actual barcode/package identity verification. No invented confidence, medical advice, diagnosis, safety certification, personalized CKD prescriptions or overall health score.
- T06.3 deferred, billing disabled; no paywalls, Chat, cosmetics, collections or unrelated refactors. Preserve owner-approved testing limits unless explicitly changed; document production 30/3 readiness separately.

SCOPE / IMPLEMENT
Work ONLY on T08.2 (post-submission only) and directly necessary prerequisites after checking its dependencies. Do not start the next task automatically or alter unrelated behavior. Obtain actual evidence before claiming tests or completion.

EXACT TASK REQUIREMENTS
**Status / dependencies:** POST-SUBMISSION; NOT STARTED. Depends on T08.1. May proceed independently of T08.3 after the Passport contract is stable.

- [ ] Compare two accepted Product Passport revisions using structured validated ingredients/nutrition and explicit product/variant/package identity context.
- [ ] Normalize compatible units and serving/per-100g bases deterministically using versioned rules; preserve original values and show calculation basis.
- [ ] Keep missing, ambiguous or incompatible quantities explicitly unknown/non-comparable; do not assume serving mass, density, added sugar or absent nutrients.
- [ ] Present meaningful evidence-backed differences within the approved visual system; no numeric overall food score, unsupported health ranking, safety certification or personalized CKD suitability recommendation.
- [ ] Reuse cached validated data and sources; do not trigger ordinary lookup/comparison AI calls or add account history, billing or unapproved services.

**Acceptance:** Two products can be compared on compatible validated bases with reproducible normalization and explicit unknowns; incompatible data cannot produce a misleading ranking.

**Targeted validation:** Unit/basis/serving conversion tests, mass/volume incompatibility, partial labels, total-versus-added-sugar cases, revision consistency and accessible comparison UI tests.

COMPLETION REPORT
Report status, exact files changed, observed commands/test results, security/privacy/cost implications, residual risks and blocked criteria. Distinguish local/mock/live/owner-device evidence. Update only genuinely verified TASKS checkboxes and identify the next dependency without starting it.
```

## T08.3 — Enhanced Identity Verification

```text
TASK: Pickwell AI V2 — T08.3: Enhanced Identity Verification

READ FIRST
- Read root and applicable nested AGENTS.md, docs/PICKWELL_PRD.md v1.5, docs/PICKWELL_DESIGN.md v1.3, docs/PICKWELL_SPEC.md v1.3, docs/PICKWELL_DATABASE.md v1.1 and docs/PICKWELL_TASKS.md v1.2. Inspect actual implementation, git diff and existing evidence; preserve completed work.
- Read docs/PICKWELL_END_TO_END_QA.md and docs/PICKWELL_UI_POLISH.md plus the audit/mitigation reports when available. Use the exact task contract below. Never treat a proposed roadmap feature as implemented.

LOCKED PRODUCT / ARCHITECTURE
- Preserve the Flutter/StartAppLab Cubit/Bloc conventions, approved lemon/cream/green UI, guest barcode cache reads, mandatory Front → Nutrition → Ingredients photos and verified Email OTP for new analyses per T07.1C.1. Front observations do not independently verify barcode ownership.
- Keep deterministic findings, Meta server-side, atomic publication/quotas/idempotency, image deletion after processing and bounded private pending drafts. Retain only justified minimal non-image provenance; never expose secrets, image payloads or contributor email.
- Separate extraction/model uncertainty, cross-photo consistency and actual barcode/package identity verification. No invented confidence, medical advice, diagnosis, safety certification, personalized CKD prescriptions or overall health score.
- T06.3 deferred, billing disabled; no paywalls, Chat, cosmetics, collections or unrelated refactors. Preserve owner-approved testing limits unless explicitly changed; document production 30/3 readiness separately.

SCOPE / IMPLEMENT
Work ONLY on T08.3 (post-submission only) and directly necessary prerequisites after checking its dependencies. Do not start the next task automatically or alter unrelated behavior. Obtain actual evidence before claiming tests or completion.

EXACT TASK REQUIREMENTS
**Status / dependencies:** POST-SUBMISSION; NOT STARTED. Depends on T08.1 and T07.1B/C findings. Does not require T08.2.

- [ ] Extend the mandatory three-photo evidence with conditional additional package/barcode evidence and product identity cross-checks where needed; preserve the approved capture path unless further evidence is justified.
- [ ] Define identity methods, evidence requirements and explicit unknown/conflict/verified semantics; model uncertainty or a matching barcode format alone cannot establish verification.
- [ ] Implement dispute resolution with authorized review and safe formulation/barcode-reuse handling; no contributor overwrite of trusted records or silent loss of prior revisions.
- [ ] Validate new evidence and revision transitions server-side with auth/RLS, idempotency, concurrency protection and sanitized public status; preserve guest reads and authenticated contributions.
- [ ] Delete processing/front-package photos after use and expire bounded pending drafts; retain only justified minimal non-image provenance, not permanent evidence images.

**Acceptance:** Insufficient/conflicting identity requests appropriate conditional evidence, disputes/formulation changes preserve trusted history, and verified claims are tied to a defined performed method rather than a model guess.

**Targeted validation:** Barcode A/photos B, variant/package-size conflicts, missing front evidence, disputes, reformulation/reuse, concurrent corrections and image cleanup/projection tests.

COMPLETION REPORT
Report status, exact files changed, observed commands/test results, security/privacy/cost implications, residual risks and blocked criteria. Distinguish local/mock/live/owner-device evidence. Update only genuinely verified TASKS checkboxes and identify the next dependency without starting it.
```

## T08.4 — Agentic Label Investigator

```text
TASK: Pickwell AI V2 — T08.4: Agentic Label Investigator

READ FIRST
- Read root and applicable nested AGENTS.md, docs/PICKWELL_PRD.md v1.5, docs/PICKWELL_DESIGN.md v1.3, docs/PICKWELL_SPEC.md v1.3, docs/PICKWELL_DATABASE.md v1.1 and docs/PICKWELL_TASKS.md v1.2. Inspect actual implementation, git diff and existing evidence; preserve completed work.
- Read docs/PICKWELL_END_TO_END_QA.md and docs/PICKWELL_UI_POLISH.md plus the audit/mitigation reports when available. Use the exact task contract below. Never treat a proposed roadmap feature as implemented.

LOCKED PRODUCT / ARCHITECTURE
- Preserve the Flutter/StartAppLab Cubit/Bloc conventions, approved lemon/cream/green UI, guest barcode cache reads, mandatory Front → Nutrition → Ingredients photos and verified Email OTP for new analyses per T07.1C.1. Front observations do not independently verify barcode ownership.
- Keep deterministic findings, Meta server-side, atomic publication/quotas/idempotency, image deletion after processing and bounded private pending drafts. Retain only justified minimal non-image provenance; never expose secrets, image payloads or contributor email.
- Separate extraction/model uncertainty, cross-photo consistency and actual barcode/package identity verification. No invented confidence, medical advice, diagnosis, safety certification, personalized CKD prescriptions or overall health score.
- T06.3 deferred, billing disabled; no paywalls, Chat, cosmetics, collections or unrelated refactors. Preserve owner-approved testing limits unless explicitly changed; document production 30/3 readiness separately.

SCOPE / IMPLEMENT
Work ONLY on T08.4 (post-submission only) and directly necessary prerequisites after checking its dependencies. Do not start the next task automatically or alter unrelated behavior. Obtain actual evidence before claiming tests or completion.

EXACT TASK REQUIREMENTS
**Status / dependencies:** POST-SUBMISSION; NOT STARTED. Depends on T08.1 and T08.3 evidence/identity contracts; T08.2 is not required.

- [ ] Allow Muse Spark to request specific additional evidence or clarifications through an allowlisted structured action contract; verify actual model access/capability before relying on it.
- [ ] Deterministically validate each action server-side against user/job ownership, state, target field/photo, allowed reason, payload constraints and evidence policy; model output cannot authorize itself.
- [ ] Bound rounds, retries, time, concurrency and provider spend; support cancel/expiry and safe resume without duplicate publication or successful-analysis credit charges.
- [ ] Keep model requests server-side and user-visible, with no arbitrary tool/URL execution, autonomous publication, general chatbot or medical/personalized dietary recommendations.
- [ ] Validate returned evidence through existing trusted publication rules; preserve transient photo disposal, minimal non-image provenance, cache reuse, approved UI and billing disabled.

**Acceptance:** A bounded Muse Spark investigation requests and validates a specific missing piece of evidence and either produces an accountable result or stops safely; invalid actions and budget exhaustion cannot bypass backend policy.

**Targeted validation:** Mock action/schema/state/ownership/prompt-injection tests, bounded-loop/cost/cancel/expiry tests and authorized real-model evidence-request integration; no success claim based only on mocks.

COMPLETION REPORT
Report status, exact files changed, observed commands/test results, security/privacy/cost implications, residual risks and blocked criteria. Distinguish local/mock/live/owner-device evidence. Update only genuinely verified TASKS checkboxes and identify the next dependency without starting it.
```

**v1.2 (2026-11-04):** Added audit/critical protection/release and post-submission prompts, synchronized their contracts with TASKS, retained historical prompts/completed-work evidence and updated read-first document versions. No implementation or new QA claimed.

## T07.1C.3 follow-up — Deployment and real private-result validation

Read `PICKWELL_PRIVATE_RESULTS.md` and the actual diff/revision first. Preserve the
existing private-result implementation, owner-only projection, exact operator
gate, one-successful-private-credit semantics and zero publication double charge.
Do not rebuild it. Coordinated hosted rollout requires explicit authorization;
apply outstanding forward migrations in order without a reset, deploy matching
analysis/cancel/private-read handlers, verify owner/guest/RLS negatives and pruning,
then test one legitimate three-photo private result and exact-evidence operator
approval/canonical reuse. Keep 1000/100 testing limits, spend controls and billing
disabled. Do not approve substituted evidence, enable AI-authorized publication,
start UI polish/dashboard/T07.2 or invent hosted/live/device evidence.

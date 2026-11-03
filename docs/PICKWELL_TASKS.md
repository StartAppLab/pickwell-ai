# PICKWELL AI V2 — IMPLEMENTATION TASKS

**Document:** `PICKWELL_TASKS.md`  
**Version:** 1.1 — Final lemon UI and local recents  
**Date:** 2026-11-02  
**Repository:** `pickwell-ai`  
**Framework:** StartAppLab App Framework — Stage 2 (TASKS)  
**Status:** Planned; all tasks unchecked until verified in the actual repository.

## 0. Source of truth and non-goals

Read `PICKWELL_PRD.md`, `PICKWELL_DESIGN.md`, `PICKWELL_SPEC.md`, and `PICKWELL_DATABASE.md` before implementing. Respect existing repository structure and Flutter boilerplate; do not invent file paths, replace existing code wholesale, or assume work is unfinished if the repository proves otherwise.

**Locked MVP:** Flutter local recent-product Home → separate Scan action → Supabase cache lookup → immediately display published ready record OR three-step capture (Barcode ✓ → Nutrition → Ingredients) → require verified Supabase Email OTP to submit uncached analysis → Meta multimodal AI via Supabase Edge Function → validate nutrition, ingredients and findings with documented rules → publish reusable result → future cache hits skip AI. Optional name/brand. Green/yellow/red findings, with explanations and evidence.

**Initial limits:** 30 barcode lookups/day (signed-in accurate, guests best-effort fair-use) and 3 successful new-product analyses/day for verified Free accounts; configurable server-side, reset 00:00 UTC. Two photos constitute one analysis; bounded retries and unsuccessful extraction must not burn a successful-analysis credit. AI spend limits are separate.

**RevenueCat:** Prepare backend identity mapping, entitlements, webhook authentication/idempotency and `billing_enabled=false`. **No purchases, paywall, pricing UI, or premium offering during the hackathon.** Future Premium quotas and billing products remain unspecified.

**Not MVP:** product comparison, cosmetics, AI Q&A/chat (visual-only future concept), numeric food score, cloud/offline analysis history, Add to List/collections, subscriptions, community, favorites, advanced onboarding, broad localization. Device-local barcode recents are included without a backend history table. No new backend service beyond approved Supabase + Meta API.

**Definition of done for each task:** implementation completed; acceptance criteria met; targeted tests run and outcomes recorded; no keys committed or client privilege escalation; mark checkbox only with evidence. Avoid blanket full regression until final release gate.

## 1. Critical path & sequencing

| Phase | Deliverable | Dependencies | Gate |
|---|---|---|---|
| 0 | Repository and integration readiness | Existing repo + credentials | Bootstrap |
| 1 | Real Meta AI two-image extraction spike | 0 | **Stop if no working Meta vision access** |
| 2 | Supabase database/security/quota foundation | 0 | Schema + RLS + safe quota tests |
| 3 | Guest barcode lookup & scanner | 2 | Cached hit / miss / error |
| 4 | Capture wizard & Email OTP | 3 | Guest can capture then sign in seamlessly |
| 5 | Server AI analysis + publishing | 1,2,4 | New product → saved ready result |
| 6 | Results UI + metering + premium-ready backend | 2,3,5 | Color findings, usage, RevenueCat backend safety |
| 7 | End-to-end targeted QA and hackathon demo | All P0 | Submission-ready demo |

Work on Phase 1 as early as possible, even in parallel with Phase 2. If time becomes critical, defer P1 polish and any unnecessary webhook deployment, **not** authorization, RLS, quotas or the functioning AI/cache path. A simplified entitlement table with secure future migration is preferable to a broken primary flow.

## 2. Phase 0 — Audit and technical readiness (P0)

### T00.1 Inspect actual repo, docs and environment

- [ ] Identify existing Flutter template modules, routing, Cubit/Bloc patterns, native targets, Supabase initialization, environment conventions, and any `AGENTS.md`; reuse instead of duplicating.
- [ ] Reconcile any old code/docs that contradict latest PRD (especially authentication, 30/3 quotas, billing disabled, and use of Meta via Supabase); report conflicts before destructive edits.
- [ ] Confirm configured Supabase project, local CLI/deployment method, target app identifiers, device camera test path, CI/secret management.

**Acceptance:** Concise integration inventory of existing files, work already completed, missing credentials, and risks; no unnecessary scaffold rewrite.  
**Targeted validation:** Dependency install / static analyzer on relevant code; verify environment examples contain no real secrets.

### T00.2 Configure secret-safe dev environment

- [ ] Configure Flutter with only Supabase project URL and publishable key (legacy anon only if existing project requires it).
- [ ] Configure Meta API key and privileged Supabase credentials only in protected Edge Function/server environments; never expose them to Flutter or logs.
- [ ] Prepare `.env.example`, `.gitignore`, safe test accounts, development/staging environment values, and zero-secrets check.

**Acceptance:** App can connect using public configuration and backend can read private secrets; no secret is committed.  
**Targeted validation:** Search tracked files and build config for known secret patterns; verify fake secret in client cannot authorize privileged work.

## 3. Phase 1 — Stop-the-line multimodal AI feasibility spike (P0)

### T01.1 Supabase → Meta vision proof of concept

- [x] Deploy a narrowly scoped, non-public or separately protected test Edge Function that sends **two real food-package photos** (nutrition and ingredients) to the selected Meta vision model.
- [ ] Validate authentication/authorization, request format, model availability, response schema, per-image behavior, max input size, duration, provider token/cost reporting, timeout and failure modes.
- [ ] Test at least two clearly different product pairs and one unreadable label. Demand null/unknown rather than fabricated values; evaluate image basis/units.
- [x] Remove or lock down temporary spike endpoint after use; retain tests/fixtures with non-sensitive sample data.

**2026-11-02 — PARTIAL:** [Live spike evidence](PICKWELL_META_VISION_SPIKE.md). Verified Email OTP, protected hosted multi-image Meta calls and post-trial disabled-state/token rotation. Product A nutrition and Product B ingredients extracted in diagnostic candidates; their other labels requested retakes, so complete two-product extraction did not pass. The supplied third image passed a mismatch-retake test; genuinely unreadable testing is deferred by user direction. Eleven local tests pass. Original full T01.1 acceptance remains unmet; no later phase started.

**Acceptance:** Actual live Meta call returns structured ingredient and nutrient extraction from two photos; unreadable sample fails safely. Capture measured real latency/tokens and blocked constraints.  
**Targeted validation:** One real API integration script/test, explicit invalid-image case, model access and secret-leak check.  
**Hard blocker:** Do not claim the MVP AI integration is ready until a genuine call works.

## 4. Phase 2 — Supabase foundations (P0)

### T02.1 Migrations for shared catalog and analysis jobs

- [x] Translate `PICKWELL_DATABASE.md` illustrative SQL into real versioned migrations; review existing schema before applying.
- [x] Create products, analyses, ingredient/nutrition structured fields, findings/evidence, analysis jobs, unique normalized barcode constraint, status lifecycle, timestamps, model/rule versions and contributor references as specified.
- [x] Plan product correction/invalidation without giving contributors overwrite rights; make error/retry state explicit.
- [x] Seed a **clearly identified demo record** with complete safe nutrition and analysis for cache-hit testing.

**2026-11-02 — COMPLETE, including native local Supabase validation:** [Catalog foundation evidence](PICKWELL_CATALOG_FOUNDATION.md). Nine isolated tests pass with 46 expected rejection checks. Native Supabase CLI 2.122.0/PostgreSQL 15.19 then passed clean migration/seed reset, actual migration replay with an existing-data sentinel, demo replay without duplicates, and all 37 pgTAP assertions across catalog/consumer suites. Test stack stopped afterward. Docker blocker resolved through Native Runtime; no remote database changed. T02.2 and later phases are not started.

**Acceptance:** Migrations apply cleanly to clean test DB and preserve existing data when rerun via migration runner; duplicate barcode prevented; only `ready` considered published.  
**Targeted validation:** SQL schema/assertion tests for unique barcode, FK integrity, job state and version metadata.

### T02.2 RLS and least-privilege boundary

- [x] Enable RLS on every exposed table; deny direct anonymous/authenticated writes to shared catalog, jobs, entitlements, usage, and webhook data.
- [x] Keep privileged DB access in Edge Functions; public `get-product` returns a sanitized published projection only.
- [x] Ensure `get-analysis-status` is owner-scoped; avoid overprivileged callable SQL functions and harden any security-definer functions.
- [x] Separate all test/sandbox billing events from production entitlements.

**2026-11-02 — PARTIAL (public lookup runtime deferred):** [Security boundary evidence](PICKWELL_SECURITY_BOUNDARY.md). Native PostgreSQL 15.19 passes 59 pgTAP assertions and 7 Auth/REST tests, including 64 denied client table operations, server-only inserts and cross-user job rejection. Server-only quota/entitlement/webhook storage and default-privilege hardening added; no quota/billing logic activated. Sanitized published reader is verified, but public `get-product` waits for T02.3 admission controls and T03.1 endpoint wiring. Status handler core exercised with real local Auth/REST; Edge deployment is not claimed. Native stack stopped; no hosted project changed.

**Acceptance:** Client cannot directly forge findings, grant Premium, increment/decrement quota or retrieve another user's jobs.  
**Targeted validation:** Negative DB/REST authorization tests using publishable and verified-user tokens; server-only insert works.

**T03.1 follow-up:** The deferred sanitized public-read handler is now implemented and verified over local HTTP against native Auth/REST; see [lookup evidence](PICKWELL_PRODUCT_LOOKUP.md). All T02.2 local implementation checks are now covered. Hosted Edge gateway execution remains unverified; the earlier PARTIAL report above records its original task-time state.

### T02.3 Plan config, quotas, reservations, and spend controls

- [x] Seed Free plan with `barcode_lookup=30` and `ai_analysis=3`, reset at 00:00 UTC, with server-controlled mutable config and version/audit fields.
- [x] Implement atomic per-user quota consumption/reservations and idempotency. Successful publication finalizes one AI usage; cache hit/failed extraction releases a reserved AI slot.
- [x] Prevent repeated retries, cross-request races and multiple AI calls on the same barcode; track provider spending separately from user allowance.
- [x] Implement best-effort public lookup throttling for guests (IP/proxy-aware) and authenticated exact barcode usage. Set global spend ceiling and concurrency caps.

**Acceptance:** 30th authenticated lookup allowed and 31st denied; 3rd successful new analysis allowed and 4th denied; changing limit to 20 applies on subsequent calls without mobile release. Guest is not promised enforceable per-person usage.  
**Targeted validation:** Concurrent atomic reservation, 00:00 UTC reset, negative usage, idempotent retry and rollback/release tests.  
**Note:** Quota counting semantics must match PRD: charge only valid definitive lookup statuses; no charge for local reopening or lookup transport errors.

**2026-11-02 — COMPLETE (backend/native validation):** [Quota controls evidence](PICKWELL_QUOTA_CONTROLS.md). Additive audited 30/3 Free config, atomic UTC reservations/finalization, bounded job/barcode provider claims, separate spend/concurrency admission and trusted-proxy-aware guest throttling. Native checks pass 85 pgTAP assertions, 19 quota/Auth/REST tests, 7 existing security tests and 9 isolated migration tests. No hosted migration, public endpoint or Meta call occurred. Billing and normal inference remain disabled; verified model cost bounds/proxy attribution and endpoint integration are deployment prerequisites. T02.2 public lookup remains open for T03.1. Native services stopped.

### T02.4 Operational events and cost ledger

- [x] Record minimal backend events: `barcode_scanned`, `product_cache_hit`, `product_not_found`, `capture_completed` (if intentionally sent), `analysis_started`, `analysis_completed`, `analysis_failed`, `analysis_retake_required`, `quota_exceeded`.
- [x] Maintain server-only model/provider/tokens/estimated cost/duration ledger if available; limit access and retention.
- [x] Ensure nonessential analytics failures do not bypass or incorrectly deny quota checks.

**Acceptance:** Can inspect counted cache hits, Meta calls, failures and daily spend without revealing image payloads, passwords or API tokens.  
**Targeted validation:** Redacted event assertions and optional analytics failure behavior.

**2026-11-02 — COMPLETE (backend/native validation):** [Operational evidence](PICKWELL_OPERATIONAL_EVENTS.md). Fixed-field deduplicated events, separate estimates/provider metrics, server-only daily reports and atomic retention/archival added. 128 native pgTAP assertions, 8 operational tests, 19 quota tests, 7 security tests and 9 isolated migration tests pass. Analytics-write failures preserve quota decisions; mandatory cost failures stay fail closed. No hosted change, public endpoint or live AI call occurred. Local Cron is absent: maintenance was tested directly; automatic scheduling must be enabled/verified before hosted use. Native stack stopped.

## 5. Phase 3 — Barcode scanning and cached lookup (P0)

### T03.1 Implement `get-product` backend endpoint

- [x] Validate/canonicalize barcode; return typed `ready`, `not_found`, `processing`, `rate_limited`/`quota_exceeded`, or `error` states.
- [x] Apply correct guest throttling/authenticated quota; securely read published projection; do not trigger AI.
- [x] Return effective quota/remaining and UTC reset when reliably known; never trust client counters.

**Acceptance:** Seeded barcode returns complete results with **zero Meta calls**; missing barcode explicitly returns `not_found`; timeout/DB unavailable does not masquerade as a miss.  
**Targeted validation:** Function endpoint tests for found, miss, malformed, throttled and DB error; trace confirms no model invocation.

**2026-11-02 — COMPLETE (backend/local HTTP validation):** [Lookup evidence](PICKWELL_PRODUCT_LOOKUP.md). Guest-capable handler with independent Auth verification, throttling, canonical GTIN validation, sanitized published responses, atomic quota/read settlement and bounded replay receipts. Native tests pass 142 pgTAP assertions, 11 lookup HTTP/handler tests, 19 quota tests, 15 security/events tests and 9 isolated migration tests. Trace and unchanged provider ledger confirm zero Meta calls. No hosted deployment or Deno gateway execution was performed; HMAC/ingress configuration and actual gateway checks remain deployment prerequisites. Native services stopped.

### T03.2 Flutter scanner/home and lookup UX

- [x] Reuse existing template/navigation; implement **lemon-branded recent-products Home**, not scanner-first. Header logo + only search icon, All/Food chips, Newest sort, separate rounded cards, no section heading or list/grid toggle.
- [x] Create liquid-glass-inspired translucent Home/Settings pill, **separate far-right scan circle with icon only**; hide it on nested routes, with Android visual fallback. Chat is future visual reference and must not ship as dead tab.
- [ ] Implement minimal scanner camera and permissions following DESIGN.
- [ ] Integrate suitable scanner dependency only if none exists; enable camera and gallery where needed; test common EAN/UPC.
- [x] Use Cubit/Bloc states for idle, scanning, checking, found, miss, processing, denied, error.
- [x] Navigate directly to results for `ready`; to 3-step wizard for `not_found`; expose retry for network failure.
- [x] Optionally add manual barcode input as a P1 fallback, without displacing P0.

**Acceptance:** Guest lands on correct empty/local recents Home, opens scanner with prominent rightmost Scan icon, scans existing and unknown demo barcodes; no sign-in gate before lookup.  
**Targeted validation:** Scanner/lookup Cubit tests, camera permission-denied flow, one real-device barcode scan.

**2026-11-02 — PARTIAL (device/live backend acceptance pending):** [Scanner/Home evidence](PICKWELL_SCANNER_HOME.md). Mason-derived catalog layers, local recent Home/search, green/cream themes, separate scan dock action, camera/gallery/manual input, typed Cubit/lookup, minimal result/capture routes and 30-reference index implemented. 25 focused tests and static analysis pass; iOS simulator/signed device and Android debug builds pass. iPad install/launch succeeded, but user deferred physical barcode testing. Hosted get-product availability probe returned 404; no hosted deployment/write occurred. Native camera/permissions/EAN-UPC/gallery tests and live ready/miss remain unverified. Approved lemon artwork is missing (labeled emoji placeholder); new copy has English locale fallbacks. Camera/native-format checkboxes remain open; no full T04 capture/OTP/submission or monetization was started.

**2026-11-02 — Hosted lookup follow-up:** Existing `get-product` is now deployed and
live guest demo ready/miss, invalid-session/body/method, signed-in quota/idempotency
and guest throttle checks passed; [hosted evidence](PICKWELL_PRODUCT_LOOKUP.md#hosted-deployment-and-live-validation--2026-11-02).
Only the labeled synthetic demo seed was added. Provider ledger remains empty;
inference/billing stay disabled. T03.2 remains PARTIAL for physical camera,
permissions, EAN/UPC/gallery and live mobile navigation. No device checkbox changed.

### T03.3 Local recent-products Home index and search (P0 recent index / P1 filtering polish)

- [x] Record only unique published ready barcode references and last-opened timestamps in a bounded device-local index; no personal account/cloud history, persistent user label photos or full offline analysis payloads.
- [ ] On app relaunch, display available last-viewed product cards with truthful thumbnails (actual authorized media or placeholder). Refresh summary online when needed and follow server lookup/quota rules; never invent package photos or pretend results are locally available offline.
- [x] Search icon expands into search field; filter the local list, allow All/Food and newest order; Cosmetics and Chat must remain nonfunctional concepts outside shipped MVP.
- [x] Empty state encourages scan without fake product fixtures.

**Acceptance:** A real ready barcode opened once appears in Home after app restart, newest-first and deduplicated. Empty state correct. Scanning remains guest-accessible. Local reopening does not trigger Meta.  
**Targeted validation:** Local persistence/dedup/search/filter unit tests, widget check for screen density and scan button, missing-photo fallback and offline handling.

**2026-11-02 — PARTIAL (real-product restart acceptance pending):** [Local recents evidence](PICKWELL_LOCAL_RECENTS.md). Existing 30-entry reference-only persistence reused; online resolution after source/repository restart added without rewriting opening timestamps. Local newest/search/Food filtering, unavailable placeholders, retry and duplicate-load protection verified. **32 focused tests pass; static analysis clean.** SharedPreferences/repository restart checks use synthetic ready fixtures. A real published product and actual device restart/card restoration remain unverified; the relaunch criterion stays open. No cloud write, new Meta call, billing or later capture/submission task was performed.

## 6. Phase 4 — Guided capture and Email OTP (P0)

### T04.1 Three-step nutrition + ingredients photo capture

- [x] Display **Step 1 Barcode ✓ → Step 2 Nutrition → Step 3 Ingredients**, with preview, retake, guidance, and progress.
- [x] Store in-progress photos only in bounded app-local transient state; compress/resize; check supported MIME and size before upload.
- [ ] Optionally infer/edit product name and brand without extra mandatory step; never accept them as authoritative replacements for labels.
- [ ] Preserve selected photos/barcode across OTP redirect and return.

**Acceptance:** After a missing barcode, user captures 2 readable photos without rescanning barcode; can retake one image independently.  
**Targeted validation:** Wizard state persistence across navigation, invalid-format/oversize, camera failure, separate retake paths.

**Follow-up — PARTIAL (hardware capture and real OTP return pending):** [Capture draft evidence](PICKWELL_CAPTURE_DRAFT.md). Fixed three-step guided capture, separate retakes/previews, signature/size/decode/dimension checks and app-private temporary file references implemented. Single one-hour draft survives route replacement; discard/retake/expiry/late-result and startup cleanup covered. **42 focused tests pass; static analysis clean.** Physical label readability/native camera behavior and the actual T04.2 OTP redirect remain unverified, so those checkboxes stay open. Optional name/brand editing is omitted. No upload, Meta call, new package, billing change or later-phase implementation.

**2026-11-03 user confirmation:** Physical-camera capture works on the user's device. Capture UI checkbox verified using that report plus automated tests; actual OTP return remains pending T04.2. No agent-run hardware test is claimed.

**User-requested draft follow-up (2026-11-03):** [Pending analysis evidence](PICKWELL_PENDING_ANALYSES.md). Back and ordinary app close now preserve one bounded private pending draft, with a 24-hour expiry, Home/detail resume warning and explicit deletion. Publication still awaits local photo cleanup; no photos enter published recents or cloud history. The old one-hour process-only policy is superseded by this explicit request. Device forced-close acceptance is not claimed.

**Multiple-draft follow-up (2026-11-03):** The user-requested pending queue now supports five independent products, one per normalized barcode, with legacy single-draft migration and per-item Home/detail resume, expiry and deletion. Switching products preserves photos and idempotency metadata; a full queue refuses new captures without evicting saved items. 100 catalog tests pass; analyzer clean. Device/live acceptance remains unverified. See [pending analysis evidence](PICKWELL_PENDING_ANALYSES.md).

### T04.2 Email OTP auth and submission gate

- [x] Configure Supabase Auth Email OTP as an actual code flow; verify email template, provider delivery limits and session persistence.
- [x] Prompt sign-in **only when submitting unknown-product analysis**; scanned cached products remain publicly accessible.
- [x] Support send/verify/resend/error/cancel and safe resume of the two photos; session expiration handled.
- [x] Backend verifies trusted JWT and persistent verified email; do not rely solely on Flutter or on the generic `authenticated` role if anonymous auth is later enabled.

**Acceptance:** Guest captures photos, signs in, returns to exactly the same analysis submission, and can proceed; guest direct call to analysis endpoint is forbidden.  
**Targeted validation:** OTP integration, incorrect/expired OTP, guest rejection server-side, post-auth resume.

**2026-11-03 — PARTIAL (actual analysis endpoint wiring remains T05):** [Email OTP evidence](PICKWELL_EMAIL_OTP_GATE.md). Contextual Analyze → Email code → same-photo review implemented using existing auth SDK/session and app-owned draft; send/resend/cooldown/error/cancel/expired-session handling tested. Cloud settings confirm 8-digit OTP, one-minute interval and 30 emails/hour; no security setting was weakened to match the six-digit design example. Fresh real code verified HTTP 200; wrong/consumed codes HTTP 403. Deployed auth-only `authorize-analysis`: guest/public-key/forged-token HTTP 401, verified user HTTP 200. **54 Flutter tests, 12 backend tests pass; 1 native-stack test skipped; analyzer clean; Android debug build passes.** Shared backend guard is ready, but the actual analyze-product handler does not yet exist and must enforce it in T05. Physical app OTP/restart persistence and natural code-age expiry remain unverified; UI/SDK persistence and return are automated checks. No Meta call, image upload, billing or quota change.

**T05.1 follow-up:** The actual protected `analyze-product` handler now invokes the shared trusted-email guard, and hosted guest/public-key/forged-token calls are denied before model work. This resolves the backend-boundary checkbox; full app submission remains dependent on T05.2/T05.3 and Flutter upload wiring, and on-device OTP/restart evidence is still not claimed.

## 7. Phase 5 — AI processing and reusable publication (P0)

### T05.1 `analyze-product` secure job orchestration

- [x] Recheck normalized barcode and existing job/`ready` record atomically before invoking Meta; deduplicate with job lease/idempotency key.
- [x] Authorize verified user, apply quota reservation and rate/concurrency/global spend checks before model call; record job states.
- [x] Validate both image inputs; send private server-side API request with bounded timeouts; use status/polling only if necessary for hosted execution constraints.
- [x] Limit retries to prevent API-cost storms; user retry of same request idempotency key must not double-charge.

**Acceptance:** One new barcode has no duplicate published record; blocked/unverified caller cannot invoke model; concurrent users share the outcome safely.  
**Targeted validation:** Mocked provider with parallel submit, auth, duplicate, quota rejection and timeout tests.

**2026-11-03 — COMPLETE (backend orchestration/native targeted validation; hosted inference remains OFF):** [Orchestration evidence](PICKWELL_ANALYSIS_ORCHESTRATION.md). Image-bound idempotency, trusted confirmed non-anonymous identity, atomic existing-job/cache/quota admission, one provider claim and bounded Meta adapter reuse implemented. Private structured handoff awaits T05.2/T05.3; no photos are retained or premature product published. **54 native Auth/REST/SQL/handler tests plus 25 isolated/spike/auth/schema tests pass**, including 32 parallel submissions from two users, same-key retry, exact quota/attempt/spend caps, timeout/lost-acknowledgement holds and one synthetic atomic publication reused without more model calls. Migration and protected endpoint deployed; hosted guest/forged sessions 401, malformed verified input 400, valid unknown input 503 inference_disabled, cached demo 200 already_exists. Hosted provider ledger/jobs/candidates remain zero. No live Meta inference or billing activation; actual extraction/interpretation/publication and client upload remain later tasks. Native stack stopped.

### T05.2 Extract, interpret and validate

- [ ] Extract ingredient raw text, ordered items, nutrition values with units and per-serving/per-100g basis, and declared allergens where visible.
- [x] Meta generates understandable explanations; deterministic backend rules assign green/yellow/red only with evidenced and threshold-backed reasons.
- [x] Represent ambiguous values as unknown; verify required fields, product consistency, numeric ranges and source basis.
- [x] If nutrition or ingredient image unclear, return `needs_retake` referencing **which photo** rather than publishing partial misleading results.
- [x] Record model version, prompt/rules version and evidence/provenance; no overall food score or blanket healthy/unhealthy certification.

**Acceptance:** Two representative food labels produce readable validated result; a bad image produces actionable retake; traffic-light claims trace to label/rules.  
**Targeted validation:** Fixture-based schema/rules tests; malformed and contradictory payload tests; real images from Phase 1.

**2026-11-03 — PARTIAL:** [Validation and real-call evidence](PICKWELL_ANALYSIS_VALIDATION.md). V2 source/unit/basis/consistency validation, photo-specific retakes, constrained Meta fact explanations and versioned deterministic nutrient rules integrated into the private handoff; no publication. **43 targeted native/mock/schema tests pass.** Three fresh protected two-image Meta calls returned retakes; corrected source-spelling checks were rerun on the saved candidates without more paid calls. Product A still needs ingredients; Product B needs both photos; the readable cookie mismatch is not an unreadable test. Two complete real products, genuine unreadable-image evidence and substantive ingredient explanations remain unmet, so the first two checkboxes remain open. Protected analyze-product updated with inference/billing OFF; spike disabled/token rotated after use. No Flutter or migration changes.

**User-approved policy follow-up (2026-11-03):** Recognizable nutrition panels may proceed with contextually resolved nutrient words and explicit unknown amounts/basis; individual uncertain fields no longer force retakes. Publication preserves missing information and avoids unsupported findings. See [updated validation evidence](PICKWELL_ANALYSIS_VALIDATION.md). 58 backend and 12 client tests pass, analyzer clean; additive storage compatibility migration and protected handler deployed. Real-image success remains unverified; the existing three-attempt test cap was not increased.

**Retake diagnostics follow-up (2026-11-03):** [Retake evidence](PICKWELL_RETAKE_DIAGNOSTICS.md). Model and validator failures now return separate photo/field/reason codes with owner-only replay persistence. A conflicting shared prompt was aligned with the approved unknown-field policy. Legacy results do not invent reasons and can explicitly reanalyze saved photos to obtain diagnostics. 106 Flutter / 82 backend tests pass; additive migration and protected handler deployed. Full real-image success remains unverified.

**Numeric-source regression follow-up (2026-11-03):** [Matching evidence](PICKWELL_NUMERIC_SOURCE_MATCHING.md). Uppercase/compact/word-unit and explicit parenthesized formats now match their equivalent transcription; amounts and decimal meanings are not guessed. Completed source-check retakes may explicitly reanalyze saved photos under unchanged server controls. Real-photo/full-flow acceptance remains open.

### T05.3 Publish product and securely dispose photos

- [x] Write accepted record and analysis/findings as an atomic published transition to `ready`; finalize one successful-analysis credit.
- [x] Rejected/failed analysis does not consume successful-analysis credits, but provider spend remains in ledger.
- [x] Do not persist original images unless private temporary storage is absolutely required; delete temporary files after successful extraction and via bounded cleanup of failures/orphans.
- [x] Do not expose contributor email or transient images in public record.

**Acceptance:** Another guest sees the result by scanning same barcode without AI; photos are not retained after successful extraction.  
**Targeted validation:** Save/lookup integration, duplicate publish, cleanup success/failure, sensitive data projection.

**2026-11-03 — PARTIAL (backend complete; client disposal/full flow pending):** [Publication evidence](PICKWELL_PUBLICATION.md). Recomputed validation and exact staged/version binding precede atomic product/revision/findings/ready/quota settlement. Lost acknowledgements resume without another model call; invalidated products require operator review. Terminal/expired candidates clean up, original server photos are never persisted, and public metadata is allowlisted. **76 targeted tests plus 11 hosted checks pass.** New additive migration and protected analyze-product/get-product deployed with inference/billing OFF. Real new publication→guest reuse is verified against native Auth/REST/SQL with a mocked provider, not fresh real Meta labels. Successful client upload/result must still invoke existing draft discard; leave the photo-disposal checkbox open. Full-flow/device tests are deferred by user request; T05.2 quality blockers remain.

**T06.1 follow-up:** The previously missing Flutter submission/result/disposal handoff is implemented. Confirmed ready/cache success awaits owned-file disposal before result navigation; real temporary-file deletion, cleanup failure/retry and late-result protection pass targeted tests. All T05.3 implementation checkboxes are now verified; full live/device acceptance is still deferred and no new real Meta publication is claimed. See [client-flow evidence](PICKWELL_RESULTS_FLOW.md).

## 8. Phase 6 — Results, quota UI and RevenueCat readiness (P0/P1)

### T06.1 Product results and accountable findings (P0)

- [x] Implement approved nested Product Details: back + overflow, **no logo app-bar title or bottom tabs**, product identity/photo or fallback, ingredient explanations, nutrition, summary, green/yellow/red findings, declared allergens, missing information and analysis timestamp.
- [x] **No numeric 92/100 score, unsupported healthy certification, or Add to List.** Share native action is optional P1 with valid non-sensitive data.
- [x] Show color-independent warning icons/labels and readable explanations; format servings/units consistently.
- [x] Display explicit status while analyzing and relevant-label retake state; safe retry, not infinite progress.

**Acceptance:** Cached and newly generated analyses use the same result UI and evidence model; result understandable without relying on color.  
**Targeted validation:** Widget tests for green/yellow/red/unknown, missing values, long ingredient names and error states.

**2026-11-03 — IMPLEMENTED (targeted automated acceptance; live/device flow deferred):** [Results/client-flow evidence](PICKWELL_RESULTS_FLOW.md). Contextual OTP now submits bounded binary photos with image-bound request-key reuse, explicit response states, bounded manual checks and no automatic paid retry. Accepted publication is stored in memory/recents and opens the shared nested result UI after awaited photo cleanup; cleanup failure has a cleanup-only retry and late results preserve unrelated drafts. Result cards expose label explanations, evidence/rules, units/basis, unknowns, declared allergens, missing information and timestamp, with icons/text beyond colour and no score/Add to List/dock. **74 focused tests pass, analyzer clean; light/dark renders inspected.** No new packages, backend changes, paid calls or inference/billing activation. Real-device/live Meta acceptance and prior T05.2 blockers remain deferred; new translations use English fallbacks.

### T06.2 Remaining usage and quota-exceeded states (P0)

- [x] Surface exact authenticated remaining barcode and AI quota where backend provides it, with UTC reset converted to user's time zone for display.
- [x] Guest messaging must avoid claiming strict personal limits; display general fair-use or rate-limit status as appropriate.
- [x] When quota exhausted, explain next reset and allow user to view already loaded results; no unavailable purchase button.
- [x] Avoid refreshing usage on every widget frame; trust server response, not a local mutable allowance.

**Acceptance:** 30/3 remaining states agree with server; changing server plan limits updates UI without app release.  
**Targeted validation:** Boundary/reset, offline display fallback and no-paywall quota states.

**2026-11-03 — IMPLEMENTED (targeted/native/hosted verification):** [Quota UI evidence](PICKWELL_QUOTA_UI.md). Typed server snapshots, local reset display, guest fair-use copy, loaded-result access and unknown/offline/expired states; no client allowance or paywall. **86 Flutter and 58 backend tests pass; analyzer clean; eight hosted checks pass.** Updated only the protected analysis response metadata; zero Meta calls, billing/inference remain disabled. Full live/device flow and earlier T05.2 constraints remain deferred.

### T06.3 Premium-ready entitlement tables and RevenueCat webhook safety (P0 backend design; deploy only when prerequisites satisfied)

- [ ] Implement backend Free/Premium plan resolution, future entitlements, user-to-RevenueCat App User ID mapping, append-only unique event ledger and billing feature flag `false`.
- [ ] Prepare protected `revenuecat-webhook` entrypoint or isolated handler with RevenueCat's documented authentication verification; refuse unsigned/invalid requests; test duplicate/out-of-order event handling.
- [ ] Never grant Premium from Flutter `CustomerInfo`, a claimed plan string or any unverified webhook. Ambiguous aliases and expired subscription events require reconciliation before changing a plan.
- [ ] No paywall, billing SDK initialization, product IDs, offering fetches or purchase buttons in MVP; exact Premium allowances remain TBD.
- [ ] If RevenueCat credentials/config are unavailable, keep webhook **not deployed/disabled** and test safely with fixtures; do not expose an unauthenticated public webhook.

**Acceptance:** Free is the effective plan for normal users, backend can represent test Premium without client tampering, and fake/replayed webhooks cannot grant entitlements.  
**Targeted validation:** SQL/API role tests, webhook authentication and replay fixture tests, billing flag false.  
**Scope safeguard:** Do not block the actual hackathon barcode+AI demo on real subscription events or RevenueCat store configuration.

### T06.4 Settings/account & minimal operational UI (P1)

- [ ] Implement minimal account email, sign-out, privacy links, and usage section per DESIGN; no fake purchases. Use newest lemon/cream tokens and consistent simple surfaces.
- [ ] Respect template styling and avoid new onboarding carousel or additional premium screens.

**Acceptance:** Account state and usage can be viewed; sign-out prevents another analysis without re-authentication.  
**Targeted validation:** Settings/account widget behavior and session invalidation.

## 9. Phase 7 — Demo/release checks (P0)

### T07.1 End-to-end acceptance and security pass

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

### T07.2 Hackathon submission handoff

- [ ] Record a truthful ≤3-minute demo using actual working flows and confirmed Meta model; don't misrepresent mock responses as live.
- [ ] Capture quick technical explanation: shared barcode cache, two-image Meta analysis, rule-based findings, safe retries/auth/quotas.
- [ ] Prepare public GitHub repository/submission materials according to verified organizer instructions while removing secrets and sensitive credentials.
- [ ] Verify organizer deadline and upload requirements directly before final submission.

**Acceptance:** Public demonstration and repository reflect actual product; submission checklist and proof of Meta integration are complete.

## 10. Risk-based fallback order

If timeline threatens completion, narrow in this order **without changing approved safety behavior**:

1. Drop P1 Settings polish, manual barcode entry and brand editing.
2. Simplify transitions and icons; maintain readable core screens.
3. Keep only concise evidence-aware findings, no complex visual charts.
4. Keep RevenueCat backend schema/config designed but defer live webhook deployment if credentials/testing are unavailable; billing remains off.
5. Use basic synchronous analysis only if validated under real Edge Function timeouts; otherwise use minimal durable job tracking.
6. **Never drop:** Meta end-to-end proof, barcode cache hit, server-side verified auth for AI, RLS, quotas, duplicate-write protection and safe failure/retake.

## 11. Agent workflow and status tracking

- One focused task/phase per agent handoff. Read real repo and docs before edits.
- Task IDs are stable. When completed, check the relevant box **only after test evidence**, with a brief completion note in existing task-tracking convention.
- Always report changed files, targeted commands/tests and results, pending credentials, blocked acceptance criteria, and introduced placeholders.
- Do **not** default to full-project regression or unrelated refactors.
- `AGENTS.md` is the next StartAppLab artifact; preserve any existing agent instructions and extend rather than overwrite.
- If any requirement contradicts approved PRD/SPEC/DATABASE, stop only that conflicting implementation step and document the conflict; do not silently change the product.

**Prepared documents:** `PICKWELL_PRD.md` v1.4; `PICKWELL_DESIGN.md` v1.2; `PICKWELL_SPEC.md` v1.2; `PICKWELL_DATABASE.md` v1.0; this `PICKWELL_TASKS.md` v1.1.

**2026-11-03 — T05.2 real-fixture follow-up:** Three real Meta calls reproduced
Product B's redundant raw/source rejection. Both supplied pairs now validate after
the named-row/bilingual-calories fix; 41 minimal tests pass. See
[numeric-source evidence](PICKWELL_NUMERIC_SOURCE_MATCHING.md#real-fixture-reproduction-and-correction--2026-11-03).
No checkbox changed: per-field accuracy, genuine unreadable sample and full device
publication flow are still unverified.

**2026-11-03 — User-approved OCR-first policy:** [Evidence](PICKWELL_OCR_FIRST_POLICY.md).
Readable partial/text-only label information proceeds; duplicate transcription
checks gate colour claims rather than extraction. Invalid/contradictory amounts
become unknown; empty/wrong/mismatched photos still need replacement. Two real
fixture pairs validated and 68 targeted native/schema/adapter tests passed.
Independent field-accuracy review, genuine unreadable-image testing and device
full-flow acceptance remain unverified; no additional completion checkbox marked.

**2026-11-03 — T05.2/T06.1 nutrient-unit follow-up:** [Unit evidence](PICKWELL_NUTRIENT_UNITS.md).
Added IU, qualified vitamin and percent/DV units throughout extraction, storage and
Flutter display; historical unknown amounts expose their source. No conversions
or new health classifications. 71 backend/native and 14 Flutter tests passed;
mobile rebuild/device confirmation remains outstanding. No task checkbox changed.

**2026-11-03 — T05.2/T06.1 evidence-aware interpretation:** [Implementation and evidence](PICKWELL_INTERPRETATION.md).
Reviewed ingredient functions, contextual nutrition, source-backed serving-reference
findings, model-selected bounded composition and meaningful summaries now replace
literal fact restatements for new analyses. Expandable details show references,
limitations and uncertainty. Versioned operator refresh preserves immutable facts
and performs no model call on lookup. The understandable-explanations checkbox is
verified; no broader task completion is implied. The low-resolution cereal fixture
has inconsistent OCR and further product/accuracy testing is deferred at user request.

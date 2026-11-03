# PICKWELL AI V2 — TECHNICAL SPECIFICATION

**File:** `PICKWELL_SPEC.md`  
**Version:** 1.3 — Product trust gates and post-submission architecture\
**Date:** 2026-11-04\
**Repository:** `pickwell-ai`  
**Framework:** StartAppLab App Framework — Stage 2 (PRD → DESIGN → SPEC → DATABASE → TASKS → AGENTS)  
**Status:** Existing implementation/verification is recorded in TASKS and T07.1 evidence. Section 18 is an approved future contract, not implemented by this documentation revision; earlier feasibility caveats remain historical planning context.

## 1. Source of truth, principles and scope

Read `PICKWELL_PRD.md` (canonical v1.5), then `PICKWELL_DESIGN.md`, before this spec. If they disagree, apply later **user-approved decisions** and flag discrepancies instead of silently changing scope.

**App promise:** Barcode-first packaged food scanning. Guests can scan and view previously published nutrition/ingredient analysis immediately without AI. Unknown products enter a **Barcode ✓ → Nutrition photo → Ingredients photo** capture. Verified Email OTP user can submit. Meta AI analyzes labels in Supabase Edge Functions; validated structured results and documented red/yellow/green findings are published and reused by all subsequent scanners.

**Included:** Barcode scanning, public catalog lookup, three-step capture, Email OTP at submission, AI analysis, backend rules, retake/error states, shared published product data, quotas, lightweight analytics, privacy/security. **Excluded:** product comparison, chatbot, cosmetics, numeric food score, personal history/offline access, social sign-ins, ads, **active** payments/subscriptions or paywall, personalization. Server-side RevenueCat-readiness is included. Do not silently add excluded packages, tables or UI.

**Architecture rules:** Flutter is untrusted. Never embed a Meta API key or privileged Supabase key in the app. Keep AI orchestration and all catalog writes on the server. Preserve existing Flutter template structure and dependencies wherever compatible; confirm rather than assume repo layout.

## 2. Stack and deployment

| Layer | Decision | Verification/notes |
|---|---|---|
| Mobile | Flutter + Dart; Cubit/Bloc within existing template | Keep existing routing, DI, localization and design conventions |
| Barcode scanner | Existing template solution if present, else evaluate `mobile_scanner` | Test EAN-8, EAN-13, UPC-A, UPC-E and camera behavior on actual devices; normalize UPC/EAN carefully |
| Image capture | Flutter `image_picker` or installed equivalent | Gallery/camera, in-memory draft, preview, retake, crop/resize only when legible |
| Supabase client | `supabase_flutter`, approved compatible version | App holds URL + **publishable** key only |
| Auth | Supabase Auth **Email OTP code** | Guest lookups without login; only verified signed-in user may submit new AI analysis |
| Backend API | Supabase Edge Functions (TypeScript/Deno) | Public lookup and user-protected analysis; prefer current Supabase server auth helper where compatible |
| Database | Supabase Postgres | RLS + revoked client privileges; dedicated server-only writes; unique barcode/job constraints |
| Processing images | Transient upload over HTTPS; private Storage only if queued or payload constraints require | Delete private temporary images after extraction, plus orphan cleanup |
| AI | Accessible Meta multimodal model API | **Blocking spike:** verify real credentials, endpoint, cost, model version and two-image extraction from a deployed Edge Function |
| Analytics | Minimal Supabase operational events/metrics | No third-party analytics SDK; no label image or token payload logging |
| Billing readiness | RevenueCat + Supabase (server-side integration points) | Entitlement mapping, webhook contract and persistence prepared; **no live purchases/paywall** |

**Platform baseline:** Implement for the OS/device minimums already supported by the boilerplate; do not invent exact iOS deployment target or Android min/target SDK before inspecting its files. Verify actual targets, camera permissions, OS policies, OTP delivery and current store requirements before public submission. This hackathon build may be demonstrated without both production store releases.

## 3. High-level flows

```text
Flutter: barcode scan
    └─ HTTPS → Edge Function get-product → Postgres (published ready barcode)
            ├─ found → stored nutrition + ingredients + findings → results UI (ZERO Meta calls)
            ├─ processing → status + retry/poll (no duplicate AI call)
            ├─ not_found → photo capture wizard
            └─ failure → network/server error (never misclassified as not_found)

Unknown barcode
    → Barcode ✓ → Nutrition photo → Ingredients photo
    → optional name / brand → Analyze
    → verified email OTP if guest (preserve draft)
    → Edge Function analyze-product (JWT, quotas, idempotency, duplicate recheck)
    → Meta image extraction → validate → interpretation + deterministic rules
    → transactionally publish ready record → clean temporary images
    → results UI → next barcode scanner receives cached result
```

## 4. Flutter modules / state ownership

Suggested feature areas (adapt paths to existing project, do **not** impose a new architecture):

- `home`: bounded device-local recent barcode index, UI fetch/resolve, search/filter/newest, empty state and navigation.
- `scanner`: permission, camera stream, barcode formats, debounce, lookup trigger and retry.
- `capture`: three-step wizard, draft state, previews, legibility guidance, optional name/brand, retakes.
- `auth`: send Email OTP, verify code, resend cooldown, session observer, resumed submission.
- `analysis`: submit images, track job/result, retry/retake/error mapping.
- `product`: read-only product result view, labeled findings and provenance.
- `settings`: email/account state, sign out, privacy and analysis limits info.
- `core`: Supabase client, repositories, typed DTOs, structured network error handling and analytics facade.

**State:** Cubit/Bloc for independent feature machines. Keep a capture `Draft` containing normalized barcode, nutrition and ingredients file references, optional product identity, captured timestamps and progress state. Preserve that draft in memory while OTP is in progress, and clear it after successful submission or explicit discard. Persist **only the small approved device-local index of recent barcode references + timestamps** across restart, separately from in-progress photo drafts. Do **not** claim server-synced history or offline nutrition results. Temporary files must be removed when not needed. Avoid retaining raw image bytes in Cubit state or logs; use references/paths and controlled disposal.

**Scanner controls:** Scan one code at a time; debounce repeating camera frames. Pause scan stream while lookup/result/capture is active. Do not auto-trigger capture after a network timeout. Provide manually entered barcode fallback if available at low cost.

**Navigation:** Home (recent-product list) → separate rightmost Scan action → Scanner → transient lookup → cached Result **OR** Not Found → Capture → OTP (only if unauthenticated) → Processing → Result. Settings is primary secondary navigation. Home search opens from top-right icon. Returning from OTP preserves capture draft. Product Details is a nested route without root bottom navigation. Chat and cosmetics concepts are excluded from live navigation. Follow approved lemon DESIGN v1.2 for tokens, 60/30/10 and accessibility.

## 5. API contracts (logical v1)

Use versioned JSON shapes; return typed states and stable error codes. These contracts are a starting implementation contract and should be reconciled with database schema in `PICKWELL_DATABASE.md`.

### 5.1 `get-product` — guest-capable

`POST /functions/v1/get-product` with `{ "barcode": "..." }`.

Success examples:

```json
{ "status": "ready", "product": { "barcode": "...", "name": null, "brand": null, "nutrition": {}, "ingredients": [], "findings": [], "summary": "...", "analyzed_at": "...", "analysis_version": "..." } }
```

```json
{ "status": "not_found", "barcode": "..." }
```

```json
{ "status": "processing", "barcode": "...", "retry_after_seconds": 4 }
```

Return explicit `invalid_barcode`, `rate_limited` and `service_unavailable` error codes with suitable HTTP statuses. **Never report `not_found` when network/database lookup failed.** Do not return private job details, contributor email, quota records or internal model logs.

**Authorization:** public guest-capable function needs `verify_jwt = false` at platform layer if called without a session. Use an explicit handler authorization mode appropriate to an untrusted public endpoint, plus rate limiting; publishable key (when supplied) is **not proof of client identity**. Do not expose direct product database writes. Treat all inbound headers and IP addresses according to trusted proxy configuration.

### 5.2 `analyze-product` — verified user only

Prefer multipart image upload or time-limited **private** upload references. Request includes:

```json
{
  "barcode": "...",
  "nutrition_image": "<binary multipart upload or temporary private file reference>",
  "ingredients_image": "<binary multipart upload or temporary private file reference>",
  "name": null,
  "brand": null,
  "idempotency_key": "client-generated-uuid"
}
```

JSON shown only to illustrate fields; do not literally serialize images using this placeholder. Do not accept arbitrary external image URLs for model processing (SSRF). Validate content type from inspected file signature rather than trusting filename/MIME alone. Reject out-of-scope files, very large images, excessive dimensions or duplicate/reused submissions before invoking AI. Client-side compression must preserve text legibility. **Initial engineering defaults** (not approved business limits): max 2 required images, 5 MiB compressed per image, max one active job per user, default 5 new analyses/user/day; configuration must make limits easy to change, and deployment/runtime envelope must be tested.

Possible outcomes: `ready` with product, `processing` with job ID, `already_exists` with cached product, `needs_retake` with `nutrition` or `ingredients` target, `quota_exceeded`, `rate_limited`, `invalid_input`, `unauthorized`, `analysis_failed`. Return a stable idempotent result when same user/key retries; recheck ready barcode before charging quota or calling Meta.

**Authorization:** valid user JWT in `Authorization: Bearer <JWT>`; server must verify actual session and a **verified non-anonymous** email identity, not just `authenticated` role. Prefer `verify_jwt = true` and explicit user authorization in handler. Never allow a publishable key on its own to pass analysis authentication. Use server-owned elevated DB client only for tightly scoped operation after auth/authorization checks; avoid accidentally forwarding caller JWT to admin client.

### 5.3 `get-analysis-status` — optional for queue fallback

Only required if async processing is introduced or Meta request times out; `GET/POST` with job ID and verified caller session, return owner-scoped status. Do not reveal another user's job. For first end-to-end demo, a synchronous bounded request is acceptable **if measured duration is within hosting timeouts**. A server-side job state is still useful for atomic deduplication.

## 6. Authentication details

- Supabase **Email OTP numeric code** only. Supabase passwordless API may send a magic link by default unless the email template is configured with `{{ .Token }}`. Confirm template and SMTP/test delivery. OTP code entry should use platform autofill when available. Guard resends and failures.
- Allow guest scanning and `get-product` without creating an anonymous Auth account. No compulsory sign-in screen on app launch.
- On unknown barcode, allow both photo steps before sign-in. At Analyze, show Email OTP; after verified session, resume same draft.
- Guest submitting to backend is rejected even if the client somehow bypasses OTP UI. No elevated catalogue permissions attached to user tokens.
- Session expiry while submitting → `unauthorized` → refresh/re-auth without losing current draft (as long as app remains running).
- Sign out clears Auth state but not public product access.

## 7. Image and Meta AI processing pipeline

**Critical technical gate:** deployed Supabase Edge Function must successfully call the actual Meta model with **two different food label photos**, parse returned content and measure latency/usage. Model API product names, exact endpoint, token accounting, pricing and available image formats **must be verified using live project credentials**; no fallback provider is silently approved.

1. Check authorization/quota (analysis only), validate barcode and idempotency key.
2. Atomically query ready product and lock-or-claim job for barcode; avoid duplicate paid inference.
3. Validate uploads: format, dimensions, limit, legibility hints, and label-type tags; reject untrusted URLs and zip/binary payloads.
4. **Meta extraction pass:** request structured fields (`ingredients_raw`, ordered ingredient items, allergen declarations visible on label, nutrition values, per-serving/per-100g basis, units, serving size, uncertainty/missing fields). Temperature and schema strategy to be tuned in spike; parse and validate structured output regardless of model claims.
5. **Automated validation:** typed JSON schema; expected images and mandatory label content; realistic numeric ranges; units; consistency; source/basis; clear unknowns; cross-photo product consistency if discernible. On failure set `needs_retake` with an indicated image. Do not publish partial/guessed fields.
6. **Meta explanation pass:** concise non-medical ingredient descriptions and nutrition interpretation based only on extracted facts and approved source material. No invented citations.
7. **Backend deterministic findings:** apply documented versioned rules for favorable/concern/caution results. Rules engine owns categories, not model prose. Use documented reference thresholds and preserve serving basis; when not validated, omit classification rather than invent one.
8. Revalidate and transactionally persist a published ready analysis with model/rule version, extraction confidence/provenance and timestamp. Preserve raw label text where appropriate but not photos.
9. Delete transient photos after successful extraction; on errors or abandoned private temporary uploads run expiring cleanup policy. Preserve data required for a user to retake only as long as their in-app draft is needed.
10. Return final result / bounded job status. Record provider spend for every billable model request; charge a user AI allowance once only after successful validated publication, not on a cache hit or failed/retake attempt.

**No numeric food score.** Colors are **findings**, not a binary certified `healthy`/`unhealthy` verdict. A declared allergen is a caution, not evidence of universal risk. Missing allergen text does **not** mean allergen-free. Summary should state what is known and what needs context.

**Meta API failure:** timeout, invalid output or insufficient quota must yield `analysis_failed` or `needs_retake`, never success. Explicit retry budget; idempotent requests must not cause unbounded repeated AI billing. Set implementation timeout smaller than gateway idle timeout; hosted Edge Function request idle timeout and CPU/wall-clock limits must be respected. Network I/O is suitable for Edge Functions; heavy image processing in-function is not.

## 8. Database, security and permissions

Database tables are to be fully defined, indexed and migrated in `PICKWELL_DATABASE.md`. Minimal logical entities:

- `products`: normalized barcode **UNIQUE**, optional name and brand, `status`, published timestamps.
- `product_analyses`: versioned structured extraction, nutrition, ingredient records/JSON, summary, provenance and model/rules version.
- `findings`: severity (`positive`, `caution`, `concern`), explanatory text, evidence and reference rule ID.
- `analysis_jobs`: user ID, idempotency key, barcode, state, lease/lock, attempts and safe error details.
- `ai_usage`: user ID, request counts, token/cost estimates, timestamps and outcome; quota and aggregate analytics support.
- Supabase `auth.users` is managed by Auth; no redundant user password table.

**Recommended exposure:** Client has **no direct table access** to these internal records; all read/write access goes through authenticated/guest-safe functions. For exposed Postgres tables explicitly enable RLS, **revoke** broad grants and create policies only for permitted operations; absent direct access, avoid creating permissive select policies. Owner-specific job access enforced in function and DB. Service role/secret access is only within trusted Edge Functions, never mobile. Note that service role bypasses RLS—its presence is not itself safe if handler authorization is wrong.

- Migrations define canonical barcode constraint and transactional unique job admission/lease to prevent two simultaneous AI calls for the same unknown barcode.
- Do not let client declare `published`, `verified`, `severity`, `model_version` or `quota_consumed` as trusted values.
- No in-app edits to existing ready products; admin-only invalidation and correction path for data quality.
- Server checks user quota, IP rate cap, global budget, concurrency and request body size; publishable key cannot identify a user.
- **Do not rely on default RLS:** test that guest and signed-in clients cannot directly insert/update product data, read usage logs, or access private storage.
- Protect logs and database metadata from exposing contributor emails and raw AI content unnecessarily. Add safeguards against prompt injection in label text; treat labels as data, never instructions.

## 9. Data privacy, storage and retention

- Inform user **before contribution** that their photos are sent to Supabase and Meta for processing, and structured data/findings are shared in Pickwell's catalog.
- Production privacy policy must identify data processors, account data, retention and contact route. Need to review actual Meta provider policies before launch (including what Meta retains).
- Images: **do not store as permanent product assets**. If private Storage is used, enforce private buckets, short-lived signed access, expiry and deletion on success, failure and abandoned-job cleanup. **Discard after successful extraction** even if subsequent inference fails; capture draft may remain on user's device for retake. Do not store base64 images in database/logs/analytics.
- Account/usage data: least necessary user ID, quotas, security events with defined retention and deletion process, to be set concretely in DATABASE and privacy copy before launch.
- App should not claim local-only or offline operation; network required for lookup, OTP and new analysis.

## 10. Analytics, budgets, and operational visibility

Use minimal Supabase-backed aggregate/operational instrumentation (no separate marketing analytics SDK):

`barcode_scanned`, `product_cache_hit`, `product_not_found`, `capture_completed`, `analysis_started`, `analysis_completed`, `analysis_failed`, `analysis_retake_required`, `quota_exceeded`, and restricted `ai_usage`.

Suggested fields: timestamp, event, anonymized session correlation if justified, model and prompt version, elapsed_ms, token usage if provided, cached boolean, error category; avoid raw barcode in broad telemetry if not required, images, full email and authorization tokens.

Track: cached-lookup rate, AI-analysis completion rate, retake rate, estimated inference cost per published product, duplicate prevented, quota denials, typical lookup/processing latency. Per-user quota and rate-limit enforcement **cannot depend on noncritical analytics logging success**.

No live monetization or purchase flow in MVP. RevenueCat webhook audit is a future-ready restricted operational event stream, not marketing analytics. Test spending caps before inviting public users. Use configured limits—not hardcoded claims of free/unlimited AI.

## 11. States, failures and accessibility

| Condition | UI behavior | Server response/handling |
|---|---|---|
| Known barcode | Show cached result | `ready`, no Meta call |
| Unknown barcode | Invite capture | `not_found`, not an error |
| Duplicate analysis in progress | Show processing and retry/poll | `processing`, do not start second job |
| Network/server unavailable | Retry lookup | `service_unavailable`, never `not_found` |
| Barcode unreadable/invalid | Re-scan or manually enter | `invalid_barcode` |
| Camera permission denied | Explain and offer settings / picker | No server work |
| Nutrition or ingredients unclear | Retake specific label | `needs_retake` with label type |
| Guest tries analysis | OTP gate; preserve draft | `unauthorized` if bypassing UI |
| Email OTP invalid/expired | Retry/resend/change email | Supabase Auth-specific error |
| User quota exhausted | Explain, cached lookup still works | `quota_exceeded`, no new AI |
| Rate limit exceeded | Retry later | `rate_limited`, optionally Retry-After |
| Meta timeout/invalid response | Safe retry / recover | `analysis_failed`, no publication |

Accessible controls: 48+ dp touch targets, dynamic text, screen-reader labels, no color-only meaning for findings, status announcement, real nutrition units in readable text, avoid misleading red/green symbolism without evidence. Check approved DESIGN for hierarchy and spacing.

## 12. Platform API/permissions and external services

| Concern | iOS | Android | Test |
|---|---|---|---|
| Barcode camera | Usage description in Info.plist; verify supported native plugin permission behavior | CAMERA runtime + manifest permission | First launch, deny, allow later, interruptions |
| Label photo camera | Same permission with clear purpose | CAMERA when native camera capture requires it | Readable images and retake |
| Gallery image import | System photo picker if available; review Info.plist entries and plugin behavior | System Photo Picker where supported; no blanket gallery permission | Gallery cancellation and access |
| Internet | HTTPS with ATS-compliant hosts | INTERNET permission and TLS | Loss of connectivity mid-lookup / submit |
| OTP email | External mail delivery and in-app code input | Same | Expired code, autofill, sign-in resume |
| Background processing | Not required | Not required | Return from app suspension; no false durable job promises |
| Push notifications | Not required | Not required | No permissions or packages added |

Verify actual deployment target, target SDK and package versions within the existing repo; build reproducibility must be tested on device. Do not present new design mockups as genuine store screenshots.

## 13. Tests and acceptance gates (targeted by default)

1. **Feasibility:** deployed Edge Function → Meta actual two images → valid JSON; record latency/error/token cost; email OTP numeric code arrives, verifies and resumes draft.
2. **Lookup:** seeded barcode returns ready data with **zero AI call**; nonexistent barcode returns not_found; timeout returns error; bad barcode rejected.
3. **Auth:** guest lookup succeeds; guest analysis rejected server-side; verified user analysis accepted; expired token rejected; anonymous auth (if enabled elsewhere) not equivalent to verified email.
4. **Security:** SQL RLS/grants negative tests for anon/authenticated direct table writes; arbitrary job ID cannot access other user data; secrets absent from Flutter/repo/logs; external URL/image abuse blocked.
5. **AI validity:** two real products, per-serving vs 100g basis, allergen visibility, invalid JSON, unreadable ingredient label, cross-label mismatch and proper retake state.
6. **Dedup/concurrency:** parallel same barcode submissions create one published product, avoid duplicate Meta calls as much as job lease allows, and second scan returns cached result.
7. **Quotas:** per-user and rate limit imposed before calling Meta; concurrent quota bypass prevented; failure telemetry and usage accounting verified.
8. **Storage:** photo deleted after successful extraction; cleanup for failed/orphaned uploads; no permanent image record.
9. **UX:** cache hit bypasses OTP; unknown barcode guides two photos, retains draft through OTP and returns results; screen-reader labels and color-independent findings.
10. **Release/demo:** stable end-to-end new scan and cached second scan, actual backend logs/cost limits verified, capture real UI and submit working 3-minute demonstration.

Do focused tests per task and reserve broader release QA for submission readiness. Don't invent a project directory layout or overwrite working boilerplate to match this document.

## 14. Risks / unknowns requiring explicit resolution

- **Blocking:** actual Meta multimodal API entitlement, request schema, model selection, two-image support and deploy-time key configuration. Prototype before implementing polished views.
- **Blocking:** actual OTP numeric email template / SMTP deliverability for test accounts.
- **Blocking:** safe public lookup endpoint and server-enforced verified-user analysis with rate limits, quotas and SQL RLS grants.
- **Must define in DATABASE:** concrete schema, owner ACL, status transitions, job idempotency/lease, database migration, analytics quota strategy, retention and cleanup policy.
- **Must define before color-coded nutrition claims:** documented, reference-based deterministic threshold tables and source/version. When unknown, use nonjudgmental data display and no unsupported red/green label.
- **Provisional until verified:** image size defaults, 5 analyses/day, actual OS targets, exact Flutter packages, hosting latency, storage necessity, original Pickwell brand tokens and budget amounts.

## 15. Handoff and references

**Next document:** `PICKWELL_DATABASE.md`, then `PICKWELL_TASKS.md` and existing/reconciled `AGENTS.md`. App design stays governed by `PICKWELL_DESIGN.md`. PRD governs feature scope; the technical details here must not add features.

Verified Supabase documentation (accessed 2026-11-02):
- Edge Function authorization modes: https://supabase.com/docs/guides/functions/auth
- Authorization headers and `verify_jwt`: https://supabase.com/docs/guides/functions/auth-headers
- Email OTP and `{{ .Token }}` template: https://supabase.com/docs/guides/auth/auth-email-passwordless
- Edge Function limits: https://supabase.com/docs/guides/functions/limits
- RLS grants and tests: https://supabase.com/docs/guides/database/postgres/row-level-security

**Critical distinction:** This is an implementation specification, not a claim that Meta API access, a deployed backend, credential setup or actual app tests have already succeeded.


## 16. Quota architecture and RevenueCat preparation — v1.1 (approved)

### 16.1 Locked free allowances and dynamics

- Backend default `free`: **30 barcode lookups per UTC calendar day** (accurately attributable to signed-in users; for guests, best-effort fair-use/IP/network throttling only) and **3 successful new-product analyses per verified signed-in user per UTC day**.
- Store effective allowances in `plan_limits`, not Flutter code or client-writable tables. Changes (including lowering 30 to 20) apply on the next backend evaluation without redeployment or app release. Return `limit`, `used`, `reserved`, `remaining`, `resets_at` from the server.
- `get-product` applies public abuse controls; for authenticated requests also enforces the daily user lookup allowance. For anonymous guests a strong per-person quota is infeasible; **do not rely on spoofable device IDs**. A configurable coarse public request cap and per-IP/token-bucket rate limiting are required to control scraping. Guest fair-use semantics must be clearly communicated.
- Valid completed `ready`/`not_found`/`processing` lookups count once; invalid barcodes, network/server errors, opening a locally held result, and poll status requests do not count. Replay-safe idempotency suppresses duplicate counts where supported.
- `analyze-product` requires verified Supabase Auth identity, checks that cache is not already ready, atomically reserves one AI credit, and finalizes one credit only on successful validated publication. Bounded retakes/technical failures release the credit; separate **provider spend** accounting tracks all calls even when a credit is refunded. Implement lease expiry cleanup and idempotency to prevent stuck or double reservations.
- Limit adjustments apply on the next check; if `used` exceeds newly lowered cap, block additional quota-consuming work until reset. Define a global Meta AI spend ceiling and concurrency cap in server config.

### 16.2 Entitlement resolution

- Define plans `free`, `premium` with `plan_limits(metric, daily_limit, effective_at, ...)`. Premium limits **TBD**, must be finite/configurable unless a separate explicit decision approves unlimited.
- Resolve server-side `user_entitlements` (active, non-expired, trusted source), falling back to Free; an expiring Premium entitlement must not be prolonged by an old or duplicated webhook. Administrative test grants permitted only via server credentials and clearly labeled.
- Future RevenueCat **App User ID** = stable Supabase Auth user UUID (string) after verified login; link in `revenuecat_customers`, handle aliases/transfers cautiously. No RevenueCat account initialized anonymously for purchase flows in this hackathon.
- When eventually enabled, purchases/restores occur through RevenueCat SDK in Flutter, but **the server independently resolves** entitlements and quotas from verified webhooks and reconciliation. SDK `CustomerInfo`, client `plan` labels and local cached Premium status never authorize model spend.
- Backend feature flag `billing_enabled=false` in hackathon. No paywall/offers, product IDs, price points, revenue projections or purchase behavior is in the hackathon's acceptance criteria.

### 16.3 RevenueCat webhook contract (future activation, backend-ready now)

- Reserved `revenuecat-webhook` Supabase Edge Function, **not available as a public user operation**. Since RevenueCat sends a server-to-server POST, it must not rely on a user JWT; configure the correct no-user-JWT route and enforce independent webhook authenticity before parsing/processing.
- RevenueCat recommends a configured Authorization header, and supports HMAC signed webhook payloads. Prefer signature verification over **raw request bytes** with timestamp tolerance, constant-time signature comparison, and/or dedicated secret header as documented. Never use a public Supabase publishable key as proof of webhook origin. <https://www.revenuecat.com/docs/integrations/webhooks>
- Persist webhook `event.id` under a unique key, environment, customer identifier/aliases, event type, event timestamp, verification status and sanitized metadata. Dedupe replay; acknowledge accepted events quickly, process event state safely, and retry failures.
- Events can arrive late/out of order; do **not** blindly set Premium on any `INITIAL_PURCHASE`/`RENEWAL` notification or revoke on any `CANCELLATION`. Reconcile effective entitlement status and expiry using RevenueCat's authoritative current customer information or a carefully tested lifecycle reducer (including grace periods, transfers, refund and expiry). Event mapping and canonical user identity must be verified before launch.
- Never grant Premium to unmapped or ambiguous anonymous RevenueCat IDs; queue for reconciliation. Sandbox and production data must not leak into each other's entitlements.
- Record test webhook deliveries safely; reject unsigned/invalid requests, event replays, unmatched customer IDs and client entitlement writes.

### 16.4 Atomic quota lifecycle / SQL responsibilities

- Database transaction or SECURITY DEFINER RPC reserves a slot atomically under a row lock for `(user_id, utc_day, metric)`; check `used + reserved < effective_limit`, then insert a unique reservation for `(user_id, idempotency_key, metric)`.
- `finalize`: mark reserved credit consumed once after successful publication; `release`: decrement reserved once after retryable failure or retake. Expired reservations require recovery with job-state reconciliation; do **not** blindly refund ongoing model work.
- Store provider usage/cost in restricted `ai_usage` independently of final user credit so spent-but-failed attempts remain visible.
- Future Premium quota resolution uses the same reservation path; plan downgrades must never grant extra credits on repeated webhook delivery.

### 16.5 Implementation tests

1. Default Free returns 30 lookups and 3 analyses per day for verified user; guest scan remains usable within fair-use throttle.
2. Change `free.barcode_lookup` to 20 in DB; next request reflects 20 without Flutter update; `remaining=0` when previously used >=20.
3. Cache hit consumes zero AI credits; repeated replay of same lookup/analysis idempotency key consumes no duplicate credits.
4. Concurrent analysis requests at one remaining credit admit at most one new job.
5. Bad images/Meta timeout release user credit but record actual AI provider usage/cost; retries are bounded.
6. Unauthorized user cannot write quotas/entitlements or forge a Premium claim; default plan Free.
7. RevenueCat webhook with invalid signature is rejected; duplicate event ignored; out-of-order expiry does not grant or incorrectly remove access; client `CustomerInfo` does not authorize backend model calls.
8. With `billing_enabled=false`, no paywall/purchase action appears, no user is charged, and test Premium grants work only through privileged admin operations.

**Exact schema, SQL constraints, policies, jobs and cleanup are specified by `PICKWELL_DATABASE.md`.**

## 17. Final approved Flutter UI implementation contract — v1.2

### 17.1 Root/navigation state

- Root is **Home/RecentProducts**, not scanner. Root nav uses native-looking translucent/blurred pill (Home + Settings) with separate rightmost round scan icon; hide root bar on nested scanner/capture/OTP/process/details flows. Chat is a visual-only future concept and not tappable in MVP. On Android, implement legible translucent fallback rather than promising Apple-only glass rendering.
- Home header consists of approved lemon emblem + Pickwell wordmark and **magnifier at right only**. Search expands on tap, not always visible. Avoid a second user/profile icon or a recently-scanned heading.
- Home filter chips All / Food and right-aligned Newest sort; no list/grid toggle and no active Cosmetics chip while cosmetics analysis is deferred.
- Cards are individually rounded white surfaces, truthful image thumbnail or placeholder, title/one subtitle, trailing chevron. Never use a green check to certify health unless a documented claim specifically supports it.

### 17.2 Local recents implementation

- Maintain a **bounded local index** of `{normalized_barcode, last_opened_at_utc}` for most recently viewed/scanned ready products. Suggested max length 30, deduplicated and sorted by last-opened. Use preexisting project-safe local persistence (SharedPreferences or equivalent if already installed); don't add Drift/server table merely for this.
- Do not persist product label photos, AI raw payloads, personal account identifiers, or full cached nutrition details. Refresh product summaries from backend where accessible. If offline/unavailable, render graceful missing-state; do not advertise offline access to full results.
- Reopening a *locally cached currently displayed card* does not consume another camera-scan quota. If the system must fetch from backend, follow server's actual lookup/quota rules; do not invent free or quota-exempt backend endpoints.
- Home search filters loaded local records by name/brand/barcode; category Food filters known food type; Newest sort uses timestamp. This is not a global product discovery search.

### 17.3 Nested details and actions

- Nested Product Details uses back + overflow (no logo/title or bottom tabs), product identification, a non-numeric evidence-aware summary, ingredients/allergens, nutrition with units/basis, caveats and analysis date.
- Do not render the earlier prototype's 92/100 score, dial, generic 'Good Choice' certificate or Add to List unless later approved and methodologically implemented. Share can be optional P1 via native share sheet of valid public record link or carefully composed non-sensitive text, avoiding fabricated URL.
- Use semantic green, amber and red independently from brand lemon decorations; icons and text labels required.

### 17.4 Platform and design tests

- Test portrait safe insets/dynamic text, keyboard and expanded search, genuine camera rendering and photo capture, compact device height, real scroll/nav bottom insets, and Android fallback blur/translucency. Do not use static generated screenshots as functioning UIs.
- Unit/widget tests: home record index dedupe/newest persistence; filter/search empty; root bar visibility vs nested routes; scan action; product card factual placeholder; details omission of score/Add to List; Chat hidden; auth capture-draft survival.


## Evidence-aware interpretation implementation addendum (2026-11-03)

The extraction and explanation passes above are logical stages within the existing
single bounded Meta request. `interpretation.mjs` supplies reviewed reference
statements and a structured selection/composition schema. Meta selects ingredient
indices, matching reference IDs, nutrition topics and summary priorities. Backend
validation checks every index/reference pairing and each selected statement against
the reviewed text, then combines it with accepted label quantities. Unsupported
prose/links are omitted with uncertainty; no new medical claim is accepted. This
constrained composition supplies ingredient functions and meaningful nutrition
context rather than label restatements, without an unaccounted second paid call.

Original UK per-100g rules remain. `fda-dv-5-20-v1` additionally supports explicit
US FDA reference classifications for source-backed per-serving sodium, saturated
fat, added sugars and fibre (<=5% low; >=20% high; high fibre favorable). Daily
Values 2300mg sodium, 20g saturated fat, 50g added sugars and 28g fibre apply to the
stated US adults/children-4+ reference population, not personal dietary targets or
Philippine legal claims. Unknown portions/bases, percent-only facts, IU and
uncorroborated quantities do not receive those classifications. Total and added
sugars remain separate; no added-sugar amount is inferred from ingredients.

Interpretation/reference/context-rule versions are explicit provenance. Ordinary
get-product is unchanged and never calls Meta. Operator-only reference refresh uses
existing facts, an immutable revision and compare-and-swap; it does not rescan,
rerate old findings, spend a user credit or call Meta. See
[PICKWELL_INTERPRETATION.md](PICKWELL_INTERPRETATION.md) for coverage, evidence,
operator commands and limitations. Future source changes require review/versioning.


## 18. Product trust and post-submission extension (approved 2026-11-04; planned)

### 18.1 Existing behavior and audit boundary

Reuse the existing `analyze-product` handler, `analysis_validation.mjs`, `analysis_publication.mjs`, versioned interpretation and server-only admission/publication RPCs. The current validator has cross-photo `consistent` / `unknown` / `mismatch` output and mismatch handling; publication revalidates a staged candidate. These mechanisms and existing leases, immutable revisions and RLS are starting evidence for T07.1B, not proof of barcode-to-package identity. A model judgment about two photos cannot independently bind them to a scanned code. The new audit has not been performed by this documentation update.

### 18.2 Pre-submission sequence — T07.1B → T07.1C → T07.1D → T07.2

- **B audit:** Trace scanner input, barcode normalization, image request pairing, model prompt/output, validation, candidate staging, atomic publication, refresh/invalidation and public cache projection. Test barcode A/photos B; conflicting image identity; names/brands/variants/sizes; schema-valid but unverified content; overwrites; parallel submissions/retries; duplicate/reused barcodes/reformulations; missing evidence and repeat poisoning. Record actual paths, reproducible results, severity, affected records and unknowns without logging images or secrets. Deliver an evidence-based report and minimal mitigation plan, not a broad rebuild.
- **C critical protection:** Implement only audited critical controls that can be completed and verified safely before submission. Reuse existing authorization, locks/idempotency and revision ownership; keep contributors unable to overwrite trusted records. Admission and publication must recheck applicable identity/conflict policy transactionally. Do not guess identity from model confidence or barcode syntax, or make every partial nutrition value a retake again. If critical safety cannot be verified, fail the release gate or restrict the affected path. An evidence-backed no-change disposition is valid if no critical fixes are needed.
- **D release gate:** Verify affected cached/new/reuse/retake paths, auth/RLS, concurrency, quota settlement, cleanup and public projection. Compare with recorded T07.1 results; distinguish automated, live and owner/device evidence. Retain the owner-approved testing configuration explicitly; restore 30/3 before production public release or keep the deployment explicitly restricted as a testing environment. Billing remains disabled. No known unresolved P0 issue may be hidden by the deadline.

### 18.3 Separate evidence dimensions

Future contracts must distinguish: (a) schema/range/source-basis validation; (b) model extraction uncertainty; (c) cross-photo consistency; (d) barcode/package identity evidence and verification method; (e) publication/revision state. `ready` is a publication lifecycle state, not a certificate. Unknown identity remains unknown; “consistent” is not independent verification. No synthetic confidence score or unverifiable verified flag. Source text, model observations and independently checked evidence must be distinguishable; client flags remain untrusted. Proposed fields/states require reviewed contracts/migrations in the later task, not ad hoc schema edits here.

### 18.4 Post-submission implementation contracts

| Task and dependency | Planned contract | Validation gate |
| --- | --- | --- |
| T08.1 after T07.2 and trust gates | Extend current products/immutable analyses into a Product Passport with identity, nutrient/ingredient facts, provenance, validation state, model/rule/prompt/reference versions and revision history | Sanitized current and historical revision projections; unknown identity/values explicit; no contributor PII or image persistence; no AI on ordinary lookup. |
| T08.2 after T08.1 | Compare two accepted revisions using deterministic unit conversion and a compatible per-serving/per-100g basis | Preserve originals; no conversion across mass/volume without justified density; missing serving mass or incompatible basis is non-comparable. Separate total/added sugar; no invented nutrient amounts or overall rank. |
| T08.3 after T08.1 and audit findings | Conditional front-package evidence and identity cross-checks, dispute resolution and safe formulation changes | Server-validated evidence policy; no silent trusted-record replacement; explicit revision/conflict handling for barcode reuse, aliases and reformulation. Do not assume a barcode is a timeless formulation ID. |
| T08.4 after T08.1 and T08.3 | Muse Spark emits allowlisted structured requests for specific evidence/clarification | Deterministic server checks action type, target field/photo, reason, user/job ownership, state, size and budget; cap rounds/time/provider spend, allow cancel/expiry. Model cannot execute arbitrary tools/URLs, change quotas or publish by itself. |

T08.2 and T08.3 can proceed independently after T08.1; T08.4 requires the identity/evidence contract from T08.3. Do not implement a general chat interface. Before invoking a future model version, verify actual access/capabilities rather than assume the model name grants tool support.

### 18.5 Safety, privacy and migration discipline

CKD-related educational explanations must use reviewed, versioned sources with reference population/basis and limitations; do not translate generic traffic-light rules into personalized renal recommendations or safety certificates. No patient data, diagnosis or prescription flow is introduced. Undeclared nutrients are unknown, not absent.

Maintain guest lookup and verified Email OTP for new analysis, deterministic classifications, server-only Meta and no inference on cache hits. Additional evidence is conditional future work, not a new mandatory capture step now. Delete original images after processing; private pending drafts keep the existing five-item/24-hour recovery bound. Preserve only justified non-image provenance, not permanent evidence photos, raw model logs or contributor emails. New data contracts must be versioned with least-privilege migrations and targeted tests when their implementation task begins. No migration, deployment or new runtime dependency is authorized by this revision. T06.3 stays deferred, `billing_enabled=false`; optional T06.4 is not started.

**v1.3:** Added planned trust/release and Passport/comparison/identity/investigator contracts; preserved existing implementation and historical evidence.

# PICKWELL AI V2 — PRODUCT REQUIREMENTS DOCUMENT

**File:** `PICKWELL_PRD.md`  
**Version:** 1.7 — Consumer product intelligence and trust roadmap\
**Date:** November 4, 2026\
**Project / repository:** `pickwell-ai`  
**Framework:** StartAppLab App Framework — Stage 2, PRD  
**Status:** Core flow and T07.1 QA complete for the recorded hackathon testing profile; UI polish has implementation evidence. T07.1B–D and Phase 8 below are approved roadmap work, not implemented by this revision.\
**Platforms:** iOS and Android via Flutter; prioritize one end-to-end demonstrable build for the hackathon  
**Backend:** Supabase; **AI:** Meta multimodal AI API  
**Target submission:** Meta AI Hackathon, November 4, 2026 (US Eastern); reconfirm cutoff and required submission materials on official portal.

> **Scope authority:** This PRD supersedes Pickwell PRD v1.1 wherever it excluded accounts or left backend choices undecided. It preserves the user's barcode-first seven-step experience, while adding optional sign-in for guests and mandatory verified authentication only when requesting a new AI analysis.

---

> **2026-11-04 — T07.1C current implementation authority:** New analyses require an **evidence-bound operator decision before shared publication**; schema validity, three coherent photos and Muse certainty do not authorize publication. Locally implemented/tested, **not deployed or release-signed-off**. `review_required` keeps a private candidate/reserved slot for at most 30 minutes; rejection, cancellation or expiry releases the slot without a successful-analysis charge. Operator review is distinct from independent barcode verification. Cross-image discrepancies are review conditions, superseding C.1's automatic identity-conflict retakes; unreadable/wrong photos still use relevant-photo retakes. Existing guest cache reads remain available. See [safeguards, tests, rollout and operator procedure](PICKWELL_PRODUCT_TRUST.md). T07.1D remains NOT STARTED; billing remains disabled and existing testing allowances unchanged.

> **2026-11-04 — T07.1C.1 approved flow update:** Unknown barcode → **Front packaging → Nutrition → Ingredients** (three required photos) → contextual Email OTP → one server-side Muse analysis. Barcode is already captured, outside the three photo steps. This supersedes earlier two-photo/Barcode-as-Step-1 wording for new submissions; historical completed-task evidence remains unchanged. Front identity is a model observation, **not independent barcode ownership verification**. T07.1C's approval gate and T07.1D remain pending. [Implementation, verification and rollout](PICKWELL_FRONT_PACKAGING.md).

## 1. Product vision and positioning

Pickwell is an **evidence-aware consumer product intelligence and transparency platform**, beginning with packaged-food ingredient and nutrition information. Its mission includes helping Filipinos understand labels relevant to everyday nutrition awareness and CKD-related concerns, without medical advice, diagnosis, food safety certification, or personalized dietary prescriptions.

**Core promise:** **Scan a barcode. If we know the product, see its existing analysis immediately. If not, capture its nutrition and ingredient labels once so Pickwell can analyze it and make the information available to future shoppers.**

Primary audience: everyday shoppers in the Philippines and other markets with packaged foods, retail barcodes, and printed labels. Users need understandable, evidence-aware information—not clinical diagnoses or absolute declarations that food is safe, healthy, or unhealthy.

**Differentiation:** Community-benefiting barcode cache + image-to-structured-data AI + understandable findings with explicit evidence and uncertainty. Meta AI is involved only when analysis is required; cached lookups never trigger AI.

**Activation event:** A successful barcode scan that displays a validated, useful product result (cached or newly analyzed).

**Public-launch considerations:** Brand, market research, ASO rankings, and monetization economics require separate StartAppLab Stage 1 work; they are not falsely marked validated by this time-boxed hackathon PRD.

## 2. Approved decisions — locked

1. Repository is `pickwell-ai`, the long-term V2 revival; this hackathon iteration is its first narrow delivery milestone.
2. Mobile: Flutter using the existing StartAppLab boilerplate, Cubit/Bloc conventions where applicable.
3. Backend: Supabase PostgreSQL + Edge Functions; private Supabase Storage only if temporary processing requires it.
4. AI: Meta AI performs server-side image extraction and plain-language interpretation.
5. Barcode-first flow: check the shared database before prompting for any label images.
6. Existing validated product: display saved nutrition, ingredients and analysis **without an AI call**.
7. Unknown barcode: after Barcode ✓, guide through **three photo steps — Front packaging → Nutrition facts → Ingredients**.
8. Optional product name and brand: infer if reliable, allow correction, never block on missing names.
9. Analysis classifications use **Meta AI explanations + deterministic, documented validation/rules**.
10. Publish shared product result **after automated validation**; rejected or low-confidence results require retake and must not become public `ready` records.
11. Submitted label images are **discarded after successful extraction**; do not keep permanently as a default.
12. Enforce **per-user AI quotas plus backend rate limits**. Default Free allowances: **30 barcode lookups/day** and **3 successful new-product AI analyses/day** (for verified users); both are adjustable server-side. Guest lookups use best-effort rate limiting, not a falsely guaranteed per-person 30/day counter.
13. If extracted labels are unreadable, incomplete or contradictory, **ask the user to retake the affected photo**.
14. **Guest browsing and barcode scanning** are permitted. **Verified Supabase sign-in is required to submit a new product for Meta AI analysis**.
15. Authentication method for the hackathon: **Email OTP only**. Google/Apple sign-in, billing, chat, and other deferred features stay out of scope.
16. **RevenueCat**: chosen future billing provider; premium-ready server-side entitlements/webhook integration, with paywall/purchases disabled in hackathon build.
17. Security: Flutter contains only public Supabase configuration; privileged database keys and Meta secrets are server-side; RLS and endpoint authorization must be configured, not assumed.

## 3. MVP scope and feature priorities

| ID | Feature | Priority | Result |
|---|---|---|---|
| F01 | Barcode scan and validated database lookup | P0 | Found / not found / processing / error |
| F02 | Instant cached results for ready barcodes | P0 | No Meta call |
| F03 | Seamless 3-step guided capture | P0 | Barcode, nutrition photo, ingredient photo |
| F04 | Email OTP authentication at contribution gate | P0 | Guests scan; verified accounts submit |
| F05 | Meta AI image extraction and nutrition/ingredient explanation | P0 | Typed, evidence-aware structured output |
| F06 | Validation and retake for missing/unreadable label information | P0 | Never publish bad records |
| F07 | Shared database save and barcode-based deduplication | P0 | Reusable product records |
| F08 | Green/yellow/red findings and contextual summary | P0 | Explanations, sources, uncertainties |
| F09 | Backend secrets, RLS, rate limits, usage quotas | P0 | Guard expensive and privileged operations |
| F10 | Lemon-branded Home/product-list, scanner, camera/error/permission states | P0 | Complete usable demo |
| F13 | Local recent-products index (lightweight, on this device) | P0 | Home shows previously opened/scanned product references without cloud history |
| F14 | Home search/filter/sort and product cards | P1 | Search locally indexed recent items, food category, newest sort |
| F12 | Free quotas and premium-ready entitlement resolver | P0 | Server-side 30/day barcode + 3/day AI, with future RevenueCat integration |
| F11 | Optional name/brand correction, manual barcode entry | P1 | Improve legibility and demo resilience |

No chat assistant, numeric food score, cosmetic analysis, comparisons, favorites/collections, **cloud/personal account-wide scan history**, full offline product results, **active purchases or paywall**, notifications, or elaborate onboarding in this hackathon iteration. A small **device-local list of recent product references** is included for Home; this does not create a server history table. Server-side monetization readiness is included.

## 4. Primary user flows

### 4.1 Guest scans an existing barcode

1. Open app directly to home/scanner with no registration wall.
2. Grant camera permission when scanner opens; a manual barcode entry fallback may be offered.
3. Read EAN/UPC code; normalize on the server and request `get-product`.
4. While checking, show finite loading feedback.
5. If status is `ready`, render stored product ingredients, nutrition, findings, analysis date and evidence/caveats **immediately, without invoking Meta AI**.
6. If `processing`, provide a clear status and retry/poll option rather than prompting redundant image submission.
7. If network failure, show network error; **never treat timeout as a missing barcode**.

**Acceptance:** Guest can scan a seeded ready barcode, view results, and backend logs show zero AI calls.

### 4.2 Guest scans an unknown barcode and contributes a product

1. Server confirms `not_found`; UI says **“Product not found — let’s add it.”**
2. Barcode is already captured. Wizard photo steps are **1/3 Front packaging → 2/3 Nutrition → 3/3 Ingredients**, with preview and independent retake.
3. Front captures visible name, brand, variant and net quantity; missing/unreadable fields remain unknown. Nutrition/ingredients extraction remains unchanged.
4. Preserve the barcode and all three photos in the existing bounded private pending draft across navigation, restart and OTP; no rescan or permanent product-photo storage.
5. On **Analyze product**, check session:
   - Verified signed-in user: continue to server-side quota and submission checks.
   - Guest: show an in-context **Email OTP sign-in** gate, retaining all three captures and the barcode. After successful verification, resume submission without starting over.
6. Backend rechecks barcode (another user may have already contributed it). If it now exists, return the cached ready result without AI.
7. Otherwise submit images for Meta AI extraction, validation, interpretation, controlled persistence and display.
8. If extraction is incomplete/unreadable, identify **which label must be retaken**; never publish the invalid record.
9. Once accepted as `ready`, future guests can scan the barcode and see the stored result without AI.

**Acceptance:** Guest can fully capture labels before sign-in, authenticate with Email OTP, and finish analysis without losing their work.

### 4.3 Existing signed-in user analyzes a missing barcode

Same three-step capture, but skip sign-in gate. User quota and abuse checks still apply. A signed-in user does **not** receive direct write privileges to shared catalog tables.

### 4.4 Duplicate/race, failure and retry

- Two users scanning the same uncached barcode must not create conflicting published records or spend unnecessary duplicate AI budget. Unique barcode and atomic claim/job state are mandatory.
- `not_found`, `processing`, `needs_retake`, `rate_limited`, `quota_exceeded`, `unauthorized`, and `network_error` require distinguishable UI behavior.
- A failed AI request may retry within a controlled cap; never silently spend repeated tokens on repeated button presses.
- An `analysis_failed` response returns safe detail and the recoverable user action; do not present an invented result.
- Malformed/mismatched images, labels for a different product, or inconsistent units cause retake/review, not automatic public publication.
- If product is reformulated, protect existing published data from unreviewed overwrite; a limited admin invalidation/correction path is required for testing and future upkeep.

## 5. Functional requirements and acceptance criteria

### F01 — Barcode scan / lookup

- Camera scanning supports common retail EAN/UPC formats; barcode text is canonicalized and validated by backend.
- Do not assume every barcode is globally unique across packaging revisions: retain provenance, analysis date, and mismatch flags.
- Lookup is through a controlled `get-product` Edge Function (or equivalent locked server API); only published `ready` records are returned as final results.
- Finite progress/loading feedback and explicit server response states.

**Pass:** Cached barcode gives correct record; unknown barcode gives capture invitation; offline/timeout shows a distinct error.

### F02 — Fast cached product results

- Show stored nutrition, declared ingredients, summary, explainable green/yellow/red findings, uncertainties, and freshness/source information.
- Server does not run Meta inference on cache hits.
- Cached response is readable by guests, subject to backend throttling.

**Pass:** Repeated scan from a different session uses the original saved analysis with no inference.

### F03 — Three-step capture

- Barcode complete remains visible; photo progress: Front packaging → Nutrition → Ingredients. All three photos are required to submit.
- Camera gallery import, preview, retake; clear photo guidance for legibility.
- User may optionally correct/enter name and brand; do not create an extra compulsory wizard step.
- Never lose captured images when authentication is required; warn if leaving the flow would discard them.

**Pass:** Full capture and auth gate can be completed without rescanning barcode or retaking accepted images.

### F04 — Supabase Auth: Email OTP

- No login required for barcode scanning, product lookup, or viewing ready results.
- Email OTP is required **only at the new-product analysis submission gate**.
- Only verified persistent users may request paid AI analysis; do not confuse a Supabase anonymous session with a verified account.
- Handle OTP delivery, expiration, invalid codes, resend throttling, success and cancel.
- Backend checks verified authentication from trusted Supabase JWT/user claims and independently authorizes each submission.
- Sign-out and session expiration handling must not leak secrets.

**Pass:** Guest cached lookup succeeds; guest analysis without verified auth fails server-side; valid verified account succeeds subject to quotas.

### F05 — Meta AI extraction and analysis

- Supabase Edge Function is the sole caller of the Meta model API; never embed Meta keys or privileged Supabase keys in Flutter.
- Input: barcode plus nutrition and ingredients images, with clear field labels.
- Extract faithfully: ingredient raw text, ordered ingredients, declared allergens when visible, serving information, nutrition values/units and per-serving/per-100g basis.
- Prefer null/unknown and retake over guessed quantities. Preserve a distinction between printed label facts, AI interpretation and externally sourced background information.
- Generate concise plain-language descriptions and product-level summary; avoid medical diagnoses, automatic ingredient demonization and fabricated citations.
- Validate actual access to a Meta multimodal endpoint handling two real packaging images before building extensive UI.

**Pass:** At least two different real label pairs produce structurally valid nutrition/ingredient data; ambiguous inputs fail safely.

### F06 — Deterministic validation / rules

- Verify required fields, enum types, numeric ranges, units, serving bases, consistency, duplicate ingredients, evidence links and output schema.
- Define any green/yellow/red nutrition rule with reproducible thresholds and source references; avoid universal `healthy/unhealthy` claim.
- A missing label, unreadable essential field or inconsistent cross-image product identity triggers **retake** of the relevant capture.
- The AI may propose candidate interpretations, but server-side logic decides acceptance and final classification.
- An analysis can be made public only after automated acceptance criteria pass.

**Pass:** Unclear image cannot create `ready` public record; retaken photo can resume the analysis workflow.

### F07 — Shared catalog and publication

- Unique canonical barcode with lifecycle status; store product identity (optional name/brand), structured nutrients, ingredient text/items, findings, evidence/provenance, model and rule versions, analysis timestamp and publication status.
- Use server-only privileged writes. Do not expose public insert/update policy on shared product records.
- Deduplicate concurrent submissions and retain bounded job status/attempt metadata.
- Publish as `ready` only after validation; use admin-only remediation for incorrect records.

**Pass:** Product analyzed once is immediately retrievable across devices without another model request.

### F08 — Results and traffic-light findings

- Green: substantiated favorable observations, not inferred universal safety.
- Yellow: cautions, declared allergens, uncertainty or context-sensitive observations.
- Red: clearly defined concerns that meet a documented threshold; show relevant units/serving basis.
- Each finding includes a short explanation, data/evidence basis and limitations.
- Use text and icons as well as color for accessibility; no arbitrary overall score or binary healthy/unhealthy certification.
- If insufficient evidence, say **“Not enough information to assess”** and prompt retake before publication where required.

**Pass:** Test findings are traceable to original labels or defined references; users can understand them in grayscale.

### F09 — Security, abuse and privacy

- Flutter may include Supabase project URL and publishable key; **never** include Meta API key, database password, Supabase secret/service-role key.
- RLS enabled on exposed tables; deny direct public writes and unauthorized reads of jobs, quota logs, and other users' data.
- Server validates user JWT and verified email at analysis gate, applies per-user quotas and IP/device-level rate limiting (device identifiers, if used, must not be trusted as sole enforcement).
- Set conservative configurable limits for image count, file size, MIME type, request frequency, concurrent jobs, timeout and retry count.
- Protect request idempotency; never accept arbitrary client-supplied SQL, trusted product findings, or 'verified' flags.
- Photos are processed transiently and **discarded after successful extraction**. If temporary private Storage is necessary for a job, keep it private, use time-limited access and delete files on successful extraction and via cleanup for errors/orphans.
- Disclose that photos are sent to backend and Meta AI, and that **structured product information and analysis will be shared** to help other shoppers.
- Do not log image contents or full user tokens; store minimal operational telemetry. Define retention for failed uploads and account data in SPEC/Privacy policy.

**Pass:** Unauthorized submission is rejected, direct table writes are denied, model key is absent from app binary/repo, and cleanup paths are tested.

### F10 — Minimal user experience

- Home opens to a minimal **recently scanned product list** (or empty state), not a camera-first scanner. An independent prominent Scan action opens the barcode camera. Other destinations: lookup, guided capture, contextual OTP, analysis, results, and minimal Settings/account.
- Home uses approved lemon + forest green + green + cream + white 60/30/10 *visual balance* (dominant neutral/cream, supportive greens, restrained lemon accents); no heavy shadows or large marketing panels.
- Home header: lemon mark + Pickwell wordmark left; **only search icon** at upper right, expanding into search when tapped (no permanent search bar).
- Under header: category filter chips (Food and All in MVP), compact newest sort, then **separate rounded photo product cards**. Each card displays actual product identity when known and a genuine available photo or neutral fallback, without invented package imagery. Avoid arbitrary checkmarks that imply a nutritional safety certification.
- iOS 26-style translucent **liquid-glass-inspired** floating navigation pill for **Home and Settings**, with distinct far-right circular Scan action. The proposed Chat tab may appear in **design concepts only**, but must be hidden or disabled without false affordance in hackathon production. No cosmetics tab/filter while cosmetics analysis is deferred.
- Product details is a nested page **without a bottom navigation bar or Pickwell header title**. Back + overflow, product photo/details, ingredient observations and nutrition cards, explanatory color-coded findings; Share is optional. Numeric Pickwell Score and Add to List belong to future roadmap.
- Camera permission requested only when needed; gallery access uses appropriate platform mechanism.
- Clear empty/loading/error/permission-denied/quota-exceeded/OTP-failed states.
- Tiny contextual introduction suffices; no lengthy onboarding.

**Pass:** New user can reach value quickly and complete both cached and uncached journeys.

## 5A. Approved Home, navigation and product-details experience — v1.4

**Scope:** The newest approved UI supersedes all prior scanner-first Home layouts and older green-only mockups. The product list is the opening screen; the primary Scan action remains a single tap away.

- **First launch / empty Home:** lemon wordmark and search icon at top, gentle explanation, clear separate Scan action; no fake seeded products presented as actual user history.
- **Local recents:** once a valid product record has been opened, add `{barcode, opened_at}` to a small device-local bounded index (e.g. max 30 unique recent barcodes). On next launch, resolve those barcodes through the published lookup endpoint when network permits. Never store private image captures or account identifiers in this index. Treat missing/offline records as unavailable, not as trusted complete offline analyses. Device-local recents do not synchronize across users/devices.
- **Search/filter/sort:** Search icon opens search mode; search filters the local recent index by product name/brand/barcode already available. All and Food are active chips. Cosmetics, My Products, Chat, advanced search of the shared global catalog, and collections are **future UX**, not working MVP features. Newest sort should be true to `opened_at`. No list/grid toggle.
- **Cards:** Individual softly rounded white product cards on warm white/cream surfaces, photo on left (real user/product photo only when legitimately available; otherwise neutral placeholder), product name and brief supporting text, trailing chevron and *only* substantiated status. No unsourced green checks as healthy certifications.
- **Navigation:** Home and Settings in a translucent floating navigation pill; separate Scan circle at far right (scan icon **only**, no “Scan” text). No bottom navigation on nested Product Details, Scanner, OTP, or capture views. Chat is a future design reference and must not become a dead production tab.
- **Product Details:** Product thumbnail/identity, evidence-aware findings by severity, ingredients/allergen and nutrition information. No 0–100 food score until a method is validated. The visually mocked score dial and Add to List are deferred; sharing via native share sheet is P1 only if the actual product URL/privacy contract permits it.
- **Color semantics:** The general 60/30/10 brand balance means 60% warm white/cream foundation, 30% forest and supportive green typography/actions/soft shapes, 10% lemon yellow brand accents. Warning yellow must be distinguished from decorative lemon yellow with text and icon.

**Acceptance:** Guest opens into local recent-product Home without a login gate; tapping the search icon expands search; filtering and newest ordering affect local recents; tapping a product opens nested details without bottom navigation; prominent scan action opens live barcode camera; zero unsupported Chat/cosmetic/score/collections controls appear interactive.

## 6. Backend and data contract (refine in SPEC.md / DATABASE.md)

Expected logical endpoints/functions (exact naming and API shape to finalize in SPEC):

- `get-product(barcode)`: public controlled lookup → `ready` with product record, `not_found`, `processing`, or error; **no AI call**.
- `analyze-product(barcode, nutrition_image, ingredients_image, idempotency_key)`: verified user only → check quota, recheck cache, validate payload, reserve job, call Meta AI, validate, store/publish or request photo retake.
- `get-analysis-status(job_id)`: read only by authorized owner (or a safe, scoped polling credential) → `queued`, `processing`, `needs_retake`, `ready`, `failed`.
- Admin-only invalidation/correction facility (not a public client capability).

Logical entities: `products`, `product_analyses` / structured `nutrition` and `ingredients`, `findings`, `analysis_jobs`, and `ai_usage`/`rate_limit` records. Supabase Auth manages users. Relational layout, RLS grants, indices, job leases, quotas and cleanup rules belong in DATABASE.md.

### Processing outline

1. Validate barcode, user (for analysis), quota, uploads and idempotency token.
2. Atomically check for existing `ready` record or already-running job.
3. Extract faithful structured label data from images via Meta.
4. Validate schema and labeling/basis; request photo retake if insufficient.
5. Produce grounded ingredient/nutrition explanations and apply deterministic classification rules.
6. Validate complete result and evidence, then commit a published, reusable product record.
7. Discard transient images on extraction success; clean up failed-job artifacts according to bounded policy.
8. Return/poll the final product record.

**Important:** Edge Functions orchestrate network calls; Meta processes images. Heavy local OCR, long-running in-function processing, and unrestricted anonymous AI calls are outside this MVP.

## 7. UX copy and safety principles

- Cache miss: **“Product not found — let’s add it.”**
- Auth gate: **“Sign in to analyze and add this product. Your scan and photos will be kept while you sign in.”**
- Lookup error: **“Couldn’t check the product. Try again.”** Not “Not found.”
- Image problem: **“We couldn't read the nutrition label clearly. Please retake this photo.”**
- Quota reached: **“You've reached the analysis limit for now. You can still scan products already in Pickwell.”**
- Summary: **“What looks favorable,” “What to watch,” “What needs context.”**
- Medical/allergen limitations: label-level information is educational, not individual dietary advice or a guarantee of allergen absence.

Never imply absence of a listed allergen is proof of safety. Never invent nutrition values, references, high-risk claims, or numeric health scores.

## 8. Out of scope for the hackathon: preserved Pickwell V2 roadmap

- Ask Pickwell product-specific chat and suggested questions.
- Cosmetics and personal care scanning.
- Arbitrary image analysis with no barcode, product-to-product comparisons and alternatives.
- Overall food score (0–100), pending validated methodology.
- Cloud/account-wide scan history, favorites, saved collections, server-side user-product sync, and fully offline analysis history. **Lightweight device-local recent product references for the Home list are in MVP.**
- Google/Apple sign-in (Email OTP is the approved MVP method).
- **Active** subscriptions, paywalls, purchase buttons, RevenueCat checkout and monetization, referrals. RevenueCat-ready database entitlements and webhook design are included now; charging users is deferred.
- Community ratings/reviews, extensive moderation workflows, broad localization, push notifications.
- Full onboarding, advanced dashboards, expanded nutrition personalization.
- Automatic reformulation/version management (basic provenance + admin invalidation still required).

**Authentication itself is in scope.** This is the deliberate change from PRD v1.1. The post-submission features approved in section 13 remain outside hackathon implementation; they do not authorize expanding the submission build.

## 9. Minimum success criteria and observability

- Demonstrate a cached scan without AI, new scan with capture+OTP+Meta analysis, saving and subsequent cached rescan.
- Verify zero Meta calls on ready database hits using server logs or counters.
- Demonstrate verified auth enforcement server-side and rejected guest/expired token analysis calls.
- Demonstrate per-user quota/rate limit responses without consuming unintended AI tokens.
- AI correctly extracts two distinct representative real nutrition/ingredient label sets; unreadable sample requests retake.
- Published records contain sufficient ingredient and nutrition evidence plus explainable colored findings.
- Two devices or sessions retrieve the same saved result.
- No privileged secret in Flutter/repository, no unauthorized public writes, and confirmed image cleanup after success.

**Hackathon monetization:** No live monetization, paywall or checkout. RevenueCat is selected for eventual billing: implement server-side entitlements, configurable plan limits, RevenueCat identity mapping and a protected, feature-flagged webhook integration, but keep purchases and subscription UI disabled. AI analysis remains free under quota. Premium prices and allowances are undecided.

**Minimal Supabase operational analytics (included):** `barcode_scanned`, `product_cache_hit`, `product_not_found`, `capture_completed`, `analysis_started`, `analysis_completed`, `analysis_failed`, `analysis_retake_required`, `quota_exceeded`. In addition collect restricted server-side `ai_usage` records with model name, token counts if available, estimated cost, request status, and duration. Prefer aggregate counts; minimize identifiers, never log images or credentials, and limit access/retention. These events are not a separate third-party analytics integration. Usage quotas must work even if noncritical analytics recording fails.

## 9A. Free usage policy and premium readiness — approved

- Launch default: **30 barcode lookups per day** for Free; **3 successful new-product AI analyses per UTC day** for verified Free users. These are initial values, **not permanent pricing promises**.
- Server-owned `plan_limits` (or equivalent versioned config) must allow changing either limit, including decreasing the barcode allowance, **without a Flutter release**. Return the effective allowance and reset timestamp from backend, never trust Flutter counters. For a later reduction, apply on subsequent checks; users already above the new limit stop receiving further quota-consuming lookups until reset. Communicate changes in UI/policy as appropriate.
- Guest barcode scanning stays available. Guest identity is unverifiable; enforce best-effort IP/device/network abuse limits and a configurable fair-use threshold; do **not** advertise an exact enforceable 30-per-person guest quota. Accurate account-level barcode usage applies after sign-in.
- Charge a barcode lookup only when a valid request receives a definitive `ready`, `not_found`, or safe `processing` response; don't count local reopening or network failures. Reject rate-abusive requests before costly work. Do not charge AI quota for cache hits.
- Two label images for one product count as **one** new-product analysis; reserve before starting model work, finalize one credit on successful analysis, release reservations for technical failure / validation retake within bounded retries. **Actual provider charges on failed requests remain an internal cost**, tracked separately. Enforce atomic reservations/idempotency and a global model spending cap.
- Use `free` and future `premium` plans, `user_entitlements`, usage counters/reservations, and a RevenueCat customer identity map plus append-only webhook events. RevenueCat webhook events must be authenticated, deduplicated, processed safely out of order and reconciled before granting privileges; client-reported Premium is never trusted.
- Future RevenueCat App User ID should be the stable Supabase Auth user UUID after sign-in (or a stable documented mapping). Purchases should require a signed-in account once billing is enabled; avoid uncontrolled anonymous RevenueCat accounts.
- During hackathon: **everyone is Free**, no active purchase flow or paywall. Test-only Premium assignment must require privileged server/admin control. Premium allowances, pricing, product IDs and actual RevenueCat entitlement identifier remain to be selected and verified before billing launch.
- UI: expose remaining quota and reset time where reliable; quota-exhausted actions explain options without advertising unavailable purchases.

## 10. Risk register and technical gates

| Risk | Impact | Mitigation / prerequisite |
|---|---|---|
| Meta multimodal model access unavailable | Blocks key value proposition | **First spike:** Edge Function calls real Meta model with two package photos |
| Email OTP delivery/configuration issues | Blocks new-product submissions | Verify delivery, session, email verification and post-auth resume early; configure SMTP if required |
| Anonymous endpoint abuse and scraping | Cost and data exposure | Rate-limit lookups; restrict writes; JWT + verified-email gate for inference |
| Authenticated account farming | AI spend and spam | Per-user plus IP limits, global spend cap, concurrency cap and monitoring |
| Inconsistent AI nutrition extraction | Incorrect result | Units/basis validation, unknown fields, retake and traceability |
| False 'healthy/unhealthy' verdict | Safety / credibility | Evidence-aware traffic lights, sourced rules, no binary health certification |
| Barcode race / data poisoning | Wrong shared record | Unique barcode, idempotency, write-only backend, automated acceptance, admin invalidation |
| Edge timeout or large images | Failed jobs | Client compression, bounded payloads, explicit timeout; add queued job if necessary |
| Captured-photo privacy | Trust/privacy incident | Temporary private transport, no permanent retention, expiry cleanup |
| Deadline-driven scope creep | Unfinished demo | Strict P0 first; do not implement deferred features |

**Gate 1:** Meta AI two-photo extraction via Supabase Edge Function works.  
**Gate 2:** Supabase Email OTP sign-in returns verifiable server-accepted identity, and guest scanning still works.  
**Gate 3:** Cached round trip and uncached full workflow both succeed with RLS and quota tests.  
**Gate 4:** Demo tested with actual food packages; privacy/secrets checks passed.

## 11. Implementation and hackathon demo priorities

1. Feasibility spike: Meta model access + two-image analysis from Edge Functions; Email OTP delivery and callback.
2. Database migrations + RLS + `get-product` with seeded demo barcode.
3. Flutter scanner and found/miss/error states.
4. Guided 3-step photos, retake and preservation through OTP.
5. Authenticated `analyze-product`, limits, Meta extraction and deterministic validation.
6. Publish reusable product result; accessible traffic-light screen.
7. Targeted security/accuracy tests and short demo recording.

**2–3 minute demonstration:** Guest scans a seeded barcode → instant cached result → scans new barcode → captures nutrition and ingredients → signs in via Email OTP → backend Meta analysis produces explainable result → data published → same barcode scanned from another session → instant cached result, no AI.

Avoid promising exact performance before measuring actual hosted backend and model latency.

## 12. Next documents and source-of-truth rules

Follow StartAppLab Stage 2 order:
1. `PICKWELL_DESIGN.md` — approved essential screens, wizard, OTP interruptions, retake/error states and accessibility.
2. `PICKWELL_SPEC.md` — Flutter implementation architecture, Edge Function lifecycle, Meta API client, auth, quotas, security, privacy, tests.
3. `PICKWELL_DATABASE.md` — actual SQL schema, constraints, RLS, jobs, publication and cleanup.
4. `PICKWELL_TASKS.md` — dependency-ordered tasks with focused acceptance checks; no unrelated features.
5. `AGENTS.md` — inspect existing template and instructions first, preserve working code, avoid full regression except release QA.

Maintain a separate future `ROADMAP.md` when needed; roadmap items are **not** PRD acceptance requirements.

### State of decisions

**Historical v1.4 planning snapshot:** The unverified items below describe the original planning date. Current implementation evidence and completed work are recorded in [TASKS](PICKWELL_TASKS.md) and [T07.1 QA](PICKWELL_END_TO_END_QA.md); the new roadmap does not reopen that completed work.

- **Locked:** six-step-plus barcode flow, Supabase, Meta AI, Email OTP, optional product identity, validated rules, auto-publish after validation, transient images, user quotas, retake, guest lookup and authenticated analysis.
- **Unverified:** Meta model credentials and image capabilities in your account, real SMTP delivery, host timeout/budget suitability, exact deterministic nutritional thresholds and credible reference sources, OS/device camera behavior, current submission portal details.
- **Not implemented by this PRD:** any mobile UI, live Edge Functions, production policies or database migrations.

### Revision history

- **v1.0:** Initial AI-first hackathon feature set.
- **v1.1 (Nov 1, 2026):** Seven-step barcode-first shared-product workflow superseded AI-first scope.
- **v1.2 (Nov 2, 2026):** Added approved Supabase backend, optional Email OTP guest/auth split, eight locked operational decisions and server-side security requirements while retaining the narrow hackathon scope.

- **v1.3 (Nov 2, 2026):** Added server-controlled initial 30 barcode/3 AI daily limits, future RevenueCat entitlement/webhook schema, quota semantics and explicit paywall-disabled hackathon policy.

- **v1.4 (Nov 2, 2026):** Locked lemon 60/30/10 visual identity, recent-products Home, expandable search, rounded photo cards, separate Scan action and minimalist nested Product Details. Local recents explicitly distinct from deferred cloud history; Chat/cosmetics/score/Add to List remain deferred.

## Evidence-aware implementation clarification (2026-11-03)

F05/F08 now use reviewed ingredient-function and nutrition-reference statements
selected/composed by Meta in the existing server-only analysis request. Backend
checks reject unsupported prose/references and own all quantities/classifications.
General ingredient background is distinguished from label facts and from individual
risk; unfamiliar ingredients are not automatically harmful. Coverage and missing
information stay explicit. No new product scope, overall health score or clinical
recommendations. Cached reference refresh is operator-only, immutable/versioned and
never an ordinary barcode-lookup inference. See [interpretation evidence](PICKWELL_INTERPRETATION.md).


## 13. Approved trust and product-transparency roadmap (2026-11-04)

**Status:** Approved requirements only. This revision changes documentation, not code, database schema, deployment or completed QA. [TASKS](PICKWELL_TASKS.md) defines acceptance and dependencies; [SPEC](PICKWELL_SPEC.md) and [DATABASE](PICKWELL_DATABASE.md) define technical/data boundaries.

### 13.1 Pre-submission safety gates

Preserve completed T07.1 and finish the remaining T07.1A UI review using its existing evidence. Before T07.2, perform **T07.1B Product Identity & Data Integrity Audit**, then **T07.1C Minimum Product Trust Protection** for critical, safely verifiable findings, followed by **T07.1D Targeted Regression and Release Gate**. The audit must cover barcode/photo mismatches, conflicting images, names/brands/variants/package sizes, schema-only publication, trusted-record overwrites, races, duplicate/reused barcodes and reformulations, missing identity evidence, poisoning and repeat abuse. It must distinguish demonstrated defects from unknowns and propose the smallest safe mitigations. These protections have not yet been audited or implemented under the new task IDs.

If a critical issue cannot be mitigated and verified before submission, restrict the affected capability or hold the release gate and document the blocker. Timing is not permission to publish known unsafe shared records. If the audit finds no critical changes needed, record an evidence-backed no-change disposition for T07.1C; never invent implementation work.

**Identity is a separate trust question:** A valid barcode/check digit, schema-valid extraction, internally consistent photos, or a model's apparent certainty does not prove the photos belong to the scanned barcode. Track what identity evidence actually exists and what remains unverified. Keep model extraction uncertainty separate from identity verification; do not create percentage confidence scores or a verified badge without a defined, performed verification method. Existing automated validation remains valuable but is not independent identity verification.

### 13.2 Post-submission features — not built or required for T07.2

| Task | Approved capability | Boundary |
| --- | --- | --- |
| T08.1 Product Passport | Reusable product identity, nutrition, ingredients, provenance, validation state and revision history | Extend existing product/analysis revisions; distinguish label facts, interpretation, model uncertainty and identity evidence. No claim of full implementation from current caching alone. |
| T08.2 Product Comparison | Compare two products using structured validated information | Deterministic unit/serving normalization; explicit missing/non-comparable values; no overall health ranking or CKD suitability verdict. |
| T08.3 Enhanced Identity Verification | Conditional front-package evidence, identity cross-checks, disputes and formulation-change handling | No universal new capture step now; no silent replacement of a trusted revision or assumption that a barcode identifies a formulation forever. |
| T08.4 Agentic Label Investigator | Muse Spark requests specific additional evidence or clarification | Bounded structured actions, deterministic authorization/validation and budgets; no autonomous publication, arbitrary tools or medical advice. Not a general chat feature. |

### 13.3 Safety, evidence and continuity

- CKD-related awareness is educational label transparency. Use reviewed reference material with population/basis/limitations; do not repurpose general nutrition thresholds as renal prescriptions, imply suitability for a disease stage, or infer that an undeclared nutrient is absent. Patient profiles, diagnosis, treatment and personalized dietary targets are outside this roadmap.
- Preserve guest barcode lookups, verified Email OTP for new analyses, deterministic findings, server-only Meta requests, ordinary cache hits with no model call, and approved visuals/navigation. A future investigator's additional evidence is conditional and does not replace the current two-label workflow before implementation/validation.
- Delete processing images after extraction; retain only justified minimal non-image provenance (source type, observed identity text, validation method/result, versions and revision links). Preserve bounded private pending drafts for recovery under the existing five-draft/24-hour policy; clear completed drafts. No permanent front/label photos or contributor email in public records.
- T06.3 remains explicitly deferred, `billing_enabled=false`; no paywall, purchases or new Premium promises. T06.4 remains an optional scope decision, independent of this extension. The owner-approved cloud testing allowances remain unchanged; the production 30/3 policy and release configuration decision must be explicit at the gate.
- T07.2 must truthfully distinguish pre-existing template, hackathon-built functionality, remaining limitations and proposed roadmap; provide a runnable public repository and a genuine three-minute demo of actual behavior.

**Revision history addition — v1.5 (Nov 4, 2026):** Approved platform mission, pre-submission trust audit/mitigation/regression gates and post-submission T08.1–T08.4. No implementation or new verification claimed.


## 14. T07.1C.1 — Mandatory front packaging and identity observations

Approved before submission, implemented/tested locally; no deployment or new live-model/hardware proof. Capture front packaging for every unknown code; known guest lookups stay immediate and model-free. Extract nullable product name, brand, variant and printed net quantity per image. Distinguish package quantity from nutrition serving size. Preserve unknown identity and forgiving nutrition OCR. Explicit model conflicts and conservative brand/variant/comparable-size contradictions return an affected-photo retake; matching observations never prove barcode ownership.

Names/brands on new records come from front observations, not trusted client fields. Public results expose the limited observations and unverified status. Photo bytes stay transient; device recovery remains five drafts/24 hours, cleared on success/discard/expiry. Three photos are one analysis, one provider request and at most one successful-analysis credit. T07.1C must still control shared publication and address the remaining audit findings; a readable front alone does not fix poisoning. T06.3 deferred, billing disabled. See implementation report for deployment ordering and limits.

**v1.6:** Mandatory front-photo requirement supersedes earlier two-photo flow; no identity certification or full publication gate claimed.

## T07.1C pre-submission safety restriction

The shared catalog must not auto-publish new barcode/label associations merely
because extraction is plausible. The minimum implemented protection is a bounded,
private candidate review followed by an authorized, exact-evidence decision before
publication. Operator review is a restricted operational workflow, not independent
identity certification or a full moderation product. If the operator cannot obtain
and review the submitted evidence and barcode association, the candidate must not
be approved. Existing cache reads remain guest-accessible with no additional AI.
Readable partial labels remain usable; discrepancies and uncertain identity are
review conditions. This restriction requires hosted rollout and T07.1D verification
before a release claim. No T08 scope or monetization is enabled.

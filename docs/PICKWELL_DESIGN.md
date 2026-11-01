# PICKWELL AI V2 — DESIGN SPECIFICATION

**File:** `PICKWELL_DESIGN.md`  
**Version:** 1.1 — Usage quotas and premium-ready UI  
**Date:** November 2, 2026  
**Project:** `pickwell-ai`  
**Framework:** StartAppLab App Framework — Stage 2 / DESIGN  
**Status:** Proposed implementation-ready UI design; product scope approved, visual tokens require review against original design assets  
**Source of truth:** `PICKWELL_PRD.md` (PRD v1.3, November 2, 2026)

## 1. Design intent

**Promise:** Scan a packaged-food barcode. If Pickwell already knows the product, get its saved analysis immediately. If not, follow a seamless capture flow, sign in only when submitting a new analysis, and receive interpretable ingredient and nutrition findings.

Design for someone standing in a grocery aisle holding a product with one hand. Minimize steps, typing, sign-in interruptions, visual clutter, and unsupported promises about product health.

**Guiding principles**
1. **Scan first:** first-launch experience is scanner-ready, with no mandatory sign-in or long onboarding.
2. **Database first:** cached results open immediately after lookup; do not display AI-processing UI on cache hits.
3. **Three recognizable steps:** Barcode → Nutrition → Ingredients. Barcode remains visually complete throughout new-product capture.
4. **Trust through clarity:** distinguish facts from labels, interpreted findings, rules/reference thresholds, and missing information.
5. **Color supports meaning; it does not replace text:** favorable observations are green, concerns red, caution/uncertainty yellow; labels and icons are always provided.
6. **Recovery over failure:** camera retry, network retry, OTP retry, relevant-label retake and quota explanations.
7. **Strict hackathon scope:** no numerical food score, chatbot, cosmetics, comparisons, history, subscriptions, notifications, social/community, or full onboarding.

### Original website alignment

Official product messaging at https://pickwell.app emphasizes scanning products, ingredient/nutrition interpretation and making informed decisions. Preserve the **Pickwell** name and approachable, health-conscious identity; do not carry over currently advertised scores, cosmetic features, history or pricing into the hackathon UI. Website graphics have not been approved as exact screen assets. **Existing logo, icon, fonts and brand hex codes must be checked against the real project's assets before implementation.**

## 2. Navigation model and information architecture

A single primary scan-oriented flow with no bottom navigation needed for MVP:

```text
App start
  └─ Home / scanner (guest permitted)
       ├─ Scan existing barcode → Checking → Product result
       ├─ Scan unknown barcode → Capture wizard
       │    Step 1 Barcode ✓
       │    Step 2 Nutrition photo
       │    Step 3 Ingredients photo
       │        └─ Analyze product
       │             ├─ Verified session → processing → result
       │             └─ Guest → Email OTP → resume processing → result
       ├─ Checking network error → retry lookup
       ├─ Another user analyzing same barcode → processing/poll → result
       └─ Account / Settings (minimal)
```

Use a conventional back arrow on nested routes. On return from result, reopen barcode scanner ready for another product. **Do not show a post-capture gallery of scan history**: that is deferred.

## 3. Visual system — provisional tokens

Tokens below are **design recommendations, not claimed official pickwell.app values**. Replace only after comparing supplied brand assets / current design files. Keep one consistent token source in Flutter.

| Token | Light-mode proposed value | Usage |
|---|---|---|
| `brand.primary` | `#15805D` | Scan CTAs, active navigation / step completion |
| `brand.primaryPressed` | `#106749` | Pressed states |
| `canvas` | `#F8FAF9` | App surface |
| `surface` | `#FFFFFF` | Cards and sheets |
| `text.primary` | `#172420` | Titles / core values |
| `text.secondary` | `#64726C` | Descriptions / supporting metadata |
| `border` | `#DFE7E2` | Dividers / camera frames |
| `finding.positive` | `#16784F` | Favorable findings; not overall certification |
| `finding.concern` | `#BA3436` | Rule-supported nutritional concerns |
| `finding.caution` | `#9B6A08` | Cautions / uncertainty / allergens |
| `finding.neutral` | `#52645B` | Informational/unknown states |

Use light mode as primary demo target. If the Flutter boilerplate already offers functional dark mode, keep it coherent; **do not build a new dark theme solely for the hackathon**.

**Type:** Material-compatible text system using existing boilerplate font. Proposed scale: display 28/34 semibold, screen heading 24/30 semibold, section heading 18/24 semibold, body 16/24 regular, secondary 14/20, metadata 12/16. Prefer accessible system font fallback. Do not invent an official branded font.

**Spacing:** 4px base unit; screen padding 20px; typical gaps 8/12/16/24; cards with 16px padding and 14–18px radius; primary buttons at least 48px tall (prefer 52px). Respect safe-area insets and system text scaling. Avoid horizontal overflow on compact devices.

**Iconography:** Consistent outlined icons from existing Flutter UI kit; barcode, camera, check-circle, alert-triangle, info, refresh, arrow-back, lock and mail. No need for new illustration assets.

**Motion:** Short, subtle (150–250ms) transitions; never rely on motion for critical instructions. Reduced-motion preferences respected where supported.

## 4. Screen inventory

| ID | Screen / state group | Entry | Primary action | Required variants |
|---|---|---|---|---|
| S01 | Home + barcode scanner | App launch, return | Scan | camera permission, scanning, unsupported code, manual entry fallback (P1) |
| S02 | Barcode lookup | Accepted code | Wait or retry | checking, ready, not found, already processing, offline, timeout |
| S03 | Guided product capture | Confirmed miss | Nutrition → ingredients → Analyze | empty, image preview, retake, camera/gallery failure |
| S04 | Email OTP auth gate | Guest taps Analyze | Verify email OTP | email entry, code entry, resend, invalid, expired, loading, cancel |
| S05 | AI processing | Authorized request | Wait, retry where safe | queued, processing, retake needed, quota reached, failure |
| S06 | Product result | Cache hit or successful analysis | Scan another product | complete, partial explained info, unknown fields, provenance, accessible findings |
| S07 | Minimal account/settings | Home overflow / icon | Sign in/out and privacy | guest, authenticated, sign-out confirmation |

These are **seven screen/state groups**, but only **six principal UI destinations**: Scanner, Capture, OTP, Processing, Result, Settings. Barcode lookup is a transient state within Scanner, not a separate navigation destination.

## 5. Screen-by-screen UX specification

### S01 — Home / Scanner

**Layout (top to bottom)**
- Compact Pickwell wordmark and right-aligned account/profile action; account status should not dominate.
- Headline **“Scan a food product”** and subtext **“Understand its nutrition and ingredients.”**
- Camera barcode viewfinder taking the main available area; visible rectangular scan guide, adequate contrast, flashlight control only if supported by camera package.
- Helper line: **“Place the barcode inside the frame.”**
- Contextual camera-permission fallback and **Open Settings** action when denied. Optional **Enter barcode manually** action (P1; useful for demo resilience).
- No chat, search history feed, score badge, cosmetics switcher, or paywall.

**Behavior:** Camera detects supported retail barcodes, debounces repeated detections, suspends scanner while lookup is pending, resumes after dismissing error or exiting result. Invalid or unsupported barcodes trigger an explanatory error, not the upload wizard.

**Accessibility:** Semantics for viewfinder, accessible flashlight and manual-entry buttons, haptic feedback optional, and text instructions always visible.

### S02 — Barcode lookup (inline / transitional)

- A small overlay or sheet on top of paused camera: **“Checking Pickwell…”** with activity indicator and scanned barcode (truncated only for display).
- `ready`: navigate directly to S06 with no AI animation.
- `not_found`: show **“Product not found — let’s add it.”** plus **“Continue”** to S03.
- `processing`: show **“This product is being analyzed.”** and a bounded **Check again** option; do not launch another analysis.
- network error/timeout: **“Couldn’t check this product. Try again.”** + **Retry** / **Scan another**. Never conflate network errors with cache misses.
- rate limit: explain lookup delay and provide retry guidance; do not loop automatically.

### S03 — Three-step capture wizard

**Persistent progress header:**

`✓ Barcode  →  2 Nutrition  →  3 Ingredients`

On nutrition step, barcode is complete, nutrition active, ingredients upcoming. On ingredients step, barcode and nutrition are complete. The user must never have to scan barcode again because the database missed.

**Step 2 — Nutrition facts**
- Screen title **“Photograph nutrition facts”**.
- Guidance **“Fit the whole nutrition panel in the photo. Make the numbers readable.”**
- Large capture area / placeholder with camera and **Choose photo** option.
- After capture: image preview, **Retake**, **Use photo / Continue**.
- Optional short helper: avoid blur and glare; include serving units and serving size if present.

**Step 3 — Ingredients**
- Screen title **“Photograph ingredients”**.
- Guidance **“Include the full ingredient list and declared allergens, if printed.”**
- Same camera/gallery picker and preview pattern for consistency.
- After valid local capture, primary action **“Analyze product”**.
- Optional expandable row **“Product name / brand (optional)”** to enter/correct identity, but never block submission.

**Data behavior:** Retain the original barcode and currently accepted photos in in-memory draft state across wizard and OTP; on cancellation, offer discard confirmation. Do not promise persistence across process termination. Camera/gallery selections should be compressed suitably without making text unreadable; exact limits set in SPEC.

**Multi-image clarification:** The approved *simple multi-image* behavior is one readable photo of nutrition and one of ingredients. No complex unlimited gallery management is required. If a panel cannot fit, allowing a small bounded extra photo per label is an implementation-time fallback only if backed by the AI payload contract.

### S04 — Email OTP authentication gate

Shown **only when a guest taps Analyze product** (not on app launch or barcode lookup).

- Use a modal full-screen sheet or separate page preserving capture draft behind it.
- Title **“Sign in to analyze this product”**.
- Supporting copy **“Scanned products are free to view. Sign in to add a new analysis to Pickwell.”**
- Email field, keyboard-aware action **“Send code”**.
- OTP code field (platform autofill when available), **Verify**, resend countdown or disabled state, **Change email**, **Cancel**.
- After success, return directly to processing (do not restart the wizard or add profile setup).
- After fail/expire: inline message with manual retry and safe resend controls.
- Session refresh and email verification should be handled by backend; client must not infer authorization merely from locally stored email.

**Security UX:** Explain that structured product information will become available to other users; show privacy terms link before analysis, not an expansive onboarding consent wall.

### S05 — AI analysis / processing

- Heading **“Analyzing product labels”**.
- A simple indeterminate progress indicator with status copy such as **“Reading nutrition facts and ingredients…”**; avoid fabricated percentages or guaranteed times.
- Copy **“We'll check the extracted information before publishing the result.”**
- Prevent duplicate submission while pending. If user backgrounds app, gracefully restore job state if supported by backend rather than silently creating a second job.
- If processing completed, transition to S06.
- If `needs_retake`, identify exact photo (**nutrition** or **ingredients**); navigate to relevant wizard step with the other accepted image preserved.
- If `quota_exceeded`, show **“You've reached your analysis limit for now. You can still view products already in Pickwell.”** + **Scan another product**.
- If server error, show action appropriate to safe idempotent retry. Never offer endless automatic retries.
- If no connection, show recoverable state and avoid pretending a publish succeeded.

### S06 — Product result (single scannable screen)

**Information hierarchy**
1. **Identity header:** product name if verified, optional brand, barcode. Fallback **“Food product”** when identity unavailable. Avoid invented packaging imagery.
2. **Summary:** short plain-language explanation of the product's nutritional characteristics and ingredient observations. Use **“What we found”**, never a 0–100 score or a universal 'healthy/unhealthy' verdict.
3. **Finding cards:** grouped favorable (green), concern (red) and caution (yellow), each with icon, explicit label, short plain-language explanation and what label data or rule supports it. Hide empty groups rather than invent filler.
4. **Nutrition facts:** compact readable rows with value, unit, serving basis; display **“Not available”** for unknowns. Do not mix per-serving and per-100g metrics without labeling.
5. **Ingredients:** ordered readable list, expandable details only where explanations exist and are substantiated.
6. **Declared allergens / label cautions:** clearly identify *declared on packaging* versus unknown / not checked; absent mention is not absence guarantee.
7. **Source & limitations:** **“Based on packaging submitted to Pickwell”**, date analyzed, notes on AI interpretation and missing data; never fabricate external sources.
8. Sticky/visible exit action **“Scan another product”** (one tap back to camera).

**Color usage example (illustrative, not final nutrition thresholds):**
- **Green • Favorable:** “Contains a meaningful amount of protein” **only if** a documented backend threshold exists and evidence supports it.
- **Red • Concern:** “High in sodium” **only if** validated label data and an adopted published threshold support it.
- **Yellow • Caution:** “Milk is declared as an allergen” or “Serving-size information is incomplete.”

Do **not** imply yellow or red ingredients are inherently dangerous. Show user-visible explanations and data basis. Color swatches alone must not carry meaning.

### S07 — Settings / account

Minimal list: signed-in/guest status, **Sign in** (for guest), **Sign out** (for account), **Privacy**, **About Pickwell**. No account profiles, syncing, personalized nutrition preferences, premium pages, or history.

## 6. Shared components

| Component | Implementation role | States |
|---|---|---|
| `PickwellPrimaryButton` | Main CTA | enabled, disabled, loading |
| `ScanViewfinder` | Barcode scanner overlay | ready, scanning, paused, denied |
| `StepProgress` | 3-step capture tracker | completed, active, upcoming |
| `LabelPhotoTile` | Guided photo input | empty, preview, error, retake |
| `StatusPanel` | Lookup/AI feedback | progress, error, retry, processing |
| `FindingCard` | Traffic-light findings | positive, concern, caution, neutral |
| `NutritionRow` | Single nutrient value | known, unknown, basis shown |
| `IngredientRow` | Ingredient explanation | name only, details, uncertain |
| `OtpInput` | Verification code entry | empty, invalid, expired, verifying |
| `EvidenceFooter` | Attribution/limitations | data source, analyzed date, caveat |

Use components already provided by the user's Flutter template when they satisfy the spec; do not rebuild the design system just for this app.

## 7. Copy, accessibility and localization readiness

- MVP language: English interface. Write plain, globally comprehensible copy; long-term multilingual support is deferred.
- Centralize all visible strings in localization-compatible resources, even if only English ships.
- Do not use red/green alone; pair with icon and labels **Favorable**, **Concern**, **Caution**.
- Target WCAG AA-like text contrast where possible; verify final token pairs on actual devices.
- Interactive target minimum approximately 44×44pt iOS / 48×48dp Android.
- Support dynamic text scaling, VoiceOver/TalkBack, keyboard focus for OTP, screen reader descriptions for barcode scanner and status changes.
- Loading states announce status without excessive repetition. Avoid infinite retry spinners.
- For camera use, include permission rationale and clear alternative action if denied.
- When reading label content, avoid medical claims, definitive absence-of-allergens statements, and disease-specific advice.

## 8. Error/state matrix

| Situation | UI outcome | Next user action |
|---|---|---|
| Camera denied | Explanation + system-settings link | Enable camera or use supported manual entry |
| Invalid barcode | Unsupported/invalid code message | Rescan |
| Known product | Immediate result | Review or scan another |
| Unknown product | Friendly contribution prompt | Begin guided photos |
| Barcode currently processing | Nonterminal status | Check again; no duplicate AI job |
| Lookup offline or timeout | Explicit connection failure | Retry lookup |
| Nutrition photo unclear | Retake nutrition prompt | Retake only nutrition |
| Ingredient photo unclear | Retake ingredients prompt | Retake only ingredients |
| Email OTP invalid/expired | Inline auth error | Re-enter or resend |
| Auth canceled | Return to captured draft | Resume later while draft remains in session |
| Session expired | Reauthentication required | Verify email before submit |
| User quota exhausted | Clear quota notice | Scan cached products instead |
| AI timeout/error | Recoverable error / job status | Bounded retry without duplicate submission |
| Missing nutrition field in valid record | “Not available” and uncertainty | Understand limitations; no invented values |
| Conflicting product label/barcode | Refuse publication with explanation | Check product and recapture |

## 9. Backend/UI contract and privacy boundary

The UI consumes **server-provided statuses** rather than deriving truth from timeouts:

- `ready` → S06 cached or newly saved result
- `not_found` → S03 capture
- `processing` / `queued` → S05 or S02 processing status
- `needs_retake` with `field: nutrition | ingredients` → S03 corresponding step
- `unauthorized` / `email_unverified` → S04
- `rate_limited` / `quota_exceeded` → S05 explanation
- `failed` / `network_error` → S02 or S05 with safe retry

Never show a privileged token, full API request detail, backend stack trace, or raw personal-data analytics identifier. Label images are sent for processing and not retained as a permanent product gallery; any temporary private uploads must be cleaned up per SPEC. Product records and AI interpretations will be shared after automated validation; communicate that before submission.

## 10. Asset inventory and handoff

**Required:** Existing Pickwell logo/icon (if repository supplies it), barcode/scanner UI icon, generic illustration-free empty scanner fallback. Prefer bundled vector/material icons.

**Not required:** Stock food photography, fake product catalog images, subscription/paywall artwork, mascots, AI-generated decorative banners, store screenshots.

**Verification tasks before visual lock:**
1. Inspect original Pickwell branding assets and screenshot references from `pickwell`/`pickwell-ai` repo.
2. Confirm or replace provisional palette, font and logo use without altering approved UX flow.
3. Check that Flutter template already provides reusable theme, buttons, route framework and icon set.
4. Capture **real implemented screens** for any hackathon demo or eventual store listing; do not mislabel design concepts as app screenshots.

## 11. Acceptance and targeted design QA

- Guest launch can reach barcode scanner without sign-in.
- Cached barcode opens readable result, bypassing all capture/AI/OTP screens.
- Unknown barcode follows Barcode ✓ → Nutrition photo → Ingredients photo → Analyze.
- User can preview and retake each photo independently.
- Guest submits → OTP gate → returns to exact preserved draft → authenticated analysis.
- Incomplete AI interpretation requests retake of correct label, without publishing result.
- Result contains labeled green/yellow/red findings with provenance and no numerical score.
- Error states distinguish cache miss from network failure and concurrent analysis.
- Compact phone, large text, camera-denied and screen-reader states are usable.
- All visual assets conform to original brand once verified; no unapproved visual claims.

## 12. Cross-document consistency and next steps

**PRD locked:** Barcode-first flow, shared cache, Supabase, Meta AI, Email OTP at analysis gate, rules-based findings, automated publication, ephemeral label images, initial 30/day barcode and 3/day AI allowances (server-configurable), minimal analytics and RevenueCat-ready backend without active monetization.

**To specify in `PICKWELL_SPEC.md`:** Actual Flutter packages and architecture, scan lifecycle, draft state through OTP, typed API/error models, image compression/payload caps, auth redirect handling, job polling/timeouts, backend model integration, security/RLS surface, analytics event definitions, accessible widget implementation and targeted tests.

**To specify in `PICKWELL_DATABASE.md`:** Product uniqueness/normalization, published revisions, analysis/jobs and quotas, atomic claims, server-only writes, RLS, retention/cleanup and admin remediation.

**Do not silently expand scope while translating this design into tasks.** Store launch ASO, full payment funnel and public-release interface features remain future work.

---
**Change log:** v1.0 — Initial hackathon design specification derived from approved PRD v1.2. Tokens explicitly provisional pending real brand asset inspection.


## 13. Usage allowance UI and future-premium readiness (v1.1)

**No new paywall destination, purchase CTA, subscription offer, Premium price, or active checkout in hackathon.** Preserve six essential screens and inline lookup state.

- On **Home/Scanner** show compact “Free usage today” rows only if the backend supplies credible values: **Barcode lookups: 30/day**, **AI analyses: 3/day**. Never hardcode those numbers in labels; pull `limit`, `remaining`, and `resets_at` from entitlement/usage API. For a guest, display “Guest scans available — fair-use limits apply” rather than fake personalized count.
- On **Product Capture**, after an unknown barcode, show the user's available analysis count if authenticated; if guest, prompt for Email OTP at submission as already locked. The two label images count as **one** analysis.
- On **AI Processing**, don't decrement the displayed remaining count until successful finalization. While pending, use “1 analysis reserved” messaging if needed; on failure/retake, return to capture preserving draft and showing unchanged final usage (bounded retries).
- For **lookup limit reached**, keep the scanner accessible but block further server lookup requests with clear wording, server `resets_at` and no fake ability to buy more. Example: “You've reached today's barcode lookups. Try again after 00:00 UTC.” Prefer the viewer's local reset timestamp if formatted correctly from server-provided UTC; don't always show literal UTC to end users.
- For **AI limit reached**, let the user view cached products while new analysis is disabled; explain next reset. No purchase CTA.
- On **Settings/Account** show active plan “Free” and read-only quota usage. Premium status can render if set by server test override, but don't show billing management or a broken Upgrade button.
- **Accessibility:** quotas and traffic lights use text+icons in addition to color; loading/error states must be announced to screen readers. Avoid unexpected changes while someone is completing an OTP form.
- **Dynamic allowances:** a backend change from 30 to 20 must reflect at the next quota response without a Flutter release; remaining is clamped to zero if user has already spent more than the new limit.

**Design QA:** guest scanning has no account wall; OTP preserves draft; cache-hit never uses an AI credit; quota exhausted states give accurate reset; no unactionable “Upgrade” control; the six MVP destinations remain intact.

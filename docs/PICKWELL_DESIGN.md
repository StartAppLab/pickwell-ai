# PICKWELL AI V2 — DESIGN SPECIFICATION

> **2026-11-04 — T07.1C.4 hosted state:** Thumbnail and immediate owner-private-result migrations/handlers are deployed from `5178ec1`, with hosted HTTP/SQL boundary checks passing and inference restored. The 1000/100 testing profile, disabled billing, model/spend limits and exact operator approval remain unchanged. No genuine three-photo private-result/thumbnail demo was completed; automatic thumbnail Storage cleanup scheduling remains pending (protected manual cleanup works). [Deployment versions, actual tests and device limitations](PICKWELL_HOSTED_PRIVATE_RESULTS_ROLLOUT.md). Earlier C.3 “not deployed” notes describe its original local-only run.

**File:** `PICKWELL_DESIGN.md`  
**Version:** 1.6 — Preserved UI and planned trust presentation\
**Date:** November 4, 2026\
**Repository:** `pickwell-ai`  
**Framework:** StartAppLab App Framework / DESIGN  
**Status:** Final visual direction approved through iterative reference mockups; platform fidelity and real product-photo sources remain implementation checks.  
**Source of truth:** `PICKWELL_PRD.md` v1.6. For technical semantics use SPEC/DATABASE; this document governs presentation and navigation.

> **2026-11-04 — T07.1A.1 approved media exception (implemented locally, not deployed):** Only a bounded **front-package derivative** may be intentionally retained as reusable media after exact-evidence operator approval and publication. Original evidence, nutrition and ingredient photographs remain temporary/nonpublic. The post-publication operator command does not alter three-photo submission or approval/quota authority. Private upload → immutable ready association → controlled public image endpoint; no public Storage bucket. Legacy products without an eligible published review retain placeholders. See [architecture, privacy, tests, operator cleanup and rollout](PICKWELL_PRODUCT_THUMBNAILS.md). T07.1A UI polish is not started by this task.

> **2026-11-04 — T07.1C deployed baseline authority (before local C.3):** New analyses require an **evidence-bound operator decision before shared publication**; schema validity, three coherent photos and Muse certainty do not authorize publication. **Deployed and hosted-security verified in T07.1D.1**; genuine three-photo/Muse/operator/device validation deferred by owner. [Rollout evidence](PICKWELL_HOSTED_TRUST_ROLLOUT.md). `review_required` keeps a private candidate/reserved slot for at most 30 minutes; rejection, cancellation or expiry releases the slot without a successful-analysis charge. Operator review is distinct from independent barcode verification. Cross-image discrepancies are review conditions, superseding C.1's automatic identity-conflict retakes; unreadable/wrong photos still use relevant-photo retakes. Existing guest cache reads remain available. See [safeguards, tests, rollout and operator procedure](PICKWELL_PRODUCT_TRUST.md). T07.1D.1 resolves the missing hosted gate; testing deployment PASS WITH LIMITATIONS ([rollout](PICKWELL_HOSTED_TRUST_ROLLOUT.md)); real-product sign-off remains deferred; billing remains disabled and existing testing allowances unchanged.

> **2026-11-04 — T07.1C.1 approved flow update:** Unknown barcode → **Front packaging → Nutrition → Ingredients** (three required photos) → contextual Email OTP → one server-side Muse analysis. Barcode is already captured, outside the three photo steps. This supersedes earlier two-photo/Barcode-as-Step-1 wording for new submissions; historical completed-task evidence remains unchanged. Front identity is a model observation, **not independent barcode ownership verification**. T07.1C's approval gate and T07.1D remain pending. [Implementation, verification and rollout](PICKWELL_FRONT_PACKAGING.md).

## 1. Design goals and scope boundaries

Pickwell is a premium-feeling yet approachable product label intelligence app. Avoid dashboard clutter and visual health claims unsupported by source labels. Use the approved **whole lemon** with green leaves as the app brand mark: no scanner brackets, text, glow, drop shadow or rounded-corner container baked into the source icon. Mobile OS can mask the app icon; asset canvas stays full square.

**Approved mockup patterns:** home with product cards and real photos; no permanently expanded search, no recently scanned section heading, no list/grid switch; product details without bottom tab bar or center-logo title; camera-first barcode/label capture; compact OTP, failure/retake, quota, search, settings and empty states.

**Important:** Images are design references, not reliable product data. Several concepts showed Chat, cosmetics, a 92/100 score or Add to List—these are **not** approved hackathon functions. Do not ship dead-end or misleading controls. T07.1C.1 now requires a transient front-package photo for unknown barcodes; it must not be reused as permanent thumbnail art; image thumbnail must be legitimately available, or use an attractive neutral placeholder. Food-only active category in hackathon; cosmetics is visually explored for V2 later.

## 2. Visual system — 60/30/10

This is a *visual-area guideline*, not a literal requirement to fill 30% of the canvas with saturated green.

| Token | Hex (proposed locked visual direction) | Usage |
|---|---|---|
| `canvas.white` | `#FFFFFF` | Primary surfaces, cards, native navigation backdrop |
| `canvas.cream` | `#FFF7D6` | Warm supporting canvas, gentle accents, empty states |
| `brand.lemon` | `#FFD428` | Lemon mark, rare active-chip/decorative highlights; ~10% visual weight |
| `brand.green` | `#168A3B` | Actions, valid navigation emphasis, completion |
| `brand.forest` | `#173A25` | Brand wordmark, strong UI text, scanner button |
| `ink.primary` | `#17251D` | General copy |
| `ink.muted` | `#647068` | Secondary descriptions |
| `surface.softGreen` | `#EAF5E9` | Chips, subtle selected nav background |
| `surface.border` | `#E5E9E2` | Dividers and outline when needed |
| `semantic.warning` | `#B66A00` | Cautions; text/icon accompany amber |
| `semantic.concern` | `#B3261E` | Evidence-backed concerns |

**Balance:** roughly 60% white/cream neutral, 30% forest/green text/controls/organic surfaces, 10% yellow brand accent. Positive/negative/warning signals are **semantic**, not brand decoration. Avoid more than one dominant yellow control per viewport. No huge gradient panels, heavy neobrutalist borders, thick outlines, floating decorative stickers, oversized illustrations or fake extra data. The later hand-drawn and neo-brutalist studies are explorations, not the approved core UI style.

**Type:** Use existing Flutter project sans-serif unless approved project assets provide a specific family; prominent labels and headings strong but compact. No unsupported custom fonts. Platform-scaled typography with 16sp body baseline and >= 44pt/48dp tap targets. **Cards:** 16–22dp radii, restrained elevation/hairline. **Spacing:** 8dp base, 16–20dp horizontal safe margins, ~12dp gaps between rows. Preserve safe areas/keyboard insets.

## 3. Navigation and hierarchy

```text
App launch
  └─ Home — device-local recently viewed/scanned product list (or empty state)
       ├─ Search icon → expandable search field + recent-product matches
       ├─ Category filter (All / Food); sort (Newest)
       ├─ Product card → Product Details (nested full-screen, no bottom nav)
       ├─ Settings → account, usage, privacy, sign-out
       └─ Separate rightmost Scan action → camera barcode scanner
             ├─ ready → Product Details; append local recent reference
             ├─ not_found → Product Not Found → Front packaging → Nutrition capture → Ingredients capture
             │    → Review Photos → OTP if guest → AI Processing
             │    → Product Details OR needs_retake / failure
             ├─ processing → bounded status / retry
             └─ error → barcode retry / permission advice / quota guidance
```

**Primary bar:** iOS 26-inspired translucent floating **liquid glass** pill with Home + Settings controls for hackathon, a distinct green circular Scan action aligned on the **far right** separated from that pill. Scan uses *icon only* (no label). Chat may appear in design exploration, but is excluded from active hackathon navigation. Do not imitate unlicensed Apple UI assets or assume fully equivalent native blur on Android; use native glass where reliably supported, else a restrained translucent/blurred fallback with contrast. Hidden on full-screen scanner, capture, OTP, processing, and nested Product Details.

**Back/overflow:** Nested pages have a back button upper left; Product Details has a small overflow control upper right; *no Pickwell logo or wordmark as an app-bar title on Product Details*. Do not put a main tabs bar on details.

## 4. Screen inventory (IDs fixed for handoff)

| ID | Screen/state | Hackathon | Notes |
|---|---|---|---|
| H01 | Home / Local Recent Products | P0 | Rounded list cards; empty state; not a public catalog feed |
| H02 | Search overlay/expanded field | P1 | Search local recent titles/barcodes; not global full-text database search |
| B01 | Barcode camera | P0 | Real camera, scanning corners, torch and cancel |
| B02 | Lookup loading / found | P0 | No invented fake progress; cached ready goes to details |
| B03 | Product Not Found | P0 | Show barcode and Add This Product |
| C00 | Front packaging capture | P0 | First required photo; visible identity, nullable observations, preview/retake |
| C01 | Nutrition photo capture | P0 | Actual camera, capture/preview/retake |
| C02 | Ingredients photo capture | P0 | Actual camera, capture/preview/retake |
| C03 | Review captured labels | P0 | Check photo clarity, can retake one, submit |
| A01 | Email OTP request | P0 | Contextual gate *after* photos, no loss of draft |
| A02 | Verify 6-digit code | P0 | Resend timer, error/expired states |
| P01 | AI Processing | P0 | Honest statuses, cancellable/recoverable handling |
| P02 | Retake/failure | P0 | Identify affected label; bounded retry |
| R01 | Product Details | P0 | Evidence-aware findings, ingredients, nutrition; no numeric score |
| Q01 | Daily quota reached | P0 | Accurate server limits/reset time; no paywall |
| S01 | Settings / Account | P1 | Email/guest status, usage/limits, privacy, sign-out |
| F01 | Chat and cosmetics concept | Future | Never a usable hackathon destination |

## 5. H01 Home — precise approved layout

1. iOS status bar/safe top area. Small full yellow lemon emblem + dark forest **Pickwell** wordmark on left; **only magnifier button** upper right (no user/profile icon).
2. Do **not** show a persistent full-width search bar. Tapping magnifier reveals focused search input and keyboard with cancel/close, and filters currently loaded local recent items.
3. A single compact row of category chips (`All` selected, `Food` available) and **right-aligned `Newest` sort**. Use compact capsule pills; no list/grid toggle. Cosmetics only if it becomes a real approved category in future.
4. Immediately below chips: scrollable stacked **individual rounded product cards**. **No 'Recently scanned' heading**, long marketing copy or statistics block above list. Card consists of left 64–84dp photographic thumbnail / neutral placeholder, center product title only (no barcode or subtitle), right Cupertino chevron. The later owner-approved Home dimensions and controls in section 14 supersede the earlier thumbnail dimensions in this paragraph. Show a positive/warning icon *only when meaning and evidence are clear*, and it must never imply a holistic food safety certification.
5. Cards use white with subtle borders/soft lift over mainly warm white/cream canvas. Real-world photos originate only from authorized stored/returned product media; no fabricated real packaging. If none exists, elegant placeholder with product initials/category, not invented product photo.
6. At bottom, separate softly translucent glass pill for primary available navigation (`Home`,`Settings`) and standalone circle **scan icon** on the right. Chat can be represented in future comps but must be absent from working build. Avoid inconsistent text label under scan icon.
7. Empty Home: same header/chips/nav and a short pleasant empty message with scanner action, no fabricated recently scanned records. Do not require login to use Home.

**Data contract:** Store a bounded device-local list of barcode and last-opened timestamp only; no photos, ingredient payloads, or PII. Refresh published products by barcode when online; show unavailable placeholders gracefully; never claim it is multi-device synced or robust offline product-data storage. Use existing local preference/store mechanism (no new DB package if unnecessary). Local recent index is independent of backend usage quota: simply opening a local row doesn't count a new barcode scan, but fetching an uncached remote record must obey backend-defined lookup rules.

## 6. B01–B03 Barcode scanner / lookup

- Open camera full-screen from far-right Scan control, without an extra Scan-a-Product choice screen.
- Dark live camera with large rounded rectangular corner guides and short 'Align barcode within frame' hint, torch upper right and X/back upper left. Camera permission/retry/manual fallback as appropriate. Do **not** show a shutter button for continuous barcode recognition unless an approved alternative entry requires it.
- On recognized code, pause frames and display short honest lookup state, then either show Product Details (`ready`), product-in-progress state (`processing`), or 'Product not found — let's add it' (`not_found`). Network error remains distinct.
- Not Found screen has compact barcode identifier and `Add This Product` primary button, `Scan Another` secondary; no misleading generic label-photo analysis shortcut that skips barcode.

## 7. C01–C03 Guided capture and review

- Barcode is complete before capture. Fixed three-photo progress: **Step 1 Front → Step 2 Nutrition → Step 3 Ingredients**. Review confirms step 3; it is not a fourth photo step.
- Front: capture the package front with visible name, brand, variant and net quantity. Unknown text may stay unknown; the photo is mandatory, a readable name is not.
- Nutrition: capture full readable nutrition panel with units, servings and serving size. Ingredients: capture entire ordered ingredient text and allergen statements. Distinct brief guidance and same camera components.
- Large genuine camera preview, legibility corner brackets, optional gallery import, retake and Use Photo. Avoid giant decorative illustrations in the camera stage.
- Review: three thumbnail cards labeled Front packaging, Nutrition and Ingredients, clear edit/retake per photo, optional Name and Brand fields if accurate/desired, primary `Analyze Product` at bottom. This primary action triggers OTP for a guest, preserving all captures.

## 8. A01–A02 OTP

- Clean cream/white screens with small envelope mark; title `Continue with Email`, email input, `Send Code`. Verification: six digits, email shown, resend cooldown, `Verify` action. Back/cancel preserves draft unless user explicitly discards.
- No Google/Apple auth button. Failures have human-readable recovery and no exposed code/token logs. Keep compact, not busy illustration.

## 9. P01–P02 Processing, errors and quotas

- Honest server-backed stages: processing photos → extracting → analyzing → preparing results. **Do not simulate determinate percent if server has no real progress metric**; use indeterminate animation/check states.
- `needs_retake`: identify nutrition OR ingredient photo, display existing blurry preview, primary `Retake Photo`, secondary `Use Different Photo`; preserve other approved capture.
- `quota_exceeded`: show exact 30/3 effective limits **from server**, remaining when known, and next reset with user-local time. Guests must not see a false exact per-person counter. No paywall/upgrade link.
- Distinguish invalid barcode, not-found, permission denial, network error, OTP expiry, processing duplicate, provider failure and spending cap.

## 10. R01 Product Details — approved reference with MVP corrections

- Full-screen nested page; top back (left), optional ellipsis overflow (right), no logo/title bar; no bottom navigation. Generous breathing room.
- Hero: available *real* product photo or neutral fallback on left, name/brand on right. Small findings tags may be shown if supported; avoid unsupported 'Good Choice' absolute claim.
- Separate rounded section cards: **Product Overview** (summary + favorable/needs-context/concern findings, labeled), **Ingredients & declared allergens** (ordered raw list and understandable context), **Nutrition Facts** (per-serving or per-100g basis with explicit units). The original reference layout is an inspiration, not a mandate to display fabricated `92/100` score or blanket 'None Detected' allergen claims.
- Explanatory rows may be green/amber/red **only** when sourced by printed label and validated rules. An unverified value is `Unknown`, never implied zero. Include analysis date/method and caveats.
- Sticky bottom actions: **Share** (P1, only if appropriate real link/text is available); **Add to List** remains visually approved as a *future* concept but **do not display an inert button in MVP**. Do not sneak in a saved-items database or numeric scoring to match mockup.
- If result too long, scroll content while maintaining safe bottom action space. Content density should be airy, with moderate number of white cards.

## 11. H02 Search and S01 Settings

- Search is an expansion of the Home top-right magnifier; only searches actual device-local recent records in this MVP. Show explicit no matches and close; never pretend worldwide catalog search is implemented.
- Settings: guest/verified status, Email OTP sign-in or sign-out, correct server-provided usage limits/reset, privacy/disclosure, About. No live paywall, fake chat, notifications or cosmetic options.

## 12. Assets and handoff

- Whole-lemon brand icon with two green leaves on full-square white canvas (reference generated during conversation); source logo vector/PNG and exact font assets must be confirmed in actual repository. No file path is assumed from conversation mockups.
- Real product thumbnails are optional. T07.1A.1 authorizes a small derivative of the exact reviewed front photo after publication; **never reuse full-resolution originals, nutrition or ingredient evidence as public imagery**. Keep placeholders without an eligible thumbnail.
- Reproduce the visual system with Flutter components; do not insert AI-generated screenshot images as the screen itself. Contrast, dynamic text, screen-reader semantics and tappable targets must be tested.
- Reuse existing Flutter template layouts, fonts, asset build setup, platform camera packages and Cubit state; avoid unnecessary package swaps.

## 13. Design QA / approval criteria

1. iPhone portrait proportions in actual device screenshots, not stretched imagery; Android safe areas verified where available.
2. Home header has lemon + Pickwell and **only** search icon. No recently-scanned heading, permanent search bar, list/grid control or distracting header card.
3. Active categories limited to implemented data. Home contains rounded cards with truthful thumbnails and distinct empty state.
4. Glass-inspired bar resembles current iOS translucent pill with an **independent rightmost Scan circle**; gracefully degrades on Android; scan has no text label.
5. Product Details no tab bar or logo title, no false score, optional native Share only, no fake Add to List action.
6. Capture, Email OTP, retake and quota states preserve underlying workflow and trust rules.
7. Color is never the only signal; warnings are clearly differentiated from decorative lemon yellow.

**Version history:** v1.1 quotas/preparatory UI; v1.2 November 2 2026 aligned with final visual iterations and clarified temporary local recents vs deferred cloud history.


## 14. Current UI baseline and planned trust presentation (2026-11-04)

**Status:** T07.1 remains complete for its recorded profile; T07.1A polish has implementation/test evidence in [UI polish](PICKWELL_UI_POLISH.md), with remaining screen fidelity/device review explicitly pending. The following roadmap adds no screens or controls in this documentation task.

**Preserve the latest approved Home:** 16dp page margins; cards with small secondary brand, prominent product name and subtle variant/net-quantity subtitle (T07.1A.1 follow-up), with 8dp padding and 100×80 (5:4) images or theme-gray honest placeholders. Search replaces the brand row in place: Cupertino back restores the normal header, the in-field X clears only the query. Search and brand rows have matching height; All/Food chips and sort match heights with light neutral inactive backgrounds. Custom sort offers Newest, Oldest, Name A–Z and Name Z–A, without a dropdown chevron. Home uses HugeIcons except the requested Cupertino chevrons. Keep the animated glass-inspired Home/Settings dock, independent far-right Scan, current selector padding and transparent Android edge-to-edge treatment. Keep accessible text scaling, safe areas and keyboard behavior. These owner-approved refinements supersede conflicting earlier Home dimensions/supporting-line guidance, not the established flows. Product Details retains no logo app-bar title or bottom tabs; no numeric score, Chat, cosmetics, collections or paywall.

### 14.1 Pre-submission trust work — T07.1B–D

Audit before proposing UI changes. T07.1C may add only minimal recovery or uncertainty wording justified by critical audit findings, preserving barcode → nutrition → ingredients → contextual OTP. A model-readable label and a barcode are not proof of association. Avoid “verified product,” certification badges or invented confidence percentages. If identity is unknown, distinguish it from an unreadable nutrient value and show a truthful actionable state only where implemented. Do not add a mandatory front-package capture or dispute workflow before its later task. T07.1D verifies any affected navigation, accessibility and recovery against the existing T07.1 baseline.

### 14.2 Post-submission presentation — proposed, not implemented

| Task | Planned presentation | Safety and continuity |
| --- | --- | --- |
| T08.1 | Extend existing Product Details with a reusable Product Passport: identity, facts, sources, validation state and revision history | Separate observed facts, model uncertainty and identity verification. Evidence availability is not certification. Keep truthful images or placeholders. |
| T08.2 | Focused two-product comparison with aligned quantity/basis labels | Show serving/package differences and unknown/non-comparable fields; no overall score or renal-safe verdict. |
| T08.3 | Conditional request for front-package evidence, identity conflict/dispute status and revision context | Explain what evidence is requested and why; preserve existing captures, allow cancel/recovery, never claim a dispute is resolved before review. |
| T08.4 | Specific Muse Spark evidence/clarification prompts with bounded progress and stop states | User chooses to supply evidence; no free-form chatbot, endless loop or hidden paid calls. Accessibility cannot depend on color. |

CKD-related copy supports educational label awareness for Filipinos. It must not diagnose, prescribe portions/targets, certify safety or recommend personalized renal diets. Missing label information stays unknown. Continue the cream/white, green and restrained yellow balance, source references and readable non-color status labels.

Processing photos (including future front-package evidence) remain transient, never permanent card art. Existing private pending drafts remain bounded for recovery; successful processing clears them. UI provenance may expose minimal safe evidence descriptions/revision dates, never contributor emails, private tokens or image payloads. T06.3 remains deferred and billing disabled.

**v1.3:** Roadmap presentation boundaries and current approved Home reconciled; no new UI implemented or mockup/device verification claimed.


## 15. T07.1C.1 presentation and remaining trust gap

Reuse the existing capture screen, camera adapter, independent previews/retakes, saved-draft recovery and contextual OTP; no unrelated UI polish. A legacy two-photo draft keeps its labels and requests the missing front. Front-specific failures identify the affected image; clear pair conflicts preserve the other photo. Missing/unreadable names do not by themselves force a retake. Results show front-observed name/brand, variant/net quantity when available, and a color-independent statement that barcode ownership has not been independently verified. Known cached records without identity metadata remain readable. No front image becomes product art; placeholders stay honest. The full T07.1C operator gate remains pending.

**v1.4:** Mandatory front capture supersedes section 14's earlier prohibition on a required front step. Future T08.3 enhances verification of the three-photo evidence; it does not introduce this already-approved capture requirement anew. No independent identity verification or fresh device sign-off claimed.

## T07.1C restricted-publication presentation

Keep existing capture/results layout and approved visual system. A readable
three-photo analysis may display a bounded **pending operator review** notice,
expiry in local time, manual Check request again and Cancel review actions. This
is not an infinite loading state or a request to retake every readable label.
Retain private bounded drafts until ready, explicit discard or existing draft
expiry; cancellation retains photos for an explicit new request. Rejection is
terminal for that key. Reviewed results explain operator-reviewed association and
separately state that independent barcode ownership has not been verified. No
confidence percentage or verified badge. Legacy results retain uncertainty.

## T07.1A.1 follow-up — Product identity hierarchy

Home/local recently scanned cards and Product Details share one presentation:
brand (small secondary) → product name (prominent primary) → existing front
variant/flavor and net quantity joined by ` · ` (subtle subtitle). Omit missing
brand/subtitle; retain the honest generic product title when no name is available.
Canonical published name/brand take priority; existing validated front observations
fill missing canonical fields. Do not infer package quantity from serving size or
parse label prose. Product Details retains the selectable barcode below identity;
cards do not use it as a subtitle. Thumbnail retrieval/publication and existing
image slots are unchanged. This approved follow-up supersedes prior title-only
card guidance; no general UI redesign or backend inference change.

## T07.1C.3 — Preliminary Details presentation

Reuse the existing nested Product Details (no logo title/dock/score). After a
validated private analysis, navigate immediately to the same identity, findings,
nutrition, ingredients, evidence and uncertainty content. Show a subtle **Analysis
ready** notice and **This product hasn't been approved for the shared catalog yet.**
No blocking approval screen. Display an owner-local front preview or honest
placeholder; never imply private imagery is approved shared media. Pending Home
cards become **Analysis ready / View analysis** for their owner only. Keep explicit
shared-publication check/cancel actions, TTL information and optional canonical
transition. No major visual redesign is included.

### 2026-11-05 — Product Details visual consistency

Public and owner-private Details use the same theme-derived cream canvas as Home
(`surfaceContainerLowest` blended 30% toward `surface`), without Home's decorative
shapes. Both routes use a transparent Details-specific app bar over an edge-to-edge
scrolling canvas, with `EdgeBlur` fades at the top and bottom, neutral circular
back controls, no logo title and no bottom dock. List padding includes the actual
system insets and toolbar clearance; scroll content may pass beneath the controls.
System bars remain transparent with theme-appropriate icon brightness. Retain the existing 16dp page gutter
and bounded reading width. Product identity uses a bold green headline, with brand
and variant/quantity as secondary text. White rounded section cards use 16dp content
insets, 24dp separation, green 20sp headings and comfortable body line spacing.
Keep raw label/evidence and technical metadata expandable, with all existing
uncertainty, private-result status and publication controls intact.

Validation: 44 affected Flutter tests passed, including compact 320dp layouts at
2× text scale in light/dark themes, identity presentation, private access and
published-result handoff. Flutter analyzer passed; the 390×844 fixture render was
visually inspected. This pass does not claim new device or hosted verification.

Edge-to-edge follow-up: 42 targeted result/private-result/navigation tests passed,
including inset clearance, scroll-under behavior and a usable overflow menu.
Disclosure tests now center their target before tapping in the full-height
viewport. Existing shared app bar and edge-fade implementations were reused;
no backend, authentication or publication behavior changed.

Details navigation follow-up: use a local transparent `AppBar` instead of the
shared `MaterialAppBar`, whose fixed leading slot crowded the back button. Keep
16dp horizontal control insets and 8dp vertical breathing room around a minimum
48dp back target. Match the overflow inset to the page gutter. Preserve the
edge fades, scroll-under clearance and transparent system bars.

### 2026-11-05 — Keep private-result presentation focused on the product

Completed owner-only Home cards omit the lock/“Private analysis” badge; keep
loading, expired-result and recovery messages when relevant. In owner-private
Details, hide the analysis-allowance panel and place the preliminary-result,
retention and shared-publication notice/actions in a final rounded section after
the product facts and analysis metadata. Owner scoping, private expiry, quota
accounting and operator approval remain unchanged; this is presentation only.

### 2026-11-05 — Vertical nutrition rows and unknown-value visibility

Show the energy, total sugar, sodium and protein highlights as vertically stacked,
full-width label/value rows rather than horizontal metric columns. Hide nutrient
rows whose amount or unit is unknown, in both highlights and expanded facts;
keep confirmed zero values and literal units. Omit an entirely unknown nutrition
section and unknown basis/serving placeholders. This is presentation only: retain
missing-information disclosures, raw label data and backend validation/provenance;
never substitute zero or added sugar for an unknown total-sugar value. Previously
recorded “Unknown” nutrition-row presentation is superseded by this owner request.

Validation: 31 affected Flutter tests passed, covering vertical ordering, known
zeroes, unknown amounts/units, empty sections, printed micronutrient units,
private-result recovery and compact/large-text light/dark layouts.

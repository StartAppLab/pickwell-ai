# Final UI polish and design fidelity pass

Date: 2026-11-04 (Asia/Manila). Scope: presentation-only polish after T07.1; no backend, database, quota, provider, auth policy or persistence changes. T06.4 was not started.

## Final commit validation — 2026-11-04

Reviewed the complete pending Home/control/card/spacing/localization changes and supplied original logo/reference images before committing. The reference images are design concepts, not real catalogue records; deferred scores, collections, Chat/cosmetics and fake media are not implemented to match them.

- `fvm flutter test --no-pub test/catalog test/app_config_security_test.dart`: **138 passed**.
- `fvm flutter analyze --no-pub`: **no issues**.
- `python3 tool/check_environment.py`: known-secret pattern scan passed for tracked/nonignored files; not a Git-history audit.
- `git diff --check`: passed. Populated `.secrets/`, mobile configuration and Supabase server environment files remain ignored and excluded.

Logs remain private in `.secrets/final-home-commit-tests.log` and `.secrets/final-home-commit-analyze.log`. Earlier dated “uncommitted” notes below describe their original work stage; this final validation covers the complete commit candidate. No new backend deployment, provider call, device installation or live photo trial occurred during this commit review.

## Aligned Home control heights and neutral placeholder (2026-11-04)

Latest owner-requested refinement:

- Removed the down-chevron from the Sort trigger; its HugeIcons sort symbol and selected-order label still open the custom popover.
- Photo placeholder now uses a neutral gray derived from existing theme surface/secondary-ink colors. Package icon and fallback label use secondary ink; light/dark support and image ratio remain unchanged.
- Category chips and Sort share a measured control height: 48dp at normal text size, expanding consistently for larger text. The chip's visible capsule now matches its full tap height instead of having a shorter painted fill inside a larger target.
- Normal logo/search header and inline search share one measured height (56dp normally). Larger text expands both consistently; the brand label can ellipsize instead of wrapping and changing row height. The search field remains centered, with independent Back and clear actions.

Added `home_control_metrics.dart` under existing Home presentation widgets to share those actual text/inset measurements, not a parallel design system. Changed Home chip/sort/filter/header widgets, `product_card_thumbnail.dart`, geometry tests and this report. No backend, native navigation/dock-padding, quota or persistence changes.

**Observed validation:** `fvm flutter test --no-pub test/catalog/home_header_controls_test.dart test/catalog/home_sort_test.dart test/catalog/home_product_card_test.dart test/catalog/home_widget_test.dart test/catalog/ui_polish_test.dart` — **28 passed**. New geometry assertions compare chip/Sort heights and normal/search field/header heights at 0.8×, 1×, 1.6× and 2× text scaling, and confirm the Sort trigger contains only its sort symbol. Existing narrow/landscape/tablet/dark/RTL/search/popover checks pass. `fvm flutter analyze --no-pub` — no issues; `git diff --check` — passed. Reviewed updated normal/search Home renders. Logs: `.secrets/home-matched-heights.log`, `.secrets/home-matched-heights-analyze.log`. Changes remain uncommitted; no new device or live API test claimed.

## Reduced page gutters and title-only cards (2026-11-04)

Latest owner request overrides the earlier 20dp page gutter and descriptive card subtitle:

- Shared app page padding reduced to **16dp**. Home now consumes that shared inset instead of its own 20dp token; the root dock aligns to the same gutter. Existing safe-area/keyboard protection and maximum reading width remain.
- Recent-product cards are now **title-only**, with no brand, serving or barcode subtitle. The data remains available for search and Product Details; no backend fields were deleted. Unresolved cards keep the connection/load explanation in accessibility semantics without adding a visible subtitle.
- Card padding is **8dp on all sides**, making vertical and horizontal insets equal. Image area enlarged from 84dp to **100×80dp**, preserving the requested 5:4 ratio and honest placeholder behavior.
- Header search Back now uses **CupertinoIcons.chevron_back**. Clear-search behavior and the separate product-card Cupertino chevron remain unchanged.

**Files in this follow-up:** `app_base_theme.dart`, `home_view.dart`, `root_view.dart`, `home_header.dart`, `catalog_widget.dart`, `product_card_thumbnail.dart`, related Home/card widget assertions and this report. No backend, provider, persistence, authentication or billing change.

**Observed validation:** `fvm flutter test --no-pub test/catalog test/app_config_security_test.dart` — **137 passed**. `fvm flutter analyze --no-pub` — no issues. `git diff --check` — passed. Reviewed the updated Home render with shared 16dp gutters and title-only cards. Existing large-text/keyboard/RTL/filter/sort/capture/OTP/submission/recovery checks remain passing. Logs: `.secrets/compact-spacing-tests.log`, `.secrets/compact-spacing-analyze.log`. No fresh device install or live Meta call; changes remain uncommitted.

## Inline search, custom sort and compact cards (2026-11-04)

Latest owner-directed Home refinements supersede the earlier expanded-below-header search and Material popup design:

- Extracted `HomeHeader`: search replaces the logo/wordmark in the **same header row**. Its back button exits search and restores the brand/search icon and unfiltered list. The X inside the field only clears the text/query, retaining search mode and keyboard focus. The controller/focus node are owned and disposed by Home; reopening starts with an empty query.
- Replaced `PopupMenuButton`/Material menu entries with a custom anchored, rounded floating popover using Cupertino controls, a subtle fade, explicit selected state and the existing four sort choices. It fits safe-area/keyboard bounds, can scroll on constrained displays, follows RTL alignment, respects reduced motion, and closes on selection, outside tap, system back or Escape. Sorting semantics and local-only behavior are unchanged.
- Inactive category capsules, the search icon surface, search field and sort trigger now share the light neutral `surfaceContainerLowest` background instead of letting the yellowish canvas show through. Dark mode uses the corresponding neutral theme surface.
- Product image area is now **5:4 width:height** (geometry tested). Placeholder text remains accessible and adapts at larger scales; no photos are fabricated. Card inset reduced from 16dp to **12dp**. The card's forward chevron explicitly uses **CupertinoIcons**, as requested, overriding the earlier all-HugeIcons preference only for this indicator.

**Files added:** `home_header.dart`, `home_sort_popover.dart`, `home_sort_label.dart`, `home_header_controls_test.dart`. Changed `home_view.dart`, Home filter/sort widgets and barrel, `catalog_widget.dart`, `product_card_thumbnail.dart`, the relevant Home/card/layout tests, and localized clear-search wording in all 12 supported ARB resources plus regenerated outputs. No backend, new dependencies, artwork, quota/auth changes or T06.4 implementation.

**Observed validation:** 47 targeted Flutter tests passed across header/card/sort/Home/recents/layout/pending-draft suites. They cover the separate back/clear behavior, same-row header geometry, restored results/focus after clearing, custom popover selection/Escape/outside dismissal, 5:4 thumbnail bounds, narrow/large-text/dark/RTL layouts, working sorting/filtering/search and saved-draft recovery. `fvm flutter analyze --no-pub` — no issues. `git diff --check` — passed. Render-helper checks were rerun after loading the actual Cupertino font and hiding the test-only debug banner.

Visually reviewed `.secrets/ui-polish/home-inline-search.png`, `home-custom-sort.png`, and `home-390.png` (actual widget renders with synthetic fixtures, not live catalogue evidence). Logs: `.secrets/home-controls-validation.log`, `.secrets/home-controls-render-tests.log`, `.secrets/home-controls-analyze.log`. This pass has no fresh device install or live provider test. Changes remain uncommitted pending owner review.

## Home HugeIcons and product-card identity (2026-11-04)

Owner requested HugeIcons throughout Home and product cards with a title/image area and no barcode subtitle. Confirmed that the published product contract has **no package-photo/media field**; the owner explicitly chose **placeholders for now**. No image service, schema, package-media scraping, fabricated package photo or reuse of private label captures was introduced.

- Home search/close/search-field icons, sort/caret/selection mark, product chevron/thumbnail and saved-draft warning now use the existing `AppIcon` + HugeIcons wrapper. The custom sort menu retains selected semantics; it no longer introduces a Material checkmark internally. Dock icons were already HugeIcons.
- Every recent-product card has a trimmed nonempty title, with an honest localized “Food product” fallback when no name is available. Subtitle uses available brand and explicitly labeled serving size, otherwise “Nutrition & ingredients”. Unresolved records say “Connect to load product details”. No barcode is used as the recent card subtitle; barcodes remain usable in search and Product Details. Saved-draft identifiers remain available for differentiating pending submissions.
- Added an 84dp-wide, at-least-96dp-tall rounded image placeholder with HugeIcons package symbol, visible “No photo” and accessible “Product photo unavailable” wording. It grows for larger text instead of overflowing. This is a labeled image-area placeholder, not a claim that a product photograph exists.
- Card padding is 16dp, title/subtitle have distinct weights, and source serving-size words/units stay together when wrapping. Whole-card tap navigation remains intact. Stable barcode-based widget keys preserve row identity without printing identifiers as subtitles.

**Files in this follow-up:** `home_view.dart`, `home_sort_menu.dart`, `catalog_widget.dart`, new `product_card_thumbnail.dart` and the catalog widget barrel, `pending_capture_card.dart`; Home/card/sort/pending widget tests; three new card-fallback labels across all 12 supported ARB resources and regenerated Dart outputs; this report. Earlier working-sort changes remain separate uncommitted work after commit `e2f11d5`.

**Validation:** `fvm flutter test --no-pub test/catalog/home_product_card_test.dart test/catalog/home_sort_test.dart test/catalog/home_widget_test.dart test/catalog/recent_products_test.dart test/catalog/ui_polish_test.dart test/catalog/pending_capture_test.dart` — **45 passed**. Covers missing/whitespace name/brand, no barcode subtitles, explicit image fallback, serving metadata, thumbnail tap navigation, long names/large text, Home/search/menu HugeIcons, all sort modes, filters, recents, keyboard layouts and saved-draft resume/delete. `fvm flutter analyze --no-pub` — no issues. `git diff --check` — passed. Render evidence remains `.secrets/ui-polish/home-390.png`, with synthetic fixture content; logs `.secrets/home-cards-validation.log`, `.secrets/home-cards-analyze.log`. No live backend/provider calls or fresh device install.

## Working Home sort and reference-style filters (2026-11-04)

The owner requested reverting the dock padding and committing the prior fixes **before** this Home update. Commit `e2f11d5` contains the edge-aligned dock selector, restored animation and transparent Android system-bar fixes; the temporary inset padding is not retained.

Read `APP_DESIGN_GUIDELINES.md` alongside the supplied `docs/reference/home.png`. Replaced Home's duplicated small filter controls with feature widgets that reuse existing spacing, typography, color, 48dp target and capsule-shape conventions. The selected category is forest filled; inactive categories have restrained outlines, with no checkmark clutter. Only actual All/Food filters are displayed. Measured translated/scaled labels keep the controls in one aligned row when possible; otherwise categories stay left and sort moves to a right-aligned second row. No font shrinking or clipped labels.

The previously static Newest indicator is now a real selected-state popup menu: **Newest, Oldest, Name A–Z, Name Z–A**. Newest/Oldest use the device-local last-opened timestamp; name ordering is case-insensitive lexical order, with unnamed/unresolved entries after named products and deterministic timestamp/barcode ties. This is not locale-specific dictionary collation. The bounded source index is never mutated or rewritten by sort. Search, category and ordering compose without additional lookup/AI calls. Refresh and opening/closing search retain the screen's selection; dismissing the menu changes nothing. Default Newest returns when the Home screen is recreated; sort is not a new persisted preference or cloud history feature. Saved pending drafts retain their existing separate queue behavior.

**Files for this Home update:** `mobile/lib/src/features/catalog/domain/entities/catalog_entity.dart`; `mobile/lib/src/features/home/presentation/views/home_view.dart`; `mobile/lib/src/features/home/presentation/widgets/{home_filter_bar.dart,home_filter_chip.dart,home_sort_menu.dart,_widgets.dart}`; `mobile/test/catalog/home_sort_test.dart`; four sort labels in each of the 12 supported `app_*.arb` resources and their regenerated Dart localization outputs; this report. No backend/schema/package/asset or T06.4 changes.

**Observed validation:** `fvm flutter gen-l10n` completed; added labels are translated in all 12 supported locales (the generator still reports six existing untranslated messages per non-English locale outside this change). `fvm flutter test --no-pub test/catalog/home_sort_test.dart test/catalog/home_widget_test.dart test/catalog/recent_products_test.dart test/catalog/ui_polish_test.dart` — **29 passed**. The seven new sorting tests also passed independently after adding menu-dismissal coverage and targeting the actual popup entries for hit testing. Tests cover all four orders, stable ties, unknown names, index immutability, real menu selection, refresh, combined search/Food filtering, no lookup calls, 320dp/large text, dark and Arabic RTL/German controls. `fvm flutter analyze --no-pub` — no issues. `git diff --check` — passed. Reviewed the updated `.secrets/ui-polish/home-390.png` against the reference; renders contain clearly synthetic fixture data, not a fabricated product catalogue.

Logs: `.secrets/home-sort-validation.log`, `.secrets/home-sort-final-tests.log`, `.secrets/home-sort-analyze.log`. No live API requests, paid model calls, fresh device install or broader Settings work were performed.

## Dock inset, animation and Android system bars (2026-11-04)

Owner-requested follow-up after the separate UI-polish and Home-reference commits:

- Trialed 8dp internal dock padding, then **reverted it at the owner's request before committing**. The original dock height and edge-aligned selector are restored; the animation and Android fixes remain. The Scan circle remains independent.
- The slide animation had not been removed: the previous polish shortened it from 300ms to 200ms and softened its appearance. Restored a **300ms ease-out slide**. New tests sample its intermediate position in both directions through real ShellRoute navigation and verify that RootView state survives the route change. Reduced-motion settings still select immediately.
- Located the Android black-bar regression in the shared app-bar overlay style: Flutter's light/dark presets retain a black navigation-bar color unless explicitly overridden (confirmed in the installed SDK). Home has no app bar to establish a fresh style. Added one explicit light/dark transparent system-bar style, reused by the theme and a full-route AnnotatedRegion so pages without app bars retain it. Set navigation icons for light/dark backgrounds, removed the divider/contrast scrim and explicitly enabled edge-to-edge at startup, including pre-Android-15 devices.

This follows Flutter's [system overlay guidance](https://api.flutter.dev/flutter/services/SystemChrome/setSystemUIOverlayStyle.html) and [edge-to-edge guidance](https://docs.flutter.dev/release/breaking-changes/default-systemuimode-edge-to-edge). OS navigation controls remain visible; content stays behind the transparent bars while interactive UI retains safe-area padding. A full app restart is required to run the new startup mode setting; hot reload alone does not rerun main.

**Files:** `mobile/lib/main.dart`, `mobile/lib/src/config/theme/app_theme.dart`, `mobile/lib/src/features/root/presentation/views/root_view.dart`, new `mobile/test/catalog/navigation_shell_test.dart`, and this report. No backend, authentication, quota, data or native resource changes.

**Observed validation:** `fvm flutter test --no-pub test/catalog/navigation_shell_test.dart test/catalog/home_widget_test.dart test/catalog/ui_polish_test.dart` — **18 passed**. Four new tests cover edge-aligned selector/animation with and without reduced motion, and emitted transparent system styles in light/dark across AppBar/no-AppBar transitions and keyboard focus recovery. Existing compact/tablet/large-text/layout checks pass. `fvm flutter analyze --no-pub` — no issues. `git diff --check` — passed. Reviewed updated Home widget render; final selector padding was reverted before commit. These are framework/widget checks; no new Android install, actual IME/gesture-vs-three-button visual test or device screenshot is claimed.

## Latest scope — Home reference follow-up (2026-11-04)

The owner subsequently supplied **`docs/reference/home.png`** and requested Home first, setting further logo work aside. Inspected that image directly before this revision. Earlier paragraphs describing absent mockups record the initial pass; Home now has an actual visual reference. Other supplied reference files are available but have not been applied in this Home-only follow-up.

Compared with the first flat-cream implementation, Home now has:

- Warm off-white canvas with soft green upper/lower curves, drawn in Flutter rather than generated image assets.
- Larger forest wordmark and raised circular search control; search still expands only when requested.
- Forest selected All/Food pills, outlined inactive filter and compact newest-order indicator. No fake sort menu is introduced when only newest order exists.
- Larger, individually rounded white cards with restrained elevation, 76×88 neutral thumbnail placeholders, stronger product names and quieter supporting text.
- Existing glass-inspired Home/Settings dock and independent rightmost Scan retained. Chat/Cosmetics shown in the concept remain excluded under the approved MVP scope.

The current product contract has no authorized package media, so reference package photos are not copied into live cards. Generic good/bad check badges from the concept are not assigned to products without an explicit, supported finding; this pass does not introduce an overall product safety classification. The prior logo implementation is untouched in this follow-up, as requested.

Additional files touched in this follow-up: `home_view.dart`, `catalog_widget.dart`, new `home_backdrop.dart` and its existing widget barrel, the UI layout test, this report and TASKS note. No further OTP, scanner, results, backend or persistence changes.

**Validation:** `fvm flutter test --no-pub test/catalog/home_widget_test.dart test/catalog/ui_polish_test.dart test/catalog/recent_products_test.dart` — **22 passed**. `fvm flutter analyze --no-pub` — no issues. `git diff --check` — passed. Home's compact/large-phone, landscape, tablet, large-text, keyboard, guest scan navigation and local search/filter/restart checks remain covered. The landscape keyboard test scrolls the expanded search into view before input.

Compared the reference with `.secrets/ui-polish/home-390.png`, an actual widget render containing a clearly labeled synthetic test record, not a real product or full catalogue. Reference photo content, deferred routes and global food-certification badges are intentional deviations; physical-device visual review remains outstanding. Logs: `.secrets/home-reference-tests.log`, `.secrets/home-reference-analyze.log`.

## References and limitations

Read mobile instructions, shared app design guidelines, PRD v1.4, DESIGN v1.2, SPEC v1.2 and current UI/test implementation. Inspected bundled app artwork and earlier local implementation captures (`.secrets/pickwell-home-final.png`, `.secrets/t061-results-light.png`, `.secrets/t061-results-dark.png`). The old Home capture is a splash screen, not an approved Home mockup. These files are historical implementation evidence, not approved visual targets.

At the initial pass, before the reference folder was supplied, no approved screen mockups were found in the inspected repository/assets. Requested a local reference path and proceeded with the approved written design. During the pass, `assets/pickwell-raw.png` appeared: inspected the supplied whole-lemon/two-leaf image, preserved the original, and copied it unchanged to `mobile/assets/images/pickwell_lemon.png` for Home. **Initial screen-mockup fidelity was unverified; the later Home-specific comparison is recorded above.** Home now uses that supplied brand artwork instead of the emoji placeholder. The bundled launcher/splash artwork is still the starter mark; native icon/splash regeneration was not performed. No artwork was generated or edited, and no product package photos were invented. The result/media contract currently supplies no authorized package photo, so neutral placeholders remain appropriate. Captured label photos are not reused as product imagery.

## Screens and before/after changes

| Screen or shared element | Before | After |
| --- | --- | --- |
| Shared theme | Mixed Material defaults, 14px body, 24px page padding, small text-button targets; some default card outlines visually heavy | Manrope retained; 16px body/13px supporting text, compact bold headings, 20px page padding; 52px primary and 48px secondary/icon targets; white/dark-neutral cards with subtle borders and consistent 20px radii. |
| Palette | Brand palette present, semantic green/amber not explicitly checked against finding surfaces | Cream/white, forest and restrained lemon direction retained; readable green/amber variants and explicit dark card/secondary tokens. Automated contrast >=4.5:1 for semantic labels on their tinted finding backgrounds. |
| Home/loading/search | Loading replaced header/filter area; search had only a hint; default chips | Supplied whole-lemon header asset replaces emoji; header/filter controls remain during loading; expandable labeled search with keyboard action, drag-to-dismiss and explicit close focus dismissal; capsule filters and unchanged actual local filtering/newest ordering. |
| Home cards | Honest generic placeholders already present | Preserve honest placeholders, existing local references and no fake feed; shared surface, typography and spacing improve card hierarchy. |
| Home/Settings dock | Fixed 56px shell and 10px labels; wide tablet dock; gesture-only selected state | Readable 12px labels, scaling-aware height, selected button semantics, visible ink feedback, soft green selection and restrained translucency; width bounded to existing content width, independent 64px far-right Scan circle. Dock hides while keyboard is open; reduced-motion selection animation honored. Android retains the existing zero-blur fallback. |
| Product Details | Bare package icon, dense prose, default neighboring card spacing | Neutral rounded identity placeholder, clearly separated sections, subtly tinted findings with existing text/icon severity, stronger quantity alignment and tabular figures, quiet nutrition separators, spaced expandable evidence/reference content. No logo app-bar title, bottom tabs, score or collection action. |
| Scanner | Torch among footer controls; guide could exceed compact width | Torch moved to upper-right app bar; guide width adapts to narrow screens with lemon accent. Camera controller, recognition, gallery/manual entry and navigation are unchanged. |
| Capture/review | Same-colored step chips, prominent long saved-draft note, card gaps inherited from defaults | Current capture step highlighted; completion icon, clearer card spacing and quieter saved-draft metadata. Both original previews and independent retakes retained; no fourth numbered step or additional input required. |
| Email OTP | Plain centered envelope, default keyboard actions; helper text could truncate | Small aligned soft-green envelope, scroll/keyboard-safe form, email/code keyboard submission and wrapped helper text; cancel/resend/error behavior preserved. **Actual eight-digit hosted policy remains unchanged**, despite the old six-digit design example. |
| Processing/retake/error/quota | Existing functional notices with little hierarchy | Shared card/control/typography treatment; lookup notices gain an icon and live-region heading. Honest indeterminate progress, label-specific reasons, bounded retry and server quota text remain intact. |

The 60/30/10 rule is treated as the approved visual-area guideline, not a measured pixel-percentage claim. No unrelated Settings/account content, new feature or architecture layer was introduced.

## Validation and observed results

- `fvm flutter test --no-pub test/catalog test/widget_test.dart test/app_config_security_test.dart`: **121 passed** (existing 115 plus six UI-polish tests). Covers guest routing/scan dock, lookup, capture and independent retakes, OTP cancel/verify resume, submission/cleanup, pending-draft recovery, result/evidence/uncertainty, recents and quotas. Uses existing fake/native boundary fixtures; no fresh live inference or physical camera operation.
- `fvm flutter analyze --no-pub`: **no issues**.
- `git diff --check`: passed.
- New layout checks cover **320×690, 390×844, 430×932, 844×390 landscape and 768×1024**, enlarged text up to 1.6×, modeled top/bottom safe-area insets and keyboard insets. Assert independent Scan position/target size, bounded bottom dock, local search, reachable OTP action above keyboard, long/unknown detail content, compact permission recovery and processing/retake/error layouts.
- Rendered and visually reviewed actual widgets in light/dark: Home, Details, capture review, OTP with modeled keyboard and permission state. Screenshots use clearly synthetic test content; they are not live-product/demo evidence. Test renders load the bundled Manrope/Material fonts and supplied brand image; they are not photographs of a running device.
- Initial iterations caught and corrected a tinted-card Material ink assertion, dock height/large-text overflow, OTP helper truncation and test scrolling assumptions after larger controls. Tests now wait for layout and bring actions into view before tapping.

Private render evidence: `.secrets/ui-polish/home-390.png`, `details-light.png`, `details-dark.png`, `capture-review.png`, `otp-keyboard-320.png`, `permission-320.png`. Private logs: `.secrets/ui-polish-regression.log` and `.secrets/ui-polish-analyze.log`. No private credentials or label payloads appear in this report.

## Exact files changed

- `mobile/lib/main.dart`
- `mobile/lib/src/config/theme/app_base_theme.dart`
- `mobile/lib/src/config/theme/app_color_scheme.dart`
- `mobile/lib/src/config/theme/app_theme.dart`
- `mobile/lib/src/features/auth/presentation/views/email_otp_gate_view.dart`
- `mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart`
- `mobile/lib/src/features/catalog/presentation/views/catalog_view.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/interpretation_explanation.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/label_photo_card.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/lookup_notice.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/nutrition_fact_row.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_finding_card.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_result_content.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_section.dart`
- `mobile/lib/src/features/home/presentation/views/home_view.dart`
- `mobile/lib/src/features/home/presentation/widgets/home_backdrop.dart`
- `mobile/lib/src/features/home/presentation/widgets/_widgets.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/catalog_widget.dart`
- `mobile/lib/src/features/root/presentation/views/root_view.dart`
- `mobile/lib/src/features/root/presentation/widgets/nav_item.dart`
- `mobile/test/catalog/email_otp_test.dart`
- `mobile/test/catalog/home_widget_test.dart`
- `mobile/assets/images/pickwell_lemon.png` (unchanged copy of supplied `assets/pickwell-raw.png`)
- `mobile/test/catalog/navigation_shell_test.dart`
- `mobile/test/catalog/ui_polish_test.dart`
- `docs/PICKWELL_UI_POLISH.md`
- `docs/PICKWELL_TASKS.md`

## Remaining deviations and handoff

- The supplied Home mockup has now been compared in the Home follow-up above. Other screen references have not yet had their own focused fidelity pass. Home uses the supplied whole-lemon image unchanged, including its white canvas/thin source border. A transparent/vector header variant and native launcher/splash replacements were not produced; existing starter launcher/splash artwork was preserved.
- This pass verifies widget rendering and automated navigation/workflow behavior. A quick device visual review of the new spacing, keyboard, native camera/torch and platform glass remains advisable; no fresh signed build, device installation or live Meta/OTP trial was performed here.
- Existing user-approved OCR/unknown-value behavior, server protections, photo disposal and quota semantics are unchanged. The prior T07.1 record remains historical evidence; these UI changes have their own automated regression results above.
- No backend deployment, paid provider calls, new dependency, analytics or billing activation. Cloud testing allowances remain untouched.
- Next: owner review of the polished UI and missing artwork, then decide whether to undertake optional T06.4. T07.2 remains later; neither task is started automatically.

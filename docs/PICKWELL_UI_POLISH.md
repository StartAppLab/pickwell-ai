# Final UI polish and design fidelity pass

Date: 2026-11-04 (Asia/Manila). Scope: presentation-only polish after T07.1; no backend, database, quota, provider, auth policy or persistence changes. T06.4 was not started.

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
- `mobile/test/catalog/ui_polish_test.dart`
- `docs/PICKWELL_UI_POLISH.md`
- `docs/PICKWELL_TASKS.md`

## Remaining deviations and handoff

- The supplied Home mockup has now been compared in the Home follow-up above. Other screen references have not yet had their own focused fidelity pass. Home uses the supplied whole-lemon image unchanged, including its white canvas/thin source border. A transparent/vector header variant and native launcher/splash replacements were not produced; existing starter launcher/splash artwork was preserved.
- This pass verifies widget rendering and automated navigation/workflow behavior. A quick device visual review of the new spacing, keyboard, native camera/torch and platform glass remains advisable; no fresh signed build, device installation or live Meta/OTP trial was performed here.
- Existing user-approved OCR/unknown-value behavior, server protections, photo disposal and quota semantics are unchanged. The prior T07.1 record remains historical evidence; these UI changes have their own automated regression results above.
- No backend deployment, paid provider calls, new dependency, analytics or billing activation. Cloud testing allowances remain untouched.
- Next: owner review of the polished UI and missing artwork, then decide whether to undertake optional T06.4. T07.2 remains later; neither task is started automatically.

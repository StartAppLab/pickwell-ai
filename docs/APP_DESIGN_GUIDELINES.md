# StartAppLab — App Design & Interaction Guidelines

**Version:** 1.0  
**Applies to:** Consumer mobile applications built with the StartAppLab Flutter template  
**Status:** Recommended design standard; individual app `DESIGN.md` provides brand-specific exceptions

## 1. Purpose and authority

Create polished, platform-appropriate mobile interfaces with deliberate hierarchy, consistent spacing, predictable interaction, accessibility, and adaptive layout. This is a reusable design standard, **not a copy of Apple's HIG and not a claim that the numeric values below are Apple requirements**.

Authority order:
1. Platform accessibility, system behavior, safety, privacy, and OS constraints.
2. Repository `AGENTS.md` for implementation patterns and existing shared theme infrastructure.
3. App `docs/DESIGN.md` for brand, screen-level decisions, and explicit overrides.
4. This document for shared layout and interaction defaults.
5. `docs/reference/` images for illustrative composition, not architecture or specifications.

Where documents conflict, report the conflict, choose the more explicit applicable rule, and avoid changing the product's behavior without approval. Do not copy other brands' proprietary layouts or assets exactly.

## 2. Design principles

- **Content first:** one clear primary task or takeaway per screen.
- **Consistency:** the same kind of information and action uses the same spacing and component behavior throughout the app.
- **Hierarchy:** distinguish primary, secondary, and supporting information with typography, position, whitespace, and restrained emphasis.
- **Alignment:** prefer shared left/right content edges; align numerals and labels consistently.
- **Clarity:** plain copy, readable numbers, sufficient contrast, no decorative clutter.
- **Forgiveness:** users can go back, cancel, undo when practical, and recover from errors.
- **Accessibility and responsiveness:** large text, safe areas, localization, and different widths are first-class requirements.
- **Platform conventions:** familiar iOS and Android behavior unless a deliberately custom interaction is justified.

## 3. Coordinate and sizing conventions

- Specify Flutter dimensions in logical pixels (`dp` for brevity); do not design against physical screen pixels.
- In iOS platform guidance, `pt` means points. Flutter logical pixels and platform points are comparable design units, but test native components and text scaling on actual devices.
- Respect `MediaQuery`/`SafeArea` and system insets. Never manually assume status bar, home indicator, keyboard, or gesture-bar dimensions.
- No hardcoded full-screen heights for scrollable content. Avoid positioning ordinary UI with absolute screen coordinates.

## 4. Spacing tokens — StartAppLab defaults

| Token | Value | Intended use |
|---|---:|---|
| `space.0` | 0 | Flush alignment |
| `space.1` | 4 | Tight icon/label adjustment |
| `space.2` | 8 | Closely related items |
| `space.3` | 12 | Label/value, compact row sections |
| `space.4` | 16 | Standard card padding, item gaps |
| `space.5` | 20 | Standard screen horizontal gutter |
| `space.6` | 24 | Major section spacing |
| `space.8` | 32 | Large content separation |
| `space.10` | 40 | Intentional hero separation |
| `space.12` | 48 | Exceptional layout emphasis |

Use tokens rather than arbitrary numbers. Exceptions require a reason in the widget or design specification.

Flutter uses the existing `DimensionsData` in `app_theme_data.dart`:
- Sibling gaps: `spacingXxs` 4, `spacingXs` 8, `spacingSm` 12, `spacingMd` 16,
  `spacingLg` 24, `spacingXl` 32, `spacingXxl` 40. These names are independent of content type.
- Insets: `paddingMicro` 2 (compact nested badges), `paddingXxs` 4, `paddingXs` 8, `paddingSm` 12, `paddingMd` 16,
  `paddingComfortable` 20, `paddingLg` 24, `paddingXl` 32, `paddingXxl` 40. Prefer `EdgeInsetsData` presets for standard page/card padding.
- Shapes, icons, progress height and glass blur use their named dimensions;
  do not borrow a spacing token because its numeric value happens to match.
- Use an existing token for fixed variants, or define a needed dimension. Avoid
  expressions such as `cornerRadius - 4` and `spacingXxs * 2` to invent variants.
  Actual layout measurements still combine text sizes, inset totals, sibling gaps,
  available width and system safe areas; these calculations are not token variants.

Shared floating sheets use `SheetDragHandle` and the sheet dimensions. Keep one-off
component measurements as clearly named local constants when they have no shared role
(for example, clearance for an onboarding action overlay). Preserve their measured values
when converting literals to tokens.

### Spatial relationships

- Page left and right gutters: **20 dp**, matching across headers, cards, and lists. On compact phones, 16 dp is acceptable when necessary.
- Card content inset: **16 dp default**, **20–24 dp** for prominent hero cards.
- Within a closely related group: **4–8 dp**.
- Between related rows/elements: **8–12 dp**.
- Between repeated cards: **12–16 dp**.
- Between named sections: **24 dp default**, **32 dp** when clearly separate.
- Page heading to introduction: **8–12 dp**; heading to section content: **12–16 dp**.
- Icon and text in a row: **12 dp default**.
- Bottom content: sufficient padding to clear floating navigation and safe area, calculated from actual occupied height.

**Rules:** Do not stack parent and child margins unintentionally. Prefer one owner for each gap (parent spacing *or* child outer margin). Do not insert large gaps simply to vertically center unrelated content. Avoid empty `SizedBox` piles with unexplained values.

## 5. Layout and alignment

- Define a screen-level content container and reuse its gutter.
- Use one primary vertical scroll region per ordinary page; avoid nested conflicting scrollables.
- Use consistent column boundaries and baseline alignment; numeric columns should be easy to scan.
- Prefer intrinsic height, constraints, and flexible layout over fixed-size cards.
- Long names wrap or truncate gracefully without making metrics overlap.
- Group paired labels and values; avoid unrelated controls within the same card.
- Use dividers only when spacing and grouping are insufficient.
- On wider displays/tablets, constrain reading width or use appropriate multi-column layouts rather than stretching cards edge-to-edge.
- Reference screenshots are proportions, not permission to hardcode a specific device size.

## 6. Corner radius and surfaces

| Component | Default radius |
|---|---:|
| Major hero / score card | 24 dp |
| Standard card | 20 dp |
| Compact nested card | 12–16 dp |
| Primary/secondary rectangular button | 16 dp |
| Text input/search | 12–16 dp |
| Bottom sheet top corners | 24 dp |
| Segmented control / pill | Full capsule |
| App icon frame | Platform-appropriate, not forcibly applied to exported master assets |

- Do not use random radii on neighboring components.
- Child content should visually harmonize with parent curves; do not put a 24 dp radius child flush against a 20 dp parent corner.
- Keep borders light and shadows restrained. Do not use elevation as a substitute for grouping.
- Use translucent/glass surfaces only when contrast, legibility, and performance remain acceptable. Follow platform material conventions where available.

## 7. Typography and numeric presentation

Recommended mobile scale, adjustable through the app's actual type system:

| Role | Starting size | Weight |
|---|---:|---|
| Hero score/value | 48–64 sp | Semibold/bold |
| Page title | 28–32 sp | Bold |
| Section heading | 18–20 sp | Semibold |
| Card heading | 16–18 sp | Semibold |
| Main body | 15–16 sp | Regular |
| Supporting text | 13–14 sp | Regular |
| Small metadata | 12–13 sp | Medium/regular |

- Follow platform text scaling rather than forcing an absolute fixed height.
- Keep body line heights comfortable (approximately 1.3–1.5× where appropriate).
- Avoid setting every label to semibold. Use weight to distinguish hierarchy.
- Prefer tabular figures for changing numeric metrics and charts.
- Keep units adjacent to numbers; distinguish estimates and measured values through wording.
- Don't shrink important content to fit; adapt the layout.

## 8. Button and control sizing

- Preferred primary action height: **52 dp**, potentially larger for accessibility.
- Secondary actions: **44–48 dp** visual height, with an accessible tap area.
- Minimum iOS touch target: **44 × 44 pt**; Android: **48 × 48 dp** as a conservative Material-aligned target.
- Tap targets may be larger than the visible icon; neighboring targets must not overlap.
- Prefer clear text labels for consequential or ambiguous icon-only controls.
- Primary actions have a distinct default, pressed, disabled, loading, and error/retry behavior.
- Use at most one dominant primary action in each major task context.
- Disabled controls must convey why action is unavailable when the reason isn't obvious.

## 9. Navigation and interaction patterns

- Use tabs for major parallel destinations; use push navigation for drill-down pages; use sheets for short contextual tasks such as filtering or picking a value.
- Keep navigation placement and terminology stable. Preserve selected tab when returning from a detail page.
- All visible controls must work; no inert placeholder actions. Unimplemented future features should be hidden or plainly marked unavailable without false promises.
- Selection controls update immediately or use an explicit Apply button—do not mix these two models within one sheet without reason.
- Filter sheets should permit cancellation without accidentally applying incomplete changes.
- Use confirmation for destructive irreversible actions. State what is deleted and what is preserved.
- Protect unsaved edits on dismissal where appropriate.
- Support platform back behavior (system gesture and Android Back) and don't trap users in a modal.
- Show progress for asynchronous work and clear completion/failure feedback.

## 10. Interaction states and feedback

For every actionable feature specify:

| State | Required treatment |
|---|---|
| Initial / idle | Clear affordance and expected action |
| Pressed | Immediate visual response |
| Loading | Progress or activity cue; duplicate actions prevented |
| Success | Updated content, confirmation when useful |
| Empty | Specific explanation and useful next step |
| Error | Plain-language message and recovery/retry |
| Disabled / unavailable | Honest reason when non-obvious |
| Permission denied | Explanation and repair path, without coercion |

- Do not show fake progress percentages or add delays only to display sponsorship.
- Prefer inline status for low-stakes actions; reserve dialogs for consequential interruption.
- Success feedback should match significance; avoid gratuitous alerts or haptics for routine navigation.
- Honor reduced-motion preferences where possible; animation should aid spatial continuity or status understanding.
- Typical micro-interactions can be short (roughly 150–250 ms), but do not hardcode timing when native transitions are more suitable.

## 11. Lists, charts, data cards, and forms

### Lists
- Repeated rows share the same left/right inset and consistent minimum tap area.
- Keep row information hierarchy stable: identity → secondary context → primary value.
- Don't mix wildly different row heights without a content reason.
- Use dividers sparingly when cards already separate rows.

### Charts
- Consistent plotting margins across periods.
- Show units and meaningful time intervals; avoid misleading axis scales.
- Provide accessible summaries of values/trends, not color-only identification.
- Labels must not overlap or be clipped when text grows.
- Empty or partial data must be distinguished from zero.

### Forms and sheets
- Field label to input: 8 dp; input to helper/error: 4–8 dp; form field groups: 16–24 dp.
- Keyboard-safe scrolling; maintain visibility of the focused input and primary action.
- Use contextual keyboard types, inline validation when suitable, and clear error corrections.
- Sheets need a descriptive title and clear Cancel/Close and Apply/Done behaviors as appropriate.

## 12. Accessibility

- Meet platform hit-target guidance and test larger text sizes.
- Use semantic labels for icon actions, charts, scores, and decorative-vs-meaningful images.
- Do not rely on color alone. Ensure text and UI contrast satisfy applicable accessibility expectations.
- Support screen readers and logical reading/focus order.
- Accommodate reduced motion and high-contrast/system appearance preferences where practical.
- Test light and dark presentation if both are supported.
- Avoid using tiny fixed fonts to mimic a screenshot.

## 13. Adaptive and localization checklist

Check at least:
- compact phone width and a larger phone
- portrait plus supported orientations
- keyboard displayed
- system text scaling
- long translated strings
- no data, loading, error, and permission-off states
- safe areas and bottom navigation overlap
- platform-specific transition/back behavior
- no clipping or overflow in cards, sheets, labels, or charts

Avoid full-campaign visual regression unless explicitly requested; validate changed screens and their direct navigation paths.

## 14. Assets and visual references

- Review `/docs/reference/` before implementing a screen, if available.
- Treat reference imagery as a guide for composition, not pixel-perfect authority.
- Do not generate new images, logos, illustrations, or replacement artwork unless explicitly requested.
- For missing artwork, use a neutral, easily replaceable placeholder component. Do not crop design reference screenshots into app assets.
- Reuse supplied app assets; preserve aspect ratio and original art.
- If a screen reference conflicts with actual app functionality, preserve correct functionality and note the mismatch.

## 15. Flutter implementation rules

- Extend the existing `ColorScheme`, `ThemeData`, theme extensions, shared spacing, and component architecture documented in `AGENTS.md`; do **not** create a competing design system.
- Define reusable tokens and components; avoid scattershot `EdgeInsets`/`SizedBox` magic numbers.
- Prefer `const` components and immutable UI state where practical.
- Keep feature behavior in Cubits/use cases and widgets focused on rendering and dispatch.
- Use `SafeArea`, `LayoutBuilder`, scroll constraints, and responsive breakpoints appropriately.
- Do not hide clipping/overflow by forcing font sizes or scrolling entire toolbars.
- Validate relevant screens in the existing template, preserving native integration and code-generation conventions.

## 16. Required design audit before declaring a screen done

Review each implemented screen against these criteria:

1. **Page geometry** — identical standard gutters; no unintentional edge alignment differences.
2. **Vertical rhythm** — related spacing 4–12 dp; section spacing 24–32 dp; no accidental stacked margins.
3. **Cards** — consistent insets, corner radii, borders, row gaps.
4. **Typography** — semantic type roles; no inconsistent ad-hoc sizes/weights.
5. **Buttons** — primary action obvious; size, feedback, and tap target correct.
6. **Navigation** — correct back/tab/sheet behavior; safe-area and scroll clearance.
7. **Content states** — loaded, empty, partial, loading, failure, permission denied.
8. **Accessibility** — text scaling, semantics, contrast, hit target.
9. **Responsiveness** — small and large width, no overflow, meaningful density.
10. **Visual references** — composition close to current reference without copying outdated copy/assets.

Report deviations with actual measurements and reasons. Correct inconsistencies in shared components first, then individual screens. Do not change product scope or calculation logic as part of a design-only audit.

## 17. References

Apple primary guidance (principles, not mandatory project spacing values):
- [Apple Human Interface Guidelines — Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [Apple Human Interface Guidelines — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [Apple Human Interface Guidelines — Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- [Apple Human Interface Guidelines — Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
- [Apple Human Interface Guidelines — Feedback](https://developer.apple.com/design/human-interface-guidelines/feedback)
- [Apple Human Interface Guidelines — Design Principles](https://developer.apple.com/design/human-interface-guidelines/design-principles)

On Android, respect Material 3 conventions and native Android accessibility behavior rather than blindly translating every iOS control.

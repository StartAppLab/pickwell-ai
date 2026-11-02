# T04.1 — Guided label capture and transient draft

**PARTIAL for full acceptance; implementation and targeted automated validation
passed.** Previous T03.3 work was reviewed and committed first as `72c2d03`.
No T04.2 authentication or T05 submission/provider work was started.

## Reconciliation and scope

Reviewed root/mobile AGENTS, template README/design guidance and the relevant
PRD v1.4, DESIGN/SPEC v1.2, DATABASE and TASKS sections. Reused the existing catalog
feature, camera picker, Cubit/Bloc, DI, route, theme and localization infrastructure.
No new packages, services, assets, generated artwork or database changes.

The previous capture entry was minimal T03.2 preparation: raw byte arrays lived in
a route-owned Cubit; after two photos the only action retook both. That did not
satisfy SPEC's file-reference draft, independent retakes or OTP-route lifetime.
This task replaces only that directly affected preparation, preserving barcode
lookup, recent products, shared catalog, Supabase, billing and scanner behavior.

## Implemented behavior

- Fixed three-step Barcode ✓ → Nutrition → Ingredients with numbered chips,
  progress, separate label guidance, actual file previews and per-label retakes.
  Review confirms step 3 rather than creating a fourth numbered step. Ingredients
  cannot be captured before nutrition. Platform camera provides its native
  capture/confirmation screen; hardware-specific presentation is not certified.
- Cancellation leaves the previous photo unchanged. Replacing nutrition preserves
  ingredients and vice versa; errors preserve both already accepted captures.
  Duplicate actions during camera work are suppressed.
- Domain `LabelPhoto` holds a private local path, inspected MIME, byte length,
  dimensions and capture timestamp. Raw image bytes are no longer in Cubit state.
  Only the media adapter temporarily reads bounded bytes for validation/copying.
- Existing image_picker requests max width/height 2400, quality 90 and no full
  metadata request. Actual returned files must be nonempty, at most **5 MiB**,
  signature-identified **JPEG/PNG**, decodable, and at most **2400 x 2400**. Declared
  MIME and filename are not authoritative. These are engineering capture bounds,
  not user quota limits or proof of the future provider upload envelope.
- Validated files live only in a uniquely named app-private OS temporary directory
  on supported iOS/Android targets. Camera-picker outputs are deleted on acceptance
  or validation rejection. No gallery originals, unrelated files, preferences,
  cloud history, database rows or image uploads are touched by label capture.
- One app-owned draft retains at most two accepted photo references. Retake uses
  one replacement before deleting the previous file. Failed cleanup blocks further
  capture until retried, preventing unbounded accumulation of replacements.
- Draft expires after **one hour** while the app runs; explicit discard, barcode
  replacement and Cubit disposal delete owned photos. Late camera results after
  discard/closure are deleted rather than restoring a stale draft. One-hour TTL
  is a conservative preparatory engineering choice, not permanent photo retention.
- At startup, previous-process draft directories are swept even if the user only
  visits Home. If initialization fails, cached browsing remains available and
  capture retries/fails closed with a local cleanup message. The OS may evict cache
  earlier. No background execution/deletion is promised while the process is dead;
  next-start cleanup handles abandoned private files.
- Singleton Cubit with `BlocProvider.value` keeps draft ownership above the capture
  route. Returning or replacing routes for the same barcode preserves both file
  references. A different barcode deliberately starts a new draft and cleans old
  files. It does not persist a draft across process death.
- The review screen explicitly states that Email verification/submission is not
  available in this build. There is no fake Analyze action or successful-submission
  message. Optional name/brand editing was deliberately omitted; no identity is
  inferred or treated as authoritative.

## Targeted checks and observed outcomes

Commands from `mobile/` unless noted:

```sh
flutter gen-l10n
dart run build_runner build
flutter test test/catalog
flutter analyze --no-pub
```

**Final results: 42 catalog tests passed; static analysis: no issues.** Generated
localization/DI outputs were updated; unrelated generator churn was removed.
`dart format`, `git diff --check` and a modified/new-file secret-pattern scan pass.

Ten new capture tests verify:

1. Barcode normalization/sequence, independent retakes, cancellation and exactly
   two accepted references.
2. Camera/format/size/dimension errors preserve already accepted photos; discard.
3. Same-barcode route initialization preserves the draft; changed barcode cleans it.
4. Duplicate camera actions and late results after discard.
5. Failed deletion prevents new captures and can recover on retry.
6. Closed Cubit deletes a late camera result without emitting.
7. Camera adapter receives actual resize/compression settings and deletes picker
   output on successful validation and rejection; cancellation/failure handling.
8. One-hour expiry removes photo references and invokes file cleanup.
9. Real local files and Flutter image decoding: signature overrides declared MIME,
   invalid/corrupt/empty/oversize/excess-dimension inputs rejected, deletion restricted
   to owned files and old-session drafts swept.
10. Widget preview/retake controls plus route replacement to a simulated OTP handoff
    and back retains barcode and both original references.

Small synthetic PNGs in tests are decoder fixtures only, not fake food-label or
live AI evidence. The OTP route is an explicit test fixture, not a production
sign-in flow. The actual T04.2 route/gate remains absent.

During development, an initial root-directory localization invocation failed
because it was outside the Flutter project; the correct mobile command succeeded.
The first widget run failed to find an offscreen control and analysis reported
three style issues; scrolling was added to the test and the style issues fixed.
All final checks above passed. No native build, new physical camera trial, OTP
request, hosted API call, deployment or broad regression was performed in this task.

## Security, cost and remaining acceptance

No credentials, tokens, image bytes, private paths or photo metadata are sent to
logs or reports. Files are never added to Git or a backend bucket. Capture performs
no Meta inference, consumes no analysis allowance and activates no billing. Only
ordinary local camera/decoder/cache resources are used. Privacy-sensitive cleanup
errors are surfaced locally rather than authorizing more retained captures.

**Unverified:** readable real nutrition/ingredients captures and retakes on physical
iOS/Android devices after these changes; native resize/permission behavior; actual
production OTP redirect/return once T04.2 exists. Automated route preservation is
verified, but does not establish real Email OTP success. Consequently the real
capture and OTP-return acceptance items remain open. Earlier user-reported scanning
success is not treated as new camera validation for this changed capture flow.

No credentials or reference assets are required to continue capture development.
Approved lemon artwork remains a separate T03.2 gap; this task created no assets.
New capture copy follows existing English fallbacks in non-English locale files;
translation review remains pending.

**Next: T04.2 — Email OTP auth and submission gate.** It should use the existing
app-owned capture draft, preserve it on cancel/auth return, and leave actual secure
inference/publication to T05. Do not claim a submission endpoint exists yet.

## Exact files changed

- `docs/PICKWELL_CAPTURE_DRAFT.md`
- `docs/PICKWELL_TASKS.md`
- `mobile/lib/main.dart`
- `mobile/lib/src/config/injection_container.config.dart`
- `mobile/lib/src/config/router/app_router.dart`
- `mobile/lib/src/features/catalog/data/data_sources/services/scanner_media_service.dart`
- `mobile/lib/src/features/catalog/data/repositories/_repositories.dart`
- `mobile/lib/src/features/catalog/data/repositories/label_capture_repository.dart`
- `mobile/lib/src/features/catalog/domain/entities/_entities.dart`
- `mobile/lib/src/features/catalog/domain/entities/label_photo.dart`
- `mobile/lib/src/features/catalog/domain/repositories/_repositories.dart`
- `mobile/lib/src/features/catalog/domain/repositories/label_capture_repository.dart`
- `mobile/lib/src/features/catalog/domain/use_cases/_use_cases.dart`
- `mobile/lib/src/features/catalog/domain/use_cases/capture_label_use_case.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart`
- `mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/_widgets.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/label_photo_card.dart`
- `mobile/lib/src/localization/l10n/app_ar.arb`
- `mobile/lib/src/localization/l10n/app_de.arb`
- `mobile/lib/src/localization/l10n/app_en.arb`
- `mobile/lib/src/localization/l10n/app_es.arb`
- `mobile/lib/src/localization/l10n/app_fr.arb`
- `mobile/lib/src/localization/l10n/app_hi.arb`
- `mobile/lib/src/localization/l10n/app_it.arb`
- `mobile/lib/src/localization/l10n/app_ja.arb`
- `mobile/lib/src/localization/l10n/app_ko.arb`
- `mobile/lib/src/localization/l10n/app_localizations.dart`
- `mobile/lib/src/localization/l10n/app_localizations_ar.dart`
- `mobile/lib/src/localization/l10n/app_localizations_de.dart`
- `mobile/lib/src/localization/l10n/app_localizations_en.dart`
- `mobile/lib/src/localization/l10n/app_localizations_es.dart`
- `mobile/lib/src/localization/l10n/app_localizations_fr.dart`
- `mobile/lib/src/localization/l10n/app_localizations_hi.dart`
- `mobile/lib/src/localization/l10n/app_localizations_it.dart`
- `mobile/lib/src/localization/l10n/app_localizations_ja.dart`
- `mobile/lib/src/localization/l10n/app_localizations_ko.dart`
- `mobile/lib/src/localization/l10n/app_localizations_pt.dart`
- `mobile/lib/src/localization/l10n/app_localizations_ru.dart`
- `mobile/lib/src/localization/l10n/app_localizations_zh.dart`
- `mobile/lib/src/localization/l10n/app_pt.arb`
- `mobile/lib/src/localization/l10n/app_ru.arb`
- `mobile/lib/src/localization/l10n/app_zh.arb`
- `mobile/test/catalog/label_capture_test.dart`

## User device confirmation — 2026-11-03

The user reports that physical-camera capture works. This is user-observed evidence,
not an additional agent-run device test. Real Email OTP return and submission were
still absent at that point and remain the next task. Independent native compression
measurements and all-device permission coverage are not inferred from this report.

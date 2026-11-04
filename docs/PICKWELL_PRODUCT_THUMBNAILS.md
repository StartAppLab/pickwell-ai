# T07.1A.1 — Product thumbnail storage and display

> **Current rollout:** T07.1C.4 deployed the C.3 private-result and thumbnail schema/handlers. This document preserves its original dated findings; its earlier “not deployed”/version notes are historical. See [current hosted versions, verification and genuine-product/device/cleanup limitations](PICKWELL_HOSTED_PRIVATE_RESULTS_ROLLOUT.md).

Date: 2026-11-04. Baseline: **`c7b1ee6`**, clean working tree at start.
**Status: IMPLEMENTED / locally and Native Runtime verified; NOT deployed.**
No live Meta call, cloud Storage upload, hosted migration or hosted product change.
This is a deliberately conservative **post-publication operator attachment**;
it does not upload front originals or pending-review images from the analysis handler.

## Architecture and exact lifecycle

1. Barcode → existing three-photo capture → Email OTP → Muse → validation → private
   review → exact-evidence approval → owner same-key publication are unchanged.
   `analyze-product` still never uploads images to Storage. Its digest/candidate,
   policy, quota, concurrency and publication transaction are not changed.
2. The operator retains the existing private inspection and **exact processed
   front/nutrition/ingredient files** through publication. Run the new thumbnail
   command after the owner receives ready. No fourth photograph is introduced.
3. The command refuses pending, rejected, cancelled, expired or different reviews.
   It recomputes the original ordered image digest using the existing parser, then
   generates a front-only derivative locally using pinned Pillow. Full-resolution
   evidence is never uploaded by this command.
4. `pickwell_prepare_thumbnail` accepts only a `published` trust review under
   `trust-publication-v1`, the exact barcode/input/candidate digests, and all three
   source hashes. SQL recomputes the original input digest from normalized barcode
   and ordered hashes. The current ready revision must retain this review UUID.
   A thumbnail's existence grants **no approval authority**.
5. A unique immutable product association reserves a private object key
   `v1/<asset UUID>/<JPEG SHA-256>.jpg`. Upload uses service credentials and
   `x-upsert=false` into private `product-thumbnails`. Incomplete uploads remain
   invisible. Concurrent/retried attachment can reuse only the exact same binding
   and bytes; it cannot replace an existing product image.
6. `pickwell_commit_thumbnail` checks the ready/current reviewed association again,
   30-minute upload lease, object existence, MIME and size before media state becomes
   ready. Only then does the published product projection include safe media metadata.
7. Public GET `get-product-thumbnail?id=<asset UUID>&v=<digest>` checks
   `published_thumbnail_assets`, fetches private bytes server-side, verifies hash,
   JPEG signature, size and dimensions, then returns only the derivative. It does
   not call Muse, perform barcode lookup or consume a user's lookup/AI allowance.
8. Flutter displays the metadata-backed image; missing, legacy, loading and failed
   images retain the fixed honest placeholder. Clients never receive Storage keys,
   originals, source digests or server credentials. URLs are constructed from the
   app's configured backend, not arbitrary response URLs.

**Public eligibility:** media ready AND product ready AND trust review published
AND current revision provenance references that same review. Schema validity,
model consistency, client flags and an uploaded file cannot establish eligibility.
Interpretation-only revision refresh preserves this association. A future changed
formulation/new review must not silently reuse the old image; the current immutable
association intentionally requires a separately designed media-revision workflow.

## Processing and resource limits

The only new dependency is **operator/test tooling**: Python >=3.11 with
`Pillow==13.0.0` in an isolated environment. No Flutter package, image model or Edge
native image library was added. Pillow processes bytes already proven to match the
reviewed input. [Pillow's image resource limits](https://pillow.readthedocs.io/en/stable/reference/Image.html)
and [EXIF transpose](https://pillow.readthedocs.io/en/stable/reference/ImageOps.html)
are used without generative processing.

- Input: JPEG/PNG only, <=5 MiB, each dimension <=2400, <=2400² pixels, one frame.
  Decompression-bomb warnings are errors; full decode must succeed.
- EXIF rotation/mirroring normalized; aspect ratio retained, no crop or upscaling.
  Alpha is composited on white. Metadata is stripped; the thumbnail is not a label
  transcription/evidence replacement.
- Output: JPEG, longest edge <=384 pixels, <=65,536 bytes. Bounded quality/size
  reductions, no fabricated packaging. Generator version `front-thumbnail-v1`.
- Generator is a separate process, 15-second timeout, bounded stdout; the Python
  child does not inherit server credentials. Source files are never rewritten.
- A private 0600 temporary snapshot of the verified front bytes prevents source-path changes between hashing and decoding. It and the generated local output are removed in `finally`.
  Existing operator evidence copies must be deleted after review/attachment; the
  script does not silently delete the user's original source files.
- The read endpoint bounds response bytes to 64 KiB, verifies SHA-256 and dimensions,
  uses fixed-origin requests with timeouts/no redirects, and serves `image/jpeg`
  with `nosniff`. Invalid/private entries use no-store 404/503 responses.

## Database, Storage, cleanup and privacy

Migration: **`20261104000300_pickwell_product_thumbnails.sql`**, after the two already
hosted trust migrations. It adds:

- Private JPEG-only, 64 KiB bucket `product-thumbnails`. An existing same-name bucket
  is reusable only when empty and exactly matching the contract; otherwise migration
  fails rather than repurposing someone else's media. Native resets preserve bucket
  rows, so this check supports an empty prior test bucket.
- Restrictive `storage.objects` policy denying all ordinary anon/authenticated
  access to this bucket, even alongside a future broad permissive policy.
- RLS-protected `product_thumbnails`, one row per product, exact review/source/output
  digests, dimensions/size, generator version, upload timestamp and state.
- Service-only hardened prepare/commit/cleanup/forget/orphan functions with empty
  search paths. Ordinary clients cannot mutate or inspect the media table or call
  them. Approved association fields and ready state cannot be overwritten.
- Service-only `published_thumbnail_assets` and an appended optional `thumbnail`
  field on existing `published_products`. Accepted immutable analysis rows are not
  rewritten; public JSON includes only asset id, digest, width and height.

There are **no pending-review thumbnails**, so rejected/cancelled/expired analyses
or failed publication cannot leave a media asset from this feature. A post-publication
attachment can fail independently; the published analysis stays valid and costs no
additional successful-analysis credit.

Incomplete uploads have a 30-minute logical commit deadline. Cleanup claims stale
uploads as `purging` under the same transaction lock as commit, removes objects
through the **Storage API**, then forgets tracking only after metadata confirms
absence. It also lists at most 100 unreferenced object keys older than one hour;
keys use new UUIDs and are never reused. Cleanup is bounded to 100 tracked plus 100
orphan objects per run. Slow/uncertain uploads cannot delete a newly reused path or
cause cleanup to remove a ready asset. Do not delete `storage.objects` directly:
[Supabase Storage metadata is read-only](https://supabase.com/docs/guides/storage/schema/design)
and [physical deletion must use the API](https://supabase.com/docs/guides/storage/management/delete-objects).

**Cleanup operational requirement:** the operator attachment command runs cleanup
before applying an upload. Deploy a protected scheduled operator job (recommended
every 15 minutes) invoking `--cleanup --apply`; repeat batches when necessary. The
migration does not place service credentials in SQL or create a public cleanup
endpoint. Without this job or later operator commands, incomplete/orphan derivatives
remain **private** until cleanup runs; physical deletion is not guaranteed exactly
at logical expiry. This is an explicit rollout prerequisite/limitation, not a claim
that hosted cleanup has been scheduled. Successful available thumbnails are
intentionally retained as reusable product media. Product removal creates a private
orphan eligible for later cleanup; invalidated/different-review products stop being
served by the current eligibility view.

Retention distinctions:

| Data | Retention/access |
| --- | --- |
| Three submitted evidence photographs | Existing request-local server handling and bounded private mobile drafts; never public evidence Storage |
| Operator evidence handoff copies | Existing protected manual workflow, retain only until review/derivative attachment, then delete copies |
| Incomplete derivative upload | Private bucket, <=64 KiB, cannot commit after 30 minutes; cleanup job removes abandoned/orphan objects |
| Published reusable thumbnail | Intentionally retained; public through eligible endpoint, package-only, no EXIF/location metadata |
| Client image cache | Framework's bounded in-memory cache for public derivatives; no new disk archive of evidence or full offline analysis |

Capture privacy copy now explicitly discloses possible public derivative retention
and asks users to avoid faces/personal information. Existing specialized English
fallback copy is synchronized across locales; this task does not claim a new full
translation pass. Owner-managed privacy-policy/store disclosures must reflect this
before rollout. Published nonpersonal package media follows shared catalog retention,
not a user's private capture-draft lifetime. Account removal does not secretly turn
shared package media into personal image history.

## Flutter changes

`ProductRecord` gains optional typed `ProductThumbnail`. Parser tolerates missing or
malformed metadata as no image; a valid cached product does not fail because of
missing optional art. Media URLs use only configured backend origin and id/digest.
No source/candidate hashes, private paths or access tokens go into the widget.

`CatalogWidget` uses the reusable thumbnail widget for Home/local recently scanned
cards: **100×80 (5:4)**, `BoxFit.contain`, no crop/layout jump. Product Details uses
the same component in its existing **80×96** slot. Loading/error/legacy fallback
keeps the theme-gray placeholder, existing semantics and large-text behavior.
Backend-disabled configuration does not fetch a derivative. No navigation redesign,
new recent-items screen, forced quota-consuming refresh or AI call for image fetch.
After operator attachment, already-loaded records need a normal later catalog refresh
or lookup to receive the optional reference; this feature does not poll/debit usage.

## Operator workflow (not executed against hosted production)

Keep the existing server-only URL/service-role credential environment protected.
Install tooling separately; one reproducible local setup is:

```sh
uv venv --python 3.14 .secrets/thumbnail-python
uv pip install --python .secrets/thumbnail-python/bin/python -r supabase/scripts/thumbnail-requirements.txt
```

1. Follow the existing protected review CLI; inspect the actual packaging/barcode
   and exact processed evidence. Keep those private files through owner publication.
2. Owner uses same-key Check request again and receives ready. Never approve merely
   to get a thumbnail, and never use a model/client flag as authorization.
3. With the saved private review inspection and matching three-file manifest:

```sh
node supabase/scripts/attach-product-thumbnail.mjs --review-file .secrets/review.json --evidence-manifest .secrets/evidence.json --python .secrets/thumbnail-python/bin/python
```

This is a local derivative **dry run**, no upload/attachment. After checking privacy
and framing of the packaging, repeat with `--apply`. Only the front derivative is
uploaded; the nutrition/ingredient files are read locally for exact digest matching.
The generator uses a private snapshot of the already hashed front bytes, so a source-path change during generation cannot substitute different imagery. The original inspection must match the published review's immutable bindings; it
may be the pending inspection saved before approval. Published reviews no longer
have candidate payloads, so no fabricated candidate is reconstructed.

```sh
node supabase/scripts/attach-product-thumbnail.mjs --review-file .secrets/review.json --evidence-manifest .secrets/evidence.json --python .secrets/thumbnail-python/bin/python --apply
node supabase/scripts/attach-product-thumbnail.mjs --cleanup --apply
```

Cleanup without `--apply` is nonmutating. There is no upsert/overwrite option. A
failed/uncertain operation is safe to retry with exact evidence; SQL state and
hashes decide whether to reuse the existing asset. Do not delete an uncertain
upload blindly: its commit may have succeeded. Bounded cleanup only claims stale
incomplete assets and unreferenced keys, never ready associations.

**Legacy limitation:** existing ready records without an evidence-bound published
review cannot acquire thumbnails through this command. They retain placeholders.
Do not backfill a fake approval to add art. Likewise, once the exact source evidence
has been deleted, it cannot be reconstructed from a hash or replaced with a different
front image. Reusable media correction/formulation handling is future scoped work.

## Fresh verification and observed results

All provider responses and local publication fixtures were synthetic and clearly
labeled. Native Storage HTTP really uploaded/deleted local JPEG bytes; **none of
these results is evidence of genuine hosted image publication**. No new Meta call.

| Command/suite | Result |
| --- | --- |
| `node .secrets/t071-backend-suite.mjs` | **193 passed, 0 failed/skipped, 16 files**, native-mutating suites reset serially; includes Product Trust/quota/barcode regression |
| Latest selected native `analyze_product.test.mjs` after added wrong-front CLI check | **31 passed**, 0 failures/skips; this overlaps the 193 total |
| Latest `node --test ...product_trust.test.mjs ...product_thumbnail.test.mjs` | **25 passed**, overlaps the backend total; exact binding, publication privacy, refresh association, immutability, cleanup and handler integrity |
| Native SQL `node .secrets/analysis-native-run.mjs reset` then `test` | **6 files / 142 assertions passed**; migration applies on native PostgreSQL 15 without Docker |
| `.secrets/thumbnail-python/bin/python -m unittest discover -s supabase/tests -p 'test_product_thumbnail.py'` | **6 passed**: orientation values 1–8, JPEG/PNG, dimensions/ratio, metadata stripping, no upscale, alpha, bytes/MIME, bomb and animation restrictions |
| `fvm flutter test --no-pub test/catalog` | **152 passed**, including 5 new metadata/URL/widget cases and existing capture/OTP/results/recents tests |
| Targeted Flutter analyzer | **No issues found** |
| Repository secret scanner and `git diff --check` | Passed; no image fixtures, credentials or generated Python environment committed |

Native media assertions use the actual private bucket/Storage API and operator CLI:
changed original front bytes fail; a source-file mutation between hash and decode cannot change the generated derivative; dry run creates no media record; upload is private
before commit; committed endpoint bytes/dimensions/hash match; guest catalog obtains
only safe metadata; guest and verified direct Storage reads/writes fail; MIME/size
restrictions apply; repeated attachment reuses one association; no extra mocked
provider call; physical local test assets deleted through Storage API. SQL fixtures
also exercise cancelled/rejected/expired candidates, immutable revisions, concurrent
commit, duplicate code/current-record protection and interpretation refresh.

Initial findings fixed before final verification: JPEG decoders do not always expose
`n_frames` (default one frame safely); generated-column values are excluded from the
BEFORE-update immutability comparison; native reset preserves bucket rows (strict
empty matching-bucket reuse); the analysis test fetcher intentionally rejects Storage
and must not be reused for the separate read-only media endpoint. Capture privacy
copy was shortened to preserve the first capture action's screen placement. No
publication/auth/quota safeguard was weakened to make a test pass.

## Deployment steps and remaining risks

**Do not deploy automatically.** Hosted project remains on the previously verified
T07.1D.1 source and two trust migrations; this local feature is not active there.
With explicit owner authorization:

1. Confirm the private bucket is absent or empty/matching, preserve existing data,
   dry-run and apply only `20261104000300_pickwell_product_thumbnails.sql`.
2. Deploy `get-product-thumbnail` with `verify_jwt=false` and its server-only
   published-eligibility checks. Deploy updated shared projection dependencies for
   `get-product`, `analyze-product` and status function as appropriate. Apply SQL
   before handlers selecting the new projection field; no thumbnail-driven quota
   or inference-limit change is required.
3. Provision the protected operator Python/Pillow environment and scheduled bounded
   cleanup command. Verify Storage egress/Edge quotas, cleanup receipts and disclosure
   text. Do not put service credentials into the mobile app, browser or Cron SQL.
4. Rebuild the client, then test one genuine operator-approved product with exact
   evidence, attachment, guest image retrieval and device orientation/layout. Those
   hosted/device/real-image checks remain **unverified**. Native generated pixels are
   not real package-accuracy evidence.

Public image responses use 5-minute HTTP caching and Flutter's bounded image memory
cache. Invalidation stops new uncached eligibility reads; already downloaded/cached
public images cannot be guaranteed instantly revoked. Thumbnail traffic adds normal
Supabase Storage/Edge egress cost but no Meta tokens. The endpoint is public media,
not a hidden quota-free product-analysis/catalog endpoint. Operator/service credentials
remain trusted and can be abused if compromised. Inspect front framing for personal
content; EXIF removal does not remove faces printed in pixels. The derivative matcher
is not independent identity verification. Physical orphan cleanup depends on the
protected scheduled runner; until then stale images remain private.

**T07.1A UI polish may begin locally using these tested image slots.** Real-photo
fidelity and hosted readiness still require authorized rollout and honest eligible
media; legacy placeholders remain legitimate. No dashboard, fourth photo, model,
Comparison, purchases or unrelated UI changes were introduced. No hosted deployment is claimed; baseline `c7b1ee6` is preserved in Git.
The thumbnail implementation and identity follow-up are recorded together in commit history.

## Exact changed-file manifest

Includes generated locale accessors for the two updated privacy/guidance strings; no image assets, secrets, venv or hosted deployment receipts.

- `docs/PICKWELL_AGENT_PROMPTS.md`
- `docs/PICKWELL_DATABASE.md`
- `docs/PICKWELL_DESIGN.md`
- `docs/PICKWELL_PRD.md`
- `docs/PICKWELL_PRODUCT_THUMBNAILS.md`
- `docs/PICKWELL_PRODUCT_TRUST.md`
- `docs/PICKWELL_SPEC.md`
- `docs/PICKWELL_TASKS.md`
- `mobile/lib/src/features/catalog/data/models/catalog_model.dart`
- `mobile/lib/src/features/catalog/domain/entities/_entities.dart`
- `mobile/lib/src/features/catalog/domain/entities/catalog_entity.dart`
- `mobile/lib/src/features/catalog/domain/entities/product_thumbnail.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/catalog_widget.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_card_thumbnail.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_result_content.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_thumbnail_placeholder.dart`
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
- `mobile/test/catalog/thumbnail_display_test.dart`
- `supabase/README.md`
- `supabase/config.toml`
- `supabase/functions/_shared/catalog_boundary.mjs`
- `supabase/functions/_shared/product_thumbnail.mjs`
- `supabase/functions/get-product-thumbnail/index.ts`
- `supabase/migrations/20261104000300_pickwell_product_thumbnails.sql`
- `supabase/scripts/attach-product-thumbnail.mjs`
- `supabase/scripts/make-thumbnail.py`
- `supabase/scripts/thumbnail-requirements.txt`
- `supabase/tests/analyze_product.test.mjs`
- `supabase/tests/catalog_schema.test.mjs`
- `supabase/tests/product_thumbnail.test.mjs`
- `supabase/tests/product_trust.test.mjs`
- `supabase/tests/test_product_thumbnail.py`

## Follow-up — Product identity and card presentation

Implemented without restarting the thumbnail feature. One pure display formatter
uses canonical published name/brand, with existing structured front observations as
fallback. Subtitle joins only available `identity.front.variant` and
`identity.front.net_quantity` using ` · `; no serving-size substitution, raw-text
guessing, extra API/AI call or invented missing data. One shared header presents
brand → name → subtitle on Home/local recent cards and Product Details. Details
keeps its selectable barcode; compact cards omit it. Existing thumbnail references,
privacy, upload/review/evidence bindings, placeholders, navigation and lookup
semantics are unchanged. Long text is bounded on cards and wraps in Details.

Fresh follow-up checks: `fvm flutter test --no-pub test/catalog` **159 passed**,
including seven new formatter/hierarchy/missing/long-text cases and thumbnail/
barcode/capture/OTP/recents regression. `fvm flutter analyze --no-pub
lib/src/features/catalog test/catalog`: **no issues**. No backend changes, backend
retest claim, deployment or new model invocation. Pre-existing thumbnail work is preserved.

Files touched by this follow-up (separate from the earlier feature manifest):

- `mobile/lib/src/features/catalog/domain/entities/product_display_identity.dart`
- `mobile/lib/src/features/catalog/domain/entities/_entities.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_identity_header.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/_widgets.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/catalog_widget.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/product_result_content.dart`
- `mobile/test/catalog/product_identity_presentation_test.dart`
- `mobile/test/catalog/home_product_card_test.dart`
- `mobile/test/catalog/product_results_test.dart`
- `docs/PICKWELL_DESIGN.md`
- `docs/PICKWELL_PRODUCT_THUMBNAILS.md`

## T07.1C.3 local follow-up (not deployed)

[Immediate private results](PICKWELL_PRIVATE_RESULTS.md) now separate successful
owner analysis from shared publication. A private-ready result consumes one
credit; cancellation/rejection/review expiry does not refund it, and publication
never double charges. Private payload survives review closure up to 24h, with
owner-bound local draft references/preview. This supersedes earlier hidden-result
and refund wording for the new local path only. Shared thumbnail eligibility,
exact processed evidence, review bindings and immutable canonical data remain
unchanged. No extra public image source, automatic approval or hosted rollout.

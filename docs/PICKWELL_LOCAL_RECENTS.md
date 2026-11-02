# T03.3 — Local recent-products index and search

2026-11-02. **Implementation and targeted automated validation passed; real-product
on-device restart acceptance remains unverified.** Prior hosted lookup evidence
was committed first as `be82656`. T03.3 work is separate and not yet committed.

## Existing work reused and differences resolved

Reviewed root/mobile instructions, template README/design guidance and relevant
PRD v1.4, DESIGN/SPEC v1.2, DATABASE and TASKS sections. Reused the existing catalog
repository, Cubits, SharedPreferences-backed DataStorage, 30-entry reference-only
index, DTO validator, Home cards, nested details and guest routes. No scaffold,
package, database migration, new service, image generation or auth change.

T03.2 already persisted unique ready barcode references and UTC opening times,
serialized concurrent writes, bounded entries to 30 and kept full products in
process memory only. However, Home only read references after restart; it never
resolved product details, so name/brand search had no restored data. Food changed
its selected visual state without changing the list. Those are corrected here.

## Resulting behavior

- Home resolves missing product details through existing `get-product`, newest
  references first. No alternate quota-exempt read endpoint or direct DB read.
- Resolution preserves persisted timestamps/order and creates no new history for
  misses or processing/denied/error responses. Only explicitly opened ready
  products enter/update the index through the existing repository path.
- Existing loaded products are reused in memory; tapping a loaded card makes no
  backend/Meta call. New scans still perform fresh admitted lookups.
- Normal remote lookups may consume signed-in barcode allowance. There are at most
  30 references; sequential refresh stops on the first transport/server error or
  rate/quota denial. Remaining unresolved rows stay honest placeholders. This can
  leave some references unresolved until a later refresh/window reset.
- Transport retries reuse the same in-memory refresh operation key. Expired or
  conflicting receipts allow a new key on a later attempt. No session/request
  token or additional metadata is persisted in the recent index.
- Home shows an initial loading indicator. Pull down to retry unresolved rows;
  concurrent Home loads share a single pending resolution instead of duplicating
  requests. Already loaded records are reused until process restart, not forced
  re-fetched by the gesture. A closed Cubit ignores late results.
- Search expands from the existing header icon, trims/case-folds the query, and
  filters loaded name/brand and indexed barcode locally. Newest sort is explicit.
- The current published catalog is food-only and has no category field. Food shows
  resolved published food records; All also includes unresolved references whose
  category is unknown. No cosmetics category/data or dead Chat tab was added.
- Unresolved cards show the barcode and connection/retry message, with no fabricated
  title/brand/photo. Available cards also retain the labeled missing-photo fallback
  because the existing public product contract contains no authorized photo URL.
- No full analysis, personal ID, label photo or credentials are persisted. No cloud
  history/sync or offline nutrition availability is claimed. Empty Home remains
  honest and encourages scanning without fabricated product entries.

## Targeted validation and observed results

From `mobile/`:

```sh
flutter test test/catalog
flutter analyze --no-pub
```

Final focused run: **32 tests passed**, including 8 new recent-product unit tests
and a new unavailable-card/filter/refresh widget test. Static analysis: **no issues
found**. `dart format` and `git diff --check` passed. An initial test invocation from
the repository root failed because that directory has no pubspec; it was rerun
successfully from `mobile/`. No build/device/provider success is inferred from it.

Coverage includes:

- SharedPreferences-backed storage with fresh repository/source instances:
  deduplication, newest ordering, restored ready summaries and unchanged opening
  times during hydration; only barcode/opened_at fields persisted.
- Existing 35-concurrent-write bound/dedup test and failed optional-save behavior.
- No remote calls on loaded-card reopening, repeated loaded Home reads or search.
- Offline failure stops fan-out, retains unavailable references and recovers online
  with the same operation key; quota/rate/server errors stop further requests.
- Miss and processing never become published product data or new recent entries.
- Name/brand/barcode search, case/whitespace handling, no matches and Food/All.
- Missing-photo semantics, unavailable text, pull-refresh recovery, empty state,
  independent far-right Scan action, guest routes and nested dock hiding.
- Compact Home (320 x 640), large text and light/dark layouts have no widget errors.
- Concurrent load suppression and safe completion after Cubit closure.

Tests use clearly synthetic, in-process ready responses; they do not constitute
new live product extraction or a physical app restart. Previous hosted ready/miss
checks remain documented separately in PICKWELL_PRODUCT_LOOKUP.md.

## Files changed

- `mobile/lib/src/features/catalog/data/repositories/catalog_repository.dart`
- `mobile/lib/src/features/catalog/domain/entities/catalog_entity.dart`
- `mobile/lib/src/features/catalog/presentation/blocs/catalog/catalog_cubit.dart`
- `mobile/lib/src/features/catalog/presentation/widgets/catalog_widget.dart`
- `mobile/lib/src/features/home/presentation/blocs/home/home_cubit.dart`
- `mobile/lib/src/features/home/presentation/views/home_view.dart`
- `mobile/test/catalog/recent_products_test.dart`
- `mobile/test/catalog/home_widget_test.dart`
- This report and `docs/PICKWELL_TASKS.md`.

## Remaining acceptance and next dependency

T03.3 is **PARTIAL for end-to-end acceptance**: a real validated food product must
be opened and observed after an actual app restart. The hosted catalog currently
contains only the explicitly synthetic demo, and no physical restart was performed
in this task. The relaunch/card criterion stays unchecked rather than treating
fixture tests as real-product evidence. No new credentials are required for the
existing public lookup. Approved lemon artwork remains missing from T03.2.

No Supabase writes/deployment, real Meta calls, provider spend, billing enablement
or full-project regression occurred in this task. Network refresh in normal app
use consumes ordinary Edge/DB resources and must respect the existing quota and
shared guest throttle. Automatic hosted retention remains a separate prerequisite.

Next development task: **T04.1 — Guided three-step capture**; T04.2 OTP and T05
submission/validation/publication follow. They were not started here. Final
real-product restart evidence depends on a correctly published real record.

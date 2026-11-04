# T07.1C.3 — Immediate private results and safe shared publication

> **Current rollout:** T07.1C.4 deployed the C.3 private-result and thumbnail schema/handlers. This document preserves its original dated findings; its earlier “not deployed”/version notes are historical. See [current hosted versions, verification and genuine-product/device/cleanup limitations](PICKWELL_HOSTED_PRIVATE_RESULTS_ROLLOUT.md).

2026-11-04. Source baseline: `befc320`. This implementation is a working-tree
change on that baseline, **not a deployed release**. The hosted publication gate
and testing configuration have not been changed. No live Muse call or physical
device test was performed for this change.

## Discovered behavior

The previous handler staged a validated candidate and returned `review_required`
without its facts. Its reserved successful-analysis slot was consumed only on
publication; rejection/cancellation/30-minute candidate expiry released it. A
pending candidate occupied the active barcode job, preventing another contributor
from obtaining their own private analysis. Returning that candidate without
changing settlement would permit free successful analyses through cancellation.

## Implemented contract

1. The existing verified-email Auth check, image bounds, ordered three-image
   digest, provider claim, model call and strict pure validator remain in place.
2. The server revalidates the immutable staged handoff before the new
   `pickwell_deliver_private_analysis` transaction. It stores a non-image private
   projection, consumes the reserved successful-analysis credit, marks private
   delivery, and opens the existing bound publication review atomically. A lost
   HTTP acknowledgement is recoverable using the same request key without another
   provider call or credit.
3. The response is `private_ready`, including owner job/request references, a
   bounded result expiry, publication status, sanitized product facts and optional
   *separate* canonical product. It contains no email, raw photos, operator secret,
   review digest or client publication authority.
4. Flutter routes to `/analysis/:jobId`, reusing ProductResultContent, identity,
   supported explanations, evidence and unknown values. It displays **Analysis
   ready** and **This product hasn't been approved for the shared catalog yet.**
   Private results never enter CatalogLocalSource's shared products or recents.
5. `get-private-analysis` accepts only `job_id`. It verifies the JWT against Auth,
   persistent confirmed non-anonymous email, owner identity and normal request
   throttle. All result RPCs/tables are server-only. A different owner gets the
   same `not_found` as an unknown job. Responses use `Cache-Control: no-store`.
6. An explicit owner **Check shared publication** read may finish an already
   operator-approved publication through the existing revalidator/publisher; it
   never calls Muse. Ordinary result reads do not grant approval. Canonical
   transition is explicit; it never merges another contributor's private data.

## Publication, concurrency and accounting

- The original barcode/input/candidate digest and `trust-publication-v1` approval
  requirements, immutable canonical revision and database publication boundary
  remain mandatory. No new client/model approval or service publication bypass.
- Provider inference on one barcode is still serialized while inflight/unknown.
  A private-ready job no longer monopolizes the active inference barcode index.
  Guest lookup returns `not_found` when only completed private contributions exist;
  it does not strand another user on an operator-review processing screen.
  A waiting contributor may retry the **same image-bound key** to acquire their
  own reservation. Two owners may obtain different private results. They never
  receive each other's job/data. Parallel exact approvals still yield one
  canonical revision; the losing private result remains separate and can link to
  the existing shared record. Existing ready records are never overwritten.
- **One successful private result = one successful-analysis credit**, charged
  when made durably available, even if the HTTP response is lost. Retries are
  idempotent. Later publication adds zero credits. Rejection, cancellation,
  review expiry and a competing canonical publication do not refund a successful
  private result. This supersedes the earlier review-only refund semantics.
- Failed/invalid/retake inference still releases reserved successful allowance;
  provider spending/unknown outcomes stay protected by the existing ledger.
  A later corrupted review candidate cannot replace the immutable valid private
  result or refund its already consumed credit. Legacy review-only jobs that
  have not been privately delivered retain their previous settlement path.
- Settlement uses the reservation's UTC day. Mutable plan limits, UTC reset,
  standard 30/3 and hosted testing 1000/100 profiles, spend ceilings, attempt/rate
  and concurrency caps, and disabled billing are unchanged. There are no ordinary
  lookup or private result-read model calls.

## Retention and local preview

`private_analysis_results` is immutable, RLS-protected and limited to 65,536 bytes
per job with a 24-hour lifetime. Only the owner Edge Function can project it;
anon/authenticated database roles cannot read or mutate it. It contains normalized
facts, not images or a permanent personal history. Account deletion cascades.
The existing `pickwell_prune_analysis` maintenance RPC deletes expired results;
reads/admission also prune and always deny expired payloads. Scheduled maintenance
must remain active for physical deletion during idle periods. Job/accounting
metadata and published audit evidence follow their existing retention policies.

The existing bounded five-product / 24-hour device-private draft keeps temporary
photos and only an owner/job/result-expiry reference (manifest v3), not a stored
full private/offline analysis. Legacy v1/v2 drafts still load. The original local
capture deadline is not extended by successful analysis. Review rejection,
cancellation or expiry does not delete these photos/result before that deadline.
Explicit delete, draft expiry and existing cleanup dispose of photos. This is the
user-authorized short recovery/evidence-handoff exception, not permanent label
photo retention. Expired server results do not regenerate on same-key retry.

A front preview is read only from the matching owner/job local draft after the
server has authorized the result; otherwise the existing honest placeholder is
used. It is never uploaded as shared media. Account changes clear visible results,
ignore stale asynchronous responses and hide other owners' completed drafts.
Public thumbnails still require the separate post-publication operator workflow
and exact evidence bindings from T07.1A.1. No thumbnail deployment is implied.

## Verification

Database tests were written and executed **before** changing accounting: the first
run failed because the private-delivery RPC did not exist. After implementation:

- `node --test supabase/tests/private_analysis.test.mjs`: 9 passing (parent + 8
  cases), real isolated PostgreSQL via PGlite: charge/replay, owner/role denial,
  gate, publication without double charge, rejection/cancellation/expiry,
  contradictory private contributions/one canonical, cancellation quota abuse
  and invalid handoff/failure release.
- Native Runtime CLI 2.122.0 on disposable loopback Supabase: **34 passing**
  `analyze_product.test.mjs` tests, actual Auth/REST/PostgreSQL and mocked Muse.
  Includes two owners, parallel conflicting approvals, first-publication wins,
  private owner fetch/canonical transition, immutable/expired private payload,
  stale approvals, altered digest, refunds, lost acknowledgements, client grant
  denial, preserved validation/interpretation/thumbnail and cache-no-Meta paths.
- Clean native reset and `supabase test db`: **6 files / 142 SQL assertions pass**.
  An initial run after orchestration used its populated fixture database and
  failed seed-only count/plan assertions; resetting the disposable DB resolved
  that test-isolation issue. No hosted database was reset.
- Backend suite initially found old mock assumptions that successful output must
  remain hidden until publication. Those mocks and accounting assertions were
  updated without removing publication-negative checks. **Final backend suite: 18 files / 213 passing, zero failures or skips**,
  including the 34 native orchestration cases above.
- Flutter catalog suite: **167 passing**. Affected private/submission/
  pending-draft tests: **39 passing**. Covers preliminary notice/content,
  rejected/cancelled/expired review, account isolation, bounded reference restore,
  legacy draft compatibility, shared cache exclusion and existing capture/results.
- Flutter analyzer: **no issues**. Thumbnail Python tests: **6 passing**.
- `python3 tool/check_environment.py` from `mobile`: known-secret pattern scan
  passes; ignored credentials/history are outside this scanner's guarantee.
- No fresh OTP delivery, real camera, live Muse, hosted new endpoint or deployed
  migration was tested. Earlier hosted/device evidence is not claimed for this
  change. One transient-refresh test initially asserted an offscreen lazy-list header;
  scrolling to that header corrected the test, and the recovery case passes.
  Device layout, restart/private-preview and fresh sign-in handoff still
  require verification after authorized rollout.

## Deployment requirements and release risk

**Do not record the changed flow against the current cloud deployment yet.**
An explicit deployment authorization is required. This change has not been
committed automatically.

1. Preserve the tested source and review forward migration compatibility. Apply
   outstanding migrations in dependency order: thumbnail `20261104000300` (also
   still local) then private results `20261104000400`. Never reset hosted tables.
2. Coordinate a short inference pause through the existing operator control;
   leave guest cache reads running. Avoid a mixed old/new settlement deployment.
   Do not alter plan allowances or billing.
3. Deploy the matching `analyze-product`, `cancel-analysis-review` and new
   `get-private-analysis` functions with shared dependencies. Keep existing
   get-product/status/thumbnail functions compatible. The new endpoint needs the
   existing protected Supabase/normal network-hash settings; **no new secret or
   public inference endpoint**. No Meta key is needed by private result reads.
4. Verify hosted role/owner denials, exact approval and cancellation/expiry,
   maintained pruning, quota snapshots and legacy public cache before resuming
   inference. Rebuild/install the matching Flutter client only after backend is
   ready. An old client safely retains its draft on an unknown new response, but
   does not implement immediate private results.
5. Verify one real controlled matching three-photo contribution, private result,
   exact-evidence operator decision and guest rescan without another Muse call.
   Never substitute different images to manufacture an approval.

Regression risk is **material**: successful-credit timing and active-job exclusion
changed. Native tests prove the local database boundary; they do not prove the
hosted migration or genuine model/device behavior. Operator review still requires
private access to exact processed evidence. Without action, shared review expires
at its existing deadline; private access continues only for its bounded lifetime.
The local queue remains five unique barcodes per device, not multiple account
histories for one barcode on a shared phone; completed private drafts belonging
to another signed-in identity are hidden.
This is locally implemented/tested, **not yet safe to claim as a deployed demo**.

## Changed-file manifest

- Backend: `supabase/config.toml`; migration `20261104000400_pickwell_private_analysis.sql`;
  shared `analysis_publication.mjs`, `analyze_product.mjs`, `cancel_analysis_review.mjs`,
  new `private_analysis.mjs`; new `get-private-analysis/index.ts`.
- Backend tests: `private_analysis.test.mjs`, `private_analysis_endpoint.test.mjs`,
  `analyze_product.test.mjs`, `front_packaging.test.mjs`, `trust_services.test.mjs`.
- Flutter: router; analysis API/model/repository/entity/use-case contracts;
  pending draft entity/repository/Cubit; submission Cubit/capture listener;
  pending card; shared result-content thumbnail slot; new private result view;
  English ARB and generated localization files (fallback English in other locales).
- Flutter tests: analysis fixtures/submission adapters; new private-analysis tests.
- Documentation: this report, PRD, DESIGN, SPEC, DATABASE, TASKS, AGENT_PROMPTS,
  product trust and thumbnail reports; mobile instructions and Supabase README.

### Exact modified/new paths

```text
docs/PICKWELL_AGENT_PROMPTS.md
docs/PICKWELL_DATABASE.md
docs/PICKWELL_DESIGN.md
docs/PICKWELL_PRD.md
docs/PICKWELL_PRIVATE_RESULTS.md
docs/PICKWELL_PRODUCT_THUMBNAILS.md
docs/PICKWELL_PRODUCT_TRUST.md
docs/PICKWELL_SPEC.md
docs/PICKWELL_TASKS.md
mobile/AGENTS.md
mobile/lib/src/config/router/app_router.dart
mobile/lib/src/features/catalog/data/data_sources/services/analysis_api_service.dart
mobile/lib/src/features/catalog/data/models/analysis_model.dart
mobile/lib/src/features/catalog/data/repositories/analysis_repository.dart
mobile/lib/src/features/catalog/data/repositories/pending_capture_repository.dart
mobile/lib/src/features/catalog/domain/entities/analysis_entity.dart
mobile/lib/src/features/catalog/domain/entities/pending_capture.dart
mobile/lib/src/features/catalog/domain/repositories/analysis_repository.dart
mobile/lib/src/features/catalog/domain/use_cases/analyze_product_use_case.dart
mobile/lib/src/features/catalog/presentation/blocs/catalog/analysis_submission_cubit.dart
mobile/lib/src/features/catalog/presentation/blocs/catalog/label_capture_cubit.dart
mobile/lib/src/features/catalog/presentation/views/capture_entry_view.dart
mobile/lib/src/features/catalog/presentation/views/private_analysis_view.dart
mobile/lib/src/features/catalog/presentation/widgets/pending_capture_card.dart
mobile/lib/src/features/catalog/presentation/widgets/product_result_content.dart
mobile/lib/src/localization/l10n/app_en.arb
mobile/lib/src/localization/l10n/app_localizations.dart
mobile/lib/src/localization/l10n/app_localizations_ar.dart
mobile/lib/src/localization/l10n/app_localizations_de.dart
mobile/lib/src/localization/l10n/app_localizations_en.dart
mobile/lib/src/localization/l10n/app_localizations_es.dart
mobile/lib/src/localization/l10n/app_localizations_fr.dart
mobile/lib/src/localization/l10n/app_localizations_hi.dart
mobile/lib/src/localization/l10n/app_localizations_it.dart
mobile/lib/src/localization/l10n/app_localizations_ja.dart
mobile/lib/src/localization/l10n/app_localizations_ko.dart
mobile/lib/src/localization/l10n/app_localizations_pt.dart
mobile/lib/src/localization/l10n/app_localizations_ru.dart
mobile/lib/src/localization/l10n/app_localizations_zh.dart
mobile/test/catalog/analysis_fixtures.dart
mobile/test/catalog/analysis_submission_test.dart
mobile/test/catalog/pending_capture_test.dart
mobile/test/catalog/private_analysis_test.dart
supabase/README.md
supabase/config.toml
supabase/functions/_shared/analysis_publication.mjs
supabase/functions/_shared/analyze_product.mjs
supabase/functions/_shared/cancel_analysis_review.mjs
supabase/functions/_shared/private_analysis.mjs
supabase/functions/get-private-analysis/index.ts
supabase/migrations/20261104000400_pickwell_private_analysis.sql
supabase/tests/analyze_product.test.mjs
supabase/tests/front_packaging.test.mjs
supabase/tests/private_analysis.test.mjs
supabase/tests/private_analysis_endpoint.test.mjs
supabase/tests/trust_services.test.mjs
```

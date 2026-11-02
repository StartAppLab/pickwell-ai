# T02.4 — Operational events and cost ledger

2026-11-02. **COMPLETE for scoped backend implementation and local validation.**
T02.3 was reviewed and committed first as `de23e8a`. No hosted migration,
public endpoint, live Meta inference, billing activation or Flutter change occurred.

## Scope and reconciliation

Read root instruction pointers, backend README, current migrations/shared adapters,
PRD v1.4, DESIGN/SPEC v1.2, DATABASE v1.0 and TASKS v1.1. Reuse T02.3's mandatory
provider admission ledger and atomic quota operations. No new analytics service,
SDK, auth provider, purchase flow or UI is introduced. Public lookup and production
analysis routing remain T03.1/T05.1; T02.2's deferred public route is not closed here.

The blueprint proposed 30-day operational detail before aggregation; this task
implements that policy, with two-day closed network-hash scrubbing and 365-day
nonpersonal provider aggregates. Unresolved provider work and successful results
still awaiting publication are explicit retention exceptions requiring reconciliation.

## Event storage and instrumentation

`20261102000400_pickwell_operational_events.sql` adds RLS-protected
`operational_events` with exactly these fields: UUID id, event type, opaque source
UUID, optional bounded metric/duration and database timestamp. No arbitrary JSON,
barcode, user ID, email, IP, header, raw provider error, image or token field exists.
Source IDs are backend operation/reservation correlations, never user IDs. Only
server roles may record/read events. Deduplication uses `(event_type, source_id)`;
transport retries do not inflate the same logical event.

| Event | Recorded from |
| --- | --- |
| `barcode_scanned` | Creation of a signed-in lookup reservation; future guest route uses the server lookup helper after a definitive response. This is a backend lookup attempt, not proof of a camera scan. |
| `product_cache_hit` | Ready lookup settlement, analysis reservation released for a cache hit, or cache short circuit in the quota adapter. |
| `product_not_found` | Definitive miss settlement; future guest helper supports the same event. |
| `capture_completed` | Supported explicitly, not automatically emitted: no capture-submission route exists yet. Only send after the backend has accepted both required images. |
| `analysis_started` | Atomic provider admission; means authorization to call, not proof of a billable network request. |
| `analysis_completed` | Committed successful publication/credit finalization. |
| `analysis_failed` | Known provider failure or failed analysis release; same reservation deduplicates both sources. Includes failures before a provider call. |
| `analysis_retake_required` | Committed retake/release. |
| `quota_exceeded` | Quota adapter receives a denied decision; server-generated operation key deduplicates retries. |

Database AFTER triggers derive signed-in lifecycle events from committed state.
A rolled-back publication cannot leave a success event. Cache/denial short circuits
have no reservation write, so the shared quota adapter emits those optional events.
Direct administrative calls to quota SQL bypass that adapter's short-circuit events;
events are not the authoritative quota ledger.

`operational_events.mjs` provides a bounded, server-only event writer and a guest-
capable lookup helper for T03.1. It allowlists fields, discards extra context and
returns false on invalid input, HTTP failure, timeout or network error without logging
raw errors. It does not expose a client analytics endpoint. Guest route execution
and hardware/capture telemetry remain unverified until those later routes exist.

## Accounting and safe failures

The existing `ai_usage` retains model, nullable tokens, nullable reported cost,
duration, result state, day and conservative held budget. This migration adds:

- Explicit provider `meta` and separate nullable `estimated_cost_usd`.
- `pickwell_record_provider_metrics`: mandatory transactional result/estimate
  recording. Estimates are trusted server calculations using verified pricing,
  not fields inferred from model prose. Negative/nonfinite estimates are rejected;
  recorded estimates cannot be lowered by replay.
- A mandatory ledger trigger raises the spend hold when an estimate exceeds it;
  the hold never decreases. Existing T02.3 budget admission therefore accounts for
  a higher estimate without changing or bypassing its quota algorithm.
- Restricted `daily_provider_costs` and `daily_operational_counts` views, both
  invoker-security. They expose aggregate counts only, not source/account/IP IDs.

The quota adapter's `recordProvider` keeps its existing arguments and adds an
optional last estimate argument. Reported cost (`cost`) and calculated estimate
(`estimate`) are separate; pass null when unknown. Existing `actual_cost_usd` is the
legacy storage field for caller-supplied trusted reported cost, not verified invoice
reconciliation. No price is guessed and no live token/cost measurement is claimed.

`daily_provider_costs` separates admitted/succeeded/failed/inflight/unknown work,
reported vs estimated costs, and conservative accounted spend. Report counts for
input/output tokens, costs, estimates and durations identify missing observations;
a zero aggregate with zero reports means unknown, not free inference or zero tokens.
Provider failure counts differ from failed-analysis counts because some failures
happen before any provider call, and successful extraction may still need a retake.

Optional event writes run in caught subtransactions with a 100 ms lock timeout.
They cannot roll back a valid quota charge or turn a quota denial into an allowance.
The optional HTTP writer has a 500 ms timeout. Mandatory provider admission/result/
cost operations remain fail closed: they propagate errors and preserve unresolved
holds. No success fallback, free retry or analytics-based quota source was added.

## Retention and deployment

`pickwell_prune_telemetry()` is a server-only, atomic maintenance operation:

- Delete events older than 30 days.
- Scrub closed provider IP hashes after two days; clear expired lookup throttle rows.
- Move closed provider details older than 30 days into `provider_usage_daily`, then
  remove the details in the same transaction. Retain nonpersonal daily aggregates
  for 365 days; repeated pruning cannot double-count them.
- Preserve all current-UTC-day budget evidence, unresolved provider work and results
  whose reservation/job is still active or awaiting publication. Account deletion
  still detaches private references without erasing provider spending/holds.

If `pg_cron` is already installed, the migration registers the named daily
`pickwell-telemetry-retention` job (`17 0 * * *`, in Cron's configured timezone).
It does not silently install an extension. **The local native stack has no Cron,
so scheduled invocation was not exercised.** The maintenance function itself was
executed and verified against real native PostgreSQL with aged synthetic fixtures.

Before hosted use, enable Supabase Cron and verify the named job exists and runs.
If Cron is enabled after applying the migration, register it once as the privileged
migration/maintenance role:

```sql
select cron.schedule('pickwell-telemetry-retention', '17 0 * * *',
  'select public.pickwell_prune_telemetry()');
```

Use [Supabase's Cron setup and monitoring](https://supabase.com/docs/guides/cron/quickstart).
Without a running scheduler, this policy is available but automatic retention is
not enforced. Monitor unresolved-call exceptions rather than purging them to recover
capacity. Final privacy copy must describe these retention rules/exceptions.

## Validation actually executed

Existing isolated native workflow: CLI 2.122.0, PostgreSQL 15.19, loopback-only
connection guard and TLS disabled only locally. Docker was not used. Commands with
explicit local `--db-url` print “remote”; no hosted project was targeted.
SQL suites ran after a clean reset, then mutating Node suites ran sequentially.

| Check | Observed outcome |
| --- | --- |
| Native `db reset --yes --db-url [guarded loopback URL] --workdir .secrets/native-validation` | All seven repository migrations and configured seeds applied cleanly. |
| Native `test db --db-url [guarded loopback URL] --workdir .secrets/native-validation` | **128 pgTAP assertions passed**, including 43 new operational/retention assertions and 85 previous assertions. |
| `PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test supabase/tests/operational_events.test.mjs` | **8 passed, zero skipped**: field redaction, retries, outages, mandatory failure propagation, estimate arguments and actual Auth/REST permissions/deduplication. |
| `PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test supabase/tests/quota_boundary.test.mjs` | **19 passed**, preserving 30/31, 3/4, mutable limits, concurrent admission/publication, retries, spend caps and account-deletion holds through the updated metrics adapter. |
| `PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test supabase/tests/security_boundary.test.mjs` | **7 passed**, preserving private tables and owner-scoped status. |
| `node --test supabase/tests/catalog_schema.test.mjs` | **9 passed**, 46 expected SQL rejections; additive migration/replay preserves original content. |
| Node syntax, diff and tracked/new source secret-pattern checks | Passed. No credentials/session values printed or committed. |

A real DB privilege-revocation test blocked optional event INSERT: a valid lookup
still consumed exactly once, and exhausted quota still denied. Revoking mandatory
ledger UPDATE caused the metrics operation to fail and left its provider state
inflight. Retention tests proved event expiry, detail archival, IP scrubbing,
aggregate expiry/idempotency, current-day budget protection, unresolved-call retention
and publication-pending retention. Guest and verified sessions received 16 denied/
unavailable operational-data/RPC requests; concurrent server event retries wrote one
redacted row. No raw context reached its stored fields.

Inspection after the **synthetic** quota lifecycle found all eight non-capture event
types: 34 barcode attempts, 13 cache hits, 10 misses, 11 analysis admissions,
3 publications, 9 analysis failures, 3 retakes, 23 quota denials. The provider report
showed 11 admitted authorizations and USD 0.55 in conservative fixture budget holds.
These are **not live Meta calls or actual charges**. Explicit capture-event storage
was tested transactionally, not through camera/photo submission. Normal local Auth
signup generated the test sessions; no production OTP-delivery claim is made.
Test identities were deleted and native services stopped after validation.

## Completion and next dependency

All three T02.4 backend implementation checkboxes and targeted local acceptance
checks pass. No additional credentials/assets/device access were needed. No hosted
migration/Edge execution, automatic Cron run, live inference price or public guest
route is certified. Those deployment/integration requirements remain explicit above.
Next is **T03.1 — Implement get-product backend endpoint**; do not start automatically.

Actual changed files: this report; TASKS and DATABASE references; backend README;
`20261102000400_pickwell_operational_events.sql`; shared `operational_events.mjs` and
`quota_boundary.mjs`; `operational_events.test.mjs`; `operational_events_test.sql`.

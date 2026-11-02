# T02.3 — Plan configuration, quotas and provider admission

2026-11-02. **COMPLETE for the scoped backend implementation and native validation.**
No hosted migration, public endpoint or Meta inference was executed. The preceding
T02.2 work was reviewed and committed as `7cadbc3` before starting this task.

## Reconciliation and actual scope

Reviewed root instructions, backend README, PRD v1.4, DESIGN/SPEC v1.2,
DATABASE v1.0, TASKS v1.1 and existing catalog/security code. Reused the protected
`usage_daily`, `usage_reservations`, job lifecycle, canonical barcode helper,
published view and private entitlement foundations. No earlier migration, Flutter
module, auth provider, UI or optional subscription installer was replaced.

The new additive migration is
`supabase/migrations/20261102000300_pickwell_quota_controls.sql`.
`supabase/functions/_shared/quota_boundary.mjs` supplies a server-only adapter;
there is no new public route in this task. T03.1/T05.1 must integrate these operations
before exposing lookup or analysis. T02.2's public `get-product` checkbox therefore
remains open. T02.4 still owns broader operational events/ledger reporting.

## Config and security

- `plans`: Free enabled, Premium disabled. No Premium numerical limits or active billing.
- `plan_limits`: Free lookup **30**, analysis **3**; effective timestamp, version,
  update timestamp and required change reason. A protected update to 20 takes effect
  on the next admission check. Future-dated/unavailable config fails closed.
- `quota_config_audit`: before/after snapshots, database role and timestamp.
  Limit/control edits increment versions and serialize with admission transactions.
- `quota_controls`: `billing_enabled=false` enforced by constraint; inference also
  starts **disabled**, requiring an explicit nonempty approved model before enabling.
- All six new tables have RLS and no client table privileges. All quota RPCs have
  explicit server-only EXECUTE. No client plan, verified flag or user UUID authorizes work.
- The service role cannot read `auth.users`. A single server-only, fixed-query
  `pickwell_require_identity` SECURITY DEFINER checks persistent account status and,
  for AI, confirmed email. Its empty search path, explicit grants and absence of
  dynamic SQL/returned user fields limit its surface. Other new helpers use invoker
  security. The migration owner retains this narrow guard because Supabase's Auth
  schema owner does not delegate schema-USAGE grants to a new restricted role.

No secret values, JWTs, emails or image contents are stored in config audit. The
example server environment adds blank network-HMAC/proxy settings only.

## Quota and job contract

All admission/finalization operations take one transaction-scoped advisory lock.
This deliberately serializes short database admission work for the small MVP;
provider network calls run outside that lock. Counter rows are also locked, and
idempotency/active-job uniqueness remain database constraints. This favors simple
correctness over maximum admission throughput; revisit lock granularity if traffic warrants it.

1. `pickwell_reserve_usage` derives the UTC day from database time, validates the
   barcode, checks persistent/confirmed identity as appropriate, resolves Free
   config and reserves one slot if `used + reserved < limit`.
2. Lookup idempotency binds user/metric/key to its barcode. Replays return the same
   reservation without another charge; mismatched payloads fail. Only definitive
   `ready`, `not_found`, `processing` completion consumes the slot. `transport_error`
   releases it. Local reopening and status polling need no quota RPC.
3. AI checks published cache before reserving. Existing cache returns `cache_hit`
   with zero AI credit. Active barcode jobs or unresolved provider ledger entries
   return `processing`; no second provider call is authorized.
4. A new AI reservation creates a queued job; an explicit retry may reuse an owned
   failed/retake job using a new reservation key. Job attempts and daily barcode
   calls are bounded, including attempts made through a fresh job/key.
5. `pickwell_begin_provider` atomically inserts a provider-admission ledger row and
   advances the job to processing. Exactly one caller gets `call_allowed=true`.
   Replays return false, including after an uncertain RPC response. Never retry the
   network inference merely because an admission response was lost.
6. Record provider result through `pickwell_record_provider`. Failed, retake and
   unknown attempts retain their provider cost hold independently of user credits.
   Terminal provider results are immutable through this API.
7. `pickwell_finish_usage(..., 'published', product, analysis)` publishes a prepared,
   validated owned revision, advances the job to ready and consumes exactly one
   AI credit **in one transaction**. Existing catalog shape/evidence constraints
   still apply; semantic label/rule validation remains T05.2. Invalid publication
   rolls the transaction back. Repeated finalization does not charge again.
8. Cache hit, extraction failure, retake or cancellation releases the user slot.
   An inflight/unknown provider call must first be reconciled; elapsed time alone
   is not proof that it stopped. Uncertain calls continue to hold barcode/concurrency
   capacity, including after account deletion.

`pickwell_reconcile_expired` releases expired lookup and safely abandoned/known-failed
AI reservations. It never releases unresolved provider work or a successful result
awaiting publication. Reserve invokes reconciliation; a future worker/scheduled
maintenance can invoke it without waiting for user traffic. Counters and settlement
remain on the reservation's original UTC day even if completion occurs after midnight.
A new day's new request gets a fresh counter; replaying yesterday's key stays a replay.

Provider ledger references use SET NULL on account deletion so private usage/account
rows can disappear without erasing spend evidence or allowing account-deletion races
to bypass barcode/concurrency caps. No photos are retained.

## Guest/IP and spending controls

`networkBucket` HMACs an ingress IP using a server-only secret of at least 32
characters (generate at least 32 random bytes). Raw IPs are not stored. Forwarded
headers are ignored unless the **operator**, not request JSON, configures a supported
trusted header and hop count from the right. Verify ingress stripping/appending first.
Without trusted attribution all requests share a conservative unknown-network bucket;
guests never receive a promised precise per-person allowance.

`pickwell_lookup_throttle` counts request attempts independently of successful-lookup
quota, including retries/errors. Signed-in users also face shared network abuse limits.
Throttle entries older than two days are removed during reconciliation. Retention of
closed provider IP hashes and operational ledger data must be finalized in T02.4/
privacy maintenance before deployment; they are server-only and currently undeployed.

Initial **editable operational defaults**, not prices or Premium promises:

| Control | Initial value |
| --- | --- |
| Guest network lookup throttle | 10/minute, 30/UTC day, best effort |
| Persistent user lookup throttle | 20/minute |
| All lookup attempts per network | 60/minute |
| Global provider daily admission budget | USD 1.00 |
| Reserved worst-case cost per provider call | USD 0.05 |
| Global/user/network concurrent provider work | 2 / 1 / 1 |
| Global/user/network provider calls per UTC day | 100 / 9 / 20 |
| Provider calls per barcode/day; attempts per job | 3; 3 |

Budget admission sums `max(held_usd, actual_cost_usd)` for every admitted call;
known cheap/failed calls do not refund the conservative daily hold. Unknown cost
keeps the entire bound. Actual over-bound reports increase accounted spend and
block subsequent admission; they cannot undo external charges already incurred.
Thus the USD 0.05 default is **not a measured Meta price or guaranteed cost bound**.
Before enabling inference, verify provider pricing, image/token/output limits and
configure a genuine worst-case bound in the actual model adapter. No allowance of
USD 149.93 or automatic use of remaining provider credits was inferred.

## Actual validation

Used the existing isolated `.secrets/native-validation/` Native Runtime workflow,
CLI 2.122.0, PostgreSQL 15.19; Docker was not used. DB URLs were programmatically
restricted to native loopback with TLS disabled only for that local database.
CLI calls with explicit `--db-url` print “remote”; these runs targeted localhost,
not the configured hosted project. Secrets/status files and real label inputs remain ignored.

Run SQL first after clean reset, then Node suites sequentially because they mutate
test configuration. The quota suite is disposable: reset before rerunning it since
its published synthetic catalog revisions intentionally remain immutable.

| Command/check | Observed result |
| --- | --- |
| Native `db reset --yes --db-url [guarded local URL] --workdir .secrets/native-validation` | Six repository migrations and both configured seeds applied cleanly. |
| Native `test db --db-url [guarded local URL] --workdir .secrets/native-validation` | **85 pgTAP assertions passed**: catalog 31, consumer 6, security 22, quotas 26. |
| `PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test supabase/tests/quota_boundary.test.mjs` | **19 passed, zero skipped** against actual local Auth/REST/database RPCs. |
| `PICKWELL_NATIVE_STATUS=.secrets/native-status.json node --test supabase/tests/security_boundary.test.mjs` | **7 passed, zero skipped**, preserving prior ownership/read boundaries and 64 denied table operations. |
| `node --test supabase/tests/catalog_schema.test.mjs` | **9 passed**, 46 expected SQL rejections, original content preserved across additive migration/replay on PostgreSQL-engine fixture. Auth fixture gained the two identity columns needed by the new guard. |
| Syntax, whitespace, source secret-pattern checks | Passed; no real secrets added. |

The new suite verifies 30th/31st lookups, immediate 30→20 config change, transport
release, UTC next-day/original-day settlement, 12 simultaneous lookups with one
slot, 10 same-key requests reserving once, and 10 AI requests with one slot.
Ten concurrent provider-start requests authorize one call. Five concurrent publication
finalizations per result charge once; three publications succeed and the fourth
new analysis is denied. Other checks cover bounded retakes, fresh-job barcode-cap
bypass rejection, global/user/network concurrency, global spending, expiry vs unknown
work, failed publication rollback, negative costs/usage and account-deletion races.

Guests and verified sessions made **48 denied table operations** on the six new
private tables and **10 denied/unavailable quota RPC attempts**. Existing security
tests add 64 table denials. Normal local Auth signup produced the test sessions;
local auto-confirm is not evidence of production Email OTP delivery. Test identities
were deleted. All extraction/provider results in this quota suite are explicitly
synthetic; no live inference or token/cost measurement is claimed.

Early native failures exposed service-role/Auth permissions and an insufficient
request count in a throttle assertion. Both were corrected and the final suites
passed from a clean reset. Test suites that edit shared configuration were rerun
sequentially. Native services were stopped after validation.

## Acceptance and next dependency

All four T02.3 implementation checkboxes and the stated quota acceptance cases
are verified locally. There is no blocked prerequisite for this scoped task.
Production/Edge gateway behavior, real trusted proxy attribution, model cost bounds,
worker scheduling/retention and request delivery/retry integration remain deployment/
endpoint requirements; this report does not certify them. A completed backend response
whose delivery is uncertain must be retried with the same idempotency key, never
blindly refunded or issued under a new key.

Next task: **T02.4 — Operational events and cost ledger**. Do not start it automatically.
Later T03.1 must authenticate supplied sessions (invalid JWT must not fall back to
guest), hash the trusted network, throttle, reserve signed-in usage, build a definitive
published/miss/processing response, and finalize or release on known errors. T05.1
must enforce the provider grant/result/publication sequence above. No public endpoint,
active subscription, new UI, barcode scanner, permanent image storage or real AI
charge was introduced by T02.3.

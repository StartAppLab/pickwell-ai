# T01.1 — Meta vision feasibility spike

**Current status: PARTIAL — protected live image trials executed; endpoint disabled afterward.**
See the latest live-results section below. Multi-image inference and safe retakes
are verified, but complete extraction for both supplied products has not passed.

**Initial execution status: HARD BLOCKED — safe scaffold only, no live inference or deployment.**
Inspected 2026-11-02 (Asia/Manila), starting at clean commit `299a7ef`.
All four T01.1 checkboxes remain unchecked. Neither a model response nor its quality,
latency, billable tokens, actual cost or Supabase runtime behavior is verified.

## Verified inputs and missing access

- Existing PRD v1.3, DESIGN v1.1, SPEC v1.1, DATABASE v1.0 and TASKS contracts inspected.
  Only nested mobile/web/website agent instructions exist; no root/backend instructions.
  Existing starter functions and prior environment safeguards are preserved.
- `META_API_KEY`, `META_API_URL`, `META_MODEL`, Supabase URL/public/server keys and
  CLI access token were absent from the process environment. Only the blank server
  `.env.example` exists under `supabase/`; no `.temp/project-ref` link exists.
  No confirmed project/deployment access or verified test user JWT is available.
  CLI login may use an OS credential store; that was not inspected or assumed absent.
- No real nutrition/ingredients photo pairs or unreadable label fixture exist in
  repository docs/backend/mobile assets. Existing images are app icons and an avatar.
- Node **26.11.1** and Supabase CLI are available; Deno and Docker were not found
  on PATH. No local Supabase stack, Deno check, or deployed smoke test was run.

## Current provider documentation (not account verification)

Meta's [vision guide](https://dev.meta.ai/docs/image-understanding) documents multiple
images in one request and inline data URLs. It lists JPEG/PNG among supported formats,
up to 50 inline images and 50 MB per image. This spike deliberately accepts only
two JPEG/PNG files, at most 1 MiB each, 4096 pixels per side and 12 megapixels.
Header/signature/dimension checks do not fully decode an image; corrupted compressed
content can still be rejected by the provider. Actual readable-label limits need testing.

The [vision cookbook](https://dev.meta.ai/docs/cookbook/vision-input) demonstrates
`https://api.meta.ai/v1` with `muse-spark-1.3`. The
[model catalog](https://dev.meta.ai/docs/models) identifies Standard-mode Muse Spark
1.1/1.2/1.3 as vision-capable choices; account entitlement remains unknown. No legacy
Llama endpoint or third-party host is silently substituted. The scaffold requires an
explicit model and exact Meta chat-completion URL, and rejects Contributor variants.

The [chat protocol](https://dev.meta.ai/docs/protocols/chat-completions) documents
`max_completion_tokens`; the [structured-output guide](https://dev.meta.ai/docs/structured-output)
documents JSON Schema response formats. The scaffold caps output at 2048 tokens and
validates output again locally; provider schema support is still untested for this account.

Meta's [pricing page](https://dev.meta.ai/docs/pricing-rate-limits), checked on the
audit date, lists Standard Muse Spark input at $1.25 and output at $4.25 per million
tokens, with cached input priced separately. Recheck for the selected account/model
before spending. The scaffold reports provider token counts when available and
`estimated_cost_usd=null`: no billing amount is guessed or treated as measured.
An uncached estimate can be calculated as `(input_tokens*1.25 + output_tokens*4.25)/1e6`
at those published rates. Provider failures/timeouts may still incur charges even
when usage is unavailable; cancelling HTTP does not guarantee provider cancellation.

## Prepared files and security boundary

- `supabase/spikes/meta-vision/core.mjs`: dependency-free request handler and strict
  extraction schema. `index.ts` is a small Deno adapter. Both remain **outside active
  `supabase/functions/`**; no config entry, migration, UI entry point or deployment exists.
- Disabled unless `SPIKE_ENABLED=true`. Requires an operator-only token of at least
  32 characters **and** bearer user JWT. Calls Supabase Auth `/auth/v1/user`, checks
  the configured allowlisted user, confirmed email and non-anonymous identity.
  No caller-supplied verified/user/plan fields are accepted. No service-role key is used.
  Native auth verification still requires a live negative/positive integration test.
- The provider endpoint is fixed to `https://api.meta.ai/v1/chat/completions`; images
  must be inline data, not remote URLs. No permissive CORS headers or browser/mobile
  integration. JSON body capped at 3 MiB; auth timeout 5 seconds; inference timeout
  30 seconds; provider body cap 64 KiB. No automatic retries. Errors omit raw provider
  bodies, credentials, input images and decoder exception text.
- One active inference and three attempted calls per process; repeated idempotency
  keys rejected even after failure. These are **in-memory laboratory safeguards**,
  not global/user/IP quotas: instance restarts reset them. Before hosted use, verify
  gateway abuse control and provider spending cap, restrict the operator session,
  and remove/disable the spike immediately after trials. Do not expose it as a
  production analysis endpoint or claim it implements T02 atomic quota controls.
- Extraction includes literal ingredient text, ordered items, declared-allergen text
  or unknown, nutrient values/units/basis/source spans and serving context. Null,
  unknown basis, missing evidence and unreadable labels trigger retake or safe
  failure. Returned facts are untrusted until compared with actual labels: this
  schema does not prove accuracy or implement final product publication rules.
- No database/catalog/quota mutations, permanent photo upload, file API, storage,
  image logs or billing integration. `store=false` is sent; provider-side retention
  must be reviewed separately. Request memory is released with normal runtime GC,
  not a guarantee of byte-level secure erasure.

## How to finish once prerequisites exist

1. Confirm selected Supabase dev project, public URL/key, deployment access, safe
   confirmed Email OTP account, Meta Standard model access/key and provider spend cap.
   Use protected server secrets; leave `SPIKE_ENABLED=false` until the test session.
2. Review/install the isolated adapter/core as `meta-vision-spike` in that dev project's
   function source. Keep platform JWT verification enabled and retain handler Auth
   checks. Modern key/gateway behavior, runtime bundling and secret injection must
   be verified in that environment before claiming deployment. No installation or
   deploy command was run here, and no production route should be repurposed.
3. Supply two distinct real products' readable nutrition/ingredients photos and an
   unreadable ingredients case. No generated images, borrowed app icons or header
   fixtures count as real labels. Keep photos/manifest in ignored `.secrets/`.
   `cases.example.json` is only a manifest template, with no attached photos.
4. Create an ignored **client-only** env file containing `SPIKE_URL` (exact hosted
   `/functions/v1/meta-vision-spike` URL), `SPIKE_PUBLISHABLE_KEY`, operator token and
   `SPIKE_USER_JWT`. The client runner never needs the Meta key or a service-role key.
   Set `SPIKE_OPERATOR_TOKEN` and `SPIKE_USER_ID` only in protected server config;
   operator tokens/JWTs must not be pasted into command arguments or chat/logs.
5. From repo root, run `node --env-file=.secrets/spike-client.env
   supabase/spikes/meta-vision/run.mjs .secrets/vision-cases.json`. This makes at most
   three sequential calls, stops on server failure and never retries automatically.
   It prints status, basis, counts and bounded metadata, not raw images/model text.
   It is an integration runner, not a mock demo. A matching status alone is
   insufficient: manually compare extracted values against both labels using the
   protected response (no raw-body logging) and record evidence/unit/basis errors.
6. Record per-case model, sizes, duration, HTTP status, token availability, estimated
   versus actual provider cost and unreadable-retake target. Test missing operator
   token, no/fake/expired JWT, anonymous/unverified/other-user identity and invalid
   images without model spend. Then disable the function, revoke its operator token,
   remove temporary fixtures per retention needs and verify it can no longer invoke Meta.

## Validation observed

| Check | Result |
| --- | --- |
| `node --test supabase/spikes/meta-vision/core.test.mjs` | 11 mocked/local tests passed. Header fixtures and synthetic JSON are clearly test data, not real labels/inference. |
| `node --check` on core, runner and adapter | Passed syntax checks. This is not a Deno type check or Supabase bundling/runtime verification. |
| `node supabase/spikes/meta-vision/run.mjs` | Exited 1 with `HARD BLOCKED` for missing protected URL/operator token/user JWT/public key, before network activity. |
| `python3 mobile/tool/check_environment.py` | Known-secret pattern scan passed on tracked/nonignored files. |
| `git diff --check` | Passed. |

Covered locally: disabled/config gates, operator/bearer rejection, Auth-derived
allowlist and verification, dual-image wire format, size/signature/dimension and
duplicate/external URL rejection, schema/unit failures, unreadable/unknown retake,
idempotency/attempt cap, provider rate error/timeout and sanitized failure metadata.
These mocks do not prove live Supabase authorization, OCR accuracy or provider access.

All acceptance requirements remain unverified: **no deployed call with real images;
no measured provider/runtime behavior; no two-product/unreadable live results; no
deployed endpoint to remove or prove locked down afterward.** The disabled default
and isolated files are preparation only. Next dependency: resolve T00.2's actual
project/credentials and provide real label fixtures, then run the protected spike.

## Continuation — supplied credentials verified (2026-11-02)

Resumed from clean commit `d3d15df` without rebuilding the scaffold. Earlier sections
are retained as historical evidence; their missing-credential findings are superseded
by the observations here where stated.

### Documentation reconciliation

Read root `AGENTS.md`, PRD **v1.4**, DESIGN **v1.2**, SPEC **v1.2**, DATABASE
**v1.0**, TASKS **v1.1**, PROMPTS **v1.1**, and the existing spike report/source.
Root instructions point to folder-specific guidance and do not conflict with the
Flutter template conventions. No Flutter work is required for this continuation.

The material document changes are approved lemon branding, Home/local recent-product
navigation, and photo review after the two label captures. These belong to later
UI tasks and do not alter the spike's two-image schema, verified-user gate, server-only
Meta invocation or transient-image boundary. The 30/3 server policy, UTC reset,
billing disabled and no client privilege claims remain unchanged. DATABASE changes
since the original scaffold update document references, not its backend contract.
The older SPEC 5/day provisional wording remains superseded by its approved 30/3
section and the PRD; no quota implementation is introduced here.

T00.1/T00.2 inventory, configuration safeguards and prior spike implementation still
exist. The refreshed TASKS document has unchecked preparatory entries; these are
not evidence to redo working code or reopen completed audit work. No TASKS boxes
were changed in this continuation because T01.1's real-image acceptance is unmet.

### Available resources and live observations

Secrets were loaded directly from ignored files inside local scripts, never printed
or interpolated into shell commands. This run found populated Meta credentials in
`supabase/.env.dev` and the Supabase project URL/publishable key in
`mobile/.secrets/dev.secrets`. Neither file was changed.

| Actual check | Observed result |
| --- | --- |
| Meta configuration compared with existing handler | Exact `https://api.meta.ai/v1/chat/completions` endpoint; selected Standard model `muse-spark-1.3`; key supplied and not an obvious placeholder. |
| Authenticated `GET https://api.meta.ai/v1/models` | **HTTP 200, 1071 ms**; configured model appears in the returned list. Verifies key/model discovery access, not successful vision inference or schema support. Raw model-list response was not logged. |
| Supabase `GET /auth/v1/settings` with configured publishable key | **HTTP 200, 1320 ms**; email provider enabled; anonymous Auth provider disabled. Does not prove OTP delivery or a verified test session. |
| Supabase `GET /auth/v1/user` without a user session | **HTTP 401, 115 ms**. No user token or API key was logged. |
| Supabase `GET /auth/v1/user` with deliberately invalid bearer token | **HTTP 403, 102 ms**. This tests Auth rejection, not an undeployed Edge Function's gateway. |
| `supabase projects list --output json`, captured and filtered locally | Exit 0; configured dev project is accessible using existing CLI authentication. No project reference or credentials were printed. No permanent local project link was created. |
| `supabase functions list --project-ref <configured-dev-ref> --output json`, captured and filtered locally | Exit 0; **zero deployed functions**, no existing `meta-vision-spike` endpoint. |
| `node --test supabase/spikes/meta-vision/core.test.mjs` | **All 11 tests passed** again, including concurrency. These remain mocked/local tests, not actual Meta extraction. |
| `node --check` on core.mjs, run.mjs, index.ts | Passed syntax checks; not Deno type-checking or hosted runtime verification. |
| `python3 mobile/tool/check_environment.py` | Passed known-secret scan for tracked/nonignored files. |
| `python3 mobile/tool/check_environment.py --config mobile/.secrets/dev.secrets` | Failed because `NOTIFICATIONS_ENABLED` is still enabled. Optional auth/backend/public-key configuration is present; this unrelated mobile-profile issue does not prevent server-only spike testing. Local profile preserved. |
| `git check-ignore` on server/mobile env and proposed client/manifest paths | Ignored as expected. No populated credentials committed or copied to public examples. |

All measured durations above are local HTTP wall-clock times for **discovery/Auth
requests only**, not model image processing or Supabase Edge Function execution.
No chat-completion request was made, no image was sent to Meta and no model token
usage/cost was returned. Published price formulas in the earlier findings remain
estimates; actual inference cost is still unmeasured.

### Remaining inputs and deployment decision

- Real food-label fixtures are still missing from repository docs/backend/mobile
  assets and no private manifest or client-session env file is present at the
  documented root `.secrets/` paths. Two distinct products' readable nutrition and
  ingredients photos, plus an unreadable case, are required. A request for their
  local paths was made; no synthetic label results or replacement photos were invented.
- No `SPIKE_USER_ID` allowlist entry or verified-user access token is configured.
  The supplied operator token does not meet the existing 32-character minimum.
  These need completion in ignored configuration before enabling the spike. The
  runner must receive only the public key, verified user session and operator token;
  the Meta key remains in protected server configuration.
- CLI deployment access is now confirmed. Deployment remains authorized for this
  scoped test, but was **not performed without fixtures and a valid test identity**.
  The existing disabled adapter is unchanged, outside active functions, and no
  public inference endpoint or remote secret update was created. This avoids
  leaving a temporary endpoint enabled while the test cannot run.
- Docker and Deno remain unavailable on PATH. This does not prove hosted deployment
  is impossible: installed CLI help advertises Management API bundling via `--use-api`.
  Actual bundling, gateway verification and runtime behavior remain to be tested.

No implementation correction was required by the verified results so far. Only
this evidence report changed; the scaffold, extraction schema, runner, manifests,
Flutter code, server configuration and earlier tests were preserved.

### Acceptance at this checkpoint

| T01.1 acceptance requirement | Current evidence |
| --- | --- |
| Protected deployed function sends two real label photos to Meta | **Not satisfied:** no deployment or real fixtures/session yet. |
| Live auth, model/schema, image limits, timing, tokens/cost and failures validated | **Partially verified:** real Auth/connectivity/model discovery passed; guards/schema remain mock-tested only; no live inference measurements. |
| Two distinct real product pairs and unreadable case evaluated | **Not satisfied:** no real-image trial; ingredient/nutrient/unit/basis accuracy and multi-image processing remain unknown. |
| Temporary endpoint removed/locked after actual trials; retain safe fixtures/tests | **Not satisfied:** tests and disabled source retained, but no deployed trial or post-trial lockdown exists to verify. |

**Next dependency:** provide actual image/manifest paths and a confirmed test
user/session, complete the operator credentials, then install/deploy only the protected
spike, execute the existing runner, review extractions against the labels and disable
the endpoint afterward. T02.1 is not started and T01.1 is not marked complete.

## Continuation — local photo fixtures and operator credential (2026-11-02)

**Status: PARTIAL; live inference BLOCKED by missing verified test session.**
The supplied photos resolve the two-product input blocker. A genuinely unreadable
fixture is still needed; the file named unreadable is legible, as described below.
Earlier checkpoint results remain historical evidence, not current missing-photo claims.

### Fixture inspection

All five supplied files exist with `.jpeg` extensions rather than the proposed
`.jpg` names. Each opens successfully in the image viewer and passes the existing
JPEG signature, file-size and dimension checks. No image was renamed or edited.

| Supplied local file under `test_fixtures/meta_vision/` | Bytes | Dimensions | Visual observation |
| --- | --- | --- | --- |
| `product_a_nutrition.jpeg` | 75,446 | 453 × 1080 | Readable noodle-cup panel: 105 g package, 430 calories, 14 g total fat, 1280 mg sodium, 66 g carbohydrate, 9 g protein. These are manual fixture observations, not Meta output. |
| `product_a_ingredients.jpeg` | 106,822 | 622 × 1080 | Corresponding red noodle cup; ordered ingredients and explicit Wheat/Soy declaration visible. Some text curves toward the package edge; extraction completeness must be evaluated. |
| `product_b_nutrition.jpeg` | 32,506 | 256 × 500 | Cereal panel with two nutrition columns (cereal alone and with milk). Small text and distinct serving contexts require care; do not combine columns. |
| `product_b_ingredients.jpeg` | 21,200 | 244 × 500 | Cheerios ingredients, including whole grain oats, corn starch, sugar, salt and added vitamins/minerals. Distinct from Product A. |
| `unreadable_label.jpeg` | 163,538 | 1200 × 1200 | Legible cookie packaging with nutrition and ingredients for a **third** product. It is not a confirmed unreadable-label fixture. |

Prepared an ignored `.secrets/vision-cases.json` using the existing manifest shape
and actual filenames, without changing the working runner. Its third pair combines
Product A nutrition with the supplied cookie image, with expected `needs_retake`;
this is a **mismatch test**, not proof of unreadable-image handling. The manifest
explicitly records this limitation. A separate truly unreadable photo/path has
been requested rather than generating or degrading an image without instruction.

The images initially appeared as untracked files. Added `/test_fixtures/meta_vision/`
to root `.gitignore`; `git check-ignore` confirms all five photos are excluded.
None were staged, committed, uploaded or sent to Meta.

### Credential/session checks and actions

- No existing test session/token or allowlisted `SPIKE_USER_ID` was found in the
  documented local environment locations. The runner's new private env file has
  an empty `SPIKE_USER_JWT`, not a fabricated session.
- Replaced the short operator token using cryptographically secure random bytes
  (48 bytes, base64url encoded). Saved the same value in `supabase/.env.dev` and
  `.secrets/spike-client.env`; both files have owner-only permissions (`0600`).
  The token was never printed. The private client file contains only the hosted
  spike URL, public project key, operator token and user-session placeholder;
  no Meta or service-role credential was copied into it.
- `SPIKE_ENABLED=false` remains set locally. No remote secret or function was changed.
  CLI project discovery again confirms access to the configured dev project;
  function inventory confirms no existing spike. Public keys were not used as
  deployment credentials or user identity.
- Existing auth code has password sign-in, signup confirmation and OTP verification,
  but no passwordless send-code operation. Building later-phase Flutter auth is
  unnecessary: the minimum secure test path is normal Supabase Email OTP for a
  user-controlled inbox, followed by Auth verification and private storage of the
  resulting access token/UUID. No account is administratively marked verified,
  no privileged SQL is used and no RLS/auth check is bypassed.
- Requested either an existing private session-file path or a test inbox address.
  An inbox has not yet been supplied, so no OTP email was requested. OTPs and session
  tokens must stay in ignored local files, not chat, logs or commits.

### Validation and acceptance

- `node --test supabase/spikes/meta-vision/core.test.mjs`: all **11 tests passed**.
- `python3 mobile/tool/check_environment.py`: known-secret scan passed.
- `git diff --check`: passed; private fixtures/env/manifest paths are ignored.
- Real Product A, Product B and mismatch trials: **not run**, awaiting a verified
  test session. The unreadable-label acceptance case is additionally unresolved.
  No new inference latency, token usage, schema accuracy or cost measurements exist.

Repository-file changes in this continuation are limited to `.gitignore` and this
report; private env/manifest updates stay ignored. No scaffold, schema, app UI,
database or billing implementation changed. T01.1 checkboxes remain unchanged.
Minimum next input: a private session-file path or user-controlled test inbox for
Email OTP, plus a genuinely unreadable fixture path. Then run the protected live
workflow and post-test lockdown; do not start T02.1 automatically.

## Continuation — OTP requested and disabled spike deployed (2026-11-02)

The user supplied a test inbox and explicitly approved using the current third
image for now, with deeper unreadable-label testing deferred. The third case remains
a mismatch test; it will not be reported as an unreadable-label pass. This revised
scope supersedes the preceding request for another photo before proceeding.

- Requested **one normal Supabase Email OTP** for the supplied inbox using the
  configured public client key. Auth returned **HTTP 200 (3300 ms)**. This proves
  the request was accepted, not email delivery or a verified session.
- Created ignored, owner-only `.secrets/spike-login.env` with the test email and
  an empty `OTP_CODE`. Asked the user to save the received code locally and reply
  "saved"; no code, JWT, email address or key is written to this report.
- Uploaded the existing Meta/operator configuration to the selected dev project's
  protected Edge secrets, with **`SPIKE_ENABLED=false`**. CLI exited 0. No
  Supabase reserved keys or privileged client values were uploaded.
- Deployed the unchanged existing `index.ts`/`core.mjs` as **`meta-vision-spike`**
  from an ignored deployment workspace using CLI `--use-api`. CLI exited 0;
  Docker was not needed. Config keeps **`verify_jwt=true`**. This deploy is
  authorized by the resumed task and creates only the isolated test function.
- Hosted disabled-state verification returned **HTTP 503** with the exact
  `spike_disabled` handler response, confirming successful runtime startup and
  a closed inference gate. A deliberately fake bearer JWT returned **HTTP 401**.
  A publishable-key request without a user session reached the disabled handler;
  it was not interpreted as a verified user. Enabled-state handler authorization
  still needs the normal verified session and operator token.
- Added optional `SPIKE_EVIDENCE_PATH` to the existing runner so structured handler
  responses can be saved privately for manual label comparison. It creates an
  owner-only file, refuses overwrite and leaves console output as summary receipts.
  This is a minimal evidence-recording change; no inference schema or handler was
  rebuilt. Raw provider responses and image bytes are not written to that file.
- Targeted local verification of the runner's evidence option passed: three mock
  receipts saved with `0600` permissions; a second run refused overwrite and
  preserved the original receipts. This made no network request and is not Meta
  inference evidence. Existing **11 handler tests**, runner syntax, secret scan
  and diff checks also passed.

**Current stop point:** the local OTP field remains empty. No account was marked
verified administratively; the user still needs to complete the normal email
verification. No production endpoint, database migration, billing or paid feature
was activated. The deployed test function is disabled, with no real-image inference
attempts, token usage, model latency or measured cost yet.

Next: verify the locally saved OTP, store the resulting session/allowlist privately,
briefly enable the protected function for the two products and approved mismatch
case, capture actual results, then disable/revoke the test access. T02.1 is not started.

## Live results — verified session, two products and approved mismatch case (2026-11-02)

**T01.1 status: PARTIAL.** These are actual hosted Supabase → Meta requests,
not mock responses. Earlier no-deployment/no-inference checkpoints above are
preserved history and are superseded by this section.

### Authentication and deployment

Google SMTP initially rejected Auth mail with `535 Authentication Credentials Invalid`.
After the user corrected SMTP configuration, a new OTP request returned HTTP 200.
One saved code was rejected as `otp_expired`; a replacement code subsequently
verified with **HTTP 200**, and `/auth/v1/user` returned **HTTP 200** for the same
non-anonymous, confirmed-email user. Tokens/UUID were saved only in ignored,
owner-only local files; the consumed OTP was cleared. No administrative verification
override or RLS bypass was used.

Enabled-state checks against the deployed operator-protected `meta-vision-spike`:

| Request | Actual result |
| --- | --- |
| Verified session, missing operator token | HTTP 401; no inference |
| Operator token, no user session | HTTP 401; no inference |
| Deliberately fake session | HTTP 401; no inference |
| Verified operator, external/invalid image payload | HTTP 400; no inference |
| Verified operator, client `verified`/`premium` claims | HTTP 400; no inference |

The function retains gateway `verify_jwt=true`, server Auth user verification and
the exact user allowlist. Live other-user/unverified-user tests were not performed;
their negative paths remain covered by local mocks. Process-local caps are still
laboratory safeguards, not production/global atomic quotas.

### Provider and minimal corrections

- Actual selected model: **`muse-spark-1.3`**, Standard mode.
- Actual endpoint: **`https://api.meta.ai/v1/chat/completions`**.
- Every inference request sent **two inline real JPEGs** in one user message through
  the protected Supabase function. All seven provider calls returned HTTP 200.
- The initial Product A call consumed the entire 2048-token output allowance and
  failed the response gate (`invalid_model_output`, handler HTTP 502). This suggests
  output truncation; finish reason was not retained in that initial version, so
  truncation is not asserted as independently observed.
- Increased the bounded output allowance to **4096 tokens** and requested
  `reasoning_effort=minimal`. Added safe finish-reason metadata. Subsequent six
  responses finished with **`stop`** and passed strict candidate-schema validation.
  This did not relax the missing/unclear-label publication gate.
- Added **`diagnostic_extraction`** to the operator-only spike response to inspect
  schema-validated candidate facts separately from the final retake status. These
  fields are saved only in private evidence files; console receipts omit them.
  No raw provider response, model reasoning, image bytes or candidate product was
  logged or published. The operator-only diagnostic contract is not a public app API.
- A diagnostic repeat was needed to distinguish model-requested retakes from
  literal source-span validation. For both products, the latest retake was requested
  by the model itself; the validator did not manufacture those final retake targets.
  No additional paid retries were made after that finding.

### Measured requests

Durations are measured inside the Edge handler around provider processing, including
response parsing/validation. They exclude the OTP flow, deployment and client upload.
Costs below use the previously documented Standard rates ($1.25/M input, $4.25/M
output), assuming all input uncached. They are **estimates**, not provider invoices;
cached-input discounts or other account adjustments are not included.

| Trial | Case | Handler result | Duration | Input / output tokens | Estimated USD |
| --- | --- | --- | --- | --- | --- |
| Initial | Product A | 502 `invalid_model_output` | 11.928 s | 1885 / 2048 | 0.01106025 |
| Corrected | Product A | 200 `needs_retake` ingredients | 7.495 s | 1885 / 1400 | 0.00830625 |
| Corrected | Product B | 200 `needs_retake` nutrition + ingredients | 5.660 s | 765 / 943 | 0.00496400 |
| Corrected | Mismatched pair | 200 `needs_retake` both | 8.406 s | 2898 / 1667 | 0.01070725 |
| Diagnostic | Product A | 200 `needs_retake` ingredients | 6.889 s | 1885 / 1702 | 0.00958975 |
| Diagnostic | Product B | 200 `needs_retake` nutrition | 7.328 s | 765 / 1451 | 0.00712300 |
| Diagnostic | Mismatched pair | 200 `needs_retake` both | 8.641 s | 2898 / 1502 | 0.01000600 |

**Total:** 7 provider calls; **12,981 input / 10,713 output tokens**;
estimated uncached cost **$0.06175650**. Failed/retake trials still used provider
tokens. No successful-analysis user credits or product records were created.

**User-reported provider balance:** after these tests, the dashboard shows
**$149.93 free credits remaining** (reported 2026-11-02). Against the stated $150
starting credit, that is a displayed $0.07 reduction, corroborating actual provider
charges. This balance is supplied by the user, not independently queried or a
per-request invoice; the token-based estimate above remains separately identified.

### Label comparison and limitations

- **Product A nutrition:** latest candidate has 15 nutrient entries, `per_serving`,
  `1 package (105g)`. Manual comparison against the supplied image confirms 430 kcal,
  fat 14 g, saturated fat 7 g, trans fat 0 g, cholesterol 0 mg, sodium 1280 mg,
  carbohydrate 66 g, fiber 3 g, sugars 6 g, added sugars 5 g, protein 9 g,
  vitamin D 0 µg, calcium 40 mg, iron 0.75 mg and potassium 200 mg. All retained
  source spans occur in its extracted nutrition text. These are candidate label
  facts, not nutritional classifications or a published product.
- **Product A ingredients:** model explicitly requested an ingredients retake and
  returned no ordered items in the diagnostic candidate. A declared allergen field
  was present, but full ingredient extraction accuracy is unverified. The photographed
  list curves around the cup and fades/crops toward the right edge; a clearer/full
  label capture is required. Do not treat partial visible text as complete extraction.
- **Product B ingredients:** latest candidate lists 16 ordered entries matching the
  visible oats/corn starch/sugar/salt/tripotassium phosphate, preservation vitamin E,
  and vitamin/mineral section. Explicit allergen text is unknown (`null`), not a claim
  of allergen absence. Ingredient literal-span checks pass in the latest candidate.
- **Product B nutrition:** model requested retake, with `basis=unknown`, null serving
  context and zero nutrient entries, rather than guessing. The supplied 256 × 500
  image has tiny text and separate cereal-alone/with-milk columns. No combined or
  invented nutrient values were accepted. A higher-resolution readable panel is needed.
- **Third case:** supplied readable cookie packaging paired with Product A nutrition
  repeatedly produced retakes for both fields. This verifies safe rejection of this
  actual mismatch, not a universal mismatch detector. Genuinely unreadable-label
  testing is **explicitly deferred by the user** and has not passed the original criterion.

The existing runner exited **1** on both complete three-case runs because Product A
and B were expected to be complete extractions but were retakes. This failure is
preserved; successful HTTP calls are not misreported as successful product analysis.

### Lockdown, validation and next dependency

Every live trial batch used cleanup that set **`SPIKE_ENABLED=false`** and rotated
the operator token, including the initial failed batch. After the last batch, a
request using the prior authorized session/token returned **HTTP 503** with exact
`spike_disabled`, verifying the hosted inference gate is closed. The source and safe
tests remain; label photos/evidence/session files stay ignored, not committed.
The model key remains only in protected server configuration. No public unauthenticated
inference, permanent remote photo storage, billing, app UI or database schema was added.

Targeted checks: all **11 handler tests passed** after the code corrections; runner
syntax checks passed; the private-evidence option passed its local three-receipt,
owner-only-permissions and overwrite-refusal checks; secret scanning and diff checks
passed. Live provider failures beyond the output-limit case, larger-image boundaries,
other-user authorization and broader accuracy/regression remain unverified/mocked.

Repository changes across this continuation: `.gitignore` (private fixture exclusion),
`supabase/spikes/meta-vision/core.mjs` (output budget, finish metadata, private
diagnostic candidate), `core.test.mjs` (corresponding assertions), `run.mjs`
(optional private evidence output), this report and the T01.1 evidence note/status
in TASKS. Private manifests/env/session/evidence and scratch deployment scripts were
also updated locally without staging their values or photos.

**Acceptance:** protected deployment + real two-photo inference and post-use lockdown
are verified. Complete ingredient/nutrition extraction for two distinct products
is **not satisfied**, and the original unreadable case is deferred. Keep T01.1
**PARTIAL**, without claiming the MVP AI integration is fully ready. The next task
is T02.1 if the user chooses to proceed with this recorded feasibility limitation;
do not begin it automatically. Closing T01.1 still needs clearer Product A ingredients
and Product B nutrition, plus the deferred unreadable test (or an explicitly revised
acceptance contract).

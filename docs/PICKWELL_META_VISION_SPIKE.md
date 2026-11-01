# T01.1 — Meta vision feasibility spike

**Status: HARD BLOCKED — safe scaffold only, no live inference or deployment.**
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

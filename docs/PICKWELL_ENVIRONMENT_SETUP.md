# T00.2 — Secret-safe Pickwell development setup

Prepared 2026-11-02. Public/server samples and local rejection checks are implemented.
Live connectivity, protected server secret reads, test accounts and authorization
remain **unverified**: no Supabase project is linked, local public URL/key values
are empty, Meta credentials are unavailable and Docker is unavailable on PATH.
No credentials were created, copied, logged, committed or deployed by this task.

## Public mobile configuration

Use the existing `SERVER_BASE_URL` and `SERVER_API_KEY` defines; do not add new
Supabase variable names to Flutter. Only a project URL and **publishable key**
belong in these credential fields. Neither is a user identity or permission grant.
Existing legacy `anon` JWT validation remains supported by the reusable starter;
use it only if a selected existing project actually requires it. Never use a
service-role JWT or `sb_secret_` key.

The committed `mobile/config/pickwell.dev.example.json` and
`pickwell.stg.example.json` enable backend plus optional auth, preserving guest
browsing. Their URLs are deliberately invalid placeholders and their keys blank;
they must fail preflight until filled. Billing, social providers, notifications,
onboarding, analytics and crash reporting are disabled. No Premium identifiers or
prices are approved. The generic offline `app.example.json` remains unchanged.
Optional auth does not implement the future Email OTP submission flow (T04.2).

From `mobile/`, copy a sample **only if the destination does not already exist**:

```sh
cp -n config/pickwell.dev.example.json .secrets/dev.secrets
cp -n config/pickwell.stg.example.json .secrets/stg.secrets
```

Create `.secrets/` first if absent. Existing local files were preserved in this
task; merge the public sample's switches into those files manually. Set each
environment's real project URL and publishable key using a local editor, keeping
`APP_ENVIRONMENT` matched to dev/stg. Select separate staging infrastructure
deliberately; none is provisioned or assumed here. All variants currently share
`com.startapplab.pickwell`, so installing one may replace another.

```sh
python3 tool/check_environment.py --config .secrets/dev.secrets
fvm flutter run --dart-define-from-file=.secrets/dev.secrets
```

For staging use `.secrets/stg.secrets`. Existing IDE profiles and Makefile commands
already use these paths. Preflight runs locally without network access, validates
known public fields/types and the disabled integrations, and rejects private keys,
unknown fields (including client `verified`/`plan` claims), placeholder URLs and
missing credentials. Runtime `AppConfig.validate()` rejects nonpublic Supabase
key formats before SDK bootstrap, with credential-free error text. Fake public
key formats can pass syntax checks: only Supabase can verify real credentials.
Direct Flutter commands bypass the Python preflight; never pass a server env file
to `--dart-define-from-file`. Dart defines ship in the app even if unused.

## Protected server environment

`supabase/.env.example` is a **server-only** sample with blank `META_API_KEY`,
`META_API_URL`, and `META_MODEL`. No provider endpoint/model is guessed; confirm
the real account's vision access in T01.1. `BILLING_ENABLED=false` records intended
policy for future handlers; there is no installed Pickwell handler consuming or
enforcing it yet. The RevenueCat module remains uninstalled and no webhook is
deployed.

From repository root, copy the server sample to `supabase/.env.dev` (or `.env.stg`)
without overwriting an existing file; restrict its permissions to the current
user, and populate it outside chat/logs. Both files are ignored. Do not reuse this
file for mobile, web, public assets, test fixtures or template archives.

Hosted Supabase Edge Functions receive `SUPABASE_URL`, `SUPABASE_ANON_KEY` and
`SUPABASE_SERVICE_ROLE_KEY` from the platform. Do not upload reserved `SUPABASE_`
names through `supabase secrets set`. Existing backend examples use those injected
values; privileged clients must remain behind verified request authorization.
The local CLI stack provides its own local credentials when available. Never copy
a production service-role key into local test fixtures or Flutter.

Once the intended project and deployment access are verified, CLI secrets can be
loaded from the ignored server file using `supabase secrets set --env-file
supabase/.env.dev --project-ref <confirmed-dev-ref>` (select staging explicitly
for staging). This command was **not executed**. Avoid command-line secret values,
environment dumps, debug HTTP payload logs and credential-bearing status output.
Future handlers should check required secret presence without logging values.
Do not create a public diagnostic endpoint that returns or probes secrets.

## Safe accounts and minimal live validation (pending)

- Use developer-controlled email inboxes dedicated to the selected dev/staging
  projects. Do not commit real addresses, passwords, OTPs, JWTs or SMTP credentials.
  Maintain at least two accounts for ownership isolation; use synthetic nonpersonal
  test data. Local email interception is for local tests, not proof of real delivery.
- Configure numeric Email OTP templates and verify delivery using trusted Auth;
  the current local starter has email confirmations disabled. Do not label a user
  verified based on Flutter flags or create test accounts with privileged SQL.
- After public configuration exists, launch the app and verify SDK initialization
  against the selected project's Auth service without privileged credentials.
  This starter has no `get-product` endpoint yet, so connection alone cannot prove
  guest published-product access, RLS or quota enforcement.
- After the protected T01.1 function exists, confirm required secrets are readable
  inside its server runtime without returning/logging them. Reject requests with
  no user JWT, fake JWTs, publishable keys used as bearer identity, anonymous users
  and unverified email before any Meta call. Repeat with a valid verified test
  account. These server authorization tests cannot run yet: no analysis endpoint
  or usable backend exists. Client rejection tests below prove configuration
  hygiene only, not that a modified client cannot access privileged work.

## Checks and observed results

From `mobile/`:

```sh
python3 tool/check_environment.py
python3 -m unittest discover -s tool -p 'test_*.py'
fvm flutter test --no-pub test/app_config_security_test.dart
fvm flutter analyze --no-pub
```

The scan examines tracked and nonignored new files for private keys, Supabase
secret keys/service-role JWTs, common provider/Meta tokens and credential URLs.
It reports path, line and category only. Ignored files are not scanned unless
explicitly selected as `--config`; history, arbitrary secret formats, actual
credential validity and hosted secret stores are outside its guarantee. Review
changes before staging. If a real leaked secret is found, rotate it in its provider
and assess history separately; removing a file alone does not revoke a key.

Observed validation for this change:

| Check | Result |
| --- | --- |
| `python3 tool/check_environment.py` | Passed; no known private patterns detected in tracked/nonignored files. |
| `python3 -m unittest discover -s tool -p 'test_*.py'` | All 18 tests passed, including scanner, redaction, private-field injection and existing release/packaging tests. |
| `fvm flutter test --no-pub test/app_config_security_test.dart` | Both tests passed; private keys/service-role JWTs rejected with backend enabled or disabled; public/offline profiles preserved. |
| `fvm flutter analyze --no-pub` | No issues found (5.2s). |
| Preflight on both committed Pickwell profile samples | Expected failure: placeholder URL; neither sample pretends to connect. |
| Preflight on existing ignored `.secrets/dev.secrets` | Expected failure: profile still has disabled auth/backend; preserved without modification. |
| `git check-ignore` | Dev/staging secret files, `.env.production` and Fastlane credentials ignored; public/server examples trackable. |
| Temporary archive inspection | Environment/release validators and catalog included; local secret paths excluded. Makefile assertion failed: pre-existing missing `mobile/Makefile.prod` means the packager excludes authored Makefile with no replacement. Packaging repair is outside T00.2; do not treat this archive as release-ready. |

The scan and local tests make no network requests. A minimal live connection check
was not attempted without a real URL/key; server secret reads and negative server
authorization checks were not run without an implemented/configured endpoint.

`.gitignore` now ignores `.env.*` across the workspace while allowing sample
files. `.secrets/` remains ignored. `supabase/.env.example` is trackable; populated
server files and all existing mobile environment variants must remain ignored.

T00.2 acceptance remains open until real public connection, server secret reads,
safe test accounts and negative server authorization checks are observed. No visual
assets are needed. The next dependency is a confirmed Supabase dev/staging project
and public configuration, protected server access, Docker for local DB checks,
then Meta vision credentials/model access for T01.1. Backend 30/3 limits, RLS,
rate controls and atomic quotas remain later tasks; no client counters or billing
were added here.

# Mobile app configuration

`app.example.json` contains Flutter defines. Copy it to an ignored environment
file such as `.secrets/prod.secrets` and set `APP_ENVIRONMENT` to `prod` before a
production build. `features.json` is an app-owned release catalog, not a Dart
define file or a server authorization policy. Keep it in Git and update it when
adding, removing, or changing guards.

From `mobile/` in this repository, or from the generated Flutter project's root:

```sh
make preflight-billing PLATFORM=android
make preflight-billing PLATFORM=ios
make build-android
make build-ios
```

Both release build targets run preflight before Flutter and use the exact define
file checked. Override `APP_CONFIG`, `FEATURE_CATALOG`, or `SUPABASE_DIR` when
needed. In this source repository, `make -f Makefile.prod ...` uses the committed
production Makefile; the template packager renames it to `Makefile` for generated
apps. A direct `fvm flutter build` command bypasses this gate, so run
`python3 tool/check_billing_config.py --config .secrets/prod.secrets --platform android`
first when using a custom build pipeline; select `--platform ios` for iOS. Debug and staging commands are unchanged.

## Free or offline app

Keep the catalog defaults:

```json
{
  "schema_version": 1,
  "default_premium_guard": "none",
  "features": {},
  "server": null
}
```

Use `BILLING_MODE=disabled`. No RevenueCat/Supabase credentials are required for
an offline app. Free authenticated apps still provide their normal Supabase
configuration. If a free feature has a named guard, declare it as follows and map
it to `null` in `FEATURE_ENTITLEMENTS`:

```json
"features": { "browse": { "access": "free" } }
```

## Client-only paid app

For one default premium entitlement, set `default_premium_guard` to `client`.
Both `FEATURE_ENTITLEMENTS` and `FEATURE_OFFERINGS` can remain the strings `"{}"`.
Use guards without `featureKey`, set `BILLING_MODE=revenuecat`, and supply the
selected platform's public SDK key. `REVENUECAT_ENTITLEMENT_ID` identifies the
entitlement; it retains the runtime default `premium` when omitted.

For named guards, declare each feature:

```json
{
  "schema_version": 1,
  "default_premium_guard": "none",
  "features": {
    "export": { "access": "premium", "enforcement": "client" },
    "browse": { "access": "free" }
  },
  "server": null
}
```

The corresponding define values, using your actual RevenueCat IDs, are:

```json
"FEATURE_ENTITLEMENTS": "{\"export\":\"premium\",\"browse\":null}",
"FEATURE_OFFERINGS": "{}"
```

Empty offerings mean the current RevenueCat offering. Optional offering mappings
can select a catalog per premium feature. Every mapping key must be declared in
the catalog; every named guard must have an entitlement mapping. Explicit
`entitlementId` overrides remain available at runtime: declare their access rules
as named catalog entries and map those entries to the same entitlement IDs.

Client guards support ordinary purchase UX and safe disabled-mode behavior.
Modified binaries can still bypass entirely local paid features.

## Server-protected paid app

Install the optional module from
[../../supabase/modules/subscriptions/README.md](../../supabase/modules/subscriptions/README.md)
and apply its SQL helper to your app's actual paid tables or APIs. Enable Supabase
auth (`optional` or `required`) and RevenueCat billing in the define file.

```json
{
  "schema_version": 1,
  "default_premium_guard": "none",
  "features": {
    "generate": { "access": "premium", "enforcement": "server" }
  },
  "server": {
    "environment": "PRODUCTION",
    "entitlement_ids": ["premium"]
  }
}
```

Map `generate` to your real entitlement ID in `FEATURE_ENTITLEMENTS`. Declare
all server-protected IDs in `server.entitlement_ids`. For an unnamed premium
guard, `default_premium_guard=server` uses `REVENUECAT_ENTITLEMENT_ID` instead.

Preflight checks auth/backend configuration, production server declaration,
installed migration/functions, and their expected JWT settings. The `server`
manifest is public configuration that describes the intended server catalog;
it does not contain private keys. Put actual RevenueCat private keys and webhook
authorization in Supabase secrets only. Production URLs require HTTPS, and the
mobile Supabase key must be publishable or a legacy anon key.

This check does not inspect your deployed Supabase project, confirm that RLS
protects every operation, or compare the manifest with live server secrets.
Verify those during backend deployment. The Flutter server-provider adapter is
still a separate integration step; backend authorization works independently
of client UI approval.

## What the gate checks

- Production environment and enabled-integration requirements.
- Selected store SDK key format, rejecting private and Test Store keys.
- Premium guards cannot ship with billing disabled or null/free mappings.
- Named feature/entitlement keys match exactly; offering keys are declared.
- Empty mappings remain valid for free apps and unnamed default premium guards.
- Duplicate JSON keys, malformed JSON, and string booleans are rejected.
- Known server-only credentials cannot be placed in the mobile define file.
- Server-protected features have the required local module/configuration artifacts.

The catalog is intentionally declared rather than inferred by scanning Dart
source. Keep it synchronized with all guards and action helpers, and test those
flows when changing features. Leaving a guard out of the catalog can evade local
consistency checks. A passing preflight does not establish that an entitlement,
product, or offering exists in RevenueCat: verify those in the dashboard and
store sandbox. The script never prints credential values or contacts external
services. Do not pass a populated server secrets file as a Flutter define file.

Run local tooling checks with:

```sh
python3 -m unittest discover -s tool -p 'test_*.py'
```

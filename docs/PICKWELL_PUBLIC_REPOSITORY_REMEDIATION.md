# T07.2A.1 — README, licensing and public-repository remediation

Date: **November 5, 2026, Philippine time**. Starting revision: **`49a3e9d`**.

**Decision: READY WITH FIXES for repository preparation under the owner's stated
review scope. This is not final demo/submission sign-off or independently verified
clearance of every third-party asset.** The owner confirmed framework/artwork
publication permission and subsequently reported the remaining icons/badges as
free, directing no further license-source research. That instruction is recorded
as an owner assumption; it is not converted into an invented upstream grant.

No push, visibility change, history rewrite, feature implementation, backend
change, deployment, billing/quota change or demo recording was performed.

## Initial blockers and disposition

| Prior finding | Current disposition |
| --- | --- |
| Project page lacked a concise product story and complete judge-facing presentation | Root README rewritten with the requested 18 topics, real setup/architecture and explicit evidence boundaries |
| StartAppLab/reference/website ownership unconfirmed | Owner confirmed their SaaS/framework and permission to publish the bundled references and website artwork; recorded in COPYRIGHT.md |
| Third-party notices missing or incomplete | Added scoped attribution, full font/icon/component/package notices and versioned inventories |
| GitHub historical Actions/artifact/release inventory unavailable | Authenticated repository-wide REST inventory completed; all relevant available collections empty, no pagination |
| Specific remaining icon/badge sources unverified | Owner reports these as free and requested no further license-source research; precise unverified status retained for 15 current files, with no new license assigned |
| Genuine final three-photo/Muse/device demonstration absent | Unchanged; this task explicitly excludes recording/testing that demo |
| Organizer terms and proprietary-entry compatibility unverified | Unchanged; actual portal terms must be checked before entry |

The prior T07.2A BLOCKED decision remains valid as its dated evidence record.
This task resolves repository presentation, ownership attestation, notices and
available GitHub inventory gaps. It does not retroactively certify a full IP audit,
real-device acceptance or formal hackathon submission.

## README and repository presentation

The README includes name/tagline, CKD-awareness motivation in the Philippines,
barcode-first shared cache, Meta Muse Spark 1.3, three-photo capture, immediate
private delivery, identity/nutrition/ingredient evidence, human-reviewed Product
Trust publication, optional approved thumbnails, Mermaid architecture, prerequisites,
Flutter/Supabase/Meta setup, public/server-only environment boundaries, development/
deployment/testing, privacy/quotas/image retention, limitations, 2024 concept versus
2026 implementation, and copyright/third-party attribution.

The 2024 concept is owner-supplied background. Earliest repository implementation
commit `de64bbd` is dated November 2, 2026; no 2024 working application or commit
history is invented. Framework reuse and new Pickwell work are distinguished.
No screenshots, performance measurements, store availability or deployment results
were fabricated.

START_HERE now points to actual setup. Mobile documentation identifies its retained
framework recipes as optional, rather than active hackathon features. Web/website
READMEs identify inherited starters, their real package commands and safe env setup.
A curated docs index preserves judge-useful implementation and historical evidence.
No implementation documents or existing third-party notices were deleted.

## Third-party inventory and resolved notices

| Inventory | Actual coverage |
| --- | --- |
| Historical assets | **216 path/blob variants, 124 paths**, enumerated from all 70 reachable commit trees at task entry; **122 current records**, including binary files and inline website artwork |
| Dart dependencies | **282** resolved package/version records, full installed root license texts and SHA-256 hashes |
| npm dependencies | **1,081** unique locked package/version records from both pnpm lockfiles, exact release license metadata; zod-to-ts missing field resolved from its release LICENSE |
| Ruby tools | **103** locked gem records; babosa/colored missing metadata resolved from exact release notices |
| Native iOS | Notices from all **four** pinned source revisions in Package.resolved |
| Python operator | Exact installed Pillow 13.0.0 MIT-CMU/PIL notice |
| Copied materials | Manrope OFL plus original embedded notices; flag-icons MIT; shadcn/ui MIT; Hugeicons MIT; identified Simple Icons CC0 and Font Awesome Free attribution |

See [scoped notices](../THIRD_PARTY_NOTICES.md),
[complete file inventories](../licenses/README.md) and their source/hash evidence.
The earlier 58-blob historical asset count was a narrower blob listing, not an
inventory of every path/version; the per-tree enumeration above is more complete.

Manrope's bundled copyright says 2019; that notice is preserved separately from the
retrieved upstream OFL's 2018 notice. No original author notice was overwritten.
All Rights Reserved remains limited to original Pickwell materials. Existing
third-party grants, GitHub service rights and applicable hackathon agreements are
explicit exceptions. No MIT/Apache/GPL license was applied to original Pickwell code.

Registry metadata is not full binary-compliance proof. MPL/LGPL and alternative
Ruby grants remain applicable to their covered components. No node_modules, gems,
Maven SDK artifacts or new app binaries are committed. Built-distribution obligations
must be evaluated against the actual files being distributed, separately from this
source-repository preparation.

## Remaining asset uncertainty and owner instruction

Fifteen current files have no independently established original source/grant:
two mobile provider SVGs, two website store badges and eleven website icon
components. Their exact paths and historical variants are recorded in
`licenses/asset-inventory.csv`. Some other icons have matching upstream geometry;
those matches do not license unrelated files.

The owner confirmed that these are free and instructed this task to ignore further
license-source research. Their current assets were therefore retained, and the
report does **not** claim verified redistribution rights or mark the provenance
fully resolved. No material prohibited license was identified in the reviewed
notices. If independent documentary proof of every asset's redistribution grant
is required for publication, that requirement remains unsatisfied.

No asset replacement was necessary for the verified font/flag/component families:
adding their notices preserves their existing grants. Remaining graphics are
referenced by reusable provider UI or starter pages and were retained under the
owner's latest instruction. Replacing/deleting only current files would not resolve
unknown grants for older versions in the preserved history.

## History and GitHub exposure findings

Read-only authenticated GitHub REST inventory for **StartAppLab/pickwell-ai**:

| Surface | Observed result |
| --- | --- |
| Repository | Private, default branch main, not a fork |
| Branches | One: main |
| Actions workflows / runs / artifacts / caches | **0 / 0 / 0 / 0** |
| Releases / tags / deployments | **0 / 0 / 0** |
| Pull requests / issues / issue comments | **0 / 0 / 0** |
| Wiki / Discussions | Disabled |
| Pagination | No further page advertised for any queried collection |

There were no available workflow logs/artifact contents, release assets or issue/PR
attachments to scan. No GitHub artifact was deleted. This inventories available
records; it does not prove that deleted/expired objects or inaccessible GitHub
backups never existed. Repository description/homepage and the returned branch
metadata were included in the focused pattern check without printing private values.

The previous complete reachable-history pattern audit remains applicable: source
and historical objects were not rewritten. Only documentation/notices changed in
this task. New/current tracked and nonignored files pass the repository's known
secret-pattern scanner. Intentional author/contact metadata remains in the genuine
history; preserving/publicizing this repository will expose that metadata. No
credential values or raw private API response files are committed.

## Focused validation and delivery

- Local Markdown target checks pass for the changed/new project documentation.
- Readme shell commands, environment variable names, model/endpoint and feature
  claims checked against repository examples, package commands and current reports.
- License manifests verify content hashes; all current inventoried asset blobs
  still match the unchanged assets. Source attribution is labeled by evidence type.
- Current/nonignored secret-pattern scan and diff whitespace check pass.
- No application code, dependency lockfile, migration, Edge Function or deployment
  setting changed, so completed Flutter/backend suites were not repeated. The prior
  analyzer, 223 Flutter, 42 backend, 21 tooling, Android build and APK scan evidence
  remains in [T07.2A](PICKWELL_SUBMISSION_READINESS.md).
- Changes committed locally for review. **Not pushed**; origin and visibility left
  unchanged. Final commit ID and working-tree status are reported in the handoff.

## Exact next steps for the existing repository

1. Review this local documentation/notices commit, including the explicitly
   owner-reported free-asset assumption. No independent asset-license clearance is
   claimed where source evidence is absent.
2. Check actual organizer rules, deadline and required materials, including
   compatibility of the retained proprietary license and reused framework history.
   Owner-supplied deadline: November 5, 2026, **10:00 AM Philippine time**.
3. With explicit authorization, push the reviewed commit to the existing
   `StartAppLab/pickwell-ai` main branch. Preserve history; do not create a substitute
   clean-history repository or force-push.
4. With separate explicit authorization, make that same repository public and verify
   evaluator access to the intended revision and documentation.
5. Complete genuine final device/Muse/demo evidence in its separately authorized
   task before claiming submission sign-off. This remediation does not record a demo,
   change the protected testing profile or certify an untested flow.

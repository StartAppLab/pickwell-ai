# Pickwell web starter

This inherited Next.js starter is retained from the owner's StartAppLab framework.
It is **not the Flutter hackathon demo** or evidence of a deployed Pickwell web app.
See the [root README](../README.md) for the submitted product and backend.

For optional starter development, use Node.js 20.18+ and pnpm, from this directory:

```sh
pnpm install --frozen-lockfile
cp env.example .env.local
pnpm dev
```

Set your own Supabase URL/public anon key and local site URL in the ignored file.
Never put service-role or Meta keys in `NEXT_PUBLIC_*` variables. Commands in
`package.json` include `pnpm build`, `pnpm start` and `pnpm lint`.
These starter checks/deployments were not performed in the repository-readiness task.

Source dependencies are locked in `pnpm-lock.yaml`. Copied shadcn/ui components and
other packages retain their upstream licenses; see
[third-party notices](../THIRD_PARTY_NOTICES.md). Starter logos and example screens
must not be presented as completed Pickwell features or real customer evidence.

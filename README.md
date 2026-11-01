# pickwell

A full-stack cross-platform application built with StartAppLab.

## Version: stable

## Quick Start

This workspace contains three applications:

- **Mobile** (`mobile/`) - Flutter app with Supabase integration
- **Web** (`web/`) - Next.js app with Supabase integration
- **Website** (`website/`) - Astro site with Cloudflare Pages deployment

## Project Structure

```
pickwell/
├── mobile/         # Flutter mobile application
├── supabase/       # Shared backend configuration
├── web/            # Next.js web application
├── website/        # Astro website
├── README.md       # This file
└── START_HERE.md   # Quick start guide
```

## Development Setup

### Prerequisites

- **Flutter 3.47.7** and [FVM](https://fvm.app/) for mobile development
- **Node.js** (20.18.0+) and **pnpm** for web development
- **Supabase CLI** for backend management

### Getting Started

1. **Clone and setup**:
   ```bash
   cd pickwell
   ```

2. **Start Supabase** (if using local development):
   ```bash
   cd supabase
   supabase start
   ```

3. **Run mobile app**:
   ```bash
   cd mobile
   dart pub global activate fvm
   fvm install
   fvm use 3.47.7
   fvm flutter pub get --enforce-lockfile
   fvm flutter run
   ```

   See [`mobile/README.md`](mobile/README.md) for code generation, environment setup, and
   native platform instructions.

4. **Run web app**:
   ```bash
   cd web
   pnpm dev
   ```

5. **Run website**:
   ```bash
   cd website
   pnpm dev
   ```

## Deployment

### Mobile (Flutter)
- **Validation**: GitHub Actions checks analysis, tests, and native builds.
- **Distribution**: Configure store signing and project-specific upload lanes for Play Store / TestFlight.
- **Manual**: `startapp deploy mobile` for local deployment

### Web (Next.js)
- **Vercel**: `startapp deploy web` or manual Vercel deployment
- **Optimized**: No double builds, proper project linking

### Website (Astro)
- **Cloudflare Pages**: `startapp deploy website` or manual Cloudflare deployment
- **Optimized**: Proper Pages configuration (no Workers conflicts)

### Deploy All
```bash
startapp deploy all
```

## Configuration

### Environment Variables

Each application needs Supabase configuration:

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Copy your project URL and anon key
3. Update environment variables in each app
4. Run the database migrations in `supabase/migrations/`

## Key Features

### Mobile App (Flutter)
- ✅ Supabase authentication
- ✅ Modern UI with Material Design 3
- ✅ State management with BLoC
- ✅ Navigation with GoRouter
- ✅ Responsive design
- ✅ Flutter 3.47.7 with Swift Package Manager on iOS

### Web App (Next.js)
- ✅ Supabase authentication
- ✅ TypeScript support
- ✅ Tailwind CSS styling
- ✅ App Router (Next.js 13+)
- ✅ ESLint configuration
- ✅ Optimized Vercel deployment (no double builds)

### Website (Astro)
- ✅ Static site generation
- ✅ TypeScript support
- ✅ Cloudflare Pages ready
- ✅ Minimal template
- ✅ Fast build times
- ✅ Proper Pages configuration (no Workers conflicts)

### Backend (Supabase)
- ✅ PostgreSQL database
- ✅ Row Level Security (RLS)
- ✅ Authentication & authorization
- ✅ Real-time subscriptions
- ✅ File storage

## Troubleshooting

### Common Issues

**GitHub CI/CD "not a git repository"**:
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-repo-url>
git push -u origin main
```

**iOS signing issues**:
- Open project in Xcode
- Select your development team
- Ensure provisioning profiles are set up
- Check Apple Developer account status

**Vercel deployment issues**:
- Ensure you're logged in: `vercel login`
- Check project linking: `vercel link`
- Verify environment variables in Vercel dashboard

**Cloudflare Pages issues**:
- Ensure you're logged in: `wrangler login`
- Check wrangler.jsonc configuration
- Verify build output directory

**Build failures**:
- Clear caches: `fvm flutter clean` or `pnpm clean`
- Reinstall dependencies: `fvm flutter pub get --enforce-lockfile` or `pnpm install`

## Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Next.js Documentation](https://nextjs.org/docs)
- [Astro Documentation](https://docs.astro.build/)
- [Supabase Documentation](https://supabase.com/docs)

---

**Built with ❤️ using StartAppLab CLI**

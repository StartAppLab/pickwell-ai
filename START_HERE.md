# Start Here

Welcome to your new StartAppLab project! This guide will help you get everything running in minutes.

## Quick Setup (5 minutes)

### 1. Choose Your Editor

**VS Code** (Recommended):
```bash
cd pickwell && code .
```

**Cursor** (AI-powered):
```bash
cd pickwell && cursor .
```

### 2. Start the Backend

```bash
cd supabase
supabase start
```

This starts your local Supabase instance with:
- PostgreSQL database
- Authentication service
- Real-time subscriptions
- Storage buckets

### 3. Run Your Apps

**Mobile App** (Flutter):
```bash
cd mobile
fvm flutter run
```

**Web App** (Next.js):
```bash
cd web
pnpm dev
```

**Website** (Astro):
```bash
cd website
pnpm dev
```

## First-Time Setup

### Install Prerequisites

**Flutter** (for mobile):
```bash
# macOS
brew install flutter

# Or download from: https://flutter.dev/docs/get-started/install
```

**Node.js & pnpm** (for web):
```bash
# Install Node.js 20.18.0+
# Then install pnpm
npm install -g pnpm
```

**Supabase CLI**:
```bash
# macOS
brew install supabase/tap/supabase

# Or install from: https://supabase.com/docs/guides/cli
```

### Environment Configuration

1. **Get Supabase credentials**:
   - Go to [supabase.com](https://supabase.com)
   - Create a new project
   - Copy your project URL and anon key

2. **Get Firebase credentials**:
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project (or use existing)
   - Go to Project Settings → General → Your apps
   - Add a web app if not already added
   - Copy your Firebase config values

3. **Update environment files**:
   ```bash
   # In web/.env.local
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

   # For mobile, copy mobile/config/app.example.json to an ignored define file.
   # Set AUTH_MODE and public Supabase credentials; see mobile/README.md.

   # In website/.env.local
   PUBLIC_FIREBASE_API_KEY=your_firebase_api_key_here
   PUBLIC_FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
   PUBLIC_FIREBASE_PROJECT_ID=your_project_id
   PUBLIC_FIREBASE_STORAGE_BUCKET=your_project_id.firebasestorage.app
   PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
   PUBLIC_FIREBASE_APP_ID=your_app_id
   PUBLIC_FIREBASE_MEASUREMENT_ID=your_measurement_id
   
   PUBLIC_SUPABASE_URL=https://your_project_ref.supabase.co
   PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

4. **Run database migrations**:
   ```bash
   cd supabase
   supabase db push
   ```

## What's Included

### Mobile App (Flutter)
- ✅ Supabase authentication
- ✅ Modern UI and pre-built widgets
- ✅ State management with Bloc
- ✅ Navigation with GoRouter

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

## 🚀 Deployment

### Mobile Apps
Mobile validation runs in GitHub Actions. Configure project-specific signing and upload lanes for distribution:

- **Android / iOS**: CI validates the starter; store uploads require release configuration.

**Manual deployment**:
```bash
# Deploy mobile apps locally
startapp deploy mobile
```

### Web & Website
Deploy with a single command:

```bash
# Deploy web app to Vercel
startapp deploy web

# Deploy website to Cloudflare Pages
startapp deploy website

# Deploy all platforms
startapp deploy all
```

## 🛠️ Development Workflow

### 1. Make Changes
- Edit code in your preferred editor
- All apps support hot reload/refresh

### 2. Test Locally
- Mobile: `flutter run` (with device/emulator)
- Web: `pnpm dev` (opens in browser)
- Website: `pnpm dev` (opens in browser)

### 3. Deploy
- Mobile: Push to GitHub (validation checks) or use `startapp deploy mobile`
- Web/Website: Use `startapp deploy` commands

## 📱 Testing on Devices

### Mobile Testing
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on iOS Simulator
flutter run -d ios

# Run on Android Emulator
flutter run -d android
```

### Web Testing
```bash
# Test on different devices
# Use browser dev tools to simulate mobile
# Or use ngrok for external testing
npx ngrok http 3000
```

## 🔍 Troubleshooting

### Common Issues

**Flutter not found**:
```bash
flutter doctor
# Follow the setup instructions
```

**Supabase connection issues**:
- Check your environment variables
- Ensure Supabase project is running
- Verify network connectivity

**Build failures**:
- Clear caches: `flutter clean` or `pnpm clean`
- Reinstall dependencies: `flutter pub get` or `pnpm install`

**Deployment issues**:

*GitHub CI/CD "not a git repository"*:
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-repo-url>
git push -u origin main
```

*iOS signing issues*:
- Open project in Xcode
- Select your development team
- Ensure provisioning profiles are set up
- Check Apple Developer account status

*Vercel deployment issues*:
- Ensure you're logged in: `vercel login`
- Check project linking: `vercel link`
- Verify environment variables in Vercel dashboard

*Cloudflare Pages issues*:
- Ensure you're logged in: `wrangler login`
- Check wrangler.jsonc configuration
- Verify build output directory

## 🎉 Next Steps

1. **Customize your app**: Update colors, fonts, and branding
2. **Add features**: Implement your business logic
3. **Set up analytics**: Add tracking and monitoring
4. **Deploy**: Push to production when ready

---

**Happy coding! 🚀**

# Web Application Development Guidelines

## Project Overview

This project is a dynamic web application built with [Next.js 16+ (App Router)](https://nextjs.org/). It serves as the core SaaS dashboard and application platform. The frontend is built using **React Server Components (RSC)** and Client Components, styled with Tailwind CSS v4.

The project is configured for deployment on **Vercel** (or compatible node hosts). It deeply integrates with:

- **Supabase**: Used for authentication, database (Postgres), and backend logic.

## Building and Running

### Prerequisites

- **Node.js** (LTS version recommended)
- **pnpm** (install via `npm install -g pnpm`)

### Setup

1.  **Install Dependencies:**

    ```bash
    pnpm install
    ```

2.  **Environment Variables:**
    Create a `.env.local` file in the root of the `web` directory by copying the `env.example`:
    ```bash
    cp env.example .env.local
    ```
    Populate the file with specific credentials (Supabase URL/Key).

### Commands

All commands are run from the `web` directory:

| Command          | Action                                                         |
| :--------------- | :------------------------------------------------------------- |
| `pnpm run dev`   | Starts the local development server at `http://localhost:3000` |
| `pnpm run build` | Builds the production application                              |
| `pnpm run start` | Starts the production server                                   |
| `pnpm run lint`  | Lints the codebase                                             |

---

## Detailed Architecture & Coding Standards

### Development Philosophy

- **Functional & Declarative**: Prefer functional patterns over imperative logic.
- **Type Safety**: strict TypeScript usage is mandatory.
- **Component-Driven**: Build small, reusable, isolated UI components.
- **SOLID Principles**: Keep components focused on a single responsibility.

### Project Structure & Module Organization

The web app is built with **Next.js App Router**.

**Key Technologies:**

- **Framework**: Next.js (App Router)
- **Styling**: Tailwind CSS v4 + Shadcn UI (Radix Primitives)
- **Languages**: **TypeScript Only** (`.ts`, `.tsx`). JavaScript is prohibited.
- **State**: Server State (preferred), React Context, Zustand (for complex client global state).

#### Folder Structure

- `src/app/` — App Router pages and layouts.
  - `src/app/(public)/` — Public routes (Landing Page).
  - `src/app/(auth)/` — Authentication routes.
    - `/login` — Sign in page.
    - `/signup` — Registration page.
    - `/forgot-password` — Password recovery.
    - `/auth/callback` — OAuth/Magic link handler.
  - `src/app/(app)/` — Protected dashboard routes.
    - `/dashboard` — Main overview.
    - `/analytics` — Usage stats.
    - `/teams` — Team management.
    - `/settings` — User & Org settings.
    - `/help` — Help & Support.
  - `src/app/api/` — API Routes.
- `src/components/` — Reusable UI blocks.
  - `src/components/assets/` — Static assets (Logos, Icons).
  - `src/components/layout/` — Layout components (Sidebar, Header).
  - `src/components/shared/` — Shared domain components.
  - `src/components/ui/` — Base UI system (Shadcn/Radix).
- `src/features/` — **Feature-based architecture**.
  - `src/features/[feature]/components/` — Feature UI.
  - `src/features/[feature]/lib/` — Feature Utils.
  - `src/features/[feature]/server/` — Server Actions.
- `src/contexts/` — Global React Contexts (e.g., Auth).
- `src/lib/` — Core utilities (Supabase client, Validation).
- `src/hooks/` — Global custom hooks.
- `src/types/` — Global type definitions (Database).

### Naming Conventions

- **Components**: PascalCase (e.g., `UserAvatar`, `DataTable`).
- **Files**: kebab-case (e.g., `user-avatar.tsx`, `data-table.tsx`).
- **Directories**: kebab-case (e.g., `src/features/auth-wizard/`).
- **Variables/Functions**: camelCase.
- **Constants**: UPPER_CASE (e.g., `MAX_RETRIES`).
- **Event Handlers**: Prefix with `handle` (e.g., `handleClick`).
- **Booleans**: Prefix with verbs (e.g., `isLoading`, `hasError`).

### Code Style

- **Tabs/Spaces**: Use Spaces (2).
- **Quotes**: Single quotes preferred.
- **Semicolons**: **Always use semicolons**.
- **Equality**: Strict equality (`===`) always.
- **Error Handling**: Handle errors explicitly in callbacks and promises.

## React & Next.js Best Practices

### Component Architecture

- **Functional Components**: Use `export function ComponentName() {}` or `export const ComponentName = () => {}`.
- **Hooks**: Isolate logic into custom hooks (`useAuth`, `useForm`).
- **Composition**: Prefer composition (children prop) over prop drilling.

### Next.js App Router Guidelines

- **Server Componenst First**: All components in `app/` are Server Components by default. Keep them that way to reduce bundle size.
- **Client Components**: Add `'use client'` ONLY when using:
  - State (`useState`, `useReducer`)
  - Effects (`useEffect`)
  - Event Listeners (`onClick`)
  - Browser APIs (`window`, `localStorage`)
- **Data Fetching**:
  - **Server**: Async/await in Server Components.
  - **Client**: SWR or React Query (if needed, but prefer Server Actions for mutations).

### Form Handling

Stack: **React Hook Form** + **Zod**.

- Define Zod schemas for all forms.
- Use `zodResolver`.
- **Submit via Server Actions**: Pass the action to `action={formAction}` or calling it in `onSubmit`.

### State Management

- **Server State**: Rely on Next.js caching and `revalidatePath`.
- **URL State**: Store filters/pagination in URL search params.
- **Global Client State**: Use **Zustand** if absolutely necessary. **Avoid Redux**.

### Assets

- **Images**: Use `next/image`.
- **Icons**: Use `lucide-react`.

## Core Development Patterns

### 1. Workflow: Adding New Pages

In Next.js App Router, the file system defines the routes.

1.  **Create Directory**: `src/app/path/to/page`.
2.  **Create Page File**: `page.tsx`.
3.  **Layout (Optional)**: `layout.tsx` for wrapping children.

```tsx
// src/app/dashboard/settings/page.tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Settings',
};

export default function SettingsPage() {
  return <div>Settings Content</div>;
}
```

### 2. Feature Colocation

Keep logic close to where it's used.

```
src/features/billing/
├── components/   # UI
├── server/       # actions.ts
├── lib/          # utils
└── types/        # definitions
```

### 3. Server Actions for Mutations

Do not use API routes (`src/app/api`) for standard mutations. Use Server Actions.

```ts
// src/features/todos/server/actions.ts
'use server'

import { revalidatePath } from 'next/cache';
import { db } from '@/lib/db';

export async function createTodo(formData: FormData) {
  // Validate and Mutate
  await db.todos.create({ ... });
  revalidatePath('/todos');
}
```

## Production Readiness Checklist

Before merging to main:

- [ ] Type-safe everywhere (no `any`).
- [ ] No console logs.
- [ ] `'use client'` is minimized.
- [ ] Metadata is accurate.
- [ ] Build passes (`npm run build`).
- [ ] Lint passes (`npm run lint`).

# Website Development Guidelines

## Project Overview

This project is a static and dynamic website built with [Astro](https://astro.build/). It serves as the main marketing and informational site. The frontend is built using a combination of Astro components (`.astro`) and React components (`.tsx`), styled with Tailwind CSS.

The project is configured for deployment on Cloudflare Pages. It integrates with two backend services:

- **Supabase**: Used for backend data services. Connection is configured in `src/lib/supabase.ts`.
- **Firebase**: Used specifically for Firebase Analytics. Connection is configured in `src/lib/firebase.ts`.

## Building and Running

### Prerequisites

- **Node.js** (v20.18.0 or newer recommended)
- **pnpm** (install via `npm install -g pnpm`)
- **Wrangler CLI** (for deployment and previewing, install via `pnpm install -g wrangler`)

### Setup

1.  **Install Dependencies:**

    ```bash
    pnpm install
    ```

2.  **Environment Variables:**
    Create a `.env` file in the root of the `website` directory by copying the `env.example`:
    ```bash
    cp env.example .env
    ```
    Populate the `.env` file with the necessary credentials for Supabase and Firebase.

### Commands

All commands are run from the `website` directory:

| Command        | Action                                                              |
| :------------- | :------------------------------------------------------------------ |
| `pnpm install` | Installs dependencies                                               |
| `make run`     | Starts the local development server at `http://localhost:4321`      |
| `make build`   | Builds the production-ready site to the `./dist/` directory         |
| `make preview` | Previews the production build locally using Cloudflare's `wrangler` |
| `make deploy`  | Builds and deploys the site to Cloudflare Pages                     |
| `make format`  | Formats all code using Prettier                                     |
| `make lint`    | Lints the codebase for errors                                       |

---

## Detailed Architecture & Coding Standards

This section contains the detailed rules and patterns for developing within the codebase.

## Project Structure & Module Organization

The website is built with **Astro v5** (static-first, partial hydration) and **React 18** (for interactivity).

**Key Technologies:**

- **Framework**: Astro (Pages/Routing) + React (UI Components)
- **Styling**: Tailwind CSS v4 (Utility-first, configured via Vite/CSS)
- **Animation**: `motion`
- **Languages**: **TypeScript Only** (`.ts`, `.tsx`). JavaScript is prohibited.
- **State**: Minimal global state.

### Folder Structure

- `src/assets/` — All icons, images, logos, shapes
- `src/components/` — Reusable UI blocks for both Astro and React.
  - `src/components/common/` — Shared, reusable Astro components (`.astro`).
  - `src/components/modals/` — Overlay components. **Strictly React (`.tsx`)**.
  - `src/components/sections/` — Major page slices (Hero, CTA, Features). **Strictly React (`.tsx`)**.
  - `src/components/shared/` — Shared, reusable React components (`.tsx`).
  - `src/components/ui/` — Base UI system. **Strictly React (`.tsx`)**.
- `src/layouts/` — **Astro Only** (`.astro` layout files)
- `src/lib/` — Business logic types, singletons (Firebase, Utils)
- `src/pages/` — **Astro Only** (Route entrypoints)
- `src/styles/` — CSS entry points (`global.css`, `theme.css`)
- `src/types/` — Extension type definitions

### Naming Conventions

- **Components**: `kebab-case.tsx` (e.g., `hero.tsx`, `pricing-card.tsx`)
- **Exports**: `PascalCase` (e.g., `export const HeroSection = ...`)
- **Pages**: `index.astro` for directories
- **Utilities**: `kebab-case.ts` (e.g., `utils.ts`, `analytics.ts`)
- **Types**: `PascalCase` for TypeScript types (inside files), filenames `kebab-case.ts`.

### Environment Variables

- Defined in `.env` (local) and Cloudflare Pages (prod).
- Typed in `env.d.ts` (updates required when adding new variables).
- Access via `import.meta.env.PUBLIC_...`

## Coding Style & Best Practices

### TypeScript Standards

- **Strict Mode**: No `any`. Define proper interfaces.
- **Strictly TypeScript**: `.js` and `.jsx` are forbidden in `src`.
- **Props**: Use `type` for props. Explicitly annotate all props.

### Astro Guidelines

- **Usage**: Only for `src/pages` and `src/layouts`.
- **No Logical Components**: Do not build UI widgets in Astro. Use React.
- **Directives**:
  - `client:load`: Above-the-fold interactive elements.
  - `client:idle`: Below-the-fold interactive elements.
  - `client:visible`: Heavy, low-priority components.

### React Policy

- **All UI MUST be React**: `sections/`, `ui/`, `modals/` must be `.tsx`.
- **Patterns**: Functional components, Hooks, `motion`.
- **Snippets**: Use `rafc` to scaffold.

### Form Handling

For building forms, the recommended stack is **React Hook Form** (`react-hook-form`) for managing form state and submission, paired with **Zod** (`zod`) for schema definition and validation.

- **Why?**: This combination provides excellent performance (uncontrolled inputs), type safety from end-to-end, and a great developer experience.
- **Implementation**: Define a Zod schema for your form, use the `useForm` hook with the Zod resolver, and connect your inputs.

### State Management

For client-side state that needs to be shared across multiple components, use **Zustand**.

- **Why?**: It's a small, fast, and scalable state management solution with a simple, hook-based API that doesn't require wrapping your application in context providers.
- **Usage**: Create a store to hold state and actions, and use the generated hook directly in your components.
- **Avoid**: Do not use Redux or other boilerplate-heavy libraries. For very simple, localized state sharing, React Context is acceptable, but prefer Zustand for anything non-trivial.

### Tailwind CSS v4

- **Configuration**: Configured via `@tailwindcss/vite` and CSS variables in `src/styles/theme.css`.
- **No Config File**: Do not look for `tailwind.config.js/mjs`.
- **Utility First**: Use utility classes for 99% of styling.
- **`cn()` Utility**: ALWAYS use `cn()` to merge classes.
- **Theme Tokens**: Use semantic classes defined in `theme.css` (e.g., `.headline`, `.subheadline`, `.section-style`).
  - _Note_: `theme.css` uses `@apply` to define these standard text/layout classes. Use them for consistency.

### File Imports

- Use Path Aliases defined in `tsconfig.json`:
  - `@/components` -> `src/components`
  - `@/lib` -> `src/lib`
  - `@/assets` -> `src/assets`
- **Never** use relative paths like `../../components`.

### Assets

- **Images**: Place in `src/assets/`. Use standard `<img>` tags with `loading="lazy"` (unless Hero).
- **Icons**: Prefer `lucide-react` or SVG components in `src/assets/icons`.

## Core Development Patterns

### 1. The "Section Config" Pattern (Crucial)

All major UI sections (Hero, Features, etc.) **MUST** separate content from layout using a configuration object.

**Why?**

- Easier for non-developers/AI to update text/images.
- Cleaner JSX components.

**Implementation:**

1.  Define `sectionConfig` at the top of the file.
2.  Include all copy (titles, subtitles, lists).
3.  Include structural data (IDs, image paths).

**Example:**

```tsx
import { cn } from '@/lib/utils';
import { MotionWrapper } from '@/components/shared/motion-wrapper';

// 1. Configuration Object
export const sectionConfig = {
  id: 'features',
  title: 'Powerful Features',
  subtitle: 'Everything you need to succeed',
  items: [
    { title: 'Fast', description: 'Blazing fast load times' },
    { title: 'Secure', description: 'Enterprise-grade security' },
  ],
};

// 2. Component Implementation
export const ExampleSection = () => {
  return (
    <section
      id={sectionConfig.id}
      className='section-style section-size' // Using theme.css classes
    >
      <div
        className='absolute -top-16'
        id={sectionConfig.id}
      />
      <MotionWrapper>
        <h2 className='headline'>{sectionConfig.title}</h2>
        <p className='subheadline mt-4'>{sectionConfig.subtitle}</p>

        <div className='mt-12 grid grid-cols-1 gap-8 md:grid-cols-2'>
          {sectionConfig.items.map((item, idx) => (
            <div
              key={idx}
              className='card p-6'>
              <h3 className='block-title'>{item.title}</h3>
              <p className='content-text'>{item.description}</p>
            </div>
          ))}
        </div>
      </MotionWrapper>
    </section>
  );
};
```

### 2. Workflow: Adding New Sections

1. **Create Directory**: Add a dedicated folder for the new section within `src/components/sections/`, using `kebab-case` (e.g., `src/components/sections/new-section/`).

2. **Create Component File**: Inside the new directory, create the React component file, named identically to the folder (e.g., `new-section.tsx`).

3. **Component Structure**:
   - Follow the structure of existing components like `pricing.tsx` or `problem.tsx`
   - Use `rafc` snippet for the basic React functional component structure
   - Define a `sectionConfig` object at the top to hold all text content, image paths, and other configuration for easy editing
   - Use a top-level `<section>` tag with standard classes like `section-style` and `section-size`
   - Include an absolute-positioned `div` with the section's `id` (matching `sectionConfig.sectionId`) for deep linking (e.g., `<div className='absolute -top-16' id={sectionConfig.sectionId} />`)
   - Use `<MotionWrapper>` for standard entrance animations

4. **Image Usage**:
   - Use standard HTML `<img>` tags for images
   - **Do not use `next/image`**. This project uses Astro + React, not Next.js
   - Include `width`, `height`, `alt`, and `loading='lazy'` attributes on all `<img>` tags

5. **Integration**:
   - Import the newly created component into the relevant `.astro` page file (e.g., `src/pages/index.astro`)
   - Update the import path to point to the new directory structure (e.g., `import { NewSection } from '@/components/sections/new-section/new-section';`)
   - Add the component tag to the Astro page's layout where you want it to appear (e.g., `<NewSection client:idle />`)
   - Use appropriate client directives (`client:load`, `client:idle`, `client:visible`) based on whether the component requires immediate JavaScript or can be loaded later

### 3. Workflow: Adding New Pages

1.  **Create Page File**: Add a new `.astro` file inside `src/pages/`. The name of the file will determine the page's URL (e.g., `src/pages/about.astro` creates the `yoursite.com/about` page).

2.  **Use a Layout**: Import and wrap your page content in a pre-defined layout from `src/layouts/` to ensure consistent headers, footers, and page structure.

    ```astro
    ---
    import Layout from '@/layouts/Layout.astro';
    ---

    <Layout title='About Us | My Company'>
      {/* Page content goes here */}
    </Layout>
    ```

3.  **Import Sections**: Import the React section components you want to use on the page from `src/components/sections/`.

    ```astro
    ---
    import Layout from '@/layouts/Layout.astro';
    import { HeroSection } from '@/components/sections/hero/hero';
    import { TeamSection } from '@/components/sections/team/team';
    ---
    ```

4.  **Add Components to Page**: Place the imported components within the layout. Use Astro's `client:*` directives to control when the components' JavaScript loads.

    ```astro
    <Layout title='About Us | My Company'>
      <HeroSection client:load />
      <TeamSection client:idle />
    </Layout>
    ```

5.  **Update SEO**: Make sure to provide a unique and descriptive `title` prop to the `Layout` component for SEO purposes.

## SEO + Accessibility

- Use `seo.astro` or `<head>` slots for meta info
- All buttons and links must be keyboard accessible
- Use `alt`, `aria-*`, and semantic HTML tags where applicable
- Follow WCAG AA contrast levels with Tailwind tokens
- Provide meaningful page titles and descriptions
- Use proper heading hierarchy (`h1` → `h2` → `h3`)

## Firebase + Supabase Usage

- **Firebase**: Only for analytics (log CTA clicks, scrolls, modal opens)
- **Supabase**: Used sparingly for things like email capture or feedback forms
- Don't bloat bundle—lazy load or tree shake if needed
- Always handle errors gracefully

## Performance & Production

- Lazy load images and motion where possible
- Use `loading="lazy"` for all non-critical images
- Hydrate only what's necessary—Astro SSR/SSG should dominate
- Audit Lighthouse before production deploy
- Minimize JavaScript bundle size
- Use Astro's image optimization when possible

## Dev & Tooling

- Prettier formats on save
- ESLint errors must be resolved before pushing
- Use `pnpm` as package manager (never npm or yarn)
- Use `utils.ts` to share helpers (e.g., `truncate`, `formatDate`)
- Use TypeScript path aliases (`@/components`, `@/lib`, etc.)

## Avoid

- No inline styles unless calculated dynamically
- Don't use class components or legacy React patterns
- Avoid premature optimization or over-architecture
- Never duplicate logic—extract to helper or partial
- Don't use `next/image` or Next.js-specific APIs
- Avoid global CSS—use Tailwind utilities

## Commit & Pull Request Guidelines

### Commit Messages

- Follow imperative style: `Add hero section view`
- Keep summaries ≤72 characters
- Bundle related work only
- Use present tense: "Add" not "Added"

### Pull Request Requirements

- Concise description of changes
- Screenshots or screen recordings for UI-facing changes
- Checklist of test commands executed
- Links to any GitHub issues
- Request review once CI (if configured) passes
- Respond to feedback with follow-up commits (avoid force pushes)

## Production Readiness Checklist

Before merging to main:

- [ ] Type-safe everywhere (no `any` or `@ts-ignore`)
- [ ] Astro/React split is clear
- [ ] All animations use `motion`
- [ ] No unused components or dead code
- [ ] Fully responsive across breakpoints (mobile, tablet, desktop)
- [ ] SEO tags present in all pages
- [ ] All components tested visually
- [ ] Lighthouse score > 90 for Performance, Accessibility, Best Practices, SEO
- [ ] All images have `alt` attributes
- [ ] Code formatted with Prettier
- [ ] No ESLint errors
- [ ] Tested in multiple browsers (Chrome, Firefox, Safari)

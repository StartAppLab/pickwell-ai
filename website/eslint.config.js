import pluginJs from '@eslint/js';
import configPrettier from 'eslint-config-prettier';
import pluginImport from 'eslint-plugin-import';
import pluginJsxA11y from 'eslint-plugin-jsx-a11y';
import pluginReact from 'eslint-plugin-react';
import pluginReactHooks from 'eslint-plugin-react-hooks';
import pluginSecurity from 'eslint-plugin-security';
import pluginTailwindcss from 'eslint-plugin-tailwindcss';
import pluginAstro from 'eslint-plugin-astro';
import tseslint from 'typescript-eslint';

// ============================================================================
// Shared Rule Sets
// ============================================================================

const tailwindRules = {
  'tailwindcss/classnames-order': 'warn',
  'tailwindcss/enforces-negative-arbitrary-values': 'warn',
  'tailwindcss/enforces-shorthand': 'warn',
  'tailwindcss/no-custom-classname': 'off',
};

const typescriptRules = {
  '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
  '@typescript-eslint/explicit-function-return-type': 'off',
  '@typescript-eslint/no-explicit-any': 'warn',
  '@typescript-eslint/no-empty-function': 'warn',
  '@typescript-eslint/no-empty-object-type': 'warn',
  '@typescript-eslint/ban-ts-comment': 'warn',
  '@typescript-eslint/consistent-type-imports': [
    'warn',
    {
      prefer: 'type-imports',
      fixStyle: 'inline-type-imports',
    },
  ],
  '@typescript-eslint/no-import-type-side-effects': 'warn',
};

const reactRules = {
  'react/react-in-jsx-scope': 'off',
  'react/prop-types': 'off',
  'react-hooks/exhaustive-deps': 'warn',
  'react/no-unknown-property': [
    'warn',
    { ignore: ['class', 'is:global', 'define:vars', 'set:html', 'set:text'] },
  ],
};

const importRules = {
  // Disable rules that don't work well without proper resolver config
  'import/no-unresolved': 'off',
  'import/named': 'off',
  'import/namespace': 'off',
  'import/default': 'off',
  'import/no-named-as-default-member': 'off',
  'import/no-duplicates': 'warn',
  'import/order': [
    'warn',
    {
      groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
      'newlines-between': 'never',
      alphabetize: { order: 'asc', caseInsensitive: true },
    },
  ],
};

const accessibilityRules = {
  'jsx-a11y/alt-text': 'warn',
  'jsx-a11y/anchor-has-content': 'warn',
  'jsx-a11y/anchor-is-valid': 'warn',
  'jsx-a11y/aria-props': 'warn',
  'jsx-a11y/aria-proptypes': 'warn',
  'jsx-a11y/aria-unsupported-elements': 'warn',
  'jsx-a11y/role-has-required-aria-props': 'warn',
  'jsx-a11y/role-supports-aria-props': 'warn',
  'jsx-a11y/heading-has-content': 'warn',
  'jsx-a11y/label-has-associated-control': 'warn',
  'jsx-a11y/click-events-have-key-events': 'warn',
  'jsx-a11y/no-static-element-interactions': 'warn',
};

const securityRules = {
  'security/detect-object-injection': 'warn',
  'security/detect-non-literal-regexp': 'warn',
  'security/detect-unsafe-regex': 'warn',
  'security/detect-buffer-noassert': 'warn',
  'security/detect-child-process': 'warn',
  'security/detect-disable-mustache-escape': 'warn',
  'security/detect-eval-with-expression': 'error',
  'security/detect-no-csrf-before-method-override': 'warn',
  'security/detect-non-literal-fs-filename': 'warn',
  'security/detect-non-literal-require': 'warn',
  'security/detect-possible-timing-attacks': 'warn',
  'security/detect-pseudoRandomBytes': 'warn',
};

const astroRules = {
  'astro/no-conflict-set-directives': 'error',
  'astro/no-unused-css-selector': 'warn',
  'astro/valid-compile': 'error',
};

// ============================================================================
// ESLint Configuration
// ============================================================================

export default tseslint.config(
  {
    ignores: [
      'dist/',
      '.astro/',
      'node_modules/',
      '*.config.{js,cjs,mjs,ts}',
      '.env*',
      'public/',
      'coverage/',
      '*.d.ts',
    ],
  },
  {
    // Global settings applied to all relevant files
    settings: {
      react: { version: 'detect' },
      tailwindcss: {
        callees: ['cn', 'cva', 'clsx'],
        cssFiles: ['src/styles/**/*.css'],
        config: {},
      },
    },
  },
  pluginJs.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ['src/**/*.{js,mjs,cjs,ts,jsx,tsx}'],
    languageOptions: {
      globals: {
        es2021: true,
        browser: true,
        node: true,
        window: true,
        document: true,
        localStorage: true,
        console: true,
        process: true,
        setTimeout: true,
        clearTimeout: true,
        setInterval: true,
        clearInterval: true,
        FormData: true,
        URL: true,
        URLSearchParams: true,
        Request: true,
        File: true,
        KeyboardEvent: true,
        HTMLButtonElement: true,
        HTMLImageElement: true,
        HTMLDivElement: true,
        HTMLInputElement: true,
        HTMLTextAreaElement: true,
        HTMLParagraphElement: true,
        HTMLHeadingElement: true,
        HTMLLabelElement: true,
        HTMLSpanElement: true,
        React: true,
      },
      parserOptions: {
        ecmaFeatures: { jsx: true },
      },
    },
    plugins: {
      react: pluginReact,
      'react-hooks': pluginReactHooks,
      import: pluginImport,
      'jsx-a11y': pluginJsxA11y,
      security: pluginSecurity,
      tailwindcss: pluginTailwindcss,
    },
    rules: {
      ...pluginReact.configs.recommended.rules,
      ...pluginReact.configs['jsx-runtime'].rules,
      ...pluginReactHooks.configs.recommended.rules,
      ...pluginImport.configs.recommended.rules,
      ...pluginJsxA11y.configs.recommended.rules,
      ...pluginSecurity.configs.recommended.rules,
      ...pluginTailwindcss.configs.recommended.rules,
      ...tailwindRules,
      ...typescriptRules,
      ...reactRules,
      ...importRules,
      ...accessibilityRules,
      ...securityRules,
      'no-console': ['warn', { allow: ['warn', 'error'] }],
    },
  },
  ...pluginAstro.configs['flat/recommended'],
  {
    files: ['**/*.astro'],
    languageOptions: {
      parserOptions: {
        parser: tseslint.parser,
        extraFileExtensions: ['.astro'],
      },
    },
    plugins: {
      react: pluginReact,
      tailwindcss: pluginTailwindcss,
      security: pluginSecurity,
    },
    rules: {
      ...astroRules,
      ...pluginTailwindcss.configs.recommended.rules,
      ...tailwindRules,
      'react/no-unknown-property': [
        'warn',
        {
          ignore: [
            'class',
            'is:global',
            'crossorigin',
            'set:html',
            'set:text',
            'define:vars',
            'is:inline',
          ],
        },
      ],
      'security/detect-object-injection': 'warn',
      // Note: jsx-a11y rules are disabled for .astro files due to AST compatibility issues
      // Accessibility is still enforced in React components (.tsx/.jsx files)
    },
  },
  // Prettier config must be last to override formatting rules
  configPrettier
);

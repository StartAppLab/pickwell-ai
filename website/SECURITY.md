# Security Best Practices for this Project

This document outlines key security checks and practices for maintaining the security of this website.

## Automated Security Audit with an LLM

You can perform a quick, automated security audit by providing the project context to a capable Large Language Model (LLM) like Cursor, Antigravity, Claude Code, Gemini CLI, or Codex.

### How to Use:

1.  Ensure your LLM has access to the entire project's file tree and file contents.
2.  Use a prompt similar to the following to initiate the audit:

> **Prompt for LLM-based Security Audit:**
>
> "Perform a thorough security check on this project. This is a marketing website built with Astro and React, deployed on Cloudflare Pages. It uses Firebase for analytics and Supabase for a newsletter email-capture form. It also serves a blog from local Markdown files. Please scan the project to understand all its features and then conduct a comprehensive security analysis, checking for vulnerabilities from every possible angle."

---

## Core Security Checks

### 1. Dependency Vulnerability Checks

Regularly auditing your project's dependencies for known vulnerabilities is crucial.

#### How to Check:

Use `pnpm audit` to scan your project for vulnerabilities in installed packages.

```bash
pnpm audit
```

#### Remediation:

- If vulnerabilities are found, `pnpm audit` will provide recommendations (e.g., `pnpm update <package-name>`).
- Always review recommended updates carefully, as they might introduce breaking changes. Refer to the package's changelog.

### 2. HTTP Security Headers and Content Security Policy (CSP)

HTTP Security Headers protect your site from various web-based attacks by instructing browsers on how to behave. A strong Content Security Policy (CSP) is especially vital for mitigating Cross-Site Scripting (XSS) vulnerabilities.

#### How to Check:

1.  **Deploy your website.** These headers are applied by the hosting environment (e.g., Cloudflare Pages) at deployment time.
2.  **Use an online security header scanner.** Websites like [securityheaders.com](https://securityheaders.com) can scan your live site and report on its HTTP security headers.

#### Configuration:

- Security headers are configured in the `public/_headers` file within this project.

### 3. Supabase Row Level Security (RLS)

If your project interacts with a Supabase backend, Row Level Security is critical for protecting your data.

#### How to Check:

1.  **Access your Supabase Project Dashboard.**
2.  Navigate to the `Authentication` -> `Policies` section or `Table Editor` and select the relevant table (e.g., `emails`).
3.  Review the RLS policies configured for each table.

#### Project Specifics (Emails Table):

- For the `emails` table (used for newsletter subscriptions), ensure RLS is **enabled**.
- The policy should _only_ permit `INSERT` operations for the `public` role. It should **not** grant `SELECT`, `UPDATE`, or `DELETE` permissions to prevent data exposure.

---

## Proactive Security Measures

This project includes several built-in architectural choices and dependencies to enhance its security posture from the ground up.

### 1. Attack Surface Reduction via Static Site Generation (SSG)

- **Architecture**: This project is configured as a fully static site (`output: 'static'` in `astro.config.mjs`).
- **Benefit**: This is the most significant security feature. All pages are pre-built into static HTML files. There is no live server or database connection responding to user requests, which eliminates entire classes of vulnerabilities, including most server-side injection attacks and remote code execution (RCE).

### 2. Cross-Site Scripting (XSS) Prevention

- **`dompurify`**: This library is used to sanitize any HTML content that is rendered dynamically (e.g., from the footer of Markdown files). It is the industry standard for preventing XSS when you must handle user-generated HTML.
- **`react-markdown`**: The library used to render blog content safely handles HTML by default, preventing malicious code in Markdown from being executed.
- **React Framework**: React automatically escapes dynamic content rendered in JSX, providing a strong baseline defense against XSS vulnerabilities.

### 3. Secure Development & Linting

- **`eslint-plugin-security`**: This ESLint plugin is configured in `eslint.config.js` to automatically scan the code for common security anti-patterns during development, catching potential issues before they are deployed.
- **TypeScript**: The project enforces a strict TypeScript policy. A strong type system helps prevent common bugs and logical errors that can lead to security vulnerabilities (e.g., unexpected inputs to sensitive functions).

### 4. Build-Time Security Checks

- **Path Traversal Mitigation**: The build script that parses blog posts (`src/lib/blog-parser.ts`) includes specific checks to prevent path traversal (`../`) in file lookups, hardening the build process itself against malicious file inclusion.

---

## Advanced Security Considerations

For a more comprehensive, defense-in-depth strategy, consider the following areas:

### 1. Infrastructure & Deployment Security

- **DNSSEC:** Enable DNSSEC in your domain registrar and Cloudflare dashboard to protect against DNS spoofing.
- **SSL/TLS Mode:** Ensure your SSL/TLS encryption mode in Cloudflare is set to **"Full (Strict)"** for end-to-end encryption.
- **WAF & DDoS Protection:** Be aware of Cloudflare's default DDoS protection and Web Application Firewall (WAF). Configure custom rules to block malicious traffic patterns as needed.

### 2. Process & Team Security

- **Principle of Least Privilege:** Grant team members the minimum level of access required for their roles in GitHub, Supabase, and Firebase.
- **GitHub Branch Protection:** Protect your `main` branch by requiring pull requests and code reviews before merging changes.
- **Credential Security:** Enforce strong, unique passwords and Two-Factor Authentication (2FA) for all development-related services (GitHub, Cloudflare, domain registrar, etc.).

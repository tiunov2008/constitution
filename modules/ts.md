# Module TS: TypeScript monorepo

Applies to projects with TypeScript apps or packages. Part of the Engineering Constitution; the version
is in `core.md`. Rule format and levels follow the core (CORE-02): a bullet without SHOULD, SHOULD NOT
or MAY is a MUST.

### TS-01 · Monorepo and package manager

- Turborepo with pnpm workspaces. `packageManager` is pinned exactly (`pnpm@x.y.z`); the Node version is
  pinned exactly in `.node-version`, and `engines.node` matches it (CORE-60).
- Every package offers the same task names where they apply: `lint`, `typecheck`, `test`, `build`. The
  root adds `format:check`. (Projects that use `check-types` rename it when they adopt this module.)
- In `turbo.json`, `build` depends on `^build`; `dev` has `cache: false` and `persistent: true`;
  environment variables that change outputs are declared (`globalEnv` or the task's `env`); Next.js
  outputs exclude `.next/cache`.
- Packages are named `@<project>/<name>` and consumed through `workspace:*`.

*Why*: the same commands work in every repository, for the owner and for agents.
*Check*: `pnpm turbo run lint typecheck test build` runs from the root.

### TS-02 · Shared configuration and layout

- TypeScript and ESLint configurations live in workspace packages (`@<project>/typescript-config`,
  `@<project>/eslint-config`), and every package extends them.
- Internal packages export TypeScript sources and need no build step of their own unless they are
  published.
- SHOULD: sources in `src/` with an `index.ts` entry; file names in kebab-case; schemas named
  `...Schema`; constants in SCREAMING_SNAKE_CASE.
- SHOULD: Next.js apps keep `src/app`, `src/components`, `src/lib` and `src/modules/<domain>/`, with
  tests next to the code.

*Why*: one place to change a compiler or lint setting for the whole repository.
*Check*: no package carries its own copy of the base configuration.

### TS-03 · Compiler strictness

- `strict`, `noUncheckedIndexedAccess` and `isolatedModules` are on. No package turns them off.
- SHOULD: `exactOptionalPropertyTypes` and `verbatimModuleSyntax` are on.
- `any` and `@ts-ignore` are not used (CORE-10). When a type error comes from a known defect in a
  dependency's types, `@ts-expect-error` carries the reason and a link.
- SHOULD NOT: non-null assertions (`!`).

*Why*: the type checker is the cheapest test there is.
*Check*: the base `tsconfig` sets the flags; lint rules flag `any`, `@ts-ignore` and bare
`@ts-expect-error`.

### TS-04 · Lint and format

- ESLint runs with `--max-warnings 0`.
- One Prettier configuration for the repository. `prettier --check` runs in CI in every stage
  (CORE-62).

*Why*: warnings that are allowed to stay are never read.
*Check*: the lint and format scripts carry these flags.

### TS-05 · Web framework

- The default web framework is Next.js with the App Router and `output: "standalone"`.
- A Vite single-page app is allowed for internal or admin interfaces that need no server rendering.
- The addendum records the framework of each web app (CORE-06).
- A Next.js app commits the agent notice that `next dev` writes into `apps/<app>/AGENTS.md` (read the
  bundled guide in `node_modules/next/dist/docs/` before writing code), and agents follow it.
- `next build` never needs runtime secrets: code that reads the session or runtime secrets awaits
  `connection()` before touching them, and auth and database clients are created lazily (a `getX()`
  function, not at module load). SHOULD: such helpers are wrapped in React `cache()` so that one request
  makes one call.

*Why*: Next.js changes faster than agents' training data, and a build that needs secrets leaks them
into images.
*Check*: `next build` succeeds without production secrets in the environment.

### TS-06 · Schemas and types

- One schema library per repository, zod unless the addendum names another. Types and defaults are
  inferred from schemas, not written twice (CORE-23).
- SHOULD: branded types for identifiers; errors returned as values (discriminated unions) inside domain
  code rather than thrown.

*Why*: one schema serves types and defaults.
*Check*: no second schema library in the lock file.

### TS-07 · Prisma

- Prisma Migrate owns the schema (CORE-40). `prisma migrate deploy` is the only way migrations reach the
  production environment (DOKPLOY-03). `prisma db push` is used only for throwaway local databases.
- The generated Prisma client is not committed. It is generated on install or build, and in CI.
- *(production)* CI applies all migrations to a clean database and fails when `schema.prisma` differs
  from the migrations (`prisma migrate diff` with `--exit-code`) (CORE-62).
- Where the project has invariants that every query must respect (tenant scoping, soft-delete filters,
  audit entries), they are enforced in a code path all queries go through (for example a Prisma client
  extension) and covered by tests.
- SHOULD NOT: upserts keyed on nullable columns (NULL never conflicts, so duplicates appear).

*Why*: the schema file and the migrations must never tell two different stories.
*Check*: the CI drift step; `.gitignore` excludes the generated client.

### TS-08 · Authentication and server actions

- Authentication uses Better Auth from a workspace package (`@<project>/auth`).
- Every server action and route handler checks the session and the permission before anything else,
  unless the spec lists it as public (CORE-12).
- SHOULD: server actions return `ActionResult<T>`; the user-facing message is built in the action, and
  lower layers return codes and data.

*Why*: an action that forgets the check is a public endpoint.
*Check*: a test or lint rule finds non-public actions without the session check.

### TS-09 · Browser-facing configuration

- Public build-time variables (`NEXT_PUBLIC_*`, `VITE_*`) never carry secrets. Only variables with an
  allow-listed prefix are passed to the build.
- SHOULD: security headers (Content-Security-Policy with `frame-ancestors`, `X-Content-Type-Options`,
  `Strict-Transport-Security`) are built by pure functions covered by tests.

*Why*: anything in the client bundle is public.
*Check*: the build receives variables only through the allow-list.

### TS-10 · Logging

- One logger, pino unless the addendum names another. `console.*` is not used for application logs.
  Redaction is configured for credentials (CORE-52).

*Why*: structured logs only stay structured when there is one way to write them.
*Check*: a lint rule forbids `console` outside scripts.

### TS-11 · Tests

- Vitest unless the addendum names another runner. Unit tests sit next to the code (`*.test.ts`).
  Integration tests (`*.integration.test.ts`) run against a real PostgreSQL.
- The test configuration sets `TZ=UTC` (CORE-42).
- *(production)* Playwright e2e tests of the critical user flows run in CI (CORE-62).
- SHOULD: a test fails when server-only code reaches the client bundle.
- MAY: type-level tests (`*.typecheck.ts`) for compile-time contracts.

*Why*: tests next to the code get updated with the code.
*Check*: CI runs unit and integration suites separately and reports both.

### TS-12 · Supply chain

- `pnpm-workspace.yaml` sets `minimumReleaseAge: 1440` or more (minutes; CORE-61) and an explicit
  `allowBuilds` map of the packages whose install scripts may run (pnpm 11 or later).

*Why*: install scripts run with the developer's and CI's permissions.
*Check*: `pnpm-workspace.yaml` sets both.

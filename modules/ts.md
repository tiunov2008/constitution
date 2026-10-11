# Module TS: TypeScript monorepo

Applies to projects with TypeScript apps or packages. Part of the Engineering Constitution; the version
is in `core.md`. Defaults, rules and recipes are used as CORE-02 defines them: a bullet without SHOULD,
SHOULD NOT or MAY is a MUST.

## Defaults

The addendum copies this table into its module parameters and keeps or replaces each value (CORE-06).

| Parameter | Default |
|---|---|
| Monorepo tool | Turborepo |
| Web framework per app | Next.js with the App Router and `output: "standalone"`; a Vite single-page app for internal tools that need no server rendering |
| Styling | Tailwind CSS |
| Database access and migrations | Prisma (TS-07) |
| Authentication | Better Auth in the workspace package `@<project>/auth` |
| Schema library | zod |
| Logger | pino |
| Test runner | Vitest; Playwright for e2e |
| Node version pinned in | `devEngines.runtime` in the root `package.json`, with `onFail: "download"` |

## Rules

### TS-01 · Package manager and tasks

- pnpm workspaces. `packageManager` is pinned exactly (`pnpm@x.y.z`). The Node version is pinned exactly
  in one place that the addendum names (for example `devEngines.runtime` or `engines.node` in the root
  `package.json`, or `.node-version`); every other place that states it, such as a Dockerfile or the CI
  setup, matches it (CORE-60).
- Every package offers the same task names where they apply: `lint`, `typecheck`, `test`, `build`. The
  root adds `format:check`. SHOULD: the root also offers `check`, which runs the whole gate (CORE-62).

*Why*: the same commands work in every repository, for the owner and for agents.
*Check*: `lint`, `typecheck`, `test` and `build` run for every package from the root.

### TS-02 · Shared configuration

- One base TypeScript configuration and one ESLint configuration live in workspace packages (for
  example `@<project>/typescript-config` and `@<project>/eslint-config`), and every package extends
  them.

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

### TS-05 · Builds without secrets

- Building a web app (`next build`, `vite build`) never needs runtime secrets, and the build receives
  none. The recipe "Building without secrets" shows how for Next.js.

*Why*: a build that needs secrets bakes them into images.
*Check*: the build succeeds in CI with no production secrets in the environment.

### TS-06 · Schemas and types

- One schema library per repository. Types and defaults are inferred from schemas, not written twice
  (CORE-23).

*Why*: one schema serves validation, types and defaults.
*Check*: no second schema library in the lock file.

### TS-07 · Prisma

Applies where Prisma owns a schema.

- Prisma Migrate owns the schema (CORE-40). `prisma migrate deploy` is the only way migrations reach the
  production environment (DOKPLOY-03). `prisma db push` is used only for throwaway local databases.
- The generated Prisma client is not committed. It is generated on install or build, and in CI.
- *(production)* CI applies all migrations to a clean database and fails when `schema.prisma` differs
  from the migrations (`prisma migrate diff` with `--exit-code`) (CORE-62).
- Where the project has invariants that every query must respect (tenant scoping, soft-delete filters,
  audit entries), they are enforced in a code path all queries go through (for example a Prisma client
  extension) and covered by tests.

*Why*: the schema file and the migrations must never tell two different stories.
*Check*: the CI drift step; `.gitignore` excludes the generated client.

### TS-08 · Authentication checks

- Authentication lives in one workspace package that every app uses.
- Every server action and route handler checks the session and the permission before anything else,
  unless the spec lists it as public (CORE-12).

*Why*: an action that forgets the check is a public endpoint.
*Check*: a test or lint rule finds non-public actions without the session check.

### TS-09 · Browser-facing configuration

- Public build-time variables (`NEXT_PUBLIC_*`, `VITE_*`) never carry secrets. Only variables with an
  allow-listed prefix are passed to the build.

*Why*: anything in the client bundle is public.
*Check*: the build receives variables only through the allow-list.

### TS-10 · Logging

- One logger. `console.*` is not used for application logs. Redaction is configured for credentials
  (CORE-52).

*Why*: structured logs only stay structured when there is one way to write them.
*Check*: a lint rule forbids `console` outside scripts.

### TS-11 · Tests

- Integration tests (`*.integration.test.ts`) run against a real PostgreSQL, separately from unit tests.
- The test configuration sets `TZ=UTC` (CORE-42).
- *(production)* e2e tests of the critical user flows run in CI (CORE-62).

*Why*: integration tests against a real database catch what mocks hide.
*Check*: CI runs unit and integration suites separately and reports both.

### TS-12 · Supply chain

- `pnpm-workspace.yaml` sets `minimumReleaseAge: 1440` or more (minutes; CORE-61) and an explicit
  `allowBuilds` map of the packages whose install scripts may run (pnpm 11 or later).

*Why*: install scripts run with the developer's and CI's permissions.
*Check*: `pnpm-workspace.yaml` sets both.

## Recipes

- **Node through pnpm.** With `devEngines.runtime` (`{"name": "node", "version": "x.y.z", "onFail":
  "download"}`), pnpm downloads that Node when the machine has another one and runs every script with
  it, so local runs, CI and agents use one version without a version manager. pnpm refuses to install a
  project whose own `engines.node` does not match the running Node, so do not pin `engines.node` to a
  version that differs from the runtime.
- **Turborepo.** `build` depends on `^build`; `dev` has `cache: false` and `persistent: true`;
  environment variables that change outputs are declared (`globalEnv` or the task's `env`); Next.js
  outputs exclude `.next/cache`.
- **Packages.** Name packages `@<project>/<name>` and consume them through `workspace:*`. Internal
  packages export TypeScript sources and need no build step of their own unless they are published.
  Sources live in `src/` with an `index.ts` entry; file names are kebab-case; schemas are named
  `...Schema`; constants are SCREAMING_SNAKE_CASE.
- **Next.js layout.** `src/app`, `src/components`, `src/lib` and `src/modules/<domain>/`, with unit
  tests (`*.test.ts`) next to the code.
- **Next.js and agents.** `next dev` writes an agent notice into `apps/<app>/AGENTS.md` that points to
  the guide bundled in `node_modules/next/dist/docs/`. Commit it, and read the guide before writing
  Next.js code: Next.js changes faster than agents' training data.
- **Building without secrets (TS-05).** Code that reads the session or runtime secrets awaits
  `connection()` before touching them. Auth and database clients are created lazily (a `getX()`
  function, not at module load) and wrapped in React `cache()`, so that one request makes one call.
- **Types.** Branded types for identifiers. Inside domain code, errors are returned as values
  (discriminated unions) rather than thrown. Type-level tests (`*.typecheck.ts`) protect compile-time
  contracts.
- **Server actions.** Return `ActionResult<T>`. The user-facing message is built in the action; lower
  layers return codes and data.
- **Security headers.** Content-Security-Policy with `frame-ancestors`, `X-Content-Type-Options` and
  `Strict-Transport-Security`, built by pure functions covered by tests.
- **Prisma upserts.** An upsert keyed on a nullable column creates duplicates, because NULL never
  conflicts.
- **Client bundle.** Mark server-only modules with `import "server-only"`, so that the build fails when
  one reaches the client bundle.

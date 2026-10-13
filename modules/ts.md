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
| Authorization | CASL (`@casl/ability`) with `@casl/prisma`, in `@<project>/authz` (TS-13) |
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
- Where the project has invariants that every query must respect (a tenant column that every row of a
  model carries and every query of that tenant's users matches, soft-delete filters, audit entries),
  they are enforced in a code path all queries go through (for example a Prisma client extension) and
  covered by tests. Authorization filters that depend on roles, state or relations follow TS-13.

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

### TS-13 · Data access and authorization

Applies where some user may not read some of the records or fields that a TypeScript app reads from its
database (protected data), for example in an application with more than one role or more than one
tenant, or one whose users each see only their own records. Records that every signed-in user may read
in full (reference data, listed in the addendum) are not protected data.

- The authorization rules (who may do what with which records and fields, and which records each list
  shows) are declared once, in one workspace package. Every permission check (TS-08) asks them about the
  record (`ability.can(action, subject(type, record))`) or through a filter derived from them. A check on
  the type alone (`ability.can(action, type)`) is true when any rule exists, whatever its conditions, so
  it decides only whether an entry point is shown.
- The visibility filter of a query (which rows of a list or a read the acting user may see or act on)
  comes from the rule of that action. It is derived from the rule (with the default,
  `accessibleBy(ability, action)` of `@casl/prisma`), not written a second time by hand (CORE-23). Where
  a rule cannot be expressed as a query condition, a hand-written twin is allowed; a test then holds it
  equal to the rule over every role, every combination of roles that one account may hold, and the cases
  of each column, relation and actor attribute the rule reads (each enum value; a matching, another and
  a null id; no, a closed and an open related row). Cases with a negated condition on a nullable column
  run against PostgreSQL (TS-11).
- A filter, search, sort or grouped count that the browser can set on a field reads that field only on
  the records on which the rules let the acting user read it. A test per role, and per combination of
  roles, shows that the filter cannot match a record whose field the role may not read.
- A value import of the database client (the client object or a factory of it; its types and enums are
  free) appears only in the data-access layer (query functions, server actions and route handlers) and
  in the code the addendum lists (for example the authentication package's database adapter, seeds,
  data migrations, scripts and job handlers). Pages, layouts and components call that layer; for
  TypeScript apps in scope this narrows the MAY of CORE-21. A lint rule applied to every file outside
  those paths enforces it (`no-restricted-imports` with `importNames` and `allowTypeImports`; CORE-20).
  A data-access function that reads or writes protected data takes the acting user, or the ability
  built for them, as a parameter, except in the code the addendum lists as running without a user.
- What leaves the server for the browser (what components render or receive as props, server action
  results, route handler responses, redirect targets and error messages) is built for the browser
  alone, by a DTO builder or a `select` that serves nothing else, naming each field and limited to the
  fields the rules let the acting user read on that record. A whole ORM row, a spread of one, and a row
  selected for server logic as well (commands, bulk actions) are not sent. For each page, data-returning
  server action and route handler that sends protected data, a test for each role that may open it
  checks that no record in the serialized output carries a value the rules do not let that role read on
  that record.
- SHOULD: the derived row filter of every protected model is applied in the code path that TS-07 sets up
  for invariants every query must respect (a tenant column stays a MUST there), by a Prisma client
  extension built for the acting user, so that a top-level query of a protected model cannot forget the
  filter. Reads that the extension does not see (a protected model read through a relation of another
  model, the fluent API, raw SQL) are refused by that client or carry a hand-written filter with its
  comparison test. The unscoped client is exported only to the code the addendum lists.

*Why*: a policy that is right still leaks when one query forgets to ask it, when a query restates it by
hand and drifts, when a filter matches on a field that the row withholds, or when the server sends whole
rows and only the screen hides the fields.
*Check*: the lint rule on the client's value imports covers every file outside the listed paths; every
hand-written row filter has its comparison test, and every field the browser can filter or search on has
its test per role; each page, data-returning server action and route handler that sends protected data
has a payload test per role; review finds no permission check that asks a conditional rule about the
type alone.

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
- **CASL with Prisma (TS-13).** Build the ability with `createPrismaAbility` instead of
  `createMongoAbility`: conditions are Prisma `WhereInput`, and the same rules check one record in
  memory (`ability.can("read", subject("Candidate", row))`) and filter a query
  (`where: { AND: [accessibleBy(ability, "read").ofType("Candidate"), filters] }`). Write conditions on
  columns and relations, not on computed values: a fact the rules need is a column, or a condition on
  the columns it is made of (`{ verifiedAt: { not: null } }`,
  `{ participations: { some: { companyId, endedAt: null } } }`). A relation condition always names
  `some`, `every`, `none`, `is` or `isNot`; without one, and for JSON or list equality, the in-memory
  check throws `ParsingQueryError`, while `accessibleBy` passes the condition to Prisma unchanged.
- **Where memory and SQL disagree (TS-13).** The record checked in memory carries every column and
  relation the conditions read: a relation that was not loaded makes a `can` on it false but skips a
  `cannot` on it, so the record is allowed, and a column left out of a loaded relation's `select`
  matches `null`. A negated condition on a nullable column (`not`, `notIn`, `NOT`) matches NULL in
  memory but not in PostgreSQL: name the NULL case
  (`{ OR: [{ regionId: null }, { regionId: { not: r } }] }`) or write the positive condition.
- **Empty rules fail open without the extension (TS-13).** For a user without a matching rule `ofType`
  returns `{ OR: [] }`. Prisma reads it as false only at the top of `where` and drops it inside `AND`,
  so `{ AND: [accessibleBy(...), filters] }` returns every row that `filters` matches. Add
  `createCaslExtension()` to every client that runs these queries, as its last `$extends`: it makes any
  `where` that contains an empty `OR` match nothing (`findMany` gives `[]`, `count` 0, `findUnique`
  `null`; the `OrThrow` reads, `update` and `delete` throw), also an empty `OR` that business code
  builds, `NOT` included. It reads only the top-level `where`, not the `where` of a nested `include` or
  `select`.
- **Prisma 7 and `@casl/prisma` (TS-13).** With the `prisma-client` generator, import from
  `@casl/prisma/runtime` through a small wrapper in the database package that binds the generated
  `Prisma.TypeMap` (`PrismaQueryOf<Prisma.TypeMap, T>` with `T extends PrismaModel`) and re-exports
  `accessibleBy`, `createPrismaAbility` and `createCaslExtension`. The main entry's types read
  `Prisma` from `@prisma/client`, which that generator does not fill.
- **Rules package (TS-13).** The rules package depends on the database package and is depended on by
  every server package that asks it. Client components do not import it: `@casl/prisma` loads
  `@prisma/client` when imported. Keep browser-safe constants (roles, statuses, field groups) in a
  package of their own.
- **Field-aware filters (TS-13).** `accessibleBy` ignores field lists. For a filter or search on a
  field, build the condition from the rules that grant that field, with the conversion `accessibleBy`
  uses: `rulesToCondition(ability.rulesFor(action, type, field), toWhere, hooks)` from
  `@casl/ability/extra`, where `toWhere` returns `{ NOT: rule.conditions }` for an inverted rule and
  `rule.conditions` otherwise, and `hooks` builds `{ AND }`, `{ OR }` and `{}` for empty. Use
  `{ OR: [] }` when it returns `null`, and AND the result with the filter.
- **Comparison tests (TS-13).** `prismaQuery(where)` of `@casl/prisma` evaluates a hand-written
  `WhereInput` in memory, so the test can compare it with `ability.can` over the generated cases without
  a matcher of its own; the NULL cases above still run against PostgreSQL.
- **Field lists (TS-13).** `permittedFieldsOf` from `@casl/ability/extra` gives the fields one user may
  read on one record (`fieldsFrom: (rule) => rule.fields ?? ALL_FIELDS`; pass the record wrapped in
  `subject()`, because with the type name alone the conditions are ignored and the fields of every rule
  come back). Build the DTO from that list and type client components with a branded DTO type that only
  the builder returns (a `unique symbol` property, as in the Types recipe), so that passing an ORM row
  fails the type check; a plain object type accepts a row, because TypeScript allows extra properties.
- **Scoped client (TS-13).** `dbFor(ability)` returns
  `base.$extends(scope(ability)).$extends(createCaslExtension())`. Prisma runs query hooks in the order
  the extensions were added, so with the CASL extension first it never sees the condition the scope
  adds, and a user without rules reads every row. The scope's `query` component merges
  `accessibleBy(ability, action).ofType(model)` into `where` as
  `{ ...where, AND: [filter, ...[where?.AND ?? []].flat()] }` (Prisma accepts `AND` as one object or a
  list), which keeps a unique field at the top level: `read` for `findMany`, `findFirst`,
  `findFirstOrThrow`, `findUnique`, `findUniqueOrThrow`, `count`, `aggregate` and `groupBy` of each
  protected model, and the write's action for `update`, `updateMany`, `upsert`, `delete` and
  `deleteMany`. A hook runs only for the model a call starts from: a protected model read through
  `include` or `select` of another model or through the fluent API
  (`db.company.findUnique(...).participations()`), a relation filter of another model, and `$queryRaw`
  are not filtered by it. Every protected model the scope covers needs rules first, or it reads as
  empty. Keep `dbFor` in the database package, typed with its `PrismaAbility` rather than the app's
  ability type, so that the rules package depends on the database package and not the reverse
  (CORE-20).
- **Payload tests (TS-13).** Seed the fixture with recognisable values the role may not read (a phone
  number, another tenant's id and name), call the function that builds the page's props, the action
  result or the response as that role, and assert per record: no record of the output carries a value
  the role may not read on it. A check on the whole payload fails when the same value appears
  legitimately elsewhere (a filter option, the user's own tenant). Next.js's `experimental.taint`
  enables React's `experimental_taintObjectReference` and `experimental_taintUniqueValue`, which throw
  when that exact object or value is passed to a Client Component. It switches the `app` directory to
  React's experimental channel and tracks references only: a spread, a copy or a DTO built from a
  tainted row is not tainted. It complements the test and does not replace it.

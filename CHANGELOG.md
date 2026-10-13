# Changelog

One entry per version, newest first (CORE-04). A project that moves its pin reads every entry between
its old and its new version (CORE-05).

## 2.2.0 (2026-10-13, MINOR, owner command)

- New rule TS-13 "Data access and authorization", for apps where some user may not read some records or
  fields: the authorization rules are declared once and every permission check asks them about the
  record; the visibility filters of queries are derived from them, and a hand-written query twin of a
  rule comes with a test that holds it equal to the rule; a filter or search on a field matches only
  where the field is readable; only the data-access layer and the code the addendum lists import the
  database client, enforced by a lint rule; the browser gets fields built for it alone, checked per role
  by a payload test. SHOULD: a client extension built for the acting user applies the row filter to
  every top-level query of a protected model and refuses the reads it cannot filter.
- TS-13 narrows the MAY of CORE-21 (plain data access from server code) for TypeScript apps in its
  scope, and makes CORE-20's lint SHOULD a MUST for value imports of the database client. TS-07 now
  says which invariants it means by tenant scoping (a tenant column every row carries); authorization
  filters that depend on roles, state or relations follow TS-13.
- New TS default: CASL (`@casl/ability`) with `@casl/prisma` for authorization, in `@<project>/authz`,
  also in the template's module parameters. New recipes: CASL with Prisma, where memory and SQL
  disagree, empty rules and `createCaslExtension()`, Prisma 7's `prisma-client` generator, the rules
  package, field-aware filters, comparison tests, field lists, the scoped client, payload tests.
- Reason: in a project whose policy was right, a list page sent every row's company ids to the browser
  next to the names a filter offered, so a cell that showed a dash still gave the company away; a
  company filter matched rows whose company the account could not read; and a hand-written query twin
  of a policy rule was wider than the rule. All three passed review and tests, because nothing tied the
  query to the rule or checked what left the server.
- When moving the pin: add the Authorization row to the module parameters (keep CASL, or name the
  project's library: an owner decision, CORE-02). Record each gap as a task or a standing exception
  (CORE-05): permission checks that ask a conditional rule about the type alone; database-client value
  imports outside the listed paths; data-access functions without the acting user; filters and searches
  on fields the row may withhold; what the browser gets built from whole rows or from rows selected for
  server logic; pages, actions and route handlers that send protected data without a payload test per
  role; hand-written row filters without a comparison test. With CASL on `createMongoAbility`, write the
  comparison test for each hand-written filter first; the move to `createPrismaAbility` and
  `accessibleBy` is a task of its own (it rewrites every condition and moves the rules to a package that
  depends on the database package and that no client component imports). Where a list shows rows that
  its `read` rule does not cover, deriving the list's filter from `read` changes the list and needs the
  owner (CORE-11). A project without the scoped client records the SHOULD deviation with its reason
  (CORE-02); with it, every protected model the client covers needs rules first. The starter adopts
  TS-13 in a change of its own.

## 2.1.0 (2026-10-11, MINOR, owner command)

- The deployment runbook DEPLOY.md lives in `docs/DEPLOY.md` instead of the repository root (the
  definition in core.md; the rules that name DEPLOY.md are unchanged). quickstart.md says the same.
- Reason: owner decision.
- When moving the pin: `git mv DEPLOY.md docs/DEPLOY.md` and update the links to it (AGENTS.md, README,
  CI notices).

## 2.0.1 (2026-10-11, PATCH, owner command)

- quickstart.md: a new project is a copy of the starter in a new history, made with `gh repo clone`, and
  `scripts/init-project.mjs` adds the constitution submodule at the pinned version; step 6 creates the
  GitHub repository. The definition of Starter in core.md says the same.
- Reason: a repository generated from the starter with "Use this template" stayed empty for more than
  eight minutes, and GitHub templates do not reliably carry submodules. The same check found two traps
  that the starter now handles: `next dev` moving to another port, which broke sign-in, and Windows path
  limits in the submodule clone.
- When moving the pin: nothing required.

## 2.0.0 (2026-10-11, MAJOR, owner command)

The constitution becomes a fast start on the ready stack plus the rules that keep projects cheap to
change. Its content is split into rules, defaults and recipes (CORE-02); what no rule covers needs no
approval and no record.

- New: `quickstart.md` (a new project from the starter template, adoption in an existing project,
  moving the pin); `CHANGELOG.md` replaces the Sync Impact Report at the top of `core.md`;
  `scripts/check-pin.sh` replaces the command in the README; `scripts/check-constitution.sh` checks IDs
  and versions of this repository.
- Governance: CORE-02 defines defaults and recipes. CORE-03 adds standing exceptions in the addendum's
  deviations table. CORE-04 moves the change log to `CHANGELOG.md`, counts relaxations that keep every
  compliant project compliant as PATCH, and keeps a rule only while it pays for itself. CORE-05 starts
  new projects from the starter and runs the pin check script. CORE-06 asks for the choice behind each
  default of the applied modules instead of naming module parameters itself, and no longer asks for
  rejected alternatives. CORE-07: in development, the areas of CORE-81 need only the task.
- CORE-10: the gate steps run for the affected packages and their dependents; a documentation-only
  change needs the format check; the full gate runs in CI before a merge.
- CORE-11: agents commit and push to the task's branch and open pull requests without a separate
  command; merging into `main` still needs one. Replacing a default is an owner decision.
- CORE-12: the environment templates moved to CORE-24, which also accepts a variable list in DEPLOY.md
  where a secret store injects the variables.
- CORE-13: nobody types DDL or DML into a production database; a one-off data fix is a committed data
  migration or script, run after a fresh backup.
- CORE-20, CORE-21 (renamed "Side effects at the edges"), CORE-22: what remains MUST is no import
  cycles, no silent fakes in production, vendors behind the project's own interfaces, and measured
  optimisation claims; the rest became SHOULD. Plain data access may call the database directly.
- CORE-30: each contract has one current description, derived from code where possible; a feature's
  `contracts/` folder describes the change.
- CORE-61 (renamed "Dependencies"): an agent adds a library that meets the stated criteria without
  asking; replacing a default or adding a second library for a filled role is an owner decision. The
  dependency justification left CORE-22.
- CORE-62: dependency audits and image scans run in the production gate only.
- CORE-63: branch names for work outside spec-kit.
- CORE-70: fixes, small changes, dependency updates, docs and chores go straight to a pull request;
  spec-kit is for features. CORE-71: the Constitution Check states the NON-NEGOTIABLE rules and lists
  only the rules a plan does not meet as written.
- CORE-81: deleting tracked files within a task is not irreversible; the named confirmation for schema,
  authentication, CI and public contracts applies in production only.
- Modules: each has Defaults, Rules and Recipes sections. Library choices became defaults (Turborepo,
  Next.js, Prisma, Better Auth, zod, pino, Vitest, Playwright, FastAPI, pydantic-settings, mypy,
  psycopg, alembic, goose, `log/slog`, Riverpod); Tailwind CSS is the new TS styling default.
  Mechanisms and conventions moved to recipes. TS-05 is now "Builds without secrets", TS-08
  "Authentication checks", DOKPLOY-03 "Migrations before start" (bootstrap and storage initialisation
  may also run in the application's start-up), DOKPLOY-04 covers every public service,
  FL-02 adds the format check. New DOKPLOY defaults: CI builds the `web` and `tools` images after the
  gate and pushes them to GHCR or a registry on the Dokploy server; Dokploy only pulls; a push to `main`
  deploys the test environment and a tag promotes the same images to production through the Dokploy
  API. The Node pin default is `devEngines.runtime`, which pnpm downloads when the machine has another
  Node.
- Retired IDs: FL-01, GO-01, JOBS-05, LLM-04, PY-04, PY-07 (now recipes).
- Also: the constitution names no projects; the README is shorter; the decision log and the list of
  gaps in existing projects were removed.
- When moving the pin: replace the entry file's tables with those of the new template (module
  parameters; one deviations table for standing SHOULD deviations and exceptions, including adoption
  gaps); drop the rejected-alternatives section or keep it as project notes; run
  `sh .specify/constitution/scripts/check-pin.sh` in CI instead of the old inline command; use the
  short Constitution Check from the next plan on.

## 1.0.4 (2026-10-06, PATCH, owner command)

- CORE-62 names what the secret scan covers: the commits that the push or pull request adds. A secret
  found in older history is rotated and recorded in the addendum's change log rather than failing every
  later run.
- Reason: a scan of the whole history failed on secrets removed months earlier, which only an ignore
  file could silence. A project that scans its whole history stays compliant.
- When moving the pin: nothing required.

## 1.0.3 (2026-10-06, PATCH, owner command)

- TS-01 no longer requires the file `.node-version`; the Node version is pinned exactly in one place the
  addendum names (`devEngines.runtime` or `engines.node` in the root `package.json`, or
  `.node-version`), and every other place that states it matches. CORE-60 and the project template say
  the same.
- Reason: a separate file only repeated the version that `package.json` already states, and setup-node
  reads it from `package.json`.
- When moving the pin: nothing required.

## 1.0.2 (2026-10-04, PATCH, owner command)

- CORE-63 and the Check of CORE-62 no longer assume branch protection, which GitHub Free does not offer
  for private repositories; there the rules hold by discipline (merge only on the owner's command and
  only with a green CI).
- Reason: the GitHub API refuses branch protection and rulesets on private repositories of the Free
  plan.
- When moving the pin: nothing required.

## 1.0.1 (2026-10-04, PATCH, owner command)

- CORE-02 and CORE-03 state that an addendum may mark its own rules NON-NEGOTIABLE; the plan template
  lists addendum NON-NEGOTIABLE rules too; the project template explains the title marker.
- Also: line wrapping fixed in DOKPLOY-06 (no change in meaning).
- Reason: a project needed domain rules that admit no exception.
- When moving the pin: nothing required.

## 1.0.0 (2026-10-04, ratified by the owner)

- Initial release: `core.md`; modules ts, python, go, flutter, jobs, dokploy and llm; templates
  project-constitution and plan-constitution-check.
- Sources: the constitutions and conventions of the owner's earlier projects, and the owner's decisions
  of 2026-10-04.

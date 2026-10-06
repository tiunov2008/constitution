# Engineering Constitution

One constitution for all of the owner's projects on the common stack: TypeScript monorepos (Turborepo,
pnpm, Next.js or Vite, Prisma, Better Auth), PostgreSQL and Dokploy, with Python, Go and Flutter where
present, spec-kit as the process and AI agents as developers.

Status: **v1.0.4**, ratified by the owner on 2026-10-04, last amended on 2026-10-06.

## Layout

| Path | Content |
|---|---|
| `core.md` | Rules for every project: governance, the four core NON-NEGOTIABLE rules, architecture, contracts, data, operations, toolchain and CI, process, agents |
| `modules/ts.md` | TypeScript monorepo: Turborepo, pnpm, Next.js or Vite, strictness, schemas, Prisma, Better Auth, tests |
| `modules/python.md` | Python services: uv, ruff, mypy, settings, layers, database access |
| `modules/go.md` | Go services: layout, errors, context, gate |
| `modules/flutter.md` | Flutter apps |
| `modules/jobs.md` | Background jobs: PostgreSQL job table, broker with an outbox |
| `modules/dokploy.md` | Docker images, compose files, hardening, releases, backups on Dokploy |
| `modules/llm.md` | Language-model features in the product |
| `templates/project-constitution.md` | The project's entry file and addendum (`.specify/memory/constitution.md`) |
| `templates/plan-constitution-check.md` | Formats of a plan's Constitution Check and Complexity Tracking |

The core and the modules share one version (CORE-04). Every rule has a stable ID such as `CORE-10`,
`TS-07` or `DOKPLOY-05`. Project rules use the project's prefix, such as `FINAM-03`. A bullet without
SHOULD, SHOULD NOT or MAY is a MUST.

## Adopting it in a project

1. Add the submodule and check out a release tag (CORE-05):

   ```sh
   git submodule add <repository URL> .specify/constitution
   git -C .specify/constitution checkout v1.0.0
   ```

2. Replace `.specify/memory/constitution.md` with `templates/project-constitution.md` and fill it in:
   modules, parameters, stack, project rules. Move the project's old domain rules into the addendum.
   From then on the entry file is edited directly; `/speckit-constitution` is not run on it.
3. Put the read list of the entry file into AGENTS.md (CORE-80) and make CLAUDE.md start with
   `@AGENTS.md`.
4. In CI, check out submodules (with GitHub Actions: `actions/checkout` with `submodules: true`; a
   private constitution repository needs a token with read access) and check the pin. The checkout is
   shallow and has no tags, so the check fetches the one tag it needs (the entry file states a tag, or a
   full commit SHA when the pin is not a release):

   ```sh
   PIN=$(sed -n 's/.*pinned at \*\*\([^*]*\)\*\*.*/\1/p' .specify/memory/constitution.md | head -1)
   case "$PIN" in
     v*) git -C .specify/constitution fetch --depth=1 origin "refs/tags/$PIN:refs/tags/$PIN"
         PIN=$(git -C .specify/constitution rev-parse "$PIN^{commit}") ;;
   esac
   test -n "$PIN" && test "$(git -C .specify/constitution rev-parse HEAD)" = "$PIN"
   ```

5. Record the gaps between the project and the rules in the addendum's Sync Impact Report, each as a
   task or as an exception approved by the owner (CORE-03).

Clones and git worktrees do not check out submodules by default. Use `git clone --recurse-submodules`,
or run `git submodule update --init` in a new worktree. Agents stop when the submodule is empty
(CORE-05).

To move a project to a newer version: check out the new tag in the submodule, read the Sync Impact
Report blocks in between, update the version in the entry file, record the changes and gaps in the
addendum's report, and commit the pin on its own.

## Amending

Only the owner amends (CORE-11). An amendment edits the rules, bumps the version (CORE-04), adds a block
to the Sync Impact Report at the top of `core.md`, updates the footer, and is tagged `vX.Y.Z`. A removed
rule's ID goes under "Retired IDs" in `core.md` and is never reused.

## Decision log

The owner chose the content of v1.0.0 on 2026-10-04 in eight rounds of questions, after a review of
finam_trader, data_foundry, production-free-song, nornickel-research-graph, driver-recruitment, CFO,
next-parser and eco-parser.

Adopted:

- a separate repository; core, modules and a project addendum; the addendum may tighten, never weaken;
- the constitution in English; the artifact language declared per project, English by default;
- one owner working with AI agents, who is the only reviewer and approver;
- Semantic Versioning with a Sync Impact Report; stable rule IDs with a module prefix;
- NON-NEGOTIABLE: honest verification, owner decisions, secrets and access, data integrity; an
  addendum may mark its own rules NON-NEGOTIABLE (v1.0.1);
- exceptions only through Complexity Tracking, approved by the owner;
- a development or production stage, declared in the addendum;
- pnpm everywhere; Next.js by default, Vite for internal single-page apps; base TypeScript strictness
  as MUST and two extra flags as SHOULD; pinned runtimes with lock files;
- the identifier scheme declared per project; one migrator per schema, Prisma by default; the job
  invariant in the core and the technology in the addendum; an outbox whenever a broker is used;
- CI for every project with a remote, with more checks in production; deploys verified by
  `COMMIT_SHA` and health; production deploys only by tag or owner command; compose hardening that is
  mandatory for internet-facing services;
- AGENTS.md as the source and CLAUDE.md importing it; risk tiers for agents; agent tooling committed
  except personal settings;
- backups with restore checks, an incident runbook with a note after each incident, structured logs,
  scanning in CI, dependency updates with a minimum release age, UTC time, git and pull-request rules,
  agent security;
- delivery to projects as a git submodule; finam_trader as the pilot;
- a project lists every module whose stack it has; leaving one out is an exception (CORE-06, added
  after the review);
- where the hosting plan offers no branch protection (private repositories on GitHub Free), the
  pull-request rules hold by discipline (CORE-63, v1.0.2);
- the Node version is pinned exactly in one place the project chooses, `package.json` or
  `.node-version`; the file `.node-version` itself is not required (TS-01, v1.0.3);
- CI scans for secrets in the commits that each push or pull request adds; a secret found in older
  history is rotated and recorded in the addendum instead of failing every run (CORE-62, v1.0.4).

Resolved while drafting (the stricter or the simpler reading was taken):

- The format check runs in every stage: round 3 put `prettier --check` in CI, round 5 listed it under
  production; CORE-01 takes the stricter rule.
- Secret scanning fails CI in every stage, because secrets are NON-NEGOTIABLE (CORE-12); other scan
  findings block only production release builds.
- The NON-NEGOTIABLE rules hold only the chosen items. Related obligations that may need exceptions
  are separate MUST rules: CORE-25 (least privilege), CORE-44 (consistent data changes), CORE-64
  (tests).
- CORE-10 includes "a test must be able to fail", and CORE-11 includes merging, tagging, spec-kit
  stages, exceptions and amendments, because the options the owner chose described them that way.
- Risk-tier areas need a confirmation that names the change even when a task covers them (CORE-81);
  CI configuration counts as infrastructure.
- The version a project follows is the submodule commit; a release tag is recommended and checked
  against the entry file.
- Stack-specific libraries in the modules (zod, pino, Vitest, pydantic-settings, Riverpod) are defaults
  that the addendum may replace, or SHOULD rules.

Considered and not adopted:

| Candidate | Source | Reason |
|---|---|---|
| File-by-File Gate (frozen plans, buckets, stops) | driver-recruitment `specs/README.md` | Owner decision: the risk tiers of CORE-81 are enough |
| `GATES.md` with CHECK / EXPECT / EVIDENCE | CFO | Owner decision: CI and the Constitution Check are enough |
| Subagent model rule (haiku or sonnet, no Opus unless asked) | owner's `~/.claude/CLAUDE.md` | A personal cost setting; it stays in the owner's global configuration |
| Sync script with a lock file | proposal | Owner chose a git submodule |
| A default identifier scheme | proposal | Each project declares its own (CORE-41) |
| Monitoring, error tracking and alerts | none | Not adopted in v1.0.0; a project may add rules in its addendum |
| Personal data (152-FZ) section | none | Not adopted in v1.0.0; a project may add rules in its addendum |
| Safe API defaults (schema validation at entry points, request size and rate limits, error responses without internals) | production-free-song, data_foundry | Not adopted in v1.0.0 by owner decision; a project may add rules in its addendum |
| Accessibility | none | Not adopted in v1.0.0 |
| One PostgreSQL as the only data store | finam_trader | A decision of one project; belongs in its addendum |
| Domain rules: no look-ahead, numba hot paths, JSONB stores, plugin manifests, platform adapters, audit-log helpers, Infisical injection, no dev containers | finam_trader, data_foundry, driver-recruitment, production-free-song | Project-specific; they belong in addenda |

## Known gaps in existing projects

Found while checking the rules against their sources; each project records its own gaps when it
adopts the constitution.

- driver-recruitment: pnpm 9 (TS-12 needs pnpm 11 for `allowBuilds`), the task is named `check-types`
  (TS-01), and the production compose file gives `POSTGRES_PASSWORD` a default (CORE-12).
- data_foundry: consumers requeue failing messages without a bound (JOBS-02).
- finam_trader, data_foundry, nornickel-research-graph: no CI (CORE-62).
- Most projects: `engines.node` is a range and Node is not pinned exactly (CORE-60).

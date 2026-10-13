# Engineering Constitution

Start a project on the owner's stack in minutes and keep it cheap to change: TypeScript monorepos
(Turborepo, pnpm, Next.js, Prisma, Better Auth, Tailwind CSS), PostgreSQL and Dokploy, with Python, Go
and Flutter where needed, spec-kit as the process and AI agents as developers.

Status: **v2.2.0**, ratified by the owner on 2026-10-04, last amended on 2026-10-13. Changes are in
`CHANGELOG.md`.

## Start here

- A new project: `quickstart.md`. Copy the starter (https://github.com/tiunov2008/starter), run
  `scripts/init-project.mjs`, run `pnpm check`.
- An existing project: `quickstart.md`, "Adopting the constitution in an existing project".

## How it is built

- **Rules** have stable IDs (`CORE-10`, `TS-07`, `DOKPLOY-05`) and hold in every project. A bullet
  without SHOULD, SHOULD NOT or MAY is a MUST. Four core rules are NON-NEGOTIABLE: honest verification,
  owner decisions, secrets and access, data integrity.
- **Defaults** are the stack choices the starter ships with. A project keeps them or records another
  choice in its addendum.
- **Recipes** are how-to knowledge and known traps from earlier projects. A project may leave them
  whenever the rules still hold.
- What no rule covers needs no approval and no record.

A project's constitution is the core, the modules that match its stack, and the project's addendum.
Project rules use the project's prefix, such as `<PREFIX>-03`.

## Layout

| Path | Content |
|---|---|
| `quickstart.md` | A new project from the starter; adoption in an existing project; moving to a newer version |
| `core.md` | Rules for every project: governance, the NON-NEGOTIABLE rules, architecture, contracts, data, operations, toolchain and CI, process, agents |
| `modules/ts.md` | TypeScript monorepo: Turborepo, pnpm, Next.js, Tailwind CSS, Prisma, Better Auth, CASL, data access, tests |
| `modules/dokploy.md` | Docker images, compose files, hardening, releases and backups on Dokploy |
| `modules/python.md` | Python services: uv, ruff, typed settings, database access |
| `modules/go.md` | Go services: errors, context, gate, versions |
| `modules/flutter.md` | Flutter apps |
| `modules/jobs.md` | Background jobs: PostgreSQL job table, broker with an outbox |
| `modules/llm.md` | Language-model features in the product |
| `templates/project-constitution.md` | The project's entry file and addendum (`.specify/memory/constitution.md`) |
| `templates/plan-constitution-check.md` | Formats of a plan's Constitution Check and Complexity Tracking |
| `scripts/check-pin.sh` | Checks in a project's CI that the submodule matches the pinned version |
| `scripts/check-constitution.sh` | Checks this repository: rule IDs, references and versions |
| `CHANGELOG.md` | One entry per version |

## Amending

Only the owner amends (CORE-11). An amendment edits the rules, bumps the version (CORE-04), adds an
entry to `CHANGELOG.md`, updates the footer of `core.md` and the status line above, passes
`sh scripts/check-constitution.sh`, and is tagged `vX.Y.Z`. A removed rule's ID goes under "Retired
IDs" in `core.md` and is never reused. The constitution holds only what all projects share; anything
about one project belongs in that project's addendum.

<!--
Change log (newest first; one entry per version, older entries are kept)

## 1.0.0 (<YYYY-MM-DD>)
- Constitution: vX.Y.Z
- Changes: initial addendum
- Gaps: <none, or each with its task or standing exception>
-->

# <Project> Constitution

This project follows the Engineering Constitution, pinned at **vX.Y.Z** (the submodule at
`.specify/constitution`; CORE-05). This file is the project's entry file and addendum.

## Read this first

The project's rules are, together:

1. the core: `.specify/constitution/core.md`;
2. the applied modules: `.specify/constitution/modules/<name>.md` for each module in the table below;
3. this addendum.

Agents and spec-kit commands (`/speckit-plan`, `/speckit-tasks`, `/speckit-implement`,
`/speckit-analyze` and the others) MUST read all three before planning, implementing, analysing or
reviewing work, and apply all three. Plans fill the Constitution Check and Complexity Tracking in the
format of `.specify/constitution/templates/plan-constitution-check.md` (CORE-71).

If `.specify/constitution/core.md` does not exist, the submodule is not checked out: stop and run
`git submodule update --init`. Never work from this addendum alone.

This file is edited directly (CORE-04). Do not run `/speckit-constitution` on it: that command rewrites
the whole file and drops the change log.

This addendum may tighten the core and the modules and replace their defaults, but never weaken a rule
without a recorded deviation or exception (CORE-01).

## Parameters (CORE-06)

| Parameter | Value |
|---|---|
| Applied modules | <ts, dokploy, python, go, flutter, jobs, llm: keep the ones that apply> |
| Stage (CORE-07) | development |
| Artifact language (CORE-73) | English |
| Identifier scheme (CORE-41) | <scheme per kind of entity, chosen by the owner> |
| Schema owners and migrators (CORE-40) | schema `public`: Prisma Migrate |
| Domain time zone (CORE-42) | none |
| Source-of-truth document (CORE-01) | none |
| Acceptable data loss and restore time (CORE-43) | <production only> |

## Module parameters (CORE-06)

One row per default of every applied module, copied from the module's Defaults table. Keep the default
or write the project's choice; replacing a default is an owner decision (CORE-02).

| Module | Parameter | Value |
|---|---|---|
| ts | Monorepo tool | Turborepo |
| ts | Web framework per app | apps/web: Next.js |
| ts | Styling | Tailwind CSS |
| ts | Database access and migrations | Prisma |
| ts | Authentication | Better Auth in `@<project>/auth` |
| ts | Authorization | CASL with `@casl/prisma` in `@<project>/authz` |
| ts | Schema library | zod |
| ts | Logger | pino |
| ts | Test runner | Vitest; Playwright for e2e |
| ts | Node version pinned in | `devEngines.runtime` in the root `package.json` |
| dokploy | Production compose file | `docker-compose.prod.yml`, with `image:` entries only |
| dokploy | Image build | CI builds and pushes; Dokploy only pulls |
| dokploy | Image registry | <GHCR, or a registry on the Dokploy server> |
| dokploy | Images | `web` and `tools`, tagged with the full commit SHA, plus `test` and `production` |
| dokploy | Test deploy | every push to `main` |
| dokploy | Production deploy trigger | a git tag `vX.Y.Z` |
| dokploy | Deploy verification | `scripts/verify-deploy.sh` |
| dokploy | Backups | <production only> |

## Stack and pinned versions (CORE-60)

| Tool | Version | Pinned in |
|---|---|---|
| Node | <x.y.z> | <the place named in the module parameters> |
| pnpm | <x.y.z> | `package.json` `packageManager` |

## Project rules

### <PREFIX>-01 · <Title>

- <Rule. A bullet without SHOULD, SHOULD NOT or MAY is a MUST (CORE-02). Add " · NON-NEGOTIABLE" to
  the title only for a rule that admits no exception.>

*Tightens*: <core or module rule ID, if it touches one>
*Why*: <reason>
*Check*: <how compliance is seen>

## Deviations and standing exceptions (CORE-02, CORE-03)

| Rule | Kind | Why | Compliant option rejected | Ends or is reviewed when | Owner approval |
|---|---|---|---|---|---|

*Kind* is `SHOULD` (only *Why* is required) or `exception` (every column is required). Gaps found when
adopting the constitution or moving the pin go here unless a task closes them first.

## Retired IDs

None.

---

**Version**: 1.0.0 | **Ratified**: <YYYY-MM-DD> | **Last Amended**: <YYYY-MM-DD>

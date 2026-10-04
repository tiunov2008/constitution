<!--
Sync Impact Report (newest first; one block per version, older blocks are kept)

## 1.0.0
- Version: none -> 1.0.0
- Core: v1.0.0
- Changes: initial addendum
- Gaps against the core and modules: <list, each with its task or exception>
- Follow-ups: none
-->

# <Project> Constitution

This project follows the Engineering Constitution, pinned at **v1.0.0** (the submodule at
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
the whole file and drops the Sync Impact Report log.

This addendum may tighten the core and the modules but never weaken them (CORE-01).

## Parameters (CORE-06)

| Parameter | Value |
|---|---|
| Applied modules | <ts, python, go, flutter, jobs, dokploy, llm: keep the ones that apply> |
| Stage (CORE-07) | development |
| Artifact language (CORE-73) | English |
| Identifier scheme (CORE-41) | <scheme per kind of entity, chosen by the owner> |
| Schema owners and migrators (CORE-40) | <for example: schema `public`, Prisma Migrate> |
| Domain time zone (CORE-42) | <none, or the zone and what it applies to> |
| Source-of-truth document (CORE-01) | <none, or a path> |
| Background jobs (CORE-50) | <none, PostgreSQL job table, RabbitMQ> |
| Web framework per app (TS-05) | <for example: apps/web, Next.js> |
| Production deploy trigger (DOKPLOY-06) | <production only: git tag, or owner command> |
| Acceptable data loss and restore time (CORE-43) | <production only> |

## Stack and pinned versions (CORE-60)

| Tool | Version | Pinned in |
|---|---|---|
| Node | <x.y.z> | `.node-version` |
| pnpm | <x.y.z> | `package.json` `packageManager` |

## Project rules

### <PREFIX>-01 · <Title>

- <Rule. A bullet without SHOULD, SHOULD NOT or MAY is a MUST (CORE-02). Add " · NON-NEGOTIABLE" to
  the title only for a rule that admits no exception.>

*Tightens*: <core or module rule ID, if it touches one>
*Why*: <reason>
*Check*: <how compliance is seen>

## Standing SHOULD deviations (CORE-02)

| Rule | Deviation | Reason |
|---|---|---|

## Rejected alternatives (CORE-06)

| Alternative | Reason |
|---|---|

## Retired IDs

None.

---

**Version**: 1.0.0 | **Ratified**: <YYYY-MM-DD> | **Last Amended**: <YYYY-MM-DD>

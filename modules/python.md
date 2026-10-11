# Module PY: Python services

Applies to projects with Python services, workers, engines or CLIs. Part of the Engineering
Constitution; the version is in `core.md`. Defaults, rules and recipes are used as CORE-02 defines them:
a bullet without SHOULD, SHOULD NOT or MAY is a MUST.

## Defaults

The addendum copies this table into its module parameters and keeps or replaces each value (CORE-06).

| Parameter | Default |
|---|---|
| Web framework | FastAPI |
| Settings library | pydantic-settings |
| Type checker | mypy in strict mode |
| Database driver | psycopg |
| Migrator of a schema the service owns | alembic |

## Rules

### PY-01 · Toolchain

- uv, with `pyproject.toml` and a committed `uv.lock`.
- The Python version is pinned once and is the same in `pyproject.toml` (`requires-python` and the
  targets of ruff and the type checker), the Dockerfile and CI (CORE-60).

*Why*: one interpreter version everywhere removes a whole class of "works locally" failures.
*Check*: CI compares the versions or reads them from one file.

### PY-02 · Gate

- `ruff check` (at least rule sets B, E, F, I and UP), `ruff format --check`, the type checker in strict
  mode and `pytest` run in CI (CORE-62).

*Why*: strict typing and linting are as valuable in Python as in TypeScript.
*Check*: the CI workflow runs the four steps.

### PY-03 · Settings

- All configuration goes through typed settings, validated at start-up (CORE-24).

*Why*: a missing variable should fail at start, not in the middle of a job.
*Check*: no `os.environ` reads outside the settings module.

### PY-05 · Database access

- With a Prisma-owned schema (CORE-40): SQL with bound parameters. Test databases are built from the
  Prisma SQL migrations.
- With a schema of its own: one migrator owns it and is run by the deploy's migration step
  (DOKPLOY-03).

*Why*: one owner per schema, whatever the language of its users.
*Check*: no migrations folder of a second migrator next to a Prisma-owned schema.

### PY-06 · Services

- Service-to-service calls authenticate with a shared token compared in constant time
  (`hmac.compare_digest`). A service with no token configured accepts no calls.

*Why*: internal services are reachable by every container on the network.
*Check*: a test calls the service without the token and gets a refusal.

## Recipes

- **Layers.** Imports point inward: domain, then application (ports), then adapters, then entry points
  (API, CLI, workers). Routes and CLI commands hold no business rules; workers call the application
  layer and do no orchestration of their own. An import-boundary check (for example import-linter) in
  CI keeps it that way.
- **Tests.** Tests live in `tests/`, grouped by kind (unit, contract, integration), and `pytest`
  collects from there only.
- **OpenAPI.** A FastAPI service exports its OpenAPI document and protects it with a snapshot test.

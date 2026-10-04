# Module PY: Python services

Applies to projects with Python services, workers, engines or CLIs. Part of the Engineering
Constitution; the version is in `core.md`. Rule format and levels follow the core (CORE-02): a bullet
without SHOULD, SHOULD NOT or MAY is a MUST.

### PY-01 · Toolchain

- uv, with `pyproject.toml` and a committed `uv.lock`.
- The Python version is pinned once and is the same in `pyproject.toml` (`requires-python` and the
  targets of ruff and mypy), the Dockerfile and CI (CORE-60).

*Why*: one interpreter version everywhere removes a whole class of "works locally" failures.
*Check*: CI compares the versions or reads them from one file.

### PY-02 · Gate

- `ruff check` (at least rule sets B, E, F, I and UP), `ruff format --check`, `mypy --strict` and
  `pytest` run in CI (CORE-62).

*Why*: strict typing and linting are as valuable in Python as in TypeScript.
*Check*: the CI workflow runs the four commands.

### PY-03 · Settings

- All configuration goes through typed settings, validated at start-up (CORE-24); pydantic-settings
  unless the addendum names another library.

*Why*: a missing variable should fail at start, not in the middle of a job.
*Check*: no `os.environ` reads outside the settings module.

### PY-04 · Layers

- Imports point inward: domain, then application (ports), then adapters, then entry points (API, CLI,
  workers). Routes and CLI commands hold no business rules. Workers call the application layer and do
  no orchestration of their own.

*Why*: the same domain code serves the API, the CLI and the workers (CORE-21).
*Check*: an import-boundary check (for example import-linter) in CI.

### PY-05 · Database access

- With a Prisma-owned schema (CORE-40): SQL through psycopg with bound parameters. Test databases are
  built from the Prisma SQL migrations.
- With a schema of its own: alembic, or the migrator named in the addendum, owns it and is run by the
  deploy's migration step (DOKPLOY-03).

*Why*: one owner per schema, whatever the language of its users.
*Check*: no alembic folder next to a Prisma-owned schema.

### PY-06 · Services

- Service-to-service calls authenticate with a shared token compared in constant time
  (`hmac.compare_digest`). A service with no token configured accepts no calls.
- SHOULD: a FastAPI service exports its OpenAPI document and protects it with a snapshot test.

*Why*: internal services are reachable by every container on the network.
*Check*: a test calls the service without the token and gets a refusal.

### PY-07 · Tests

- Tests live in `tests/`, grouped by kind (unit, contract, integration).

*Why*: Python tooling expects one test root.
*Check*: `pytest` collects from `tests/` only.

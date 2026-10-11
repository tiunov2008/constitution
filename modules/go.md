# Module GO: Go services

Applies to projects with Go services, workers, CLIs or libraries. Part of the Engineering Constitution;
the version is in `core.md`. Defaults, rules and recipes are used as CORE-02 defines them: a bullet
without SHOULD, SHOULD NOT or MAY is a MUST.

## Defaults

The addendum copies this table into its module parameters and keeps or replaces each value (CORE-06).

| Parameter | Default |
|---|---|
| Migrator of a schema the service owns | goose |
| Logger | `log/slog` with JSON output |

## Rules

### GO-02 · Errors, context and goroutines

- Errors are returned with context, wrapped with `%w` where callers need the cause, and checked with
  `errors.Is` or `errors.As`. `panic` is not used for expected input, database or network errors.
- `context.Context` is the first argument through handlers, services, database calls and outgoing
  calls. Deadlines and cancellation are honoured, and every `cancel` function is called.
- Every goroutine and worker has a defined end. Repeated operations have bounded retries and are
  idempotent.

*Why*: leaked goroutines and swallowed errors are the typical failures of long-running Go services.
*Check*: `go vet` and review.

### GO-03 · Gate

- `gofmt`, reproducible code generation (drift fails), `go vet`, `go test -race ./...`, the build of the
  affected modules, and `govulncheck` (findings handled as in CORE-62) run in CI.

*Why*: the race detector finds what review cannot.
*Check*: the CI workflow runs these steps.

### GO-04 · Modules and versions

- `go.mod` and `go.sum` are reproducible. `go.work` serves local development only and is never a hidden
  build dependency.
- The Go version is the same in `go.mod`, CI and the image, checked by a script (CORE-60).

*Why*: independently deployed services must build from their own module.
*Check*: the version-check script runs in CI.

### GO-05 · Storage and logging

- A schema the service owns has one migrator (CORE-40).
- Logging goes through one logger with JSON output (CORE-52).

*Why*: one migrator per schema; one way to write logs.
*Check*: no second migrator or logging library in `go.mod`.

## Recipes

- **Layout.** Executables live in `cmd/` where the repository's size justifies it; non-public code
  lives in `internal/`. Packages reflect responsibilities, not layers for their own sake. `main` wires
  the dependencies and owns the lifecycle.
- **Interfaces.** Interfaces are declared by the consumer, where they enable substitution or testing.
  No wrappers without a purpose.
- **Doc comments.** Exported symbols have doc comments that start with the symbol's name; staticcheck
  reports the missing ones.

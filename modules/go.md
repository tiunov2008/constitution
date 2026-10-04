# Module GO: Go services

Applies to projects with Go services, workers, CLIs or libraries. Part of the Engineering Constitution;
the version is in `core.md`. Rule format and levels follow the core (CORE-02): a bullet without SHOULD,
SHOULD NOT or MAY is a MUST. Based on the production-free-song backend constitution 2.0.0 and its
implementation (goose, staticcheck doc rules).

### GO-01 · Layout and lifecycle

- Executables live in `cmd/` where the repository's size justifies it; non-public code lives in
  `internal/`. Packages reflect responsibilities, not layers for their own sake.
- Interfaces are declared by the consumer, where they enable substitution or testing. No wrappers
  without a purpose.
- `main` wires the dependencies and owns the lifecycle (CORE-21).

*Why*: idiomatic layout lets any Go reader find their way.
*Check*: no import cycles; `internal/` is not imported from outside its module.

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

### GO-05 · Storage, logging and docs

- A Go service that owns its schema uses goose, or the migrator named in the addendum (CORE-40).
- Logging goes through `log/slog` with JSON output (CORE-52).
- Exported symbols have doc comments that start with the symbol's name.

*Why*: the standard library covers logging; one migrator per schema.
*Check*: no second logging library in `go.mod`.

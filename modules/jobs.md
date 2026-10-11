# Module JOBS: Background jobs and messaging

Applies to projects with background jobs (CORE-50). Part of the Engineering Constitution; the version is
in `core.md`. Defaults, rules and recipes are used as CORE-02 defines them: a bullet without SHOULD,
SHOULD NOT or MAY is a MUST.

## Defaults

The addendum copies this table into its module parameters and keeps or replaces each value (CORE-06).

| Parameter | Default |
|---|---|
| Job technology | a PostgreSQL job table (JOBS-01); RabbitMQ with an outbox (JOBS-02) when a broker is needed |
| Worker wake-up | `LISTEN/NOTIFY`, with polling as the fallback |

## Rules

### JOBS-01 · PostgreSQL job table

- Workers claim jobs with `SELECT ... FOR UPDATE SKIP LOCKED` and hold a lease that a heartbeat renews.
  Lease expiry is computed from the database clock. A job whose lease has expired can be claimed again.
- Each claim increments a fencing token. Result writes and state changes are conditional on the token
  still matching, so a worker that lost its lease cannot commit a stale result.
- A job is enqueued in the same transaction as the data change that requests it.
- Cancelling is cooperative: the worker checks for a cancel request between steps and records the
  outcome.

*Why*: a job table gives queues, retries and visibility without another moving part.
*Check*: a test stops a worker mid-job, sees the job claimed again after the lease expires, and sees the
old worker's late write rejected.

### JOBS-02 · Broker with an outbox

- The outbox row and the data change commit in one transaction (CORE-50).
- The relay claims pending or failed rows with `FOR UPDATE SKIP LOCKED` in a short transaction (marking
  them as publishing, with a claim time and an attempt count), so no lock is held while publishing. It
  publishes with publisher confirms, then marks the rows published. Failures are rescheduled with
  backoff up to a maximum attempt count, after which the row is marked failed and reported. A claim
  older than a stated timeout is stale and may be claimed again.
- Consumers acknowledge manually after processing and use deterministic job ids (for example
  `step:<id>:attempt:<n>`) so that duplicates are recognised.
- A message that keeps failing is retried a bounded number of times and then moved to a dead-letter
  queue; it is never requeued forever.
- Queue names carry an environment prefix.

*Why*: without an outbox, a crash between commit and publish loses the message or invents one.
*Check*: a test stops the broker, commits data, restarts the broker and sees the message delivered once.

### JOBS-03 · Results

- A result becomes visible as ready only after it has been completely written and verified. A failed
  job never damages an earlier ready result.

*Why*: readers must never see half a result.
*Check*: a test fails a job midway and finds the previous result intact.

### JOBS-04 · Message versions

- Job and message payloads carry a format version (CORE-30). A consumer that receives a version it does
  not support does not process it: a queue message is dead-lettered, a job-table row is marked failed
  with the reason.

*Why*: producers and consumers are deployed at different times.
*Check*: a consumer test rejects a payload with an unknown version as described.

## Recipes

- **Job row.** A job row records at least: state, attempt count and maximum, lease expiry, fencing
  token, progress, cancel request, idempotency key (unique), timestamps and the last error.
- **Wake-ups.** A notification (`LISTEN/NOTIFY` or a broker message) wakes the workers, and polling is
  the fallback: notifications are fast but not guaranteed, so an unavailable notification channel must
  never stop the work. A test disables notifications and sees jobs processed by polling.

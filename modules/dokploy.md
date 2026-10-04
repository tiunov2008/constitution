# Module DOKPLOY: Docker and Dokploy deployment

Applies to projects deployed with Docker Compose on Dokploy. Part of the Engineering Constitution; the
version is in `core.md`. Rule format and levels follow the core (CORE-02): a bullet without SHOULD,
SHOULD NOT or MAY is a MUST.

### DOKPLOY-01 · Images

- Dockerfiles are multi-stage. Application images run as a non-root user.
- TypeScript apps are built with `turbo prune` and Next.js `standalone` output.
- The image carries `COMMIT_SHA` as a build argument exposed as an environment variable (this is what
  deploy verification reads), and is tagged `<service>-<short sha>`. The project uses one form of the
  SHA (full or short) in `COMMIT_SHA` and in the verification. SHOULD: the image also sets the OCI label
  `org.opencontainers.image.revision`.
- Release images are built only from a commit that passed the CI gate (CORE-62).

*Why*: a deploy is only verifiable when the running container says which commit it is.
*Check*: `docker inspect` shows `COMMIT_SHA` in `Config.Env`; the container user is not root.

### DOKPLOY-02 · Compose files

- `docker-compose.prod.yml` serves Dokploy; a separate compose file serves local development. A local
  production-like compose file MAY exist; its environment file stays out of git.
- No YAML merge keys (`<<:`), because Dokploy rewrites the file to add its labels. Plain anchors and
  aliases (`x-logging: &logging`, then `logging: *logging`) are fine.
- Infrastructure images (PostgreSQL, MinIO, RabbitMQ and others) are pinned to a version, never
  `latest`, with a comment on why that version.
- Required variables use `${VAR:?hint}`. Secrets have no defaults (CORE-12).

*Why*: the production compose file is the deployment's contract.
*Check*: a static check of the compose file (DOKPLOY-07).

### DOKPLOY-03 · One-shot services

- Migrations, bootstrap and storage initialisation run as one-shot services. The applications depend on
  them with `condition: service_completed_successfully`. One-shot services are idempotent and run on
  every deploy.
- A bootstrap secret (for example the first owner's password) is removed from the environment after the
  first successful run.

*Why*: an app must never start against a schema it does not expect.
*Check*: the compose dependency conditions; the bootstrap variable is empty after going live.

### DOKPLOY-04 · Network and exposure

- Only the public web service joins `dokploy-network`, using `expose` and no `ports`. All other services
  stay on the internal network and publish no ports.

*Why*: what is not reachable cannot be attacked.
*Check*: no `ports:` key in the production compose file.

### DOKPLOY-05 · Health, restart and hardening

- Every long-lived service has a health check: an HTTP one where the service has HTTP, a command-based
  one (for example a fresh heartbeat) otherwise (CORE-51).
- Services use `restart: unless-stopped`. Docker does not restart containers marked `unhealthy`, so a
  health check alone does not heal a service.
- Container logs use a driver with size and file-count limits (CORE-52).
- Internet-facing services set `security_opt: ["no-new-privileges:true"]` and `cap_drop: [ALL]`, adding
  back only the capabilities they need, each with a comment.
- SHOULD: `read_only: true` with tmpfs mounts where the process allows it; memory limits set from a
  measurement (cgroup memory, not `docker stats`), with the measurement in a comment.

*Why*: a compromised public container should be able to do as little as possible.
*Check*: the static compose check verifies these keys.

### DOKPLOY-06 · Releases and verification

- *(production)* A production deploy starts only from a git tag or an explicit owner command (CORE-11),
  with an image that passed the gate.
- Automatic deploys go only to a test environment, and the owner sets them up (CORE-11). Dokploy's
  auto-deploy is off for the production environment when CI drives the releases.
- A deploy has succeeded when the containers built from the expected commit (`COMMIT_SHA`) are
  running, and healthy where the service has a health check, not when the Dokploy API returns 200. A verification script checks this, polling with a timeout, and runs in CI or is run
  by the owner (CORE-82). Until a shared script exists in this repository's `scripts/`, the project
  keeps its own.
- SHOULD: before deploying, read back the application's configured image and compare it with the
  intended one; an older pipeline never overwrites a newer deploy.
- SHOULD: the health or readiness response reports the commit and the schema version, so that the
  check needs no credentials.

*Why*: "the API said OK" is not evidence that the new version runs (CORE-10).
*Check*: the deploy job ends with the verification step.

### DOKPLOY-07 · Runbook and environment

- DEPLOY.md lists the services, the variables (pointing to the environment templates of CORE-12), the
  first deploy and the checks after a deploy. *(production)* It also holds the procedures of CORE-53.
- SHOULD: a static check of the production compose file (for example a script with a self-test) runs in
  CI.

*Why*: the deployment must be repeatable by someone who did not set it up, including an agent.
*Check*: DEPLOY.md exists and matches the compose file.

### DOKPLOY-08 · Backups *(production)*

- Dokploy volume backups or a scheduled `pg_dump` send PostgreSQL backups to S3-compatible storage
  outside the server. Object storage is backed up or replicated in the same way (CORE-43).

*Why*: a backup on the same server dies with the server.
*Check*: the backup destination is outside the server; DEPLOY.md shows the last restore.

# Module DOKPLOY: Docker and Dokploy deployment

Applies to projects deployed with Docker Compose on Dokploy. Part of the Engineering Constitution; the
version is in `core.md`. Defaults, rules and recipes are used as CORE-02 defines them: a bullet without
SHOULD, SHOULD NOT or MAY is a MUST.

## Defaults

The addendum copies this table into its module parameters and keeps or replaces each value (CORE-06).

| Parameter | Default |
|---|---|
| Production compose file | `docker-compose.prod.yml`, with `image:` entries only |
| Image build | CI builds the images after the gate and pushes them to the registry; Dokploy only pulls them |
| Image registry | GHCR, or a registry on the Dokploy server; the project chooses |
| Images | `web` (the application) and `tools` (migrations), tagged with the full commit SHA, plus the moving tags `test` and `production` |
| Test deploy | every push to `main`: CI moves `test` to the new images and deploys the test environment |
| Production deploy trigger | a git tag `vX.Y.Z`: CI moves `production` to the images already built for that commit and deploys |
| Deploy verification | `scripts/verify-deploy.sh`: polls the public readiness endpoint until it reports the expected commit (DOKPLOY-06) |
| Backups | Dokploy volume backups or a scheduled `pg_dump`, to S3-compatible storage outside the server |

## Rules

### DOKPLOY-01 · Images

- Application images run as a non-root user.
- The image carries `COMMIT_SHA` as a build argument exposed as an environment variable (this is what
  deploy verification reads). The project uses one form of the SHA (full or short) in `COMMIT_SHA` and
  in the verification.
- Release images are built only from a commit that passed the CI gate (CORE-62).

*Why*: a deploy is only verifiable when the running container says which commit it is.
*Check*: `docker inspect` shows `COMMIT_SHA` in `Config.Env`; the container user is not root.

### DOKPLOY-02 · Compose files

- Infrastructure images (PostgreSQL, MinIO, RabbitMQ and others) are pinned to a version, never
  `latest`, with a comment on why that version.
- Required variables use `${VAR:?hint}`. Secrets have no defaults (CORE-12).

*Why*: the production compose file is the deployment's contract.
*Check*: review of the compose file, or the static check of the recipes.

### DOKPLOY-03 · Migrations before start

- Migrations run before the applications start, in an idempotent one-shot step that runs on every
  deploy and that the applications wait for (for example a one-shot service with
  `condition: service_completed_successfully`).
- Bootstrap (for example the first owner account) and storage initialisation are idempotent and finish
  before the application serves requests: as such a one-shot step, or in the application's start-up.
- A bootstrap secret (for example the first owner's password) is removed from the environment after the
  first successful run.

*Why*: an app must never start against a schema it does not expect.
*Check*: the compose dependency conditions; the bootstrap variable is empty after going live.

### DOKPLOY-04 · Network and exposure

- Only public services join `dokploy-network`, using `expose` and no `ports`. All other services stay
  on the internal network and publish no ports.

*Why*: what is not reachable cannot be attacked.
*Check*: no `ports:` key in the production compose file.

### DOKPLOY-05 · Health, restart and hardening

- Every long-lived service has a health check: an HTTP one where the service has HTTP, a command-based
  one (for example a fresh heartbeat) otherwise (CORE-51).
- Services use `restart: unless-stopped`.
- Container logs use a driver with size and file-count limits (CORE-52).
- Internet-facing services set `security_opt: ["no-new-privileges:true"]` and `cap_drop: [ALL]`, adding
  back only the capabilities they need, each with a comment.

*Why*: a compromised public container should be able to do as little as possible.
*Check*: review of the compose file, or the static check of the recipes.

### DOKPLOY-06 · Releases and verification

- *(production)* A production deploy starts only from a git tag or an explicit owner command (CORE-11),
  with an image that passed the gate.
- Automatic deploys go only to a test environment, and the owner sets them up (CORE-11). Dokploy's
  auto-deploy is off for the production environment when CI drives the releases.
- A deploy has succeeded when the containers built from the expected commit (`COMMIT_SHA`) are
  running, and healthy where the service has a health check, not when the Dokploy API returns 200. A
  verification script checks this, polling with a timeout, and runs in CI or is run by the owner
  (CORE-82).

*Why*: "the API said OK" is not evidence that the new version runs (CORE-10).
*Check*: the deploy job ends with the verification step.

### DOKPLOY-07 · Runbook

- DEPLOY.md lists the services, the variables (pointing to the environment templates of CORE-24), the
  first deploy and the checks after a deploy. *(production)* It also holds the procedures of CORE-53.

*Why*: the deployment must be repeatable by someone who did not set it up, including an agent.
*Check*: DEPLOY.md exists and matches the compose file.

### DOKPLOY-08 · Backups *(production)*

- PostgreSQL backups go to S3-compatible storage outside the server. Object storage is backed up or
  replicated in the same way (CORE-43).

*Why*: a backup on the same server dies with the server.
*Check*: the backup destination is outside the server; DEPLOY.md shows the last restore.

## Recipes

- **Images.** Multi-stage Dockerfiles. TypeScript apps are built with `turbo prune`, Next.js apps with
  `output: "standalone"`. Set the OCI label `org.opencontainers.image.revision` next to `COMMIT_SHA`.
- **Images from CI.** CI passes `COMMIT_SHA=${{ github.sha }}` as the build argument, so the image always
  knows its commit, and the production server never runs a build next to live services. Promotion and
  rollback move a tag without rebuilding (`docker buildx imagetools create --tag <repo>/web:production
  <repo>/web:<sha>`): production runs the exact image the test environment ran. The compose file uses
  `image: ${IMAGE_REPOSITORY}/web:${IMAGE_TAG}` with `pull_policy: always`, and each Dokploy compose
  application sets `IMAGE_TAG` to `test` or `production`. Dokploy needs the registry's read credentials
  (Settings, Registry). The deploy itself is `POST /api/compose.deploy` with `{"composeId": ...}` and the
  header `x-api-key`; it is asynchronous, which is why verification polls.
- **Tools image.** Migrations run from a separate image with only the database package and its
  production dependencies (`pnpm --filter <db package> deploy --prod --legacy`), so the internet-facing
  image carries no CLI. `pnpm install --prod --filter` does not shrink an image: the virtual store still
  receives the whole lock file. Code that needs Better Auth (such as the owner bootstrap) runs in the
  application's start-up instead: Better Auth's optional peers pull Next.js and Vitest into any
  separate image.
- **Compose files.** A separate compose file serves local development. An override file with `build:`
  entries (`docker-compose.build.yml`) builds the production images locally; its environment file stays
  out of git.
- **No YAML merge keys.** Dokploy rewrites the compose file to add its labels, and merge keys (`<<:`)
  break. Plain anchors and aliases (`x-logging: &logging`, then `logging: *logging`) work.
- **Restarts.** Docker does not restart containers marked `unhealthy`, so a health check alone does not
  heal a service; `restart: unless-stopped` covers crashes only.
- **More hardening.** `read_only: true` with tmpfs mounts where the process allows it. Memory limits
  come from a measurement (cgroup memory, not `docker stats`), with the measurement in a comment.
- **Safe deploys.** Before deploying, read back the application's configured image and compare it with
  the intended one, so that an older pipeline never overwrites a newer deploy. Let the health or
  readiness response report the commit and the schema version, so that verification needs no
  credentials.
- **Building in Dokploy instead.** Dokploy passes no commit to compose builds. A project that replaces
  the image-build default declares `COMMIT_SHA: ${COMMIT_SHA:?...}` under `build.args` and sets it in the
  Environment tab in the same step as the branch or tag being deployed; a `COMMIT_SHA` left at its old
  value makes the verification of DOKPLOY-06 fail.
- **Static compose check.** A small script with a self-test checks the production compose file in CI for
  the keys of DOKPLOY-02, DOKPLOY-04 and DOKPLOY-05.

# Quickstart

## A new project from the starter

The starter (https://github.com/tiunov2008/starter) is a working monorepo that meets the rules and uses
the defaults of the core and of the modules ts and dokploy: Turborepo and pnpm, a Next.js app with
Tailwind CSS and a sign-in page, Prisma with PostgreSQL, Better Auth with public sign-up off, pino,
Vitest with isolated integration tests, health and readiness endpoints, CI that runs the gate, publishes
the images and deploys them through the Dokploy API, a Dockerfile and `docker-compose.prod.yml` for
Dokploy, DEPLOY.md, AGENTS.md and CLAUDE.md, spec-kit, and this constitution as a submodule with a
filled entry file.

1. Create the repository from the template and fetch the submodule:

   ```sh
   gh repo create <name> --template tiunov2008/starter --private --clone
   cd <name>
   git submodule update --init
   ```

2. Give it the project's name and rule prefix. The script renames the `@starter/*` packages and fills the
   name and prefix into the entry file, AGENTS.md and the docs:

   ```sh
   node scripts/init-project.mjs <name> <PREFIX>
   ```

3. Run it locally. pnpm downloads the pinned Node by itself; the first start creates the owner account
   from `BOOTSTRAP_OWNER_*` in `.env`, and you sign in with it at http://localhost:3000:

   ```sh
   cp .env.example .env
   docker compose up -d
   pnpm install
   pnpm db:migrate
   pnpm dev
   ```

4. Run the whole gate; it is green on a fresh copy:

   ```sh
   pnpm check
   ```

5. Fill the open parameters of the entry file `.specify/memory/constitution.md`: the identifier scheme,
   the artifact language, and any default the project replaces (CORE-06).
6. Commit and push. CI runs the gate and the pin check and publishes the images. To deploy, follow the
   project's DEPLOY.md: one Dokploy compose application per environment, the registry's read token in
   Dokploy, and four variables per GitHub environment; until they are set, CI skips the deploys.
7. Start the first feature with `/speckit-specify` (CORE-70). Fixes and small changes go straight to a
   pull request.

### Adding a stack later

To add a Python service, a Go service, a Flutter app, background jobs or language-model features: add
the module to the entry file's applied modules, copy its Defaults table into the module parameters, and
follow its rules and recipes. A library the defaults do not cover is added under CORE-61, without
asking.

## Adopting the constitution in an existing project

1. Add the submodule and check out the latest release tag (CORE-05):

   ```sh
   git submodule add https://github.com/tiunov2008/constitution.git .specify/constitution
   git -C .specify/constitution checkout vX.Y.Z
   ```

2. Replace `.specify/memory/constitution.md` with `templates/project-constitution.md` and fill it in:
   pinned version, applied modules, parameters, module parameters, stack versions. Move the project's
   own domain rules into the addendum's project rules. From then on the entry file is edited directly;
   `/speckit-constitution` is not run on it.
3. Put the read list of the entry file into AGENTS.md (CORE-80) and make CLAUDE.md start with
   `@AGENTS.md`.
4. In CI, check out submodules (with GitHub Actions: `actions/checkout` with `submodules: true`; a
   private constitution repository needs a token with read access) and run the pin check:

   ```sh
   sh .specify/constitution/scripts/check-pin.sh
   ```

5. Record each gap between the project and the rules as a task, or as a standing exception in the
   deviations table approved by the owner (CORE-03).

## Clones and worktrees

Clones and git worktrees do not check out submodules by default. Use `git clone --recurse-submodules`,
or run `git submodule update --init` in a new worktree. Agents stop when the submodule is empty
(CORE-05).

## Moving to a newer version

Check out the new tag in the submodule, read the `CHANGELOG.md` entries in between, update the pinned
version in the entry file, record the changes in the addendum's change log and each gap as a task or a
standing exception, and commit the pin on its own (CORE-05).

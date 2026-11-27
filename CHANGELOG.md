# Changelog

All notable changes per release. Versions follow [semver](https://semver.org).

## v1.4.9, 2026-11-27

- The agent skill no longer tells an agent to pipe the installer into `bash`. It downloads `downloader.sh` to a file, has you read it, then runs it. It no longer appends to `~/.bashrc` or `~/.zshrc` for you, and the `/usr/local/bin` install is an optional step. The shell, network and file access the skill declares now covers the install steps, and its example key paths are placeholders.
- When the skill is published to ClawHub, its links to files on `master` are rewritten to the release tag, so the published skill points at the installer of that release.
- The documentation site moved from Jekyll to Docusaurus at the same URLs. A new `docs.yml` workflow builds it on every pull request and publishes it from `master`, `make docs` fails on a broken internal link or anchor, and `make docs-lock` refreshes the pinned dependency lockfile.
- The project rules in `.agents/rules/` keep only what is specific to this repository.

## v1.4.8, 2026-11-10

- The documentation is published at https://psyb0t.github.io/ssh-tunnel-swarm/, and the reference material moved there from the README. The agent skill now describes the rules file, the fixed 5 second retry after a failed exit, and shutdown the way the script behaves.
- Every branch push builds the merged script and runs shellcheck and the unit tests, and `make lint` and `make test` run them locally in pinned containers. A version tag waits for that commit's master run to pass, then cuts the release and uploads the `ssh-tunnel-swarm` script the installer downloads.
- Buy Me a Coffee is in the funding links, and `AGENTS.md` plus project rules in `.agents/rules/` are committed for coding agents.

## v1.4.7, 2026-10-10

Documentation only. The README's agent integrations section names [peen](https://github.com/psyb0t/peen) as an example of an agent that reads `.agents/skills/`.

## v1.4.6 — 2026-08-01

CI/infrastructure only. No code in this repo changed — the whole diff since v1.4.5 is
under `.github/workflows/`.

- Split the pipeline: building and publishing stay in `pipeline.yml`, and everything
  that leaves the host now lives in its own file beside it.
- The repo is mirrored to Codeberg as well as GitLab.
- The repo is archived to the Wayback Machine, Software Heritage and archive.org.
- Issues opened on either mirror are copied back to GitHub every six hours, and closed
  here when the original closes.
- Pull requests are switched off on both mirrors — they are force-pushed from GitHub, so
  anything merged there would be destroyed by the next sync. Issues and forking stay
  enabled.

## v1.4.5 — 2026-07-27

- Fixed the README's Codex subsection, which was missing the actual plugin install
  command after the marketplace-add step: `codex plugin add ssh-tunnel-swarm@psyb0t`.
- Clarified that the skill's invocation form differs depending on how Codex picked it
  up: installed via the marketplace it's `$ssh-tunnel-swarm:ssh-tunnel-swarm`, while
  auto-detected from a repo's own `.agents/skills/` (no install needed) it's plain
  `$ssh-tunnel-swarm`.

## v1.4.4 — 2026-07-27

- Added Claude Code and Codex plugin manifests (`.agents/.claude-plugin/plugin.json`,
  `.agents/.codex-plugin/plugin.json`) so the existing ClawHub skill installs natively
  in both clients via the shared `psyb0t/agents` marketplace.
- Added an "Agent integrations" section to the README with the install commands for
  Claude Code, Codex, and OpenClaw.

## v1.4.3 — 2026-07-27

- Added a GitHub Actions CI status badge to the README.

## v1.4.2 — 2026-07-27

- Added self-hosted version and license badges; wired a badges job into pipeline.yml.

## v1.4.1 — 2026-07-27

First stable release. Promotes the `v1.4.x-alpha` line to a stable version; the
code at this commit is unchanged from `v1.4.1-alpha`.

- Manage multiple concurrent forward and reverse SSH tunnels from a single
  rule-based config file, including per-host user-defined SSH private keys.

## Pre-1.4.1 (alpha)

See the git tags `v1.0.0-alpha` … `v1.4.1-alpha` for the pre-stable history:
concurrent forward/reverse tunnel management driven by a predefined ruleset,
per-host key support, and packaging wiring.

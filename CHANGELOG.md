# Changelog

All notable changes per release. Versions follow [semver](https://semver.org).

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

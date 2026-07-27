# Changelog

All notable changes per release. Versions follow [semver](https://semver.org).

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

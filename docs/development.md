---
title: "Development"
description: "Work on ssh-tunnel-swarm: source layout, Make targets, the tests, how make build merges the sources, CI and the release process."
nav_order: 9
---

# Development

Docker, Make and Bash are all you need. Lint and tests run in pinned containers, so no local shellcheck is required. Coding agents start from [`AGENTS.md`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/AGENTS.md) and the rules in [`.agents/rules/`](https://github.com/psyb0t/ssh-tunnel-swarm/tree/master/.agents/rules).

## Layout

| File | What it holds |
| --- | --- |
| [`main.sh`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/main.sh) | Entry point: loads the rules, starts one subshell per connection, runs the `ssh` retry loop, handles signals |
| [`rules.sh`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/rules.sh) | `check_rules_file` and `load_rules`, which fills the `RULES` array |
| [`validators.sh`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/validators.sh) | Username, hostname or IP, port and tunnel line checks |
| [`splitters.sh`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/splitters.sh) | Splits header and tunnel strings into their parts |
| [`logger.sh`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/logger.sh) | The `logger` function and the `LOG_*` defaults |
| [`test.sh`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/test.sh), [`common_test.sh`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/common_test.sh), `*_test.sh` | Test runner, assertion helpers and the unit tests |
| [`tools/downloader.sh`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/tools/downloader.sh) | The installer that fetches the release asset |
| [`Makefile`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/Makefile) | Build, lint, test and docs targets |
| `docs/` | This site |

## Make targets

```bash
make help     # list the targets
make build    # merge the sources into build/ssh-tunnel-swarm
make lint     # shellcheck over every tracked *.sh, in a container
make test     # ./test.sh in the bash image, as your user
make docs     # build this site locally with the GitHub Pages image
make run      # bash main.sh from the repository root
make clean    # remove build/
```

## Tests

`make test` runs `./test.sh` inside the pinned `bash` image with the repository mounted read-only, as your own user and group. One test checks that an unreadable rules file is refused, which needs a non-root user. `test.sh` sets `LOG_ENABLED=0` and sources every `*_test.sh` file. The first failed assertion prints a `FAIL - ...` line and exits 1.

Add tests for a new function in `validators.sh`, `splitters.sh` or `rules.sh` to the matching `*_test.sh`. `main.sh` starts `ssh`, so it has no unit tests; try changes there with a fake `ssh` script early on your `PATH`.

## The build step

The release asset is a single file. `make build` concatenates `logger.sh`, `validators.sh`, `rules.sh`, `splitters.sh` and `main.sh` in that order, removes every line that starts with `source`, every full-line comment and every blank line, adds a `#!/bin/bash` line on top and writes `build/ssh-tunnel-swarm`. So a new source file has to be added to `SCRIPTS` in the `Makefile`, and no code may sit on a line that starts with `#` or `source`.

## CI and releases

[`.github/workflows/pipeline.yml`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/.github/workflows/pipeline.yml) runs on every push:

- On a branch push, the `code` job runs `make build`, `make lint` and `make test`. On `master`, the `badges` job then refreshes the version and license badges.
- On a `v*` tag, the checks do not run again. The `wait` job waits for the tagged commit's `master` run to pass, `release` creates the GitHub release from the annotated tag message, `release-asset` builds the script from the tag and uploads it as the `ssh-tunnel-swarm` asset that the downloader fetches, and `publish-to-clawhub` publishes the [agent skill](integrations.md).

To release: update `CHANGELOG.md` and the version in `.agents/.codex-plugin/plugin.json`, push to `master`, wait for the pipeline to pass, then push an annotated `vX.Y.Z` tag on that commit.

Other workflows mirror the repository to GitLab and Codeberg, archive it, and copy issues opened on the mirrors back to GitHub.

# ssh-tunnel-swarm

Instructions for coding agents (Codex, Claude Code and others) and for people changing this repository. Users of the tool want the documentation site, https://psyb0t.github.io/ssh-tunnel-swarm/, not this file.

## Agent setup

`CLAUDE.md` is a committed symlink to `AGENTS.md`, and `.claude` is a committed symlink to `.agents`, so Claude Code reads the same instructions, rules and skills as Codex. Claude's Edit and Write tools refuse to write through a symlink, so edit `AGENTS.md` and `.agents/rules/*.md` directly.

## What it is

A Bash tool that opens and holds many SSH tunnels at once. It reads a plain-text rules file of connection blocks (a `user@host:port=/path/to/key` header followed by `forward` or `reverse` tunnel lines), validates every line, then runs one `ssh -N` per block in a background subshell and restarts it 5 seconds after it fails. Configuration is four environment variables (`RULES_FILE`, `LOG_ENABLED`, `LOG_FILE`, `LOG_LEVEL`); there are no flags or subcommands. The release asset is one merged script, `ssh-tunnel-swarm`, that `make build` produces from the sources.

## Architecture

- `main.sh`: the entry point. Sources `logger.sh`, `rules.sh` and `splitters.sh`, calls `load_rules`, then `main` starts `establish_ssh_connection` in a background subshell for every key of `RULES`, records the subshell PIDs in `SUBSHELL_PIDS` and `HOST_PIDS`, traps `SIGTERM`/`SIGINT` with `kill_ssh_connections`, and `wait`s.
- `establish_ssh_connection` (in `main.sh`): splits the header with the `split_*` helpers, turns each tunnel line into `-L local:lport:remote:rport` (`forward`) or `-R remote:rport:local:lport` (`reverse`), then loops: `ssh -N -i <key> -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=yes <flags> -p <port> <user>@<host>`, output captured in a `mktemp` file. Exit 0 ends the loop; any other status is logged at `ERROR` and retried after `sleep 5`.
- `rules.sh`: defaults `RULES_FILE` to `rules.txt`, declares the associative array `RULES`, and defines `check_rules_file` and `load_rules`. `RULES` maps the full header line to its tunnel lines joined with `;`.
- `validators.sh`: `is_valid_hostname_or_ip`, `is_valid_username`, `is_valid_host_port`, `is_valid_forward_reverse_line`, `is_valid_port`.
- `splitters.sh`: `split_user_host_port_key`, `split_user_host_port`, `split_user_host`, `split_interface_ports`. Each echoes the parts space-separated and returns 1 when a part is empty.
- `logger.sh`: defaults `LOG_LEVEL=INFO`, `LOG_ENABLED=1`, `LOG_FILE=` and defines `logger LEVEL MESSAGE`. Levels are `DEBUG`, `INFO`, `ERROR`, `FATAL`; `FATAL` exits 1. Lines look like `[YYYY-MM-DD HH:MM:SS] [LEVEL] message`.
- `tools/downloader.sh`: the install script. Needs `jq` and `wget`, reads `https://api.github.com/repos/psyb0t/ssh-tunnel-swarm/releases`, takes the first release in the list, downloads its `ssh-tunnel-swarm` asset into the current directory and makes it executable.

Flow: `RULES_FILE` -> `load_rules` (validate, fill `RULES`) -> one subshell per header -> `ssh -N` loop -> signal -> `kill_ssh_connections`.

## Stack

- Bash only, with associative arrays (`declare -A`), so Bash 4 or newer. Runtime needs `ssh`, `mktemp`, `date` and `pgrep`.
- Tests are plain Bash: `common_test.sh` holds `assert_equals`, `assert_is_error` and `assert_no_error`.
- Lint is shellcheck in the pinned `koalaman/shellcheck` image; tests run in the pinned `bash` image. Both are set at the top of the `Makefile`.
- Docs: GitHub Pages builds `docs/` from `master` with Jekyll and the Just the Docs remote theme.
- CI: `.github/workflows/pipeline.yml` calling `psyb0t/reusable-github-workflows`.

## Layout

| Path | What it holds |
| --- | --- |
| `main.sh` | Entry point, per-host `ssh` loop, signal handling |
| `rules.sh` | Rules file checks and the parser that fills `RULES` |
| `validators.sh` | Username, host, port and tunnel line validators |
| `splitters.sh` | String splitters used by `main.sh` |
| `logger.sh` | The `logger` function and the `LOG_*` defaults |
| `*_test.sh`, `common_test.sh`, `test.sh` | Unit tests, assertion helpers, and the runner that sources every `*_test.sh` |
| `rules.txt.example` | A sample rules file |
| `tools/downloader.sh` | The `wget ... \| bash` installer |
| `Makefile` | `build`, `lint`, `test`, `docs`, `run`, `clean` |
| `build/` | `make build` output (gitignored) |
| `docs/` | The documentation site |
| `assets/` | The README image |
| `.agents/skills/ssh-tunnel-swarm/` | The agent skill and its `references/setup.md` |
| `.agents/.claude-plugin/`, `.agents/.codex-plugin/` | Claude Code and Codex plugin manifests |
| `.agents/rules/` | Rules for changing this repository |
| `.github/workflows/` | `pipeline.yml` plus the mirror, archive and issue-pull workflows |

## Commands

Docker, Make and Bash are enough. Lint and tests run in containers.

```bash
make help     # every target
make build    # merge the sources into build/ssh-tunnel-swarm
make lint     # shellcheck over every tracked *.sh
make test     # ./test.sh inside the bash image, as your uid
make docs     # build the site locally with the GitHub Pages image
make run      # bash main.sh from the repository root
make clean    # remove build/
```

## Project-specific landmines

- `make build` drops every line that starts with `source`, every full-line comment and every blank line, then concatenates `logger.sh validators.sh rules.sh splitters.sh main.sh` in that order. A new source file must be added to `SCRIPTS` in dependency order, and code must not depend on a line that starts with `#` or `source`.
- The sources use `source logger.sh` relative to the current directory, so `main.sh`, `test.sh` and the tests only work from the repository root. The built script has no `source` lines and runs from anywhere.
- `tools/downloader.sh` looks for an asset named exactly `ssh-tunnel-swarm` on the first release the API returns. The pipeline's `release-asset` job uploads it. Renaming the asset or dropping that job breaks the install command in the README.
- `logger` returns before the `FATAL` exit when `LOG_ENABLED` is below 1, so with logging off a validation failure does not stop the script. `test.sh` sets `LOG_ENABLED=0`, which is why the tests can call the validators without exiting.
- `RULES` is keyed by the whole header line. A second block with the same header resets that key and drops the first block's tunnels.
- `load_rules` counts only non-blank lines, so "in line N" in its error messages is not the file line number.

## Rules

Rules for every change live in `.agents/rules/`, one file per topic. Read the ones that match what you are touching before editing.

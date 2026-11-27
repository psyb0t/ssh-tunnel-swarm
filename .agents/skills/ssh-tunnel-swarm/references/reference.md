# ssh-tunnel-swarm: configuration reference

Requires bash 4 or newer and `ssh` (keys set up, agent or plain key files).

## Env vars (the entire CLI surface, there are no flags)

| Var | Default | Meaning |
|---|---|---|
| `RULES_FILE` | `rules.txt` (relative to cwd) | Path to the rules/config file described below. |
| `LOG_ENABLED` | `1` | `1` or higher = logging on, `0` (or any non-number) = fully silent. Silent also skips the FATAL exit, so a bad rules file no longer stops the script; prefer `LOG_LEVEL=FATAL` to quiet it. |
| `LOG_FILE` | unset | If set, log lines are appended to this file instead of stdout. |
| `LOG_LEVEL` | `INFO` | Minimum severity emitted: `DEBUG` < `INFO` < `ERROR` < `FATAL`. Messages below this level are dropped. Must be uppercase; an unknown value logs everything. |

Invocation pattern: set the vars inline, then run the script:

```shell
RULES_FILE=/path/to/rules.txt \
LOG_ENABLED=1 \
LOG_FILE=/path/to/tunnels.log \
LOG_LEVEL=DEBUG \
ssh-tunnel-swarm
```

### Log levels

- **DEBUG**: verbose, every parsing/splitting/connection-building step, the full `ssh` command and its raw output. Use while building or debugging a rules file.
- **INFO**: normal operational feedback: connection attempts, a connection that exited 0, shutdown.
- **ERROR**: a rules file check failed, or a connection attempt failed (script keeps retrying).
- **FATAL**: unrecoverable: missing/unreadable/empty rules file, missing SSH key file, invalid line syntax. Process exits with status 1.

Log line format: `[YYYY-MM-DD HH:MM:SS] [LEVEL] message`.

## Rules file: full syntax reference

Default location `rules.txt`, overridden by `RULES_FILE`. Structure = one or more **connection blocks**. Empty lines are ignored everywhere; every non-blank line must match one of the two line types below or the whole file is rejected (FATAL) at load time. The loader validates every line before any SSH connection is attempted. There is no comment syntax: a `#` line is an invalid line. Line numbers in error messages count only non-blank lines.

### 1. Header line (starts a new block)

```
user@hostname:port=/path/to/private/ssh/key
```

Regex the loader actually matches against:
`^([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+:[0-9]+)=\/[a-zA-Z0-9._\/-]+$`

Field validation on top of the regex:

- `user`: `is_valid_username`: `^[a-zA-Z0-9._-]+$`.
- `hostname`: `is_valid_hostname_or_ip`: either 4 dot-separated numeric octets each `0-255`, or a hostname matching `^[a-zA-Z0-9.-]+$` that is NOT all-digits and contains none of `! @ # $ % ^ & * ( ) , ? / < >`.
- `port`: `is_valid_port`: numeric, `0-65535`.
- `/path/to/private/ssh/key`: must be absolute and exist on disk (checked with `-f`) or the loader FATALs immediately with "SSH private key file not found".

Each header line opens a new "current host": every tunnel line that follows belongs to it until the next header line. The full header line is the key of the `RULES` array, so repeating an identical header line resets that connection's tunnel list.

### 2. Tunnel line (one or more per block, after a header line)

```
forward local-interface:local-port:remote-interface:remote-port
reverse local-interface:local-port:remote-interface:remote-port
```

Regex: `^(reverse|forward)\ [^\ ]+\:[0-9]+\:[^\ ]+\:[0-9]+$`, plus `is_valid_forward_reverse_line`, which re-validates the keyword, the local interface (hostname/IP rules same as above), and both ports (`0-65535`). The remote interface is only checked by the regex.

What each direction actually runs (per connection block, all tunnel lines for that block get folded into ONE `ssh` invocation):

- `reverse local-interface:local-port:remote-interface:remote-port` → SSH flag `-R remote-interface:remote-port:local-interface:local-port` (the REMOTE host binds `remote-interface:remote-port` and forwards connections back to `local-interface:local-port` on your machine).
- `forward local-interface:local-port:remote-interface:remote-port` → SSH flag `-L local-interface:local-port:remote-interface:remote-port` (YOUR machine binds `local-interface:local-port` and forwards connections to `remote-interface:remote-port` as reachable from the remote host).

Note the field ORDER is identical for both directions in the rules file (`local:local:remote:remote`). Only the emitted `-L`/`-R` flag differs in how those four fields get remapped into SSH's own `bind:dest` order.

### 3. Full multi-tunnel, multi-host example

```
jsmith@host123:23456=/path/to/ssh/private/key
reverse host123.example.com:6000:10.0.0.5:7000
forward 10.0.0.1:8081:host123.example.com:9090
reverse 192.168.0.10:1234:host123.example.com:5678

mjohnson@host456:56789=/path/to/ssh/private/key
reverse host456.example.com:8080:192.168.0.10:80
forward 192.168.0.5:9999:host456.example.com:3333
```

Two blocks = two independent SSH connections started concurrently, each in its own background subshell, each carrying multiple `-L`/`-R` flags on one `ssh -N` call.

### What happens per connection at runtime

For each block, `ssh-tunnel-swarm` runs one `ssh -N` in a loop, with the block's key, port and every `-L`/`-R` flag for the block, and these options:

- `-N`: no remote command, tunnel-only session.
- `-i <key>`: the private key named in the header line.
- `ExitOnForwardFailure=yes`: if any single forward/reverse bind fails, the whole `ssh` process exits (so the retry loop can catch it and retry the full set).
- `ServerAliveInterval=30` / `ServerAliveCountMax=3`: dead-connection detection (~90s to notice a hung link and exit).
- `StrictHostKeyChecking=yes`: the target's host key MUST already be in `known_hosts`, or the connection is refused. Populate `known_hosts` yourself (`ssh-keyscan` or a first manual connect on a trusted network) before running the swarm. If a host's key changes, you must manually clean the stale entry from `known_hosts`.
- On non-zero exit, the tool logs the failure at ERROR, sleeps 5s, and retries. This repeats until the script is stopped. On exit status 0 it logs "SSH connection successful" and that connection's loop ends for good (not retried).

### Shutdown

`SIGINT`/`SIGTERM` to the main process is trapped: each per-host supervising subshell is killed, INFO lines are logged, and the process exits. `Ctrl-C` in a terminal also delivers SIGINT to every `ssh` child, so everything stops. A plain `kill <pid>` of the main process does NOT reach the `ssh` children: they keep running and keep their tunnels open. Signal the process group (`kill -TERM -- -<pgid>`) or kill leftover `ssh` processes by PID.

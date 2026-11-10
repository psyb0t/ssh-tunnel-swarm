---
title: "Running the swarm"
description: "What ssh-tunnel-swarm runs for each host, how its retry loop behaves, how to stop it cleanly, and how to keep it running under systemd."
nav_order: 5
---

# Running the swarm

Run the script with your [environment variables](configuration.md) set. It stays in the foreground until you stop it:

```shell
RULES_FILE=/path/to/rules.txt ssh-tunnel-swarm
```

## What happens at startup

1. The script checks that the rules file exists, is readable and is not empty.
2. It validates every line of the [rules file](rules-file.md). The first invalid line stops it with a `FATAL` message, before any connection opens.
3. For every header line it starts a background subshell that runs that connection's loop. All connections start at the same time and run independently, so one host being down does not hold up the others.

## The ssh command

Each connection runs one `ssh` process with all of its tunnels:

```shell
ssh -N -i /path/to/private/key \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=3 \
  -o StrictHostKeyChecking=yes \
  -L ... -R ... \
  -p port user@hostname
```

| Option | Effect |
| --- | --- |
| `-N` | Run no remote command; the session only carries tunnels |
| `-i` | Use the key file from the header line |
| `ExitOnForwardFailure=yes` | If any one tunnel of the block cannot be set up, `ssh` exits instead of running with the rest |
| `ServerAliveInterval=30`, `ServerAliveCountMax=3` | Send a keepalive every 30 seconds and give up after 3 unanswered ones, so a dead link is noticed in about 90 seconds |
| `StrictHostKeyChecking=yes` | Refuse to connect unless the server's host key is already in `known_hosts`. See [Security](security.md#host-keys) |

Your own `~/.ssh/config` still applies to everything these options do not set.

## The retry loop

Each connection loops:

1. Log `Creating tunnel(s) on user@host: ...` at `INFO`.
2. Run `ssh`, with its output going to a temporary file.
3. When `ssh` exits with a non-zero status, log the status and its output at `ERROR`, wait 5 seconds and go back to step 1.
4. When `ssh` exits with status 0, log `SSH connection successful for host ...` at `INFO` and end that connection's loop for good.

The retry delay is a fixed 5 seconds with no backoff and no retry limit. A host that is down gets an attempt every few seconds for as long as the script runs. `ssh` output only shows up in the log after `ssh` exits, so a running connection logs nothing.

Status 0 is rare for `ssh -N`, but when it happens that connection stays down until you restart the script. The other connections keep running.

## Stopping it

`Ctrl-C` in the terminal stops everything. The terminal sends the interrupt to the script and to every `ssh` it started, the script logs `Killing SSH connections` and `Script terminated.`, and exits.

`kill <pid>` on the script alone is not enough. The script catches `SIGTERM` and kills its per-connection subshells, but the `ssh` processes those subshells started keep running and keep the tunnels open. Signal the whole process group instead:

```shell
kill -TERM -- -"$(ps -o pgid= -p <pid> | tr -d ' ')"
```

Check with `pgrep -a ssh` afterwards and kill any leftover tunnel by its PID.

## Running it as a service

A systemd unit keeps the swarm running across reboots. systemd's default `KillMode=control-group` stops every process of the unit, so the leftover `ssh` problem above does not apply. A minimal unit, assuming the script is in `/usr/local/bin` and the rules and keys belong to the `tunnel` user:

```ini
[Unit]
Description=ssh-tunnel-swarm
After=network-online.target
Wants=network-online.target

[Service]
User=tunnel
Environment=RULES_FILE=/home/tunnel/rules.txt
ExecStart=/usr/local/bin/ssh-tunnel-swarm
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Without `LOG_FILE`, the log goes to standard output and from there to the journal: `journalctl -u ssh-tunnel-swarm -f`. The `tunnel` user's `~/.ssh/known_hosts` must already hold every server's host key.

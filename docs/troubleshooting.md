---
title: "Troubleshooting"
description: "ssh-tunnel-swarm error messages and fixes: rules file checks, invalid lines, missing keys, host key failures, refused tunnels and processes left behind."
nav_order: 7
---

# Troubleshooting

Start with `LOG_LEVEL=DEBUG`. It logs every parsing step, the exact `ssh` command and the full `ssh` output.

## Startup errors

These stop the script with exit status 1 before any connection opens. "in line N" counts only non-blank lines of the rules file.

| Message | Cause | Fix |
| --- | --- | --- |
| `Rules file "rules.txt" not found`, then `Rules file checks failed` | No file at `RULES_FILE`. The default `rules.txt` is looked up in the current directory | Set `RULES_FILE` to an absolute path, or run from the directory holding `rules.txt` |
| `Current user does not have read permissions on rules file "..."` | The file is not readable by this user | `chmod` or `chown` the file |
| `Rules file "..." is empty` | The file has zero bytes | Add at least one block |
| `Invalid line in rules file: ... in line N` | The line is neither a header line nor a tunnel line. Common causes: a `#` comment, trailing spaces, CRLF line endings, a key path that is relative or uses `~`, a tunnel line before the first header, or a misspelled direction | Fix the line to match the [rules file syntax](rules-file.md). `sed -i 's/\r$//' rules.txt` removes CRLF endings |
| `SSH private key file not found: /path` | The key path in a header line does not point to a file | Fix the path. It must be absolute |
| `Invalid hostname/IP address: ... in line N` | The host is all digits, or looks like an IPv4 address with an octet above 255 | Fix the host |
| `Invalid port: ... in line N` | The header port is above 65535 | Use the real SSH port |
| `Invalid forward/reverse line: ... in line N` | The local interface is not a valid hostname or IPv4 address, or a port is above 65535 | Fix the tunnel line |

With `LOG_LEVEL=FATAL` you see only the `FATAL` line, `Rules file checks failed`, without the reason before it. With `LOG_ENABLED=0` you see nothing, and the script carries on past the error. See [Configuration](configuration.md#log_enabled).

## Connection errors

A failed connection logs two lines at `ERROR` and retries every 5 seconds:

```text
[2026-01-31 12:00:05] [ERROR] SSH connection to myvps.com exited with status: 255
[2026-01-31 12:00:05] [ERROR] SSH connection error message: Host key verification failed.
```

The second line is whatever `ssh` printed. The common ones:

| `ssh` output | Cause | Fix |
| --- | --- | --- |
| `Host key verification failed.` | The server's key is not in `known_hosts`, or it changed | Add or replace the key, see [Security](security.md#host-keys) |
| `Permission denied (publickey).` | The server does not accept this key for this user | Add the public key to the server's `~/.ssh/authorized_keys` for that user |
| `Error: remote port forwarding failed for listen port ...` | The server refused a `reverse` tunnel: the port is in use, it is below 1024 without a root login, or forwarding is disabled | Pick another port, or change the server's `sshd_config`, see [What the SSH server allows](rules-file.md#what-the-ssh-server-allows) |
| `bind [...]: Address already in use` | A `forward` port is already taken on your machine, often by an `ssh` left over from an earlier run | Find the owner with `ss -ltnp` and stop it |
| `ssh: connect to host ... port 22: Connection refused` or `... timed out` | The server is down, the port is wrong, or a firewall is in the way | Check with a plain `ssh` to the same host and port |
| `Load key "...": bad permissions` | The key file is readable by other users | `chmod 600` the key |

Because of `ExitOnForwardFailure=yes`, one refused tunnel takes its whole connection down, including the tunnels that would have worked.

## A reverse tunnel only listens on 127.0.0.1

The line asks for `0.0.0.0` but `ss -ltn` on the server shows `127.0.0.1`. The server has the default `GatewayPorts no`. Set `GatewayPorts clientspecified` in its `sshd_config` and reload `sshd`.

## Tunnels stay up after the script was killed

`kill <pid>` on the script stops the script but not the `ssh` processes it started. Stop them by PID (`pgrep -a ssh`), and next time signal the process group or use `Ctrl-C`. See [Stopping it](running.md#stopping-it).

## One connection stopped retrying

The log shows `SSH connection successful for host ...` and nothing after it for that host. `ssh` exited with status 0, which ends that connection's loop. Restart the script to bring it back.

## main.sh fails with "No such file or directory"

The source files load `logger.sh`, `rules.sh` and the others from the current directory. Run `bash main.sh` from the repository root, or use the built script from `make build`, which has no such dependency.

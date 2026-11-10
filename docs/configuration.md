---
title: "Configuration"
description: "The four ssh-tunnel-swarm environment variables (RULES_FILE, LOG_ENABLED, LOG_FILE, LOG_LEVEL), the log levels and the log line format."
nav_order: 4
---

# Configuration

ssh-tunnel-swarm has no command-line flags. Everything outside the [rules file](rules-file.md) comes from four environment variables, read once at startup. Set them on the command line or export them before running the script:

```shell
RULES_FILE=/etc/ssh-tunnel-swarm/rules.txt \
LOG_ENABLED=1 \
LOG_FILE=/var/log/ssh-tunnel-swarm.log \
LOG_LEVEL=DEBUG \
ssh-tunnel-swarm
```

An empty value counts as unset and gets the default.

## Environment variables

| Variable | Default | Meaning |
| --- | --- | --- |
| `RULES_FILE` | `rules.txt` | Path to the rules file. A relative path is resolved from the current directory |
| `LOG_ENABLED` | `1` | `1` or higher turns logging on. Anything else turns it off, see below |
| `LOG_FILE` | unset | When set, log lines are appended to this file instead of printed to standard output |
| `LOG_LEVEL` | `INFO` | The lowest level that gets logged: `DEBUG`, `INFO`, `ERROR` or `FATAL` |

### RULES_FILE

The file must exist, be readable by the user running the script and not be empty. Otherwise the script logs why and exits with `Rules file checks failed`. The [rules file](rules-file.md) page describes its contents.

### LOG_ENABLED

Bash compares the value as a number, so `1`, `2` or `10` turn logging on, while `0`, `yes`, `true` or `on` turn it off.

Turning logging off has a side effect: `FATAL` messages are what stop the script, and with logging off they are skipped too. A bad rules file then no longer stops the script at startup. Leave logging on, and silence it with `LOG_LEVEL=FATAL` or `LOG_FILE=/dev/null` instead.

### LOG_FILE

The script opens the file in append mode for every line and never rotates or truncates it. Use logrotate with `copytruncate`, or any tool that does not need the script to reopen the file.

### LOG_LEVEL

Write the level in capitals. A value the logger does not know, including `debug` in lowercase or `WARN`, makes it log everything, as `DEBUG` does.

## Log levels

| Level | What gets logged at it |
| --- | --- |
| `DEBUG` | Every parsing step, every split of a header or tunnel line, the full `ssh` command, and the raw `ssh` output with its exit status |
| `INFO` | `Creating tunnel(s) on user@host: ...` before each attempt, a connection that ended with status 0, and the shutdown messages |
| `ERROR` | A rules file check that failed, and each failed `ssh` attempt with its exit status and output |
| `FATAL` | A problem that stops the script with exit status 1, such as an invalid line in the rules file or a missing key file |

Each level includes the ones below it in the table: `INFO` also shows `ERROR` and `FATAL` messages.

## Log format

```text
[2026-01-31 12:00:00] [INFO] Creating tunnel(s) on user@myvps.com: reverse localhost:3000:0.0.0.0:8080;
[2026-01-31 12:00:05] [ERROR] SSH connection to myvps.com exited with status: 255
[2026-01-31 12:00:05] [ERROR] SSH connection error message: ssh: connect to host myvps.com port 22: Connection refused
```

Every line is `[YYYY-MM-DD HH:MM:SS] [LEVEL] message`, using the local time zone. The `ssh` output can span several lines, and those extra lines carry no prefix. The tunnel list in the `INFO` line is the block's tunnel lines joined with `;`.

---
title: "Home"
description: "ssh-tunnel-swarm opens many forward and reverse SSH tunnels from one rules file, one ssh process per host, and restarts each one when it fails."
nav_order: 1
permalink: /
seo:
  type: WebSite
---

# ssh-tunnel-swarm

ssh-tunnel-swarm is a Bash script that keeps a set of SSH tunnels open. You list hosts and tunnels in a plain-text [rules file](rules-file.md); it checks every line, starts one `ssh -N` per host with all of that host's `-L` and `-R` flags, and starts it again 5 seconds after it fails.

```text
rules.txt ── load_rules (validate every line)
               │
               ├─ user@vps1:22  ── ssh -N -R ... -L ... ── retry every 5s
               ├─ user@vps2:22  ── ssh -N -R ...        ── retry every 5s
               └─ ...
```

It is one file with no daemon, no flags and no config format beyond the rules file. Four environment variables cover the rest. It needs `bash` and `ssh`, and it only does key authentication.

## Quick start

1. Download the latest release into the current directory (needs `jq` and `wget`):

   ```shell
   wget -qO- https://raw.githubusercontent.com/psyb0t/ssh-tunnel-swarm/master/tools/downloader.sh | bash
   ```

2. Write `rules.txt`. This makes a web app on port 3000 of your machine reachable on port 8080 of a VPS:

   ```text
   user@myvps.com:22=/home/user/.ssh/id_ed25519
   reverse localhost:3000:0.0.0.0:8080
   ```

3. Make sure the VPS host key is already in `~/.ssh/known_hosts` (connect once with plain `ssh user@myvps.com`), then run it:

   ```shell
   ./ssh-tunnel-swarm
   ```

The remote side only listens on `0.0.0.0` if the server's `GatewayPorts` setting allows it. [Rules file](rules-file.md) has the details, and [Installation](installation.md) puts the script on your `PATH`.

## Where to go next

| Page | What is in it |
| --- | --- |
| [Installation](installation.md) | The downloader, putting the script on `PATH`, building from source, upgrading and removing it |
| [Rules file](rules-file.md) | Header and tunnel line syntax, what `forward` and `reverse` turn into, validation rules and examples |
| [Configuration](configuration.md) | `RULES_FILE`, `LOG_ENABLED`, `LOG_FILE`, `LOG_LEVEL`, log levels and the log line format |
| [Running the swarm](running.md) | The exact `ssh` command, the retry loop, stopping it, and running it under systemd |
| [Security](security.md) | Host key checking, key files, what `forward` and `reverse` expose, what the logs contain |
| [Troubleshooting](troubleshooting.md) | Every startup error message, connection errors, and what to do about them |
| [Agent integrations](integrations.md) | The agent skill for Claude Code, Codex and OpenClaw |
| [Development](development.md) | Source layout, Make targets, tests, the build step and the release pipeline |

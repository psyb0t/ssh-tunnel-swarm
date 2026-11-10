# ssh-tunnel-swarm

[![CI](https://github.com/psyb0t/ssh-tunnel-swarm/actions/workflows/pipeline.yml/badge.svg?branch=master)](https://github.com/psyb0t/ssh-tunnel-swarm/actions/workflows/pipeline.yml)
[![version](https://raw.githubusercontent.com/psyb0t/ssh-tunnel-swarm/badges/version.svg)](https://github.com/psyb0t/ssh-tunnel-swarm/releases)
[![license](https://raw.githubusercontent.com/psyb0t/ssh-tunnel-swarm/badges/license.svg)](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/LICENSE)

![ssh-tunnel-swarm](https://raw.githubusercontent.com/psyb0t/ssh-tunnel-swarm/master/assets/ssh-tunnel-swarm.png)

ssh-tunnel-swarm is a shell script that keeps many SSH tunnels open at once. You list hosts and their forward and reverse tunnels in one plain-text rules file, and it runs one `ssh` per host and starts it again whenever it drops.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Agent integrations](#agent-integrations)
- [Sponsor](#sponsor)
- [License](#license)
- [TODO](#todo)

## Features

- Multiple SSH connections, each carrying any number of tunnels.
- Forward (`ssh -L`) and reverse (`ssh -R`) tunnels, mixed freely per host.
- One rules file, validated in full before any connection opens.
- A dropped connection is retried every 5 seconds until you stop the script.
- A separate private key per host. Key authentication only.
- Logging to stdout or a file, with four levels.

It needs `bash` 4 or newer and `ssh`. The downloader also needs `jq` and `wget`.

## Installation

```shell
wget -qO- https://raw.githubusercontent.com/psyb0t/ssh-tunnel-swarm/master/tools/downloader.sh | bash
sudo mv ssh-tunnel-swarm /usr/local/bin/
```

That downloads the latest release into the current directory and moves it onto your `PATH`. [Installation](https://psyb0t.github.io/ssh-tunnel-swarm/installation/) covers per-user installs, building from source and upgrading.

## Usage

Write a rules file. Each block is a `user@host:port=/path/to/key` line followed by one tunnel per line, `forward` or `reverse` then `local-interface:local-port:remote-interface:remote-port`:

```text
user@myvps.com:22=/home/user/.ssh/id_ed25519
reverse localhost:3000:0.0.0.0:8080

user@gateway.example.com:22=/home/user/.ssh/id_ed25519
forward localhost:6366:10.137.82.201:636
```

The first block makes port 3000 on your machine reachable as port 8080 on the VPS. The second makes `localhost:6366` on your machine reach `10.137.82.201:636` through the gateway.

Every server's host key must already be in your `known_hosts`, because connections run with `StrictHostKeyChecking=yes`. Then run it:

```shell
RULES_FILE=/path/to/rules.txt \
LOG_ENABLED=1 \
LOG_FILE=/path/to/log/file \
LOG_LEVEL=DEBUG \
ssh-tunnel-swarm
```

Stop it with `Ctrl-C`.

## Documentation

The full documentation lives at **https://psyb0t.github.io/ssh-tunnel-swarm/**.

| Page | What is in it |
| --- | --- |
| [Installation](https://psyb0t.github.io/ssh-tunnel-swarm/installation/) | The downloader, `PATH` setup, building from source, upgrading and removing |
| [Rules file](https://psyb0t.github.io/ssh-tunnel-swarm/rules-file/) | Header and tunnel syntax, what `forward` and `reverse` become, validation and examples |
| [Configuration](https://psyb0t.github.io/ssh-tunnel-swarm/configuration/) | The four environment variables, log levels and log format |
| [Running the swarm](https://psyb0t.github.io/ssh-tunnel-swarm/running/) | The `ssh` command, the retry loop, stopping it and running it under systemd |
| [Security](https://psyb0t.github.io/ssh-tunnel-swarm/security/) | Host keys, key files, what tunnels expose and what the logs contain |
| [Troubleshooting](https://psyb0t.github.io/ssh-tunnel-swarm/troubleshooting/) | Every startup error and the common `ssh` failures |
| [Agent integrations](https://psyb0t.github.io/ssh-tunnel-swarm/integrations/) | The agent skill for Claude Code, Codex and OpenClaw |
| [Development](https://psyb0t.github.io/ssh-tunnel-swarm/development/) | Layout, Make targets, tests, the build step and releases |

## Agent integrations

The [skill](https://github.com/psyb0t/ssh-tunnel-swarm/tree/master/.agents/skills/ssh-tunnel-swarm) works in any agent that reads `.agents/skills/` (such as [peen](https://github.com/psyb0t/peen)), and installs natively in Claude Code, Codex and OpenClaw:

```bash
claude plugin marketplace add psyb0t/agents
claude plugin install ssh-tunnel-swarm@psyb0t
```

[Agent integrations](https://psyb0t.github.io/ssh-tunnel-swarm/integrations/) has the Codex and OpenClaw commands.

## Sponsor

<a href="https://www.buymeacoffee.com/psyb0t"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me a Coffee" height="60" width="217"></a>

## License

This software is licensed under the terms of the **Do What The Fuck You Want To Public License (WTFPL)**. This license allows you to use the software for any purposes, without any conditions or restrictions unless such restrictions are required by law. You can learn more about the license at http://www.wtfpl.net/about/.

By using this software, you agree to abide by the terms of the **WTFPL**. If you do not agree, please do not use, modify, or distribute the software.

## TODO

- refactor
- better error handling
- better testing utils

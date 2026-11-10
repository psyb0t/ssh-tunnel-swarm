---
title: "Agent integrations"
description: "Install the ssh-tunnel-swarm agent skill in Claude Code, Codex or OpenClaw so a coding agent can write rules files and run the tool."
nav_order: 8
---

# Agent integrations

The repository ships an agent skill in [`.agents/skills/ssh-tunnel-swarm/`](https://github.com/psyb0t/ssh-tunnel-swarm/tree/master/.agents/skills/ssh-tunnel-swarm). It teaches an agent the rules file grammar, the environment variables, the `ssh` command the tool runs and when not to use it. It works in any agent that reads `.agents/skills/`, such as [peen](https://github.com/psyb0t/peen), and installs natively in the clients below.

## Claude Code

```bash
claude plugin marketplace add psyb0t/agents
claude plugin install ssh-tunnel-swarm@psyb0t
```

## Codex

```bash
codex plugin marketplace add psyb0t/agents
codex plugin add ssh-tunnel-swarm@psyb0t
```

Installed through the marketplace, the skill is invoked as `$ssh-tunnel-swarm:ssh-tunnel-swarm`. Codex also picks it up with no install in any repository that contains `.agents/skills/`, where it is invoked as plain `$ssh-tunnel-swarm`.

## OpenClaw

The skill is published to ClawHub on every release:

```bash
openclaw skills install @psyb0t/ssh-tunnel-swarm
```

The plugin manifests are [`.agents/.claude-plugin/plugin.json`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/.agents/.claude-plugin/plugin.json) and [`.agents/.codex-plugin/plugin.json`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/.agents/.codex-plugin/plugin.json).

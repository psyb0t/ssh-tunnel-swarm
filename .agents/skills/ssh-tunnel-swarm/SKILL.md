---
name: ssh-tunnel-swarm
description: >
  Bash tool that spins up and holds open MANY concurrent SSH tunnels, both forward (-L)
  and reverse (-R), driven by a plain-text rules file. One connection block per host:
  a header line `user@host:port=/path/to/private/key` followed by one or more tunnel
  lines `forward|reverse local-iface:local-port:remote-iface:remote-port`. Each host
  connection runs in its own background loop
  (`ssh -N -i <key> -o ExitOnForwardFailure=yes -o ServerAliveInterval=30
  -o ServerAliveCountMax=3 -o StrictHostKeyChecking=yes`) and retries every 5s after
  a failed exit; Ctrl-C stops every tunnel. Configured entirely via env vars
  (RULES_FILE, LOG_ENABLED, LOG_FILE, LOG_LEVEL), no CLI flags. No password auth,
  key-based only. Use when the user wants to set up/manage multiple SSH forward or
  reverse tunnels from a single rules file across one or many hosts.
homepage: https://github.com/psyb0t/ssh-tunnel-swarm
user-invocable: true
permissions:
  shell: bash script (main.sh) that spawns and supervises long-running `ssh` child processes
  network: opens outbound SSH connections and forward/reverse port tunnels to every host listed in the rules file
  filesystem: reads the rules/config file (RULES_FILE) and the SSH private key path referenced by each connection block
metadata:
  openclaw:
    emoji: 🚇
    requires:
      bins: [ssh, bash]
---

# ssh-tunnel-swarm

Bash tool for running a swarm of SSH tunnels, forward and reverse, many hosts at once, off one rules file. No daemon, no config DSL beyond plain text, just `ssh -L`/`ssh -R` looped per host with automatic retry.

## Security & safety

- This opens real SSH connections using **your keys** to **hosts you list in the rules file**. Anything wrong in that file connects somewhere real.
- **Reverse tunnels (`reverse`) expose a LOCAL service to the REMOTE host.** Only point `reverse` rules at hosts you trust: a compromised or malicious remote can now reach whatever you bound on your side.
- **Forward tunnels (`forward`) expose a REMOTE service through YOUR local machine.** Same trust logic in reverse: don't forward into networks you don't control.
- All connections force `StrictHostKeyChecking=yes`: the target host must already be in `known_hosts` or the connection fails. That's intentional; don't work around it by disabling host key checking.
- No password auth support, private key only. Keep the key file permissions tight (`chmod 600`) and never put keys or the rules file (which references key paths) in a world-readable location or a git repo.
- Every connection block retries forever (fixed 5s delay) until you stop the script. Make sure that's actually what you want before pointing this at a host.

## When to use

- Standing up several forward and/or reverse SSH tunnels across one or many hosts from a single declarative file, instead of hand-rolling a pile of `ssh -L`/`ssh -R` commands or systemd units.
- Tunnels need to survive disconnects: the tool loops and reconnects automatically.
- Exposing a local dev service to a remote box (reverse), or reaching a remote-network-only service from your machine (forward).

## When NOT to use

- One-off, single tunnel for a few minutes: just run `ssh -L`/`ssh -R` directly.
- Password-based SSH auth: this tool only supports private key auth.
- You need a full VPN / mesh network (e.g. overlay networking, NAT traversal across many peers). This is tunnels over plain SSH, not a VPN.

## Config grammar (rules file)

Plain text file, default path `rules.txt` (relative to the current directory), overridable via `RULES_FILE`. It's a sequence of **connection blocks**. Each block:

```
<line 1>  user@host:port=/path/to/private/ssh/key
<line 2+> forward|reverse local-interface:local-port:remote-interface:remote-port
          ... (one or more tunnel lines)
```

- **Header line**, exactly one per block, always first:
  `user@hostname:port=/path/to/private/key`
  - `user`: `[a-zA-Z0-9._-]+`
  - `hostname`: hostname or IPv4 (no scheme, no IPv6, not all digits)
  - `port`: SSH port on the remote host, `0-65535`
  - `=/path/to/key`: ABSOLUTE path (`[a-zA-Z0-9._/-]`, no `~`, no spaces) to the private key for THIS connection; must exist on disk or the tool refuses to start (FATAL at load time).
- **Tunnel lines**, one or more per block. Every tunnel line belongs to the last header line above it:
  `direction local-interface:local-port:remote-interface:remote-port`
  - `direction` is literally `forward` or `reverse`, nothing else.
  - all four of interface/port/interface/port are required, colon-separated, no spaces.
  - **`reverse`** → `ssh -R remote-interface:remote-port:local-interface:local-port` (binds on the REMOTE host, forwards back to your LOCAL interface:port).
  - **`forward`** → `ssh -L local-interface:local-port:remote-interface:remote-port` (binds on your LOCAL interface, forwards to something reachable FROM the remote host).
- Blank lines are ignored; use them to separate blocks for readability. A new header line is what starts the next block. Multiple blocks = multiple independent SSH connections, each supervised in its own background loop.
- **No comments.** A `#` line, trailing whitespace or CRLF line endings make the whole file FATAL at load time.
- One host can carry any number of forward and reverse tunnel lines mixed together.

### Example ruleset (forward + reverse, two hosts)

Host 1 exposes a local web app on the VPS (reverse) and reaches the VPS's internal Postgres from your machine (forward). Host 2 reaches an internal-only admin panel through a jump host (forward) and exposes your local dev API back to that jump host (reverse).

```
deploy@vps1.example.com:22=/home/user/.ssh/deploy_vps1
reverse localhost:3000:0.0.0.0:8080
forward localhost:15432:127.0.0.1:5432

opsuser@jump.example.com:22=/home/user/.ssh/deploy_jump
forward localhost:9090:10.0.5.20:9090
reverse localhost:4000:127.0.0.1:4000
```

With the above: `curl http://vps1.example.com:8080` hits your local `localhost:3000` (only if the VPS's sshd has `GatewayPorts clientspecified` or `yes`; otherwise it binds loopback only); `psql -h localhost -p 15432` reaches the VPS's internal Postgres; `curl http://localhost:9090` on your machine reaches `10.0.5.20:9090` through the jump host; and the jump host's `127.0.0.1:4000` reaches your local dev API on `4000`.

## Running it

No subcommands, no CLI flags. Everything is env vars, and one invocation runs the swarm in the foreground until stopped:

```shell
RULES_FILE=/path/to/rules.txt \
LOG_ENABLED=1 \
LOG_FILE=/path/to/log/file \
LOG_LEVEL=DEBUG \
ssh-tunnel-swarm
```

`Ctrl-C` in the terminal stops every tunnel and exits. `kill <pid>` (SIGTERM) on the main process alone kills the per-host subshells but leaves their `ssh` processes running; signal the whole process group instead (`kill -TERM -- -<pgid>`), or run it under systemd, whose default `KillMode=control-group` stops everything.

Install/build details, the full env var reference, and log-level semantics are in `references/setup.md`.

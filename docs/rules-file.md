---
title: "Rules file"
description: "The ssh-tunnel-swarm rules file: header and tunnel line syntax, how forward and reverse map to ssh -L and -R, validation, and examples."
nav_order: 3
---

# Rules file

The rules file lists every SSH connection and the tunnels each one carries. ssh-tunnel-swarm reads it once at startup from the path in [`RULES_FILE`](configuration.md#rules_file), `rules.txt` in the current directory by default. A sample lives in [`rules.txt.example`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/rules.txt.example).

## Structure

The file is a list of blocks. Each block is one header line followed by tunnel lines:

```text
user@hostname:port=/path/to/private/key
direction local-interface:local-port:remote-interface:remote-port
direction local-interface:local-port:remote-interface:remote-port
```

Blank lines are skipped, so use them to separate blocks. Every other line must be a header line or a tunnel line. A tunnel line belongs to the last header line above it. Each block becomes one `ssh` process that carries all of its tunnels.

There are no comments. A line starting with `#` is an invalid line and stops the script, and so do trailing spaces and Windows (CRLF) line endings.

## Header line

```text
user@hostname:port=/path/to/private/key
```

| Part | Allowed |
| --- | --- |
| `user` | Letters, digits, `.`, `_` and `-` |
| `hostname` | A hostname made of letters, digits, `.` and `-` that is not all digits, or an IPv4 address with every octet from 0 to 255. IPv6 addresses are not accepted |
| `port` | The SSH port on that host, a number from 0 to 65535 |
| `/path/to/private/key` | An absolute path made of letters, digits, `.`, `_`, `-` and `/`. The file must exist when the script starts. `~`, `$HOME`, spaces and relative paths are rejected |

The header line is the connection's identity. If the same header line appears twice, the second block replaces the tunnels of the first. To run two separate connections to one host, use two different key files or ports.

A header line with no tunnel lines under it is valid. It opens an SSH session that forwards nothing.

## Tunnel line

```text
forward local-interface:local-port:remote-interface:remote-port
reverse local-interface:local-port:remote-interface:remote-port
```

The direction is the word `forward` or `reverse`, then one space, then four colon-separated fields with no spaces. The field order is the same for both directions: the local side first, then the remote side. What changes is which side listens.

| Direction | `ssh` flag it becomes | Who listens | Where connections go |
| --- | --- | --- | --- |
| `forward` | `-L local-interface:local-port:remote-interface:remote-port` | Your machine, on `local-interface:local-port` | `remote-interface:remote-port` as seen from the SSH server |
| `reverse` | `-R remote-interface:remote-port:local-interface:local-port` | The SSH server, on `remote-interface:remote-port` | `local-interface:local-port` as seen from your machine |

Validation checks that `local-interface` is a valid hostname or IPv4 address (same rules as the header) and that both ports are numbers from 0 to 65535. `remote-interface` is only checked for being non-empty and free of spaces, so a typo there shows up as a failed connection rather than a startup error.

### What the SSH server allows

The `ssh` options decide what the client asks for; the server's `sshd_config` decides what it gets:

- A `reverse` tunnel bound to anything other than loopback, such as `0.0.0.0`, needs `GatewayPorts clientspecified` (or `yes`) on the server. With the default `GatewayPorts no`, the server binds loopback only.
- A `reverse` tunnel on a port below 1024 needs a root login on the server.
- `AllowTcpForwarding` must not be `no`, or the server refuses every tunnel.

Because every connection runs with `ExitOnForwardFailure=yes`, a refused tunnel makes that whole connection fail and retry. See [Running the swarm](running.md#the-retry-loop).

## Examples

Make a web app on port 3000 of your machine reachable on port 8080 of a VPS:

```text
user@myvps.com:22=/home/user/.ssh/id_ed25519
reverse localhost:3000:0.0.0.0:8080
```

Opening `http://myvps.com:8080/` now reaches your local app, as long as the VPS allows it (see above).

The same app on two VPSs at once. Each block is its own connection:

```text
user@myvps.com:22=/home/user/.ssh/id_ed25519
reverse localhost:3000:0.0.0.0:8080

user@myothervps.com:22=/home/user/.ssh/id_ed25519
reverse localhost:3000:0.0.0.0:8080
```

Reach an LDAP server that only the office gateway can see, from port 6366 on your machine:

```text
user@gateway.example.com:22=/home/user/.ssh/id_ed25519
forward localhost:6366:10.137.82.201:636
```

Connections to `localhost:6366` on your machine now arrive at `10.137.82.201:636`, sent from the gateway.

Mix both directions on one host. This exposes a local API on the server's loopback and pulls the server's database to your machine:

```text
deploy@vps1.example.com:2222=/home/user/.ssh/deploy_vps1
reverse localhost:4000:127.0.0.1:4000
forward localhost:15432:127.0.0.1:5432
```

## Validation

The script validates the whole file before it opens any connection. The first bad line logs a `FATAL` message and the script exits with status 1, so a typo never leaves you with half the tunnels up. [Troubleshooting](troubleshooting.md#startup-errors) lists every message.

Line numbers in those messages count only non-blank lines, so in a file with blank lines between blocks the reported number is lower than the line number your editor shows.

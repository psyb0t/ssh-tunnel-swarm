---
title: "Security"
description: "What ssh-tunnel-swarm connects to and exposes: strict host key checking, key-only authentication, forward and reverse exposure, and log contents."
nav_order: 6
---

# Security

ssh-tunnel-swarm opens real SSH connections with your keys to every host in the rules file, and every tunnel line opens a listening port somewhere. Read this before you point it at a machine you care about.

## Host keys

Every connection runs with `StrictHostKeyChecking=yes`. `ssh` refuses a server whose host key is missing from `known_hosts` or has changed, and the script logs that failure and retries every 5 seconds. It never adds or replaces a host key for you.

Add each server's key before the first run, from a network you trust:

```shell
ssh -i /path/to/private/key -p 22 user@myvps.com true
```

That asks you to confirm the fingerprint and stores it. `ssh-keyscan` also works, but it accepts whatever key it receives, so compare the fingerprint with one you got another way.

When a server's key really changed, for example after a reinstall, remove the old entry and add the new one:

```shell
ssh-keygen -R myvps.com
```

For a non-standard port the entry is `[myvps.com]:2222`. Do not turn host key checking off to make an error go away. That error is what stops a man-in-the-middle from receiving your tunnels.

## Keys and authentication

The script supports key authentication only, with one key file per header line. It never asks for or passes a password. Keep each key readable only by the user that runs the script (`chmod 600`), and never commit a key or a real rules file to a repository. The rules file holds no secret itself, but it maps your hosts, users and key paths.

For a key with a passphrase, load it into `ssh-agent` first. The script has no way to answer a passphrase prompt, it would have to be answered again on every reconnect, and under a service manager there is no terminal for `ssh` to ask on.

## What tunnels expose

- A `reverse` line opens a port on the server that leads into your machine. Anyone who can reach that port on the server reaches your local service, with no extra authentication. Bind it to `127.0.0.1` on the server unless you mean to publish it, and remember that other users of that server can reach loopback too.
- A `forward` line opens a port on your machine that leads into the server's network. Binding it to `0.0.0.0` instead of `localhost` lets every machine that can reach yours use it.
- Each connection reconnects forever until you stop the script. A tunnel you forgot about comes back after every network drop.

## What the logs contain

At `DEBUG`, the log holds the full `ssh` command (user, host, port, key path and every tunnel) and the raw `ssh` output. At `INFO`, it holds every user, host and tunnel line. No level logs key contents or passwords, but treat the log file like the rules file: keep it out of shared directories.

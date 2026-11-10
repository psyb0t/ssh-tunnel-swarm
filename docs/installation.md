---
title: "Installation"
description: "Install ssh-tunnel-swarm with the downloader script or from source, put it on your PATH, upgrade it and remove it again."
nav_order: 2
---

# Installation

ssh-tunnel-swarm ships as one executable Bash script named `ssh-tunnel-swarm`, attached to every [GitHub release](https://github.com/psyb0t/ssh-tunnel-swarm/releases). It runs on Linux, macOS or any other Unix-like system with the tools below.

## Requirements

To run it:

- `bash` 4 or newer. The script uses associative arrays, which the Bash 3.2 that macOS ships does not have.
- `ssh`, the OpenSSH client.
- `mktemp`, `date` and `pgrep`, which come with any normal system.

To use the downloader, also:

- `jq`, to read the GitHub releases API.
- `wget`, to fetch the downloader and the release asset.

## Download the latest release

```shell
wget -qO- https://raw.githubusercontent.com/psyb0t/ssh-tunnel-swarm/master/tools/downloader.sh | bash
```

[`tools/downloader.sh`](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/tools/downloader.sh) checks that `jq` and `wget` exist and exits with a message if one is missing. It then asks the GitHub API for the repository's releases, takes the first one in the list (the newest), downloads its `ssh-tunnel-swarm` asset into the current directory and makes it executable. You can run it right there with `./ssh-tunnel-swarm`.

## Put it on your PATH

For all users:

```shell
sudo mv ssh-tunnel-swarm /usr/local/bin/
```

For the current user only:

```shell
mkdir -p ~/bin
mv ssh-tunnel-swarm ~/bin/
```

`~/bin` has to be on your `PATH` for that to work. Check:

```shell
echo "$PATH" | grep -q "$HOME/bin" && echo "on PATH" || echo "not on PATH"
```

If it is not, add it to your shell profile and reload it. For Bash:

```shell
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

For zsh:

```shell
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Build from source

```shell
git clone https://github.com/psyb0t/ssh-tunnel-swarm.git
cd ssh-tunnel-swarm
make build
```

`make build` writes `build/ssh-tunnel-swarm`, the same single file a release carries. [Development](development.md#the-build-step) explains how it is put together. Copy it onto your `PATH` as above.

You can also run the sources directly with `make run` or `bash main.sh`, but only from the repository root: the source files load each other with relative `source` lines. The built script has no such limit.

## Upgrade

Run the downloader again and move the new file over the old one. There is no state to migrate: the only inputs are your rules file and the environment variables. The [changelog](https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/CHANGELOG.md) lists what changed in each release.

## Remove

Stop any running instance (see [Running the swarm](running.md#stopping-it)), then delete the script:

```shell
sudo rm /usr/local/bin/ssh-tunnel-swarm
```

or `rm ~/bin/ssh-tunnel-swarm` for a per-user install. Apart from a temporary file for each `ssh` attempt, which it deletes afterwards, the only file it writes is the log you point `LOG_FILE` at.

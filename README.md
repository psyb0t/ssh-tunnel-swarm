# ssh-tunnel-swarm

![ssh-tunnel-swarm](./assets/ssh-tunnel-swarm.png)

ssh-tunnel-swarm is a powerful shell script tool for managing multiple SSH tunnels concurrently. It simplifies the process of creating and managing both forward and reverse SSH tunnels by applying a predefined set of rules for each tunnel.

The script supports the configuration of multiple SSH connections and can establish tunnels based on defined rules.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Installing for all users](#installing-for-all-users)
  - [Installing for the current user](#installing-for-the-current-user)
- [Configuration](#configuration)
  - [Environment Variables](#environment-variables)
    - [Supported Log Levels](#supported-log-levels)
  - [Tunnel Rules](#tunnel-rules)
    - [Example](#example)
- [Usage](#usage)
- [Important Notes](#important-notes)
- [License](#license)
- [TODO](#todo)

## Features

- Allows multiple SSH connections with each connection potentially handling multiple tunnels.
- Logging functionality for better visibility and debugging.
- Easily configurable rule sets for the creation of SSH tunnels.
- Supports both forward and reverse SSH tunnels.
- Tunnels are continuously maintained and re-established in case of disconnection.

# Prerequisites

**This script is designed to be run in a Unix-like environment.**

## General Software Requirements

- **bash**: The script is written in `bash`, so you need to have `bash` installed on your system.
- **ssh**: The script uses `ssh` to establish connections and create tunnels. Make sure you have `ssh` installed and properly configured on your machine.

## Downloader Tool Prerequisites

- **jq**: This lightweight and flexible command-line JSON processor is used by the downloader tool to parse data fetched from GitHub. Specifically, it helps identify the most recent version of ssh-tunnel-swarm.
- **wget**: wget is a versatile utility designed for non-interactive downloading of files from the web. It serves a dual purpose in this case - initially downloading the downloader tool, and subsequently employed by the downloader tool itself to retrieve ssh-tunnel-swarm.

## Installation

Execute the following command to download ssh-tunnel-swarm:

```shell
wget -qO- https://raw.githubusercontent.com/psyb0t/ssh-tunnel-swarm/master/tools/downloader.sh | bash
```

After the download is complete, you can use ssh-tunnel-swarm from the current location by executing `./ssh-tunnel-swarm` but a true installation allows you to use it from any directory.

### Installing for all users

```shell
sudo mv ssh-tunnel-swarm /usr/local/bin/
```

### Installing for the current user

```shell
mkdir -p ~/bin
mv ssh-tunnel-swarm ~/bin/
```

In order to execute ssh-tunnel-swarm from any directory, the `$HOME/bin` directory needs to be added to your system's `$PATH`. This is because the `$PATH` variable tells the system which directories to search for executable files when you type a command in the terminal. By adding `$HOME/bin` to the `$PATH`, you can run the ssh-tunnel-swarm command from any directory without needing to specify the full path.

To check if `$HOME/bin` is already in the `$PATH`, you can execute the following command in your terminal:

```shell
echo $PATH | grep -q "$HOME/bin" && echo "The $HOME/bin directory is already in your PATH" || echo "The $HOME/bin directory is not in your PATH yet"
```

This command will output a message indicating whether `$HOME/bin` is already in your path.

If it is not, add it to your shell profile file:

For `bash`:

```shell
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

For `zsh`:

```shell
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Configuration

### Environment Variables

- **RULES_FILE**: This can be used to specify the path to the file containing the tunnel rules. If this variable is not set, the default file path is set to `rules.txt`.

- **LOG_ENABLED**: This acts as a master switch for the logger. If it's set to `1`, logging is enabled. A value of `0` disables logging. Default value if not set is `1`.

- **LOG_FILE**: This determines the output destination of the log messages. If set, log messages will be written to the specified file. If not set, logs will be printed to stdout.

- **LOG_LEVEL**: This determines the severity level of the messages to be logged. Messages with a severity level less than this will not be logged. For example, if `LOG_LEVEL` is set to `INFO`, then `DEBUG` messages won't be logged. Default value if not set is `INFO`.

#### Supported Log Levels

The logger recognizes four levels of logging:

- **DEBUG**: These are verbose-level messages and are usually useful during development or debugging sessions. They provide deep insights about what's going on.

- **INFO**: These messages provide general feedback about the application processes and state. They are used to confirm that things are working as expected.

- **ERROR**: These are messages that indicate a problem that prevented a function or process from completing successfully.

- **FATAL**: These messages indicate a severe problem that has caused the application to stop. They require immediate attention.

### Tunnel Rules

ssh-tunnel-swarm reads the tunnel rules for each host from a file specified by the `RULES_FILE` environment variable. Each entry within the file should include the username, hostname, port, SSH private key and the tunnels to establish. For instance:

```
aparker@host789:34567=/home/aparker/.ssh/id_rsa
reverse host789.example.com:5432:172.16.0.5:5432

sjones@host012:67890=/path/to/ssh/private/key
reverse host012.example.com:3000:10.20.30.40:3000
forward 172.20.0.2:6060:host012.example.com:4444
reverse 10.0.0.5:5678:host789.example.com:1234
forward host789.example.com:9876:172.16.0.5:4321
```

Each block represents an SSH connection where:

- The first line is the username, host, port to connect to and the private SSH key to use. The syntax is:
  `user@hostname:port=/path/to/private/ssh/key`

- The following lines are the SSH tunnels to establish for that connection, with one tunnel per line. The syntax is:
  `direction local-interface:local-port:remote-interface:remote-port`

#### Example

**Set up a reverse tunnel from your local machine to a VPS having SSH listening on port 22**

```
user@myvps.com:22=/path/to/ssh/private/key
reverse localhost:8080:0.0.0.0:80
```

Now when you access http://myvps.com/ you'll access your local service.

**Set up a reverse tunnel from your local machine to 2 VPSs having SSH listening on port 22**

```
user@myvps.com:22=/path/to/ssh/private/key
reverse localhost:8080:0.0.0.0:80

user@myothervps.com:22=/path/to/ssh/private/key
reverse localhost:8080:0.0.0.0:80
```

Now when you access both http://myvps.com/ and http://myothervps.com/ you'll access your local service.

**Set up a forward tunnel from a remote machine to your computer**

```
user@enterprise.com:22=/path/to/ssh/private/key
forward localhost:6366:10.137.82.201:636
```

Now guess what happens when you try to connect to localhost:6366.

## Usage

```shell
RULES_FILE=/path/to/rules.txt \
LOG_ENABLED=1 \
LOG_FILE=/path/to/log/file \
LOG_LEVEL=DEBUG \
ssh-tunnel-swarm
```

## Important Notes

- ssh-tunnel-swarm does not handle SSH password authentication.

- Always use this script responsibly make sure you have the required permissions on your local and remote systems to establish SSH connections and tunnels.

- All SSH connections are established with `-o StrictHostKeyChecking=yes`.

- With `StrictHostKeyChecking=yes`, the client will refuse to connect to servers whose host key is not known or has changed since it was last recorded. This may lead to initial connection failure if the host key is not already in the known_hosts file.

  It is your responsibility to ensure that the `known_hosts` file is up to date with the public keys of the remote hosts you wish to connect to. You can manually add a host's public key to your `known_hosts` file, or you can retrieve it using SSH on a trusted network before running ssh-tunnel-swarm.

  Note that in some cases, you might have to manually remove outdated or changed host keys from your `known_hosts` file. This situation can arise if you're connecting to a server that has had its SSH keys regenerated.

## License

This software is licensed under the terms of the **Do What The Fuck You Want To Public License (WTFPL)**. This license allows you to use the software for any purposes, without any conditions or restrictions unless such restrictions are required by law. You can learn more about the license at http://www.wtfpl.net/about/.

By using this software, you agree to abide by the terms of the **WTFPL**. If you do not agree, please do not use, modify, or distribute the software.

## TODO

- refactor
- better error handling
- better testing utils

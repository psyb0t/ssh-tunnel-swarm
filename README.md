# SSH Tunnel Swarm

![ssh-tunnel-swarm](https://raw.githubusercontent.com/psyb0t/ssh-tunnel-swarm/master/assets/ssh-tunnel-swarm.png)

SSH Tunnel Swarm is a powerful shell script tool for managing multiple SSH tunnels concurrently. It simplifies the process of creating and managing both forward and reverse SSH tunnels by applying a predefined set of rules for each tunnel.

The script supports the configuration of multiple SSH connections and can establish tunnels based on defined rules.

## Table of Contents

- [SSH Tunnel Swarm](#ssh-tunnel-swarm)
  - [Features](#features)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
    - [Installing for the current user](#installing-for-the-current-user)
    - [Installing for all users](#installing-for-all-users)
  - [Configuration](#configuration)
    - [Environment Variables](#environment-variables)
    - [Tunnel Rules](#tunnel-rules)
  - [Usage](#usage)
  - [Logging](#logging)
    - [Supported Log Levels](#supported-log-levels)
  - [Important Notes](#important-notes)
  - [Contributing](#contributing)
  - [License](#license)
  - [TODO](#todo)
  - [Glossary](#glossary)

## Features

- Easy setup and usage with shell script.
- Allows multiple SSH connections with each connection potentially handling multiple tunnels.
- Logging functionality for better visibility and debugging.
- Easily configurable rule sets for the creation of SSH tunnels.
- Supports both forward and reverse SSH tunnels.
- Tunnels are continuously maintained and re-established in case of disconnection.

## Prerequisites

This script is designed to be run in a Unix-like environment.

- **Bash Shell**: The script is written in Bash, so you need to have Bash installed on your system.

- **SSH**: The script uses SSH to establish connections and create tunnels. Make sure you have SSH installed and properly configured on your machine.

## Installation

To install `ssh-tunnel-swarm`, the first step is to check if `wget` is installed on your system by running `wget --version`.

If it is installed, the output should be similar to this:

```
GNU Wget 1.21.2 built on linux-gnu.

-cares +digest -gpgme +https +ipv6 +iri +large-file -metalink +nls
+ntlm +opie +psl +ssl/openssl

Wgetrc:
    /etc/wgetrc (system)
Locale:
    /usr/share/locale
Compile:
    gcc -DHAVE_CONFIG_H -DSYSTEM_WGETRC="/etc/wgetrc"
    -DLOCALEDIR="/usr/share/locale" -I. -I../../src -I../lib
    -I../../lib -Wdate-time -D_FORTIFY_SOURCE=2 -DHAVE_LIBSSL -DNDEBUG
    -g -O2 -ffile-prefix-map=/build/wget-8g5eYO/wget-1.21.2=.
    -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects
    -fstack-protector-strong -Wformat -Werror=format-security
    -DNO_SSLv2 -D_FILE_OFFSET_BITS=64 -g -Wall
Link:
    gcc -DHAVE_LIBSSL -DNDEBUG -g -O2
    -ffile-prefix-map=/build/wget-8g5eYO/wget-1.21.2=. -flto=auto
    -ffat-lto-objects -flto=auto -ffat-lto-objects
    -fstack-protector-strong -Wformat -Werror=format-security
    -DNO_SSLv2 -D_FILE_OFFSET_BITS=64 -g -Wall -Wl,-Bsymbolic-functions
    -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now
    -lpcre2-8 -luuid -lidn2 -lssl -lcrypto -lz -lpsl ftp-opie.o
    openssl.o http-ntlm.o ../lib/libgnu.a

Copyright (C) 2015 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later
<http://www.gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Originally written by Hrvoje Niksic <hniksic@xemacs.org>.
Please send bug reports and questions to <bug-wget@gnu.org>.
```

If `wget` is not installed, you can easily install it using the package manager for your operating system. Here are the installation commands for some known operating systems:

- Debian/Ubuntu-based systems: `sudo apt-get install wget`
- Arch Linux-based systems: `sudo pacman -S wget`
- Fedora-based systems: `sudo dnf install wget`
- CentOS/RHEL-based systems: `sudo yum install wget`
- openSUSE-based systems: `sudo zypper install wget`
- Alpine Linux-based systems: `sudo apk add wget`
- FreeBSD-based systems: `sudo pkg install wget`
- NetBSD-based systems: `sudo pkgin install wget`
- OpenBSD-based systems: `sudo pkg_add wget`
- macOS with Homebrew installed: `brew install wget`
- Tiny Core Linux: `tce-load -wi wget`

If your operating system is not listed above, you can visit the `wget` website at https://www.gnu.org/software/wget/ and download it from there.

Once `wget` is installed, execute the following command to download `ssh-tunnel-swarm`:

```shell
wget -qO- https://raw.githubusercontent.com/psyb0t/ssh-tunnel-swarm/master/tools/downloader.sh | bash
```

After the download is complete, you can use `ssh-tunnel-swarm` from the current location by executing `./ssh-tunnel-swarm` but a true installation allows you to use it from any directory.

### Installing for the current user

```shell
mkdir ~/bin
mv ssh-tunnel-swarm ~/bin/
```

In order to execute `ssh-tunnel-swarm` from any directory, the `$HOME/bin` directory needs to be added to your system's `$PATH`. This is because the `$PATH` variable tells the system which directories to search for executable files when you type a command in the terminal. By adding `$HOME/bin` to the `$PATH`, you can run the `ssh-tunnel-swarm` command from any directory without needing to specify the full path.

To check if `$HOME/bin` is already in the `$PATH`, you can execute the following command in your terminal:

```shell
echo $PATH | grep -q "$HOME/bin" && echo "The $HOME/bin directory is already in your PATH" || echo "The $HOME/bin directory is not in your PATH yet"
```

This command will output a message indicating whether `$HOME/bin` is already in your path.

If it is not, execute the following command for either `bash` or `zsh`:

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

## Installing for all users

```shell
sudo mv ssh-tunnel-swarm /usr/bin/
```

## Configuration

### Environment Variables

- **RULES_FILE**: This can be used to specify the path to the file containing the tunnel rules. If this variable is not set, the default file path is set to `rules.txt`.

- **LOG_ENABLED**: This acts as a master switch for the logger. If it's set to `1`, logging is enabled. A value of `0` disables logging. Default value if not set is `1`.

- **LOG_FILE**: This determines the output destination of the log messages. If set, log messages will be written to the specified file. If not set, logs will be printed to stdout.

- **LOG_LEVEL**: This determines the severity level of the messages to be logged. Messages with a severity level less than this will not be logged. For example, if `LOG_LEVEL` is set to `INFO`, then `DEBUG` messages won't be logged. Default value if not set is `DEBUG`. You can find all of the [supported log levels here](#supported-log-levels).

### Tunnel Rules

SSH Tunnel Swarm reads the tunnel rules for each host from a file specified by the `RULES_FILE` environment variable. Each entry within the file should include the username, hostname, port, and the tunnels to establish. For instance:

```
aparker@host789:34567
reverse host789.example.com:5432:172.16.0.5:5432

sjones@host012:67890
reverse host012.example.com:3000:10.20.30.40:3000
forward 172.20.0.2:6060:host012.example.com:4444
reverse 10.0.0.5:5678:host789.example.com:1234
forward host789.example.com:9876:172.16.0.5:4321
```

Each block represents an SSH connection where:

- The first line is the username, host, and port to connect to.
- The following lines are the SSH tunnels to establish for that connection, with one tunnel per line. The syntax is:
  `direction local-interface:local-port:remote-interface:remote-port`

#### Example

**Set up a reverse tunnel from your local machine to a VPS having SSH listening on port 22**

```
user@myvps.com:22
reverse localhost:8080:0.0.0.0:80
```

Now when you access http://myvps.com/ you'll access your local service.

**Set up a reverse tunnel from your local machine to 2 VPSs having SSH listening on port 22**

```
user@myvps.com:22
reverse localhost:8080:0.0.0.0:80

user@myothervps.com:22
reverse localhost:8080:0.0.0.0:80
```

Now when you access both http://myvps.com/ and http://myothervps.com/ you'll access your local service.

**Set up a forward tunnel from a remote machine to your computer**

```
user@enterprise.com:22
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

## Logging

SSH Tunnel Swarm includes a logging functionality that provides visibility into the operations and state of your SSH connections.

It is designed to enable configurable log levels and output destinations and provides different levels of logging based on the severity of the log message. This is particularly useful in complex scripts or systems where detailed logging is beneficial for development, debugging, or ongoing system maintenance.

### Supported Log Levels

The logger recognizes four levels of logging:

- **DEBUG**: These are verbose-level messages and are usually useful during development or debugging sessions. They provide deep insights about what's going on.

- **INFO**: These messages provide general feedback about the application processes and state. They are used to confirm that things are working as expected.

- **ERROR**: These are messages that indicate a problem that prevented a function or process from completing successfully.

- **FATAL**: These messages indicate a severe problem that has caused the application to stop. They require immediate attention.

## Important Notes

- SSH Tunnel Swarm does not handle SSH authentication(yet). Please ensure that the necessary SSH key is available(currently only the default one is used).

- Make sure you have the required permissions on your local and remote systems to establish SSH connections and tunnels.

- All SSH connections are established with -o StrictHostKeyChecking=no for convenience. However, this option may expose you to potential security risks.

- Always use this script responsibly and ensure you have the permissions to establish tunnels with your target hosts.

## Contributing

I welcome your contributions. Please submit a pull request with your improvements. Make sure to adhere to the existing coding style and ensure all tests pass before submitting your PR.

### Clone the repository:

```shell
git clone https://github.com/psyb0t/ssh-tunnel-swarm.git
cd ssh-tunnel-swarm
make test
```

If all tests run you're ready do go

To execute the script in development you can either just run `bash main.sh` or execute `make build` and run the compiled script `./build/ssh-tunnel-swarm`

## License

This project is licensed under the terms of the **Do What The Fuck You Want To Public License (WTFPL)**. This license allows you to use the software for any purposes, without any conditions or restrictions unless such restrictions are required by law. You can learn more about the license at http://www.wtfpl.net/about/.

By using this software, you agree to abide by the terms of the **WTFPL**. If you do not agree, please do not use, modify, or distribute the software.

## TODO

- add support for specifying keys for each host
- add more tests

## Glossary

- **SSH**: Secure Shell is a protocol used to securely connect to a remote server/system.
- **Tunnel**: In the context of SSH, a tunnel is a route through which the entirety of your data is going to pass.
- **Forward Tunnel (Local Port Forwarding)**: Forwarding calls for a specific IP and port from the client system to an IP and port on the server system.
- **Reverse Tunnel (Remote Port Forwarding)**: Allows the server to receive a connection as a client from the client system.
- **SSH Key**: A way of logging into an SSH/SFTP account using a cryptographic pair of keys, hence providing an alternative way to password-based logins.
- **Bash**: A shell, or command language interpreter, for the GNU operating system.
- **Shell Script**: A computer program designed to be run by the Unix shell, a command-line interpreter.
- **wget**: A free utility for non-interactive download of files from the web. It supports HTTP, HTTPS, and FTP protocols and can retrieve files through HTTP proxies.
- **PATH**: An environment variable on Unix-like operating systems, DOS, OS/2, and Microsoft Windows, specifying a set of directories where executable programs are located.
- **$HOME**: An environment variable that displays the path of the home directory of the current user.
- **WTFPL**: Do What The Fuck You Want To Public License, a very permissive license for software and other scientific or artistic works that offers a huge degree of freedom.
- **GNU**: Stands for GNU's Not Unix, an extensive collection of free software, which includes the GNU Project, the GNU Operating System, and the GNU General Public License.

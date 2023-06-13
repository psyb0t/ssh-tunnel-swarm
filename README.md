# SSH Tunnel Swarm

SSH Tunnel Swarm is a powerful shell script tool for managing multiple SSH tunnels concurrently. It simplifies the process of creating and managing both forward and reverse SSH tunnels by applying a predefined set of rules for each tunnel.

The script supports the configuration of multiple SSH connections and can establish tunnels based on defined rules. The process is controlled through different shell scripts for logging, rule definition, and data splitting.

## Features

- Easy setup and usage with shell script.
- Allows multiple SSH connections with each connection potentially handling multiple tunnels.
- Logging functionality for better visibility and debugging.
- Easily configurable rule sets for the creation of SSH tunnels.
- Supports both forward and reverse SSH tunnels.
- Tunnels are continuously maintained and re-established in case of disconnection.

## Installation

SSH Tunnel Swarm is a shell script and thus does not need a traditional installation process. However, you must ensure you have a working SSH client installed on your system. This script is designed to be run in a Unix-like environment.

- coming up soon

## Configuration

SSH Tunnel Swarm reads its configuration from a file named `rules.txt` which contains the tunnel rules for each host. Each entry should include the username, hostname, port, and the tunnels to establish. For instance:

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

- coming up soon

## Logging

SSH Tunnel Swarm includes a logging functionality that provides visibility into the operations and state of your SSH connections.

It is designed to enable configurable log levels and output destinations and provides different levels of logging based on the severity of the log message. This is particularly useful in complex scripts or systems where detailed logging is beneficial for development, debugging, or ongoing system maintenance.

## Environment Variables

- **LOG_ENABLED**: This acts as a master switch for the logger. If it's set to `1`, logging is enabled. A value of `0` disables logging. Default value if not set is `1`.

- **LOG_FILE**: This determines the output destination of the log messages. If set, log messages will be written to the specified file. If not set, logs will be printed to stdout.

- **LOG_LEVEL**: This determines the severity level of the messages to be logged. Messages with a severity level less than this will not be logged. For example, if `LOG_LEVEL` is set to `INFO`, then `DEBUG` messages won't be logged. Default value if not set is `DEBUG`.

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

## License

This project is licensed under the terms of the **Do What The Fuck You Want To Public License (WTFPL)**. This license allows you to use the software for any purposes, without any conditions or restrictions unless such restrictions are required by law. You can learn more about the license at http://www.wtfpl.net/about/.

By using this software, you agree to abide by the terms of the **WTFPL**. If you do not agree, please do not use, modify, or distribute the software.

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

## TODO

- add support for specifying keys for each host
- add more tests

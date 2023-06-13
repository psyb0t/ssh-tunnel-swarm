#!/bin/bash
# Function to split a user, host, and port combination and returns the user/host and port separately.
# Accepts one parameter:
# $1 - user_host_port: A string containing the username, hostname, and port number to connect to, separated by colons. Example: "john@example.com:22"
# Returns:
#   0 - on success
#   1 - if user_host or port is empty
split_user_host_port() {
    local user_host_port="$1"
    local IFS=":"
    read -r user_host port <<<"${user_host_port}"
    if [[ -z "$user_host" || -z "$port" ]]; then
        return 1
    fi
    echo "$user_host" "$port"
    return 0
}

# Function to split a user and host combination and returns the user and host separately.
# Accepts one parameter:
# $1 - user_host: A string containing the username and hostname to connect to, separated by an '@' symbol. Example: "john@example.com"
# Returns:
#   0 - on success
#   1 - if user or host is empty
split_user_host() {
    local user_host="$1"
    local IFS="@"
    read -r user host <<<"${user_host}"
    if [[ -z "$user" || -z "$host" ]]; then
        return 1
    fi
    echo "$user" "$host"
    return 0
}

# Function to split an interface and port combination and returns the local interface, local port, remote interface, and remote port separately.
# Accepts one parameter:
# $1 - interface_ports: A string containing the local interface, local port, remote interface, and remote port to configure the tunnel, separated by colons. Example: "1.1.1.1:8080:localhost:80"
# Returns:
#   0 - on success
#   1 - if interface, local port, remote interface, or remote port is empty
split_interface_ports() {
    local interface_ports="$1"
    local IFS=":"
    read -r local_interface local_port remote_interface remote_port <<<"${interface_ports}"
    if [[ -z "$local_interface" || -z "$local_port" || -z "$remote_interface" || -z "$remote_port" ]]; then
        return 1
    fi
    echo "$local_interface" "$local_port" "$remote_interface" "$remote_port"
    return 0
}

#!/bin/bash
# shellcheck disable=SC1091
# Load logger functions
source logger.sh

# Function to check if a given hostname or IP address is valid or not.
# Accepts one parameter:
# $1 - input: the hostname or IP address to validate as a string.
# Returns:
# 0 - if the input is a valid IP address or hostname.
# 1 - if the input is an invalid IP address or hostname.
is_valid_hostname_or_ip() {
    logger "DEBUG" "Starting is_valid_hostname_or_ip function with input: $1"

    local input="$1"

    # Check if input is empty
    if [[ -z "$input" ]]; then
        logger "DEBUG" "Input is empty"
        return 1
    fi

    # Validate the input as a hostname or IP address
    if [[ "$input" =~ ^[0-9]+(\.[0-9]+){3}$ ]]; then
        # If the input is an IP address, validate the format of each octet
        local IFS='.'
        read -ra octets <<<"$input"
        for octet in "${octets[@]}"; do
            if [[ "$octet" -lt 0 || "$octet" -gt 255 ]]; then
                logger "DEBUG" "Invalid IP address format: $input"
                return 1
            fi
        done
    else
        # If the input is a hostname, validate that it contains only valid characters
        if ! [[ "$input" =~ ^[a-zA-Z0-9.-]+$ ]]; then
            logger "DEBUG" "Invalid hostname format: $input"
            return 1
        fi

        # Check if input consists only of numbers
        if [[ "$input" =~ ^[0-9]+$ ]]; then
            logger "DEBUG" "Input consists only of numbers: $input"
            return 1
        fi

        # Check if input contains special characters
        if [[ "$input" =~ [\!\@\#\$\%\^\&\*\(\)\,\?\/\<\>]+ ]]; then
            logger "DEBUG" "Input contains special characters: $input"
            return 1
        fi
    fi

    logger "DEBUG" "is_valid_hostname_or_ip function completed successfully"
    return 0
}

# Function to check if a given username is valid or not.
# Accepts one parameter:
# $1 - username: The username to validate as a string.
# Returns:
# 0 - if the username is valid.
# 1 - if the username is invalid.
is_valid_username() {
    local username="$1"

    logger "DEBUG" "Starting is_valid_username function with username: $username"

    # Check if the username contains only allowed characters
    if [[ ! "$username" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        logger "DEBUG" "Invalid username: $username"
        return 1
    fi

    logger "DEBUG" "Valid username: $username"
    return 0
}

# Function to check if a given hostname and port number are valid or not.
# Accepts one parameter:
# $1 - host_port: A string containing the hostname and port number to validate in the format "hostname:port". Example: "example.com:22"
# Returns:
# 0 - if the hostname and port are valid.
# 1 - if the hostname and port are invalid.
is_valid_host_port() {
    logger "DEBUG" "Starting is_valid_host_port function with hostname and port: $1"

    local host_port="$1"
    local hostname
    local port

    # Extract the hostname and port number from the input string
    hostname="${host_port%%:*}"
    port="${host_port##*:}"

    # Validate the hostname
    if ! is_valid_hostname_or_ip "$hostname"; then
        logger "DEBUG" "Invalid hostname: $hostname"
        return 1
    fi

    # Validate the port number
    if ! is_valid_port "$port"; then
        logger "DEBUG" "Invalid port number: $port"
        return 1
    fi

    logger "DEBUG" "is_valid_host_port function completed successfully"
    return 0
}

# Function to check if a given forward or reverse tunnel rule is valid or not.
# Accepts one parameter:
# $1 - forward_reverse_line: A string containing the port forwarding or reverse tunnel rule to validate in the format "direction IP1:port1 IP2:port2". Example: "forward 8080:localhost:80"
# Returns:
# 0 - if the forward/reverse rule is valid.
# 1 - if the forward/reverse rule is invalid.
is_valid_forward_reverse_line() {
    logger "DEBUG" "Starting is_valid_forward_reverse_line function with line: $1"

    local line="$1"
    local keyword
    local ip1
    local port1
    local ip2
    local port2

    # Extract the keyword (forward/reverse), IP addresses and port numbers from the input string
    keyword="${line%% *}"
    ip1="${line#* }"
    ip1="${ip1%%:*}"
    port1="${line#*:}"
    port1="${port1%%:*}"
    ip2="${line##* }"
    ip2="${ip2%%:*}"
    port2="${line##*:}"

    # Validate the keyword
    if ! [[ "$keyword" =~ ^(forward|reverse)$ ]]; then
        logger "DEBUG" "Invalid keyword: $keyword"
        return 1
    fi

    # Validate the IP addresses
    if ! is_valid_hostname_or_ip "$ip1"; then
        logger "DEBUG" "Invalid IP address: $ip1"
        return 1
    fi
    if ! is_valid_hostname_or_ip "$ip2"; then
        logger "DEBUG" "Invalid IP address: $ip2"
        return 1
    fi

    # Validate the port numbers
    if ! is_valid_port "$port1"; then
        logger "DEBUG" "Invalid port number: $port1"
        return 1
    fi
    if ! is_valid_port "$port2"; then
        logger "DEBUG" "Invalid port number: $port2"
        return 1
    fi

    logger "DEBUG" "is_valid_forward_reverse_line function completed successfully"
    return 0
}

# Function to check if a given port number is valid or not.
# Accepts one parameter:
# $1 - port: the port number to validate as a string.
# Returns:
# 0 - if the port number is valid.
# 1 - if the port number is invalid.
is_valid_port() {
    logger "DEBUG" "Starting is_valid_port function with port number: $1"

    local port="$1"

    # Validate the port number format
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        logger "DEBUG" "Invalid port number format: $port"
        return 1
    fi

    # Validate the port number range
    if ((port < 0 || port > 65535)); then
        logger "DEBUG" "Invalid port range: $port"
        return 1
    fi

    logger "DEBUG" "is_valid_port function completed successfully"
    return 0
}

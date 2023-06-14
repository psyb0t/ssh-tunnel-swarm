#!/bin/bash
# shellcheck disable=SC1091
# Load logger functions
source logger.sh
# Load validator functions
source validators.sh

# Set default rules file to rules.txt if it's not already set
: "${RULES_FILE:=rules.txt}"

declare -A RULES

# This function checks if the rules file exists, is readable, and has non-zero size
# It logs ERROR errors for any failed checks and returns a non-zero status
# Accepts one parameter:
# $1 - rules_file: A string containing the path to the rules file
# Return values:
#   0 - on success
#   1 - if any of the checks fail (file not found, no read permissions, or empty file).
check_rules_file() {
    local rules_file="$1"
    logger "DEBUG" "Starting check_rules_file function"

    if [ ! -f "$rules_file" ]; then
        logger "ERROR" "Rules file \"$rules_file\" not found"
        return 1
    fi

    if [ ! -r "$rules_file" ]; then
        logger "ERROR" "Current user does not have read permissions on rules file \"$rules_file\""
        return 1
    fi

    if [ ! -s "$rules_file" ]; then
        logger "ERROR" "Rules file \"$rules_file\" is empty"
        return 1
    fi

    logger "DEBUG" "check_rules_file function finished"
}

# This function loads the rules from the rules file into an associative array called RULES.
# The format of the rules file is:
# <username>@<hostname/IP address>:<port>
# <forward/reverse> <local address>:<local port>:<remote address>:<remote port>
# Note that empty lines and invalid lines will be ignored.
# Invalid lines will be logged with the FATAL level.
# The rules file must exist and have content, otherwise, FATAL errors will be logged.
# This function uses other functions such as logger.sh and validators.sh to validate the content of the rules file.
load_rules() {
    logger "DEBUG" "Starting load_rules function"

    if ! check_rules_file "$RULES_FILE"; then
        logger "FATAL" "Rules file checks failed"
    fi

    # Variable to keep track of the current host being processed
    local current_host=""
    # Variable to keep track of the current line number
    local line_no=0

    # Loop through each line of the rules file
    while IFS= read -r line; do
        # Ignore empty lines
        if [[ -z "$line" ]]; then
            continue
        fi

        # Increment the line number
        ((line_no++))

        logger "DEBUG" "Processing line $line_no: $line"

        # If the line matches the username@hostname:port pattern, extract the username,
        # hostname, and port and create a new key in RULES
        if [[ "$line" =~ ^([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+:[0-9]+)=\/[a-zA-Z0-9._\/-]+$ ]]; then
            local ssh_key_path
            local username_host_port
            # Extract the username@hostname:port combo and ssh key path
            IFS='=' read -r username_host_port ssh_key_path <<<"$line"

            # Checking if ssh_key_path exists
            if [ ! -f "$ssh_key_path" ]; then
                logger "FATAL" "SSH private key file not found: $ssh_key_path"
            fi

            local username
            local host_port
            # Extract the username and host_port combo
            IFS='@' read -r username host_port <<<"$username_host_port"

            # Validate username
            if ! is_valid_username "$username"; then
                logger "FATAL" "Invalid username: $username in line $line_no"
            fi

            local host
            local port
            # Extract the host and port
            IFS=':' read -r host port <<<"$host_port"

            # Validate host
            if ! is_valid_hostname_or_ip "$host"; then
                logger "FATAL" "Invalid hostname/IP address: ${host_port%:*} in line $line_no"
            fi

            # Validate the port
            if ! is_valid_port "$port"; then
                logger "FATAL" "Invalid port: ${host_port#*:} in line $line_no"
            fi

            # Create a new key in RULES with the current host as the key and an empty value
            current_host="$line"
            RULES["$current_host"]=""
        # If the line matches the forward/reverse pattern and a host is currently being processed, add it to the current host's value
        elif [[ -n "$current_host" && "$line" =~ ^(reverse|forward)\ [^\ ]+\:[0-9]+\:[^\ ]+\:[0-9]+$ ]]; then
            # Validate the forward/reverse rule
            if ! is_valid_forward_reverse_line "$line"; then
                logger "FATAL" "Invalid forward/reverse line: $line in line $line_no"
            fi

            # Add the rule to the current host's value in RULES, separated by a semicolon
            RULES["$current_host"]+="$line;"
        else
            # Log an error for invalid lines
            logger "FATAL" "Invalid line in rules file: $line in line $line_no"
        fi
    done <"$RULES_FILE"

    logger "DEBUG" "load_rules function finished"
}

#!/bin/bash
# shellcheck disable=SC1091
# Load logger functions
source logger.sh
# Load validator functions
source validators.sh

declare -A RULES

# This function loads the rules from rules.txt file into an associative array called RULES.
# The format of the rules file is:
# <username>@<hostname/IP address>:<port>
# <forward/reverse> <local address>:<local port>:<remote address>:<remote port>
# Note that empty lines and invalid lines will be ignored.
# Invalid lines will be logged with the FATAL level.
# The rules file must exist and have content, otherwise, FATAL errors will be logged.
# This function uses other functions such as logger.sh and validators.sh to validate the content of the rules file.
load_rules() {
    logger "DEBUG" "Starting load_rules function"

    # Check if rules.txt exists and has content
    if [ ! -f "rules.txt" ]; then
        logger "FATAL" "rules.txt not found"
    fi

    if [ ! -s "rules.txt" ]; then
        logger "FATAL" "rules.txt is empty"
    fi

    local current_host="" # Variable to keep track of the current host being processed
    local line_no=0       # Variable to keep track of the current line number

    # Loop through each line of the rules file
    while IFS= read -r line; do
        # Ignore empty lines
        if [[ -z "$line" ]]; then
            continue
        fi

        ((line_no++)) # Increment the line number

        logger "DEBUG" "Processing line $line_no: $line"

        # If the line matches the username@hostname:port pattern, extract the username,
        # hostname, and port and create a new key in RULES
        if [[ "$line" =~ ^([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+:[0-9]+)$ ]]; then
            local username
            local host_port
            # Extract the username and validate it
            username="${line%@*}"
            if ! is_valid_username "$username"; then
                logger "FATAL" "Invalid username: $username in line $line_no"
            fi

            # Extract the hostname/IP address and validate it
            host_port="${line#*@}"
            if ! is_valid_hostname_or_ip "${host_port%:*}"; then
                logger "FATAL" "Invalid hostname/IP address: ${host_port%:*} in line $line_no"
            fi

            # Extract the port and validate it
            if ! is_valid_port "${host_port#*:}"; then
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
    done <rules.txt

    logger "DEBUG" "load_rules function finished"
}

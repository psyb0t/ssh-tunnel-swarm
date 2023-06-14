#!/bin/bash
# Set default log level to INFO if it's not already set
: "${LOG_LEVEL:=INFO}"
# Set default log enabled flag only if it's not been set before
: "${LOG_ENABLED:=1}"
# Set default log file if it's not already set
: "${LOG_FILE:=}"

# Declare an associative array to map different log levels with a numerical value
declare -A log_levels=(
    ["DEBUG"]=1
    ["INFO"]=2
    ["ERROR"]=3
    ["FATAL"]=4
)

# This function checks if a given log level is valid or not
# Accepts one parameter:
# $1 - log_level: A string containing the log level to be checked.
is_valid_log_level() {
    local level=$1
    if [[ -n ${log_levels[$level]} ]]; then
        return 0
    else
        return 1
    fi
}

# This function logs the message with the specified log level
# Accepts two parameters:
# $1 - log_level: A string containing the log level of the message.
# $2 - message: A string containing the message to be logged.
logger() {
    local log_level=$1
    local message="$2"
    local dt=""
    dt=$(date +"%Y-%m-%d %H:%M:%S")

    # Check if logging is enabled
    if [[ "${LOG_ENABLED}" -lt 1 ]]; then
        # Exit the function without printing anything
        return
    fi

    # Check if the log level is valid or not
    if [[ -n ${log_levels[$log_level]} ]]; then
        # Check if the log level is greater than or equal to the current log level
        if ((log_levels[$log_level] >= log_levels[$LOG_LEVEL])); then
            if [[ -n ${LOG_FILE} ]]; then
                # Append to log file
                echo "[$dt] [$log_level] $message" >>"$LOG_FILE"
            else
                # Print to stdout
                echo "[$dt] [$log_level] $message"
            fi

            # If the log level is 'FATAL', exit with status code 1
            if [ "$log_level" = "FATAL" ]; then
                exit 1
            fi
        fi
    else
        echo "Invalid log level: $log_level"
        exit 1
    fi
}

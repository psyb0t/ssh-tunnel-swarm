#!/bin/bash
# Load logger functions
source logger.sh
# Load tunnel rules
source rules.sh
# Load splitter functions
source splitters.sh

# Load tunnel rules into memory
load_rules

# Function to establish an SSH connection to a remote host and create tunnels based on pre-defined rules.
# Accepts two parameters:
# $1 - user_host_port: A string containing the username, hostname, and port number to connect to, separated by colons. Example: "john@example.com:22"
# $2 - raw_tunnel_rules: A string containing semicolon-separated tunnel rules, where each tunnel rule is in the format "direction interface_ports", separated by spaces. Example: "forward 8080:localhost:80;reverse 2222:localhost:22"
establish_ssh_connection() {
    local user_host_port="$1"
    local raw_tunnel_rules="$2"
    local IFS=" "

    logger "DEBUG" "Splitting user, host and port from: $user_host_port"
    # Split the username, hostname, and port number from the user_host_port string
    read -r user_host port <<<"$(split_user_host_port "$user_host_port")"
    logger "DEBUG" "Got user_host and port: $user_host, $port"

    logger "DEBUG" "Splitting user and host from: $user_host"
    # Split the username and hostname from the user_host string
    read -r user host <<<"$(split_user_host "$user_host")"
    logger "DEBUG" "Got user and host: $user, $host"

    logger "DEBUG" "Processing raw tunnel rules: $raw_tunnel_rules"
    # Split the tunnel rules into an array
    IFS=';'
    read -ra tunnel_rules <<<"$raw_tunnel_rules"

    logger "DEBUG" "Building ssh_tunnel_parameters string"
    local ssh_tunnel_parameters=""
    # Loop through each tunnel rule and build the ssh_tunnel_parameters string
    for tunnel_rule in "${tunnel_rules[@]}"; do
        logger "DEBUG" "Splitting tunnel_rule into direction interface_ports: $tunnel_rule"
        # Split the tunnel rule into the direction (forward/reverse) and interface:port pairs
        IFS=" "
        read -r direction interface_ports <<<"${tunnel_rule}"
        logger "DEBUG" "Got direction and interface_ports: $direction, $interface_ports"

        logger "DEBUG" "Splitting local_interface, local_port, remote_interface, remote_port from: $interface_ports"
        # Split the interface:port pairs into local_interface, local_port, remote_interface, remote_port
        read -r local_interface local_port remote_interface remote_port <<<"$(split_interface_ports "$interface_ports")"
        logger "DEBUG" "Got local_interface, local_port, remote_interface, remote_port: $local_interface, $local_port, $remote_interface, $remote_port"

        logger "DEBUG" "Determining ssh_tunnel_parameters based on direction: $direction"
        # Append the appropriate ssh_tunnel_parameters string based on the direction of the tunnel
        if [[ "${direction}" == "reverse" ]]; then
            ssh_tunnel_parameters="${ssh_tunnel_parameters} -R ${remote_interface}:${remote_port}:${local_interface}:${local_port}"
        elif [[ "${direction}" == "forward" ]]; then
            ssh_tunnel_parameters="${ssh_tunnel_parameters} -L ${local_interface}:${local_port}:${remote_interface}:${remote_port}"
        else
            logger "FATAL" "Unknown direction: $direction"
        fi
    done
    logger "DEBUG" "Got ssh_tunnel_parameters: $ssh_tunnel_parameters"

    logger "DEBUG" "Entering ssh loop for ${user}@${host}"
    # Loop continuously to establish and maintain the SSH connection
    while true; do
        logger "INFO" "Creating tunnel(s) on ${user}@${host}: ${raw_tunnel_rules}"

        logger "DEBUG" "Creating temporary file"
        # Create a temporary file to store the SSH connection output
        local temp_file
        temp_file=$(mktemp)
        logger "DEBUG" "Created temporary file: $temp_file"

        # Convert the ssh_tunnel_parameters string and other connection details into the SSH command
        IFS=' '
        read -ra split_ssh_tunnel_parameters <<<"$ssh_tunnel_parameters"
        logger "DEBUG" "Executing ssh command ssh -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=no" "${split_ssh_tunnel_parameters[@]}" "-p" "${port}" "${user}@${host}"
        # Establish an SSH connection and create the tunnels
        ssh -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=no "${split_ssh_tunnel_parameters[@]}" -p "${port}" "${user}@${host}" >"$temp_file" 2>&1

        local ssh_exit_status=$?
        local ssh_output
        ssh_output=$(<"$temp_file")
        logger "DEBUG" "SSH exit status and output: $ssh_exit_status, $ssh_output"

        logger "DEBUG" "Removing temporary file ${temp_file}"
        # Remove the temporary file
        rm -f "$temp_file"
        logger "DEBUG" "Removed temporary file: $temp_file"

        if [ "$ssh_exit_status" -eq 0 ]; then
            logger "INFO" "SSH connection successful for host $host"
            break
        fi

        logger "ERROR" "SSH connection to $host exited with status: $ssh_exit_status"
        logger "ERROR" "SSH connection error message: $ssh_output"
        sleep 5
    done
    logger "DEBUG" "Exited ssh loop for ${user}@${host}"
}

# Arrays to keep track of process IDs for each connection
declare -A SUBSHELL_PIDS
declare -A HOST_PIDS

# Function to kill all SSH connections and exit the script
kill_ssh_connections() {
    logger "INFO" "Killing SSH connections"
    # Loop through each connection and kill the SSH process and its children
    for user_host_port in "${!SUBSHELL_PIDS[@]}"; do
        local host=${user_host_port%:*}                      # Extract the hostname from the user_host_port string
        local subshell_pid=${SUBSHELL_PIDS[$user_host_port]} # Get the subshell PID for the connection

        logger "INFO" "Killing SSH process for host $host (PID: $subshell_pid)"
        # Kill the subshell process and its children
        kill "$subshell_pid" 2>/dev/null
        kill "${HOST_PIDS[$user_host_port]}" 2>/dev/null
    done

    # Log an exiting message and exit the script
    logger "INFO" "Script terminated."
    exit
}

# Main function to start SSH connections based on the pre-defined rules
main() {
    # Loop through each user_host_port and start a connection in the background
    for user_host_port in "${!RULES[@]}"; do
        (
            establish_ssh_connection "$user_host_port" "${RULES[$user_host_port]}"
        ) &

        # Record the process IDs for the connection
        SUBSHELL_PIDS["$user_host_port"]=$!
        HOST_PIDS["$user_host_port"]=$(pgrep -P "${SUBSHELL_PIDS[$user_host_port]}")

        logger "DEBUG" "SSH connection started for host ${user_host_port%:*} (PID: ${SUBSHELL_PIDS[$user_host_port]}, HOST PID: ${HOST_PIDS[$user_host_port]})."
    done

    # Register the signal handlers for killing SSH connections
    trap kill_ssh_connections SIGTERM SIGINT
    wait
}

# Start the script
main

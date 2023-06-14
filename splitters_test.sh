#!/bin/bash
# shellcheck disable=SC1091
# Source the common test functions
source common_test.sh
# Source the bash file containing the functions to be tested
source splitters.sh

# Test function for split_user_host_port
test_split_user_host_port() {
    # Test with hostname
    test_split_user_host_port_with_hostname() {
        local input="john@example.com:22"
        local expected_output=("john@example.com" "22")
        assert_equals "$(split_user_host_port $input)" "${expected_output[*]}" "${FUNCNAME[0]}: test with hostname"
        assert_no_error $? "${FUNCNAME[0]}"
    }
    test_split_user_host_port_with_hostname

    # Test with IP address
    test_split_user_host_port_with_ip() {
        local input="alice@192.168.1.10:8080"
        local expected_output=("alice@192.168.1.10" "8080")
        assert_equals "$(split_user_host_port $input)" "${expected_output[*]}" "${FUNCNAME[0]}: test with IP address"
        assert_no_error $? "${FUNCNAME[0]}"
    }
    test_split_user_host_port_with_ip

    # Test with localhost
    test_split_user_host_port_with_localhost() {
        local input="root@localhost:3306"
        local expected_output=("root@localhost" "3306")
        assert_equals "$(split_user_host_port $input)" "${expected_output[*]}" "${FUNCNAME[0]}: test with localhost"
        assert_no_error $? "${FUNCNAME[0]}"
    }
    test_split_user_host_port_with_localhost

    # Test with empty input
    test_split_user_host_port_with_empty_input() {
        local input=""
        local expected_output=()
        local expected_return_code=1
        assert_is_error "$(
            split_user_host_port "$input"
            echo $?
        )" "${expected_return_code}" "${FUNCNAME[0]}: test with empty input"
    }
    test_split_user_host_port_with_empty_input

    # Test with missing port
    test_split_user_host_port_with_missing_port() {
        local input="bob@example.com:"
        local expected_output=()
        local expected_return_code=1
        assert_is_error "$(
            split_user_host_port $input
            echo $?
        )" "${expected_return_code}" "${FUNCNAME[0]}: test with missing port"
    }
    test_split_user_host_port_with_missing_port
}

# Test function for split_user_host
test_split_user_host() {
    # Test with hostname
    test_split_user_host_with_hostname() {
        local input="john@example.com"
        local expected_output=("john" "example.com")
        assert_equals "$(split_user_host $input)" "${expected_output[*]}" "${FUNCNAME[0]}: test with hostname"
        assert_no_error $? "${FUNCNAME[0]}"
    }
    test_split_user_host_with_hostname

    # Test with IP address
    test_split_user_host_with_ip() {
        local input="alice@192.168.1.10"
        local expected_output=("alice" "192.168.1.10")
        assert_equals "$(split_user_host $input)" "${expected_output[*]}" "${FUNCNAME[0]}: test with IP address"
        assert_no_error $? "${FUNCNAME[0]}"
    }
    test_split_user_host_with_ip

    # Test with localhost
    test_split_user_host_with_localhost() {
        local input="root@localhost"
        local expected_output=("root" "localhost")
        assert_equals "$(split_user_host $input)" "${expected_output[*]}" "${FUNCNAME[0]}: test with localhost"
        assert_no_error $? "${FUNCNAME[0]}"
    }
    test_split_user_host_with_localhost

    # Test with empty input
    test_split_user_host_with_empty_input() {
        local input=""
        local expected_output=()
        local expected_return_code=1
        assert_is_error "$(
            split_user_host "$input"
            echo $?
        )" "${expected_return_code}" "${FUNCNAME[0]}: test with empty input"
    }
    test_split_user_host_with_empty_input

    # Test with missing hostname
    test_split_user_host_port_with_missing_hostname() {
        local input="@example.com"
        local expected_output=()
        local expected_return_code=1
        assert_is_error "$(
            split_user_host $input
            echo $?
        )" "${expected_return_code}" "${FUNCNAME[0]}: test with missing hostname"
    }
    test_split_user_host_port_with_missing_hostname
}

# Test function for split_interface_ports
test_split_interface_ports() {
    # Test with IP addresses
    test_split_interface_ports_ips() {
        local input="192.168.1.2:8080:192.168.1.100:80"
        local expected_output=("192.168.1.2" "8080" "192.168.1.100" "80")
        assert_equals "$(split_interface_ports $input)" "${expected_output[*]}" "${FUNCNAME[0]}: test with IP addresses"
        assert_no_error $? "${FUNCNAME[0]}"
    }
    test_split_interface_ports_ips

    # Test with mixed hostnames
    test_split_interface_ports_mixed_hostnames() {
        local input="localhost:80:test.com.test:2048"
        local expected_output=("localhost" "80" "test.com.test" "2048")
        assert_equals "$(split_interface_ports $input)" "${expected_output[*]}" "${FUNCNAME[0]}: test with mixed hostnames"
        assert_no_error $? "${FUNCNAME[0]}"
    }
    test_split_interface_ports_mixed_hostnames

    # Test with empty input
    test_split_interface_ports_with_empty_input() {
        local input=""
        local expected_output=()
        local expected_return_code=1
        assert_is_error "$(
            split_interface_ports "$input"
            echo $?
        )" "${expected_return_code}" "${FUNCNAME[0]}: test with empty input"
    }
    test_split_interface_ports_with_empty_input

    # Test with missing local port
    test_split_interface_ports_with_missing_local_port() {
        local input="192.168.1.2::192.168.1.100:80"
        local expected_output=()
        local expected_return_code=1
        assert_is_error "$(
            split_interface_ports $input
            echo $?
        )" "${expected_return_code}" "${FUNCNAME[0]}: test with missing local port"
    }
    test_split_interface_ports_with_missing_local_port

    # Test with missing remote interface
    test_split_interface_ports_with_missing_remote_interface() {
        local input="localhost:80::2048"
        local expected_output=()
        local expected_return_code=1
        assert_is_error "$(
            split_interface_ports $input
            echo $?
        )" "${expected_return_code}" "${FUNCNAME[0]}: test with missing remote interface"
    }
    test_split_interface_ports_with_missing_remote_interface
}

# Run all test functions
test_split_user_host_port
test_split_user_host
test_split_interface_ports

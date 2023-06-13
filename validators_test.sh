#!/bin/bash
# shellcheck disable=SC1091
# Source the common test functions
source common_test.sh
# Source the bash file containing the functions to be tested
source validators.sh

# Test function for is_valid_username
test_is_valid_username() {
    test_is_valid_username_with_valid_username() {
        local input="username_123"
        assert_no_error "$(
            is_valid_username $input
            echo $?
        )" "${FUNCNAME[0]}"
    }
    test_is_valid_username_with_valid_username

    test_is_valid_username_with_invalid_username_special_characters() {
        local input="username@#!"
        local expected_error=1
        assert_is_error "$(
            is_valid_username $input
            echo $?
        )" $expected_error "${FUNCNAME[0]}"
    }
    test_is_valid_username_with_invalid_username_special_characters
}

# Test function for is_valid_host_port
test_is_valid_host_port() {
    test_is_valid_host_port_with_valid_host_port() {
        local input="localhost:8080"
        assert_no_error "$(
            is_valid_host_port $input
            echo $?
        )" "${FUNCNAME[0]}"
    }
    test_is_valid_host_port_with_valid_host_port

    test_is_valid_host_port_with_invalid_host_port_no_port() {
        local input="localhost"
        local expected_error=1
        assert_is_error "$(
            is_valid_host_port $input
            echo $?
        )" $expected_error "${FUNCNAME[0]}"
    }
    test_is_valid_host_port_with_invalid_host_port_no_port
}

# Test function for is_valid_forward_reverse_line
test_is_valid_forward_reverse_line() {
    test_is_valid_forward_reverse_line_with_valid_forward() {
        local input="forward 192.168.1.1:8080:localhost:80"
        assert_no_error "$(
            is_valid_forward_reverse_line "$input"
            echo $?
        )" "${FUNCNAME[0]}"
    }
    test_is_valid_forward_reverse_line_with_valid_forward

    test_is_valid_forward_reverse_line_with_valid_reverse() {
        local input="reverse 192.168.1.1:8080:localhost:80"
        assert_no_error "$(
            is_valid_forward_reverse_line "$input"
            echo $?
        )" "${FUNCNAME[0]}"
    }
    test_is_valid_forward_reverse_line_with_valid_reverse

    test_is_valid_forward_reverse_line_with_invalid_no_port() {
        local input="forward 192.168.1.1 localhost:80"
        local expected_error=1
        assert_is_error "$(
            is_valid_forward_reverse_line "$input"
            echo $?
        )" $expected_error "${FUNCNAME[0]}"
    }
    test_is_valid_forward_reverse_line_with_invalid_no_port
}

# Test function for is_valid_port
test_is_valid_port() {
    test_is_valid_port_with_valid_port_int() {
        local input="8080"
        assert_no_error "$(
            is_valid_port $input
            echo $?
        )" "${FUNCNAME[0]}"
    }
    test_is_valid_port_with_valid_port_int

    test_is_valid_port_with_invalid_port_string() {
        local input="nan"
        local expected_error=1
        assert_is_error "$(
            is_valid_port $input
            echo $?
        )" $expected_error "${FUNCNAME[0]}"
    }
    test_is_valid_port_with_invalid_port_string

    test_is_valid_port_with_invalid_port_out_of_range() {
        local input="70000"
        local expected_error=1
        assert_is_error "$(
            is_valid_port $input
            echo $?
        )" $expected_error "${FUNCNAME[0]}"
    }
    test_is_valid_port_with_invalid_port_out_of_range
}

# Test function for is_valid_hostname_or_ip
test_is_valid_hostname_or_ip() {
    test_is_valid_hostname_or_ip_with_valid_ip() {
        local input="192.168.1.1"
        assert_no_error "$(
            is_valid_hostname_or_ip "$input"
            echo $?
        )" "${FUNCNAME[0]}"
    }
    test_is_valid_hostname_or_ip_with_valid_ip

    test_is_valid_hostname_or_ip_with_invalid_ip_format_error() {
        local input="192.168.1.256"
        local expected_error=1
        assert_is_error "$(
            is_valid_hostname_or_ip "$input"
            echo $?
        )" $expected_error "${FUNCNAME[0]}"
    }
    test_is_valid_hostname_or_ip_with_invalid_ip_format_error

    test_is_valid_hostname_or_ip_with_valid_hostname() {
        local input="localhost"
        assert_no_error "$(
            is_valid_hostname_or_ip "$input"
            echo $?
        )" "${FUNCNAME[0]}"
    }
    test_is_valid_hostname_or_ip_with_valid_hostname

    test_is_valid_hostname_or_ip_with_valid_full_domain() {
        local input="test.co.uk"
        assert_no_error "$(
            is_valid_hostname_or_ip "$input"
            echo $?
        )" "${FUNCNAME[0]}"
    }
    test_is_valid_hostname_or_ip_with_valid_full_domain

    test_is_valid_hostname_or_ip_with_invalid_hostname_format_error() {
        local input="my_host@name"
        local expected_error=1
        assert_is_error "$(
            is_valid_hostname_or_ip "$input"
            echo $?
        )" $expected_error "${FUNCNAME[0]}"
    }
    test_is_valid_hostname_or_ip_with_invalid_hostname_format_error

    test_is_valid_hostname_or_ip_with_numeric_value() {
        local input="1234234"
        local expected_error=1
        assert_is_error "$(
            is_valid_hostname_or_ip "$input"
            echo $?
        )" $expected_error "${FUNCNAME[0]}"
    }
    test_is_valid_hostname_or_ip_with_numeric_value

    test_is_valid_hostname_or_ip_with_special_characters() {
        local input="host!@#"
        local expected_error=1
        assert_is_error "$(
            is_valid_hostname_or_ip "$input"
            echo $?
        )" $expected_error "${FUNCNAME[0]}"
    }
    test_is_valid_hostname_or_ip_with_special_characters

    test_is_valid_hostname_or_ip_with_valid_hostname_with_dash() {
        local input="host-name"
        assert_no_error "$(
            is_valid_hostname_or_ip "$input"
            echo $?
        )" "${FUNCNAME[0]}"
    }
    test_is_valid_hostname_or_ip_with_valid_hostname_with_dash

    test_is_valid_hostname_or_ip_with_empty_input_error() {
        local input=""
        local expected_error=1
        assert_is_error "$(
            is_valid_hostname_or_ip "$input"
            echo $?
        )" $expected_error "${FUNCNAME[0]}"
    }
    test_is_valid_hostname_or_ip_with_empty_input_error
}

test_is_valid_username
test_is_valid_host_port
test_is_valid_forward_reverse_line
test_is_valid_port
test_is_valid_hostname_or_ip

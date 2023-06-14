#!/bin/bash
# Function to print a failure message
print_failure() {
    local message="$1"
    local expected="$2"
    local actual="$3"
    local is_error_check="$4"

    local check_type
    if [[ "$is_error_check" -eq 1 ]]; then
        check_type="Error check"
    else
        check_type="Equality check"
    fi

    echo "FAIL - Test failed: $message. $check_type. Expected '$expected', but got '$actual'"
    exit 1
}

# Function to print a success message
print_success() {
    local message="$1"

    echo "OK - Test passed: $message"
}

# Assert function to check if actual and expected values are the same
assert_equals() {
    local actual="$1"
    local expected="$2"
    local message="$3"

    if [[ "$actual" == "$expected" ]]; then
        print_success "$message"
    else
        print_failure "$message" "$expected" "$actual" 0
    fi
}

# Assert function to check if the function produces an error code
assert_is_error() {
    local actual="$1"
    local expected="$2"
    local message="$3"

    if [[ "$actual" -eq "$expected" ]]; then
        print_success "$message"
    else
        print_failure "$message" "$expected" "$actual" 1
    fi
}

# Assert function to check if the function produces no error code
assert_no_error() {
    local actual="$1"
    local message="$2"

    if [[ "$actual" -eq 0 ]]; then
        print_success "$message"
    else
        print_failure "$message" "no error" "$actual" 1
    fi
}

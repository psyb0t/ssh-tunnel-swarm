#!/bin/bash
# shellcheck disable=SC1091
# Source the common test functions
source common_test.sh
# Source the bash file containing the functions to be tested
source rules.sh

# Test function for check_rules_file
test_check_rules_file() {
    # Test with existing and readable rules file
    test_check_rules_file_with_existing_readable_file() {
        local temp_file
        temp_file=$(mktemp /tmp/rules.XXXXXX)
        touch "$temp_file"
        chmod u+r "$temp_file"
        assert_no_error "$(check_rules_file "$temp_file")" "${FUNCNAME[0]}: test with existing and readable file"
        rm "$temp_file"
    }
    test_check_rules_file_with_existing_readable_file

    # Test with non-existent file
    test_check_rules_file_with_nonexistent_file() {
        local temp_file
        temp_file=$(mktemp /tmp/rules.XXXXXX)
        rm "$temp_file"
        local expected_return_code=1
        assert_is_error "$(
            check_rules_file "$temp_file"
            echo $?
        )" "${expected_return_code}" "${FUNCNAME[0]}: test with non-existent file"
    }
    test_check_rules_file_with_nonexistent_file

    # Test with non-readable file
    test_check_rules_file_with_nonreadable_file() {
        local temp_file
        temp_file=$(mktemp /tmp/rules.XXXXXX)
        touch "$temp_file"
        chmod u-r "$temp_file"
        local expected_return_code=1
        assert_is_error "$(
            check_rules_file "$temp_file"
            echo $?
        )" "${expected_return_code}" "${FUNCNAME[0]}: test with non-readable file"
        rm "$temp_file"
    }
    test_check_rules_file_with_nonreadable_file

    # Test with empty file
    test_check_rules_file_with_empty_file() {
        local temp_file
        temp_file=$(mktemp /tmp/rules.XXXXXX)
        local expected_return_code=1
        assert_is_error "$(
            check_rules_file "$temp_file"
            echo $?
        )" "${expected_return_code}" "${FUNCNAME[0]}: test with empty file"
        rm "$temp_file"
    }
    test_check_rules_file_with_empty_file
}

# Run all test functions
test_check_rules_file

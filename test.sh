#!/bin/bash

# shellcheck disable=SC2034
LOG_ENABLED=0

# Get the list of files ending with _test.sh in the current directory
test_files=$(find . -name "*_test.sh")

# Source each test file
for test_file in $test_files; do
    # shellcheck disable=SC1090
    source "$test_file"
done

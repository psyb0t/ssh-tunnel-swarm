# Testing

- `make test` runs `./test.sh` inside the pinned `bash` image as your uid and gid, with the repository mounted read-only. CI runs the same target.
- Run tests as a non-root user. `test_check_rules_file_with_nonreadable_file` relies on `chmod u-r` actually blocking reads, which it does not for root.
- `test.sh` sets `LOG_ENABLED=0` and sources every `*_test.sh` it finds. A test file sources `common_test.sh` and the file under test, defines `test_<function>` with nested `test_<function>_with_<case>` functions, and calls each one.
- Assertions come from `common_test.sh`. `assert_equals ACTUAL EXPECTED MESSAGE` compares strings; `assert_is_error ACTUAL EXPECTED MESSAGE` and `assert_no_error ACTUAL MESSAGE` compare a return code. A failure prints `FAIL - ...` and exits 1, which stops the whole run.
- Pass the return code, not the output, to the error assertions: capture it with `$(func args; echo $?)`. Passing `$(func args)` alone compares the function's output, which is empty for most validators and makes `assert_no_error` pass whatever the function returned.
- Tests for `validators.sh`, `splitters.sh` and `rules.sh` go in the matching `*_test.sh`. `main.sh` has no tests because it starts `ssh`; check changes there by hand with a fake `ssh` on `PATH`.

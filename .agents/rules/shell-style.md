# Shell style

Applies to every `*.sh` file in the repository.

- Every file starts with `#!/bin/bash`. The code targets Bash 4 or newer because `logger.sh`, `rules.sh` and `main.sh` use associative arrays.
- `make lint` runs shellcheck (pinned image in the `Makefile`) over every tracked `*.sh` and must stay clean at the default severity. Fix the code; add a `# shellcheck disable=SCxxxx` only for a real reason, as `test.sh` does for `SC2034` and `SC1090`.
- Source files with a plain `source <file>.sh` at the top, relative to the repository root, after `# shellcheck disable=SC1091`. `make build` strips those lines, so the merged script must still define everything the code calls.
- Never put code on a line that starts with `#` or `source`, and never rely on blank lines or comments inside strings or heredocs: `make build` deletes them.
- Functions take positional arguments into named `local` variables first, set `local IFS` when they split, and return 0 or 1. Splitters echo their parts space-separated for `read -r` on the caller side.
- Log with `logger LEVEL "message"` from `logger.sh`, never with a bare `echo`. Use `DEBUG` for parsing steps, `INFO` for connection lifecycle, `ERROR` for a failed attempt that will be retried, and `FATAL` only for a condition that must stop the script.
- Each function gets a comment block above it describing its parameters and return values, matching the existing files. Indent with four spaces.

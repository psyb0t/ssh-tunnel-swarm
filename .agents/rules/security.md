# Security

- `rules.txt` is gitignored because it names real hosts and key paths. Never read, print or commit it.
- Keep `-o StrictHostKeyChecking=yes` on the `ssh` command in `main.sh`. Do not add an option that skips or auto-accepts host keys, and do not document one as a workaround.
- The tool supports key authentication only. Do not add password handling or pass secrets on the `ssh` command line.
- `DEBUG` logs print the full `ssh` command, including the key path, and the raw `ssh` output.
- `ssh` output goes to a `mktemp` file that `establish_ssh_connection` removes after each attempt. Keep the cleanup when changing the loop.

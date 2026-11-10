# Rules file format

Applies to `rules.sh`, `validators.sh`, `splitters.sh`, `main.sh`, `rules.txt.example` and every place that documents the format (`docs/rules-file.md`, `README.md`, the skill).

- The parser is `load_rules` in `rules.sh`. Every non-blank line must be a header line or a tunnel line; anything else, including `#` comments, trailing spaces and CRLF line endings, is `FATAL`.
- Header regex: `^([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+:[0-9]+)=\/[a-zA-Z0-9._\/-]+$`. The key path must be absolute and exist (`-f`). The host then goes through `is_valid_hostname_or_ip` and the port through `is_valid_port` (0 to 65535).
- Tunnel regex: `^(reverse|forward)\ [^\ ]+\:[0-9]+\:[^\ ]+\:[0-9]+$`, only after a header. `is_valid_forward_reverse_line` checks the keyword, the first field as a host or IP, and the second and fourth fields as ports. Its `ip2` expression re-reads the first field, so the third field (the remote interface) is only checked by the regex.
- Field order is `local-interface:local-port:remote-interface:remote-port` for both directions. `forward` becomes `-L local:lport:remote:rport`, `reverse` becomes `-R remote:rport:local:lport` in `establish_ssh_connection`.
- A format change updates the regexes, the validators, their tests, `docs/rules-file.md`, `docs/troubleshooting.md` and both skill files in the same change. Examples must load: every port 65535 or lower, every key path absolute.

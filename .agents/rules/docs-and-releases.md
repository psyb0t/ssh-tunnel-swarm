# Docs and releases

- The documentation site is `docs/`, published by GitHub Pages from `master` at https://psyb0t.github.io/ssh-tunnel-swarm/ with the Just the Docs theme (`remote_theme` pinned in `docs/_config.yml`, colors in `docs/_sass/`, the shared tracker in `docs/_includes/head_custom.html`).
- The site `title`, the home page H1 and the `docs/llms.txt` H1 equal the README H1, `ssh-tunnel-swarm`. Change them together.
- Keep `docs/` flat; a file name is its URL. Wrap code blocks containing `{{` or `{%` in `<!-- {% raw %} -->` and `<!-- {% endraw %} -->`.
- After a docs change, run `make docs` and check the built site for broken links before handing off.
- There is no version file. The release version lives in the `vX.Y.Z` tag, `CHANGELOG.md` (`## vX.Y.Z, YYYY-MM-DD` headings) and `.agents/.codex-plugin/plugin.json`; keep the last two in step at release time.
- A release is an annotated `vX.Y.Z` tag on a commit whose `master` pipeline run passed. The tag run waits for that run, cuts the GitHub release from the tag notes, builds and uploads the `ssh-tunnel-swarm` asset that `tools/downloader.sh` fetches, and publishes the skill to ClawHub.

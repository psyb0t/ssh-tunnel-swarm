# Docs and releases

- The documentation site is `docs/`, published by GitHub Pages from `master` at https://psyb0t.github.io/ssh-tunnel-swarm/ with the Just the Docs theme (`remote_theme` pinned in `docs/_config.yml`, colors in `docs/_sass/`, the shared tracker in `docs/_includes/head_custom.html`).
- The site `title`, the home page H1 and the `docs/llms.txt` H1 equal the README H1, `ssh-tunnel-swarm`. Change them together.
- Every page has front matter with a unique `title` and a `description` of 50 to 170 characters, and exactly one `#` heading. Keep `docs/` flat; a file name is its URL.
- Links between pages use the relative `.md` path. A link to a file outside `docs/` uses the full `https://github.com/psyb0t/ssh-tunnel-swarm/blob/master/<path>` URL. Wrap code blocks containing `{{` or `{%` in `<!-- {% raw %} -->` and `<!-- {% endraw %} -->`.
- After a docs change, run `make docs` and check the built site for broken links before handing off.
- The README is the front door: what the tool is, install, a small example, and a Documentation section with full site URLs. Reference material lives in `docs/`. Each fact has one home.
- A behavior, variable or format change updates the matching docs page and the skill (`.agents/skills/ssh-tunnel-swarm/`) in the same change.
- Prose: no em dashes, "directory" never "folder", no AI vocabulary, sentence case headings, one paragraph per source line. Do not mention local scratch directories in committed text.
- There is no version file. The release version lives in the `vX.Y.Z` tag, `CHANGELOG.md` (`## vX.Y.Z, YYYY-MM-DD` headings) and `.agents/.codex-plugin/plugin.json`; keep the last two in step at release time.
- A release is an annotated `vX.Y.Z` tag on a commit whose `master` pipeline run passed. The tag run waits for that run, cuts the GitHub release from the tag notes, builds and uploads the `ssh-tunnel-swarm` asset that `tools/downloader.sh` fetches, and publishes the skill to ClawHub.

# Docs and releases

- The documentation pages are `docs/`, built by the Docusaurus site in `website/` and published to GitHub Pages from `master` by `.github/workflows/docs.yml` at https://psyb0t.github.io/ssh-tunnel-swarm/. Page order is `website/sidebars.mjs`, the page list for agents is `website/static/llms.txt`, and the shared tracker script is in `website/docusaurus.config.mjs`.
- The site `title`, the home page H1 and the `website/static/llms.txt` H1 equal the README H1, `ssh-tunnel-swarm`. Change them together.
- Keep `docs/` flat; a file name is its URL. Every page needs `title` and `description` front matter, and a new page goes into `website/sidebars.mjs` and `website/static/llms.txt`.
- After a docs change, run `make docs`; it fails on a broken link or anchor. After a dependency change in `website/package.json`, run `make docs-lock` first.
- There is no version file. The release version lives in the `vX.Y.Z` tag, `CHANGELOG.md` (`## vX.Y.Z, YYYY-MM-DD` headings) and `.agents/.codex-plugin/plugin.json`; keep the last two in step at release time.
- A release is an annotated `vX.Y.Z` tag on a commit whose `master` pipeline run passed. The tag run waits for that run, cuts the GitHub release from the tag notes, builds and uploads the `ssh-tunnel-swarm` asset that `tools/downloader.sh` fetches, and publishes the skill to ClawHub.

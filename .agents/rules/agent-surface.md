# Agent surface

Applies to `.agents/skills/`, `.agents/.claude-plugin/` and `.agents/.codex-plugin/`.

- The skill (`.agents/skills/ssh-tunnel-swarm/SKILL.md` and `references/setup.md`) describes the rules file, the environment variables and what the tool runs. Every regex, default, flag and message it names must match the code and the docs site. Fix both when either changes.
- Skill examples must load: no `#` comment lines inside a rules file example, ports 65535 or lower, absolute key paths.
- `.agents/.codex-plugin/plugin.json` carries the release version and `"skills": "./skills/"`. `.agents/.claude-plugin/plugin.json` has no version field.
- `pipeline.yml` publishes exactly the directories listed in `skill_names` (`["ssh-tunnel-swarm"]`) and `plugin_names` (`[]`). Add a new skill or plugin directory to those arrays.

# Claude Code Integration

The Agency was built for Claude Code. No conversion needed — agents work
natively with the existing `.md` + YAML frontmatter format.

## Install

```bash
# Copy all agents to your Claude Code agents directory
./scripts/install.sh --tool claude-code

# Or manually copy a category
cp engineering/*.md ~/.claude/agents/
```

## Activate an Agent

In any Claude Code session, reference an agent by name:

```
Activate Frontend Developer and help me build a React component.
```

```
Use the Reality Checker agent to verify this feature is production-ready.
```

## Agent Directory

Agents are organized into divisions. See the [main README](../../README.md) for
the full Agency roster.

## Install as Plugins (Marketplace)

Instead of copying agents, you can install each division as an agent plugin from
the Agency's [plugin marketplace](../plugin-marketplace/README.md):

```
/plugin marketplace add msitarzewski/agency-agents
/plugin install agency-engineering@agency-agents
/reload-plugins
```

Installed agents appear scoped by plugin (e.g. `agency-engineering:frontend-developer`)
and auto-update as the roster changes.

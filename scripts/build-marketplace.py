#!/usr/bin/env python3
"""Build the Claude-format plugin marketplace for The Agency agents.

The Agency's source agents live as flat frontmatter .md files inside top-level
division directories (engineering/, marketing/, ...), with divisions.json as the
single source of truth for the division set. This script publishes those
existing folders in place as a plugin marketplace without moving, duplicating,
or renaming any agent file:

  * One plugin per division. Each <division>/.claude-plugin/plugin.json makes
    the division folder itself the plugin root and lists every frontmatter
    agent .md as an explicit `agents` entry (./-prefixed, relative to the
    division root, subdirectories kept).
  * A marketplace registry at .claude-plugin/marketplace.json lists all
    divisions as plugins with same-repo relative sources.

The generated manifests MUST be committed: Claude Code, VS Code (Agent
Plugins), and GitHub Copilot CLI clone this repo and read them directly — no
build step runs on install. scripts/check-plugin-marketplace.sh (CI:
check-plugin-marketplace.yml) fails the build if the committed manifests drift
from what this script produces. Version is deliberately omitted from every
manifest so Claude Code versions each plugin by git commit SHA.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

MARKETPLACE_NAME = "agency-agents"
PLUGIN_PREFIX = "agency-"


def division_dirs(repo_root: Path) -> list[str]:
    # divisions.json (repo root) is the single source of truth for the division
    # set. Read it rather than hardcoding a copy here: a hardcoded list silently
    # drops new divisions (e.g. healthcare) the moment the catalog grows.
    # check-divisions.sh guards divisions.json against the tracked dirs, so
    # deriving from it keeps this plugin in sync by construction.
    data = json.loads((repo_root / "divisions.json").read_text(encoding="utf-8"))
    return sorted(data["divisions"].keys())


def division_label(repo_root: Path, division: str) -> str:
    data = json.loads((repo_root / "divisions.json").read_text(encoding="utf-8"))
    return data["divisions"][division]["label"]


def is_agent_file(path: Path) -> bool:
    # Same effective gate as convert.sh: a .md whose first line is `---`
    # frontmatter, carrying a non-empty `name`. Files with no frontmatter (e.g.
    # strategy/ playbooks, per-division docs) are not agents and are not listed.
    text = path.read_text(encoding="utf-8").replace("\r\n", "\n")
    if not text.startswith("---\n"):
        return False
    parts = text.split("---\n", 2)
    if len(parts) < 3:
        return False
    return any(
        line.startswith("name:") and line[len("name:"):].strip()
        for line in parts[1].splitlines()
    )


def division_agents(repo_root: Path, division: str) -> list[str]:
    base = repo_root / division
    return sorted(
        f"./{path.relative_to(base).as_posix()}"
        for path in base.rglob("*.md")
        if is_agent_file(path)
    )


def plugin_json(repo_root: Path, division: str, count: int) -> dict[str, object]:
    noun = "agent" if count == 1 else "agents"
    return {
        "name": f"{PLUGIN_PREFIX}{division}",
        "displayName": f"Agency — {division_label(repo_root, division)}",
        "description": (
            f"The Agency {division_label(repo_root, division)} division: "
            f"{count} specialist {noun}."
        ),
        "author": {"name": "Agency Agents"},
        "agents": division_agents(repo_root, division),
    }


def marketplace_json(repo_root: Path, counts: dict[str, int]) -> dict[str, object]:
    divisions = division_dirs(repo_root)
    plugins = []
    for division in divisions:
        count = counts[division]
        noun = "agent" if count == 1 else "agents"
        plugins.append({
            "name": f"{PLUGIN_PREFIX}{division}",
            "source": f"./{division}",
            "description": (
                f"{division_label(repo_root, division)} division "
                f"({count} specialist {noun})"
            ),
        })
    return {
        "name": MARKETPLACE_NAME,
        "description": (
            f"The Agency — {len(divisions)} installable agent divisions for "
            "Claude Code, VS Code, and GitHub Copilot CLI"
        ),
        "owner": {"name": "Agency Agents"},
        "plugins": plugins,
    }


def write_json(path: Path, obj: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(obj, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def build(repo_root: Path, out_dir: Path) -> dict[str, int]:
    counts: dict[str, int] = {}
    for division in division_dirs(repo_root):
        agents = division_agents(repo_root, division)
        if not agents:
            raise SystemExit(
                f"division '{division}' has no frontmatter agent files — "
                "refusing to emit an empty plugin"
            )
        counts[division] = len(agents)
        write_json(
            out_dir / division / ".claude-plugin" / "plugin.json",
            plugin_json(repo_root, division, len(agents)),
        )
    write_json(
        out_dir / ".claude-plugin" / "marketplace.json",
        marketplace_json(repo_root, counts),
    )
    return counts


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Repository root (default: parent of this script)",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Output directory; default is the repo root (write in place)",
    )
    args = parser.parse_args()
    repo_root = args.repo_root.resolve()
    out_dir = (args.out or repo_root).resolve()
    counts = build(repo_root, out_dir)
    total = sum(counts.values())
    print(
        f"wrote .claude-plugin/marketplace.json + {len(counts)} division "
        f"plugin manifests ({total} agents) to {out_dir}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

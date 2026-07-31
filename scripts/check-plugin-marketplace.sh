#!/usr/bin/env bash
#
# check-plugin-marketplace.sh — enforce that the committed Claude-format plugin
# marketplace stays in sync with the real agent roster.
#
# The plugin marketplace is a distribution mechanism: Claude Code, VS Code
# (Agent Plugins), and GitHub Copilot CLI clone this repo and read the
# committed manifests directly — no build step runs on install. So the
# committed .claude-plugin/marketplace.json and each <division>/.claude-plugin/
# plugin.json MUST match what scripts/build-marketplace.py would generate.
# This script fails the build if any of the following disagree:
#   1. A committed manifest differs from a fresh generation (a new/renamed
#      agent or division drifts the manifests).
#   2. .claude-plugin/marketplace.json is invalid, uses a reserved or
#      non-kebab name, is missing owner.name, or its plugin list does not
#      match divisions.json exactly (both directions, same order).
#   3. Any plugin source is not ./-prefixed, contains "..", does not exist, or
#      is missing its own .claude-plugin/plugin.json.
#   4. Any plugin.json has the wrong name, or an agents entry that is not
#      ./-prefixed, contains "..", or does not exist.
#
# No deps beyond bash 3.2 + coreutils + python3 (already required by
# check-runbooks.sh and check-hermes-plugin.py) so it runs the same on macOS
# and CI. Mirrors scripts/check-divisions.sh. The real authority — `claude
# plugin validate . --strict` — runs separately in CI.
#
# Usage: ./scripts/check-plugin-marketplace.sh

set -euo pipefail
cd "$(dirname "$0")/.."

command -v python3 >/dev/null 2>&1 || {
  echo "ERROR: python3 is required for the plugin marketplace check." >&2
  exit 2
}

python3 - <<'PYEOF'
import importlib.util
import json
import os
import pathlib
import re
import sys
import tempfile

REPO_ROOT = pathlib.Path(os.getcwd())
BUILDER = REPO_ROOT / "scripts" / "build-marketplace.py"

# Reserved marketplace names from the Claude Code plugin-marketplaces docs.
# Claude re-checks these on every marketplace load, so a collision silently
# breaks installs; fail CI instead.
RESERVED_NAMES = {
    "claude-code-marketplace", "claude-code-plugins", "claude-plugins-official",
    "claude-plugins-community", "claude-community", "anthropic-marketplace",
    "anthropic-plugins", "agent-skills", "anthropic-agent-skills",
    "knowledge-work-plugins", "life-sciences", "claude-for-legal",
    "claude-for-financial-services", "financial-services-plugins",
    "first-party-plugins", "healthcare",
}

KUBE_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")


def load_module(name: str, path: pathlib.Path):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"could not load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


builder = load_module("agency_agents_marketplace_builder", BUILDER)
divisions = builder.division_dirs(REPO_ROOT)
expected_plugin = {d: f"agency-{d}" for d in divisions}

errors: list[str] = []
def fail(msg: str) -> None:
    errors.append(msg)
    print(f"  ERROR {msg}")


def rel(p: pathlib.Path) -> str:
    return p.relative_to(REPO_ROOT).as_posix()


# --- 1. Drift: committed manifests must match a fresh generation ------------
with tempfile.TemporaryDirectory() as tmp:
    out = pathlib.Path(tmp)
    builder.build(REPO_ROOT, out)
    pairs = [(out / ".claude-plugin" / "marketplace.json",
              REPO_ROOT / ".claude-plugin" / "marketplace.json")]
    pairs += [(out / d / ".claude-plugin" / "plugin.json",
               REPO_ROOT / d / ".claude-plugin" / "plugin.json") for d in divisions]
    for generated, committed in pairs:
        if not committed.exists():
            fail(f"committed {rel(committed)} is missing — run python3 scripts/build-marketplace.py")
            continue
        if generated.read_text(encoding="utf-8") != committed.read_text(encoding="utf-8"):
            fail(f"committed {rel(committed)} drifted from the roster — run python3 scripts/build-marketplace.py")

# --- 2. Marketplace manifest structure --------------------------------------
MP = REPO_ROOT / ".claude-plugin" / "marketplace.json"
if not MP.exists():
    fail("missing .claude-plugin/marketplace.json")
    print(f"\nFAILED: run python3 scripts/build-marketplace.py to generate the manifests.")
    sys.exit(1)

try:
    mp = json.loads(MP.read_text(encoding="utf-8"))
except json.JSONDecodeError as exc:
    fail(f"{rel(MP)} is not valid JSON: {exc}")
    mp = None

if mp is not None:
    name = mp.get("name")
    if not (isinstance(name, str) and KUBE_RE.match(name)):
        fail(f"marketplace name must be kebab-case: {name!r}")
    elif name in RESERVED_NAMES:
        fail(f"marketplace name '{name}' is reserved by Claude Code")
    if not mp.get("owner", {}).get("name"):
        fail("marketplace owner.name is required")
    plugins = mp.get("plugins")
    if not isinstance(plugins, list):
        fail("marketplace plugins must be an array")
    else:
        names = [p.get("name") for p in plugins]
        want = [expected_plugin[d] for d in divisions]
        if names != want:
            fail(f"marketplace plugin list does not match divisions.json exactly "
                 f"(expected {want}, got {names})")
        for p in plugins:
            src = p.get("source", "")
            if not (isinstance(src, str) and src.startswith("./") and ".." not in src):
                fail(f"plugin '{p.get('name')}' source must be ./-prefixed with no '..': {src}")
                continue
            src_dir = REPO_ROOT / src.lstrip("./")
            if not src_dir.is_dir():
                fail(f"plugin '{p.get('name')}' source '{src}' does not exist")
            elif not (src_dir / ".claude-plugin" / "plugin.json").is_file():
                fail(f"plugin '{p.get('name')}' source '{src}' has no .claude-plugin/plugin.json")

# --- 3. Per-division plugin.json structure ----------------------------------
for d in divisions:
    pj_path = REPO_ROOT / d / ".claude-plugin" / "plugin.json"
    if not pj_path.exists():
        continue  # already failed drift above
    try:
        pj = json.loads(pj_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"{rel(pj_path)} is not valid JSON: {exc}")
        continue
    if pj.get("name") != expected_plugin[d]:
        fail(f"plugin '{d}' name should be '{expected_plugin[d]}', got '{pj.get('name')}'")
    agents = pj.get("agents")
    if not isinstance(agents, list) or not agents:
        fail(f"plugin '{d}' agents must be a non-empty array")
        continue
    for a in agents:
        if not (isinstance(a, str) and a.startswith("./") and ".." not in a):
            fail(f"plugin '{d}' agent path must be ./-prefixed with no '..': {a}")
        elif not (REPO_ROOT / d / a.lstrip("./")).is_file():
            fail(f"plugin '{d}' agent path does not exist: {a}")

# --- result ----------------------------------------------------------------
if errors:
    print(f"\nFAILED: {len(errors)} plugin marketplace consistency error(s). "
          f"Run python3 scripts/build-marketplace.py to regenerate.")
    sys.exit(1)
print(f"PASSED: {len(divisions)} division plugins consistent across divisions.json, "
      f".claude-plugin/, and scripts/build-marketplace.py.")
PYEOF

# agency-agents — published plugin marketplace

This branch is the **generated dist** for The Agency's plugin marketplace.

- **Source repo:** `<owner>/agency-agents` (branch `main`) — generator +
  agents; this branch is build output and should **never** be hand-edited.
- **How it's built:** `scripts/build-marketplace.py`, published by CI
  (`.github/workflows/publish-plugin-marketplace.yml`) on every push to main.
- **How to consume:** point `chat.plugins.marketplaces` (VS Code) at
  `<owner>/agency-agents#plugins`, or in Claude Code run
  `/plugin marketplace add <owner>/agency-agents` then
  `/plugin install agency-<division>@agency-agents`.

This branch is force-updated on every source push; treat it as a mirror of the
generated marketplace, not a codebase. See the source repo for documentation.

#!/usr/bin/env bash
#
# bootstrap.sh — convenience wrapper around `grove add` for the
# swift-worktree-agents workflow.
#
# Creates (or attaches to) a worktree for a branch and launches an AI agent in it.
# Grove owns the directory layout; this script is just the thin "add + cd + launch"
# convenience on top, plus hooks for future Apple-specific setup.
#
# Usage:
#   ./bootstrap.sh <branch> [agent]
#
#   <branch>   branch / feature name for the worktree
#   [agent]    command to launch (default: claude). e.g. "claude", "codex", "" (none)
#
# Examples:
#   ./bootstrap.sh feature-auth
#   ./bootstrap.sh bugfix-123 codex
#   ./bootstrap.sh experiment ""     # create worktree only, don't launch an agent
#
# Run this from anywhere inside the project hierarchy — grove discovers the repo.

set -euo pipefail

BRANCH="${1:-}"
AGENT="${2-claude}"   # note: ${2-...} (not :-) so an explicit "" means "no agent"

if [ -z "$BRANCH" ]; then
  echo "usage: $0 <branch> [agent]" >&2
  exit 1
fi

if ! command -v grove >/dev/null 2>&1; then
  echo "error: grove not found. Install with:" >&2
  echo "  curl https://i.safia.sh/captainsafia/grove | sh" >&2
  exit 1
fi

# Create the worktree (grove is idempotent-ish; if it exists, `grove go` still works).
echo ">> grove add $BRANCH"
grove add "$BRANCH" || true

# Resolve the worktree path. Grove places worktrees as siblings named after the branch.
# `grove list` output is parsed loosely; adjust if grove's format changes.
WORKTREE_PATH="$(grove list 2>/dev/null | awk -v b="$BRANCH" '$0 ~ b {print $NF; exit}')"
if [ -z "${WORKTREE_PATH:-}" ] || [ ! -d "$WORKTREE_PATH" ]; then
  # Fallback: assume sibling dir named after the branch under the project root.
  WORKTREE_PATH="$(git rev-parse --show-toplevel 2>/dev/null || echo .)/$BRANCH"
fi

echo ">> worktree at: $WORKTREE_PATH"

# ---------------------------------------------------------------------------
# PLANNED Apple-specific setup hooks. Intentionally no-ops for now — fill these
# in as the docs/ roadmap items get implemented. See docs/ for design notes.
# ---------------------------------------------------------------------------
setup_derived_data() { :; }   # docs/derived-data.md
setup_spm_cache()    { :; }   # docs/spm-caching.md
copy_ignored_files() { :; }   # docs/gitignore-copying.md

setup_derived_data "$WORKTREE_PATH"
setup_spm_cache    "$WORKTREE_PATH"
copy_ignored_files "$WORKTREE_PATH"

# Optionally bring base-dir AI instructions into the worktree if the agent only
# reads CLAUDE.md from its working directory. Uncomment to enable:
# BASE_CLAUDE="$(git rev-parse --show-toplevel)/CLAUDE.md"
# [ -f "$BASE_CLAUDE" ] && [ ! -e "$WORKTREE_PATH/CLAUDE.md" ] && ln -s "$BASE_CLAUDE" "$WORKTREE_PATH/CLAUDE.md"

# Launch the agent (or not).
if [ -n "$AGENT" ]; then
  echo ">> launching '$AGENT' in $WORKTREE_PATH"
  ( cd "$WORKTREE_PATH" && exec "$AGENT" )
else
  echo ">> worktree ready (no agent launched): $WORKTREE_PATH"
fi

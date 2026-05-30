# Copying ignored files into new worktrees (planned)

## The problem

`git worktree add` only materializes *tracked* files. Anything gitignored — `.env`,
`.env.local`, local signing config, scratch files — does not come along. An agent
starting in a fresh worktree may be missing secrets or config it needs.

## Approach: optional `post-checkout` hook

A `post-checkout` git hook fires after any checkout, including worktree creation. It can
copy a defined set of ignored files from the main worktree into the new one. Because it
lives at the git layer, it fires regardless of what created the worktree (Grove, raw
git, Claude Code, etc.).

The hook must detect a *new worktree* (not an ordinary branch switch) by checking that
the previous HEAD argument is the null-ref (all zeros), otherwise it would re-run on
every checkout.

```sh
#!/usr/bin/env sh
# .bare/hooks/post-checkout   (prev_head new_head branch_flag)
prev_head="$1"
if [ "$prev_head" = "0000000000000000000000000000000000000000" ]; then
  # new worktree — copy ignored files listed in .worktree-copy
  : # implement: read .worktree-copy, cp from main worktree
fi
```

Define the copy list (e.g. a `.worktree-copy` file with one path per line:
`.env`, `.env.local`, ...). Wire the actual copy into
`scripts/bootstrap.sh::copy_ignored_files` if you prefer the wrapper over a git hook.

## Status

Deferred — not needed yet. Documented so the design is ready when it is.

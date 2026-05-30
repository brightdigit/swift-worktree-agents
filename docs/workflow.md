# The worktree-per-branch workflow

## The model

Instead of one cloned repo where you switch branches, you keep:

- a **parent directory** named after the repo,
- a **bare clone** in `.bare/` (the git database, no working files),
- **one worktree per branch** as sibling directories.

```
myproject/
├── .bare/            # bare clone
├── .git              # gitdir: ./.bare
├── CLAUDE.md         # base-dir AI instructions
├── main/
├── feature-auth/
└── bugfix-123/
```

Each worktree is a full, independent working directory sharing the same history and
remote. Edits in one never touch another. That isolation is what makes it safe to run
multiple AI agents at once — one per worktree.

## Why Grove drives it

Setting this up by hand has two well-known gotchas: after a bare clone, `git fetch`
won't see remote branches (wrong refspec) and `git branch -u origin/main` fails. Grove
encapsulates the correct bare-clone setup and the add/list/remove/sync/prune lifecycle,
so you don't maintain that logic yourself.

```sh
grove init owner/myproject   # bare clone + main worktree, refspec fixed
grove add feature-auth       # new sibling worktree on a new branch
grove go feature-auth        # cd into it (with shell integration)
grove list                   # see all worktrees
grove sync                   # fetch + update from origin
grove prune                  # clean up stale worktrees
```

## Running agents in parallel

The simplest model: one terminal (or tmux pane) per worktree, each running `claude`.
Because the working directory *is* the branch, the agent's view is naturally scoped.

```sh
# terminal 1
cd myproject/feature-auth && claude

# terminal 2
cd myproject/bugfix-123 && claude
```

`scripts/bootstrap.sh <branch>` collapses the add + cd + launch into one command.

If you later want a TUI that manages several agent sessions for you, Claude Squad or
CCManager sit on top of worktrees and let you flip between running sessions — but they
manage worktree paths themselves, so you'd pick that *or* the Grove-driven layout here,
not both.

## Base-directory AI instructions

`CLAUDE.md` in the parent directory holds shared, branch-independent guidance (build
commands, architecture, worktree etiquette). Whether an agent reads it automatically
depends on the tool: some read up the directory tree, some only read the working dir.
If yours only reads the working dir, symlink the base file into each worktree (see the
commented block in `scripts/bootstrap.sh`). See `templates/CLAUDE.md`.

## Where this stops, and the Apple-specific docs begin

Plain worktrees isolate *files*, not *build state*. Two agents building the same Swift
project will still contend over DerivedData and the SPM cache, and neither carries your
ignored files (`.env`, `Package.resolved` artifacts). Those are the next things to
handle — see:

- `docs/derived-data.md` — per-worktree DerivedData isolation
- `docs/spm-caching.md` — shared SwiftPM cache (you usually want this *shared*, not
  isolated, to avoid redundant recompilation)
- `docs/gitignore-copying.md` — copying ignored files into new worktrees via a
  `post-checkout` git hook

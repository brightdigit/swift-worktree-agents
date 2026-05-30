# swift-worktree-agents

A workflow and toolkit for running parallel AI coding agents (Claude Code, Codex, etc.)
across **git worktrees** in Swift / Apple projects.

The core idea: one parent directory named after the repo, a bare clone inside it, and
**one worktree per branch** as siblings — each worktree being an isolated workspace an
AI agent can run in without stepping on the others.

```
myproject/
├── .bare/            # bare clone (the actual git database)
├── .git              # file pointing at .bare
├── CLAUDE.md         # base-dir AI instructions, shared across worktrees
├── main/             # worktree
├── feature-auth/     # worktree — agent A runs here
└── bugfix-123/       # worktree — agent B runs here
```

## Why this layout

`git clone` + branch-switching forces one working directory and serializes your work.
Worktrees give every branch its own directory, so multiple agents (or you + an agent)
can work fully in parallel. Naming the parent after the repo and keeping the bare clone
in `.bare/` keeps the topology clean and predictable.

This repo does **not** reinvent the worktree CLI. The layout is driven by
[Grove](https://github.com/captainsafia/grove), which already encapsulates exactly this
pattern. What lives here is the **Swift/Apple-specific glue and conventions** that Grove
(and every other generic worktree tool) leaves to you.

## Quick start

```sh
# install grove (once)
curl https://i.safia.sh/captainsafia/grove | sh

# lay out a project
grove init owner/myproject     # creates ./myproject/ with .bare + main worktree
cd myproject

# drop base-dir AI instructions in (see templates/CLAUDE.md)
cp /path/to/swift-worktree-agents/templates/CLAUDE.md .

# spin up a worktree and run an agent in it
grove add feature-auth
cd feature-auth && claude
```

## What's implemented vs. planned

| Area | Status | Notes |
|---|---|---|
| Parent-dir + bare + sibling worktrees | ✅ via Grove | No custom code; Grove owns this |
| Base-dir AI instructions (`CLAUDE.md`) | ✅ template in `templates/` | Shared agent context across worktrees |
| `bootstrap.sh` helper | ✅ skeleton in `scripts/` | Thin convenience wrapper over `grove add` + `claude` |
| Per-worktree DerivedData isolation | 📋 planned | See `docs/derived-data.md` |
| Shared SPM cache | 📋 planned | See `docs/spm-caching.md` |
| Ignored-file copying (`.env`, etc.) | 📋 planned | See `docs/gitignore-copying.md` (post-checkout hook) |

## Repo layout

```
.
├── README.md
├── scripts/
│   └── bootstrap.sh        # convenience: grove add <branch> + cd + launch agent
├── templates/
│   └── CLAUDE.md           # base-dir AI instructions template
└── docs/
    ├── workflow.md         # the worktree-per-branch workflow in depth
    ├── derived-data.md     # (planned) per-worktree DerivedData isolation
    ├── spm-caching.md      # (planned) shared SwiftPM cache strategy
    └── gitignore-copying.md# (planned) copying ignored files into new worktrees
```

## Background

This grew out of a survey of the parallel-AI-agent-on-worktrees tooling landscape
(Grove, Phantom, Worktrunk, Claude Squad, CCManager, Conductor, and Anthropic's native
`claude --worktree`). The conclusion: the generic orchestration problem is solved, but
**Apple-platform worktree hygiene** (DerivedData, SPM caches, simulator/bundle-ID
collisions) is the real remaining gap — and that's what this repo focuses on.

## License

MIT (see LICENSE).

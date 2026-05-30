# Project AI Instructions

> This file lives in the **base directory** of the project (the parent dir that holds
> `.bare/` and all worktrees). Copy or symlink it into each worktree if your agent only
> reads `CLAUDE.md` from its working directory. Keep shared, branch-independent guidance
> here; put branch-specific notes in the worktree's own `CLAUDE.md`.

## Project overview

<!-- One paragraph: what this app/package is, its platforms, its purpose. -->

## Architecture & conventions

<!-- Module layout, key targets, naming conventions, dependency boundaries. -->

## Build & test

```sh
# Package
swift build
swift test

# App (adjust scheme/destination)
xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16' build
xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Worktree etiquette (for agents)

- You are running inside a **git worktree**. Other agents may be working in sibling
  worktrees on different branches. Only touch files in *this* worktree.
- This branch corresponds to a single feature or bug fix. Keep changes scoped to it.
- Do not modify `.bare/` or the base-directory `.git` file.
- Commit on this worktree's branch; do not switch branches inside a worktree.

## Things to avoid

<!-- Known footguns, deprecated APIs, files not to touch, generated code, etc. -->

## Definition of done

<!-- Tests pass, lint clean, docs updated, etc. -->

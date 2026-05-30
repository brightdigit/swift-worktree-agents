# Per-worktree DerivedData isolation (planned)

## The problem

Two agents building the same Swift project at the same time both write to the default
`~/Library/Developer/Xcode/DerivedData/<project>-<hash>`. The hash is derived from the
project path — and since worktrees have *different* paths, Xcode usually gives them
different DerivedData dirs already. But `xcodebuild` invocations, SPM plugin builds, and
shared run-script phases can still collide or thrash, and you may want DerivedData living
*inside* each worktree for cleanliness and easy teardown.

## Why NOT the global "Relative" setting

Xcode → Settings → Locations → Derived Data → **Relative** drops `DerivedData/` inside
every project dir. It works, but:

- it applies to *every* project you open, not just worktree-based ones;
- some tooling/CI assumes the default absolute location;
- you lose cross-worktree module-cache reuse, so every worktree rebuilds cold.

Keep the global setting at default. Scope DerivedData per-worktree at build time instead.

## Approach (to implement)

Set a per-worktree DerivedData path explicitly:

```sh
xcodebuild -scheme MyApp -derivedDataPath "$PWD/.derived" build
```

Or a workspace-level location via `WorkspaceSettings.xcsettings`
(`DerivedDataCustomLocation`) committed per-worktree (gitignored).

Wire this into `scripts/bootstrap.sh::setup_derived_data`. Remember to add `.derived/`
to the worktree `.gitignore`.

## Open questions

- Per-worktree DerivedData vs. shared module cache: can we isolate DerivedData but still
  share the precompiled-module/clang-module cache to cut rebuild cost?
- Simulator + bundle-ID collisions when two app builds run at once (separate concern,
  may warrant its own doc).

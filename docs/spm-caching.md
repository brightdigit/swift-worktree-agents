# Shared SwiftPM cache (planned)

## Key insight: share, don't isolate

Unlike DerivedData, you generally want the SwiftPM caches **shared** across worktrees.
Isolating them means every worktree re-resolves and re-downloads identical dependencies
and rebuilds the same packages — expensive for large graphs (MistKit, Bushel, etc.).

SwiftPM caches of interest:

- `~/.swiftpm` — user-level config and security state
- the dependencies/repository cache (shared package checkouts)
- per-package `.build/` — this one is build *output*, more like DerivedData

## Approach (to implement)

- Point SwiftPM at a shared cache dir so all worktrees reuse downloads/resolution:
  ```sh
  swift build --cache-path "$HOME/.cache/swiftpm" ...
  # and/or the shared repository cache via SWIFTPM_* env / config
  ```
- Symlink or share `Package.resolved` carefully — it is tracked, so usually it just
  comes along with the worktree; no action needed.
- Decide policy on `.build/`: likely per-worktree (it's output), but the *download*
  cache underneath it should be shared.

Wire into `scripts/bootstrap.sh::setup_spm_cache`.

## Open questions

- Exact env vars / flags for the current Swift toolchain to redirect the repository
  cache without breaking reproducibility — verify against the installed Swift version.
- Concurrency: is the shared package cache safe for simultaneous resolves from multiple
  agents, or does it need a lock?

# Contributing

Thanks for your interest in improving Claude Faces Expert!

## Branch model

- **`develop`** — active development branch. **All pull requests must target `develop`.**
- **`main`** — release branch. Only maintainers merge `develop` into `main` to cut a release.

If you open a PR against `main`, you'll be asked to retarget it to `develop`.

## Submitting changes

1. Fork the repository.
2. Create a branch off `develop` for your change (e.g. `feature/my-improvement` or `fix/some-bug`).
3. Make your changes. Keep the scope focused — one logical change per PR.
4. Open a pull request **with `develop` as the base branch**.
5. Describe what changes and *why*. Link related issues if any.

## What kinds of changes are welcome

- New or improved Jakarta Faces rules, examples, or diagnostics in `.claude/faces/`.
- Fixes for incorrect or outdated guidance — please cite the spec section or authoritative source.
- New skills under `.claude/skills/` that complement the existing `/faces-review` and `/faces-migrate`.
- Installer improvements (`install.sh`, `install-opencode.sh`) and tooling support for additional AI coding agents.
- Documentation fixes in `README.md`, `CHANGELOG.md`, or topic files.

## What to avoid

- Sweeping reformatting or renaming changes mixed in with substantive edits — keep them in separate PRs.
- Hallucinated or unverifiable spec claims. If you're unsure, say so in the PR description.
- Unrelated tooling/config changes that aren't tied to the change you're making.

## Releases

Maintainers release by bumping `Version X.Y.Z` across `README.md`, `.claude/faces/rules.md`, all topic files under `.claude/faces/topics/`, and both skill `SKILL.md` files, plus a new `CHANGELOG.md` section. Contributors don't need to touch versions — leave that to the release commit.

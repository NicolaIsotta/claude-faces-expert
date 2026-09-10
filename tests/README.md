# Integration tests

These tests run `/faces-review` against small Faces projects with violations planted on purpose, then check that the report names each planted violation and none of the false positives the rules forbid.

They call the Anthropic API directly and bill your own key, so they are local-only and never run in CI.

## Setup

Create a `.env.local` in the repository root:

```ini
ANTHROPIC_API_KEY=your-anthropic-api-key
```

`.env.*` is gitignored. That is the whole setup. The suite is stdlib Python driving the `claude` CLI, so there is no build step, no virtualenv and nothing to install.

## Running

```sh
./it.sh                              # every fixture
./it.sh faces41-primefaces           # fixtures whose name contains the argument
```

Each run costs roughly $0.30-$0.50 per fixture. Without `ANTHROPIC_API_KEY` the whole suite skips and exits 0.

Reports land in `tests/.reports/<fixture>.md` — read the one for a failing fixture to see what the review actually said.

## Knobs

| Variable | Default | Purpose |
|---|---|---|
| `FACES_IT_MODEL` | `sonnet` | Model running the review |
| `FACES_IT_JUDGE_MODEL` | `claude-haiku-4-5-20251001` | Model grading the report |
| `FACES_IT_REVIEW_BUDGET` | `1.50` | Dollar cap per review |
| `FACES_IT_JUDGE_BUDGET` | `0.25` | Dollar cap per grading |
| `FACES_IT_RETRIES` | `1` | Extra attempts when a fixture's expectations are unmet |
| `FACES_IT_TIMEOUT` | `900` | Seconds allowed per `claude` invocation |

The review runs with `--permission-mode manual`, so anything that would prompt is denied rather than hanging. The skill's own `allowed-tools` (`Read`, `Glob`, `Grep`, `Agent`) cover the review itself, but a subagent reaching for the network to verify an API against the spec is denied — expect the report to mark an API unconfirmed where an interactive run would have looked it up.

A run measures the WORKING TREE. `harness.stage()` copies `.claude/faces` and `.claude/skills` from the repository into a temp copy of the fixture, and points `CLAUDE_CONFIG_DIR` at a throwaway directory, so a user-scope install of the same knowledge base cannot answer for the branch under test.

## Adding a fixture

Create `tests/fixtures/<name>/` with:

- `project/` — a real webapp: `pom.xml`, `WEB-INF/web.xml`, `WEB-INF/faces-config.xml`, `.xhtml` views, backing beans. The fixture is never compiled or deployed; the review reads the files.
- `expected.json` — the checklist.

```json
{
  "faces_version": "4.1",
  "must": [
    { "id": "kebab-case-id", "description": "One sentence naming the construct, the file, and why it is wrong." }
  ],
  "must_not": [
    { "id": "kebab-case-id", "description": "One sentence naming the false positive the report must not contain." }
  ]
}
```

The runner discovers the directory on its own. `faces_version` is asserted directly against the runtime version the report states; the rest is graded by the judge model.

Two things make a fixture worth its cost.

Write each `description` so it can be decided from the report alone. The judge sees the description and the report, never the fixture, so "reports the wrong ajax default" is undecidable where "states that `<p:commandButton>` defaults `process` to `@this`" is not.

Give the fixture more `must_not` entries than feel necessary. A rules edit regresses far more often by producing a new false positive than by dropping a finding, so plant the constructs the rules explicitly bless — a `<p:dialog>` with no `appendTo` inside a form, `managed=true` on a converter with no view-set attributes, a legitimate `immediate="true"` on a `UIInput` — beside the violations, and assert they stay unreported.

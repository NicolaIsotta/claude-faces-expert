# Run integration tests

The integration tests review real Faces projects with `/faces-review` and check that the report names each planted violation and none of the false positives the rules forbid.
They call the Anthropic API on your own key, so they are local-only and never run in CI.

First create a `.env.local` file with the following content:

```ini
ANTHROPIC_API_KEY=your-anthropic-api-key
```

<sup><em>(.env.* files are already excluded via .gitignore)</em></sup>

The tests need nothing beyond the `python3` that ships with your system and the `claude` CLI on your PATH.
There is no build step and nothing to install.

Then ensure that `it.sh` is executable:

```bash
chmod +x it.sh
```

Then run it:

```bash
./it.sh
```

Pass a substring of a fixture name to run just that one:

```bash
./it.sh faces41-primefaces
```

Each fixture prints its verdict and cost as it finishes, and the run ends with a total. The exit code is 0 when every fixture meets its expectations, 1 when any does not, and 2 when the suite could not run at all.

Without `ANTHROPIC_API_KEY` the whole suite skips. A run costs roughly $0.30-$0.50 per fixture.

A run measures the WORKING TREE.
`harness.stage()` copies `.claude/faces` and `.claude/skills` from the repository into a temp copy of the fixture, and points `CLAUDE_CONFIG_DIR` at a throwaway directory, so a user-scope install of the same knowledge base cannot answer for the branch under test.

The review runs with `--permission-mode manual`, so anything that would prompt is denied rather than hanging.
The skill's own `allowed-tools` (`Read`, `Glob`, `Grep`, `Agent`) cover the review itself, but a subagent reaching for the network to verify an API against the spec is denied — expect the report to mark an API unconfirmed where an interactive run would have looked it up.

# Reading a failure

Every run writes the review it graded to `tests/.reports/<fixture>.md`.
When a fixture fails, that file is what the report actually said — read it before changing either the rules or the expectations.

A failure names the unmet expectations from `tests/fixtures/<fixture>/expected.json`:

- `must/<id>` — a violation the rules oblige the skill to report, and the report did not.
- `must_not/<id>` — a false positive the rules oblige the skill to withhold, and the report contained.
- `runtime version` — the report stated a different runtime Faces version than the fixture has.

# Knobs

Every knob is an environment variable, so it combines with `.env.local`:

| Variable | Default | Purpose |
|---|---|---|
| `FACES_IT_MODEL` | `sonnet` | Model running the review |
| `FACES_IT_JUDGE_MODEL` | `claude-haiku-4-5-20251001` | Model grading the report |
| `FACES_IT_REVIEW_BUDGET` | `1.50` | Dollar cap per review |
| `FACES_IT_JUDGE_BUDGET` | `0.25` | Dollar cap per grading |
| `FACES_IT_RETRIES` | `1` | Extra attempts when a fixture's expectations are unmet |
| `FACES_IT_TIMEOUT` | `900` | Seconds allowed per `claude` invocation |

To check that a rule also lands on a smaller model:

```bash
FACES_IT_MODEL=haiku ./it.sh faces41-omnifaces
```

# Adding a fixture

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

The runner discovers the directory on its own.
`faces_version` is asserted directly against the runtime version the report states; the rest is graded by the judge model.

Two things make a fixture worth its cost.

Write each `description` so it can be decided from the report alone.
The judge sees the description and the report, never the fixture, so "reports the wrong ajax default" is undecidable where "states that `<p:commandButton>` defaults `process` to `@this`" is not.

Give the fixture more `must_not` entries than feel necessary.
A rules edit regresses far more often by producing a new false positive than by dropping a finding, so plant the constructs the rules explicitly bless — a `<p:dialog>` with no `appendTo` inside a form, `managed=true` on a converter with no view-set attributes, a legitimate `immediate="true"` on a `UIInput` — beside the violations, and assert they stay unreported.

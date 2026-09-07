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
FACES_IT_MODEL=haiku ./it.sh -k faces41-omnifaces
```

# Adding a fixture

See `tests/README.md`.

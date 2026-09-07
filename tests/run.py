"""Runs the /faces-review integration tests.

    python3 tests/run.py                    # every fixture
    python3 tests/run.py faces41-plain      # fixtures whose name contains the argument

Stdlib only, so it needs nothing beyond the python3 that ships with the system
and the `claude` CLI on PATH. Exits 0 when every fixture meets its expectations,
1 when any does not, and 2 when the suite could not run at all.
"""

import json
import os
import sys
import tempfile
import traceback
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

import harness

TESTS_DIR = Path(__file__).parent
REPO_ROOT = TESTS_DIR.parent
FIXTURES_DIR = TESTS_DIR / "fixtures"
REPORTS_DIR = TESTS_DIR / ".reports"

RETRIES = int(os.environ.get("FACES_IT_RETRIES", "1"))


def discover(pattern: str | None) -> list[Path]:
    fixtures = sorted(p for p in FIXTURES_DIR.iterdir() if (p / "expected.json").is_file())
    return [p for p in fixtures if not pattern or pattern in p.name]


def grade(verdicts: dict, expected: dict) -> list[str]:
    """Compare the judge's verdicts against the fixture's checklist."""
    seen = {v["id"]: v for v in verdicts["verdicts"]}
    failures = []

    detected = verdicts["detected_faces_version"].strip()
    if detected != expected["faces_version"]:
        failures.append(
            f"runtime version: report states {detected or '<none>'!r}, fixture is {expected['faces_version']!r}"
        )

    for key, want in (("must", True), ("must_not", False)):
        for item in expected[key]:
            verdict = seen.get(item["id"])
            if verdict is None:
                failures.append(f"{key}/{item['id']}: judge returned no verdict")
            elif verdict["present"] is not want:
                label = "not reported" if want else "false positive"
                failures.append(f"{key}/{item['id']}: {label} — {verdict['evidence']}")

    return failures


def attempt(fixture: Path, expected: dict) -> tuple[list[str], str, float]:
    with tempfile.TemporaryDirectory() as tmp:
        workdir = Path(tmp)
        project = harness.stage(fixture, REPO_ROOT, workdir)
        config_dir = workdir / "config"

        report, review_cost = harness.review(project, config_dir)
        verdicts, judge_cost = harness.judge(report, expected, config_dir, workdir)

    return grade(verdicts, expected), report, review_cost + judge_cost


def run(fixture: Path) -> tuple[bool, float]:
    expected = json.loads((fixture / "expected.json").read_text())
    cost = 0.0

    for attempts in range(1, RETRIES + 2):
        try:
            failures, report, attempt_cost = attempt(fixture, expected)
        except Exception:
            print(f"  ERROR {fixture.name}")
            traceback.print_exc()
            return False, cost

        cost += attempt_cost
        (REPORTS_DIR / f"{fixture.name}.md").write_text(report)

        if not failures:
            print(f"  PASS  {fixture.name}  ${cost:.4f}  {attempts} attempt(s)")
            return True, cost

    print(f"  FAIL  {fixture.name}  ${cost:.4f}  {attempts} attempt(s)")
    for failure in failures:
        print(f"          {failure}")
    print(f"        full report in {REPORTS_DIR / f'{fixture.name}.md'}")
    return False, cost


def main() -> int:
    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("SKIP: ANTHROPIC_API_KEY is unset; run via ./it.sh with a .env.local")
        return 0

    pattern = sys.argv[1] if len(sys.argv) > 1 else None
    fixtures = discover(pattern)

    if not fixtures:
        print(f"no fixtures match {pattern!r}", file=sys.stderr)
        return 2

    REPORTS_DIR.mkdir(exist_ok=True)
    print(f"running {len(fixtures)} fixture(s)")

    results = [run(fixture) for fixture in fixtures]
    passed = sum(1 for ok, _ in results if ok)
    total_cost = sum(cost for _, cost in results)

    print(f"{passed}/{len(results)} passed  ${total_cost:.4f}")
    return 0 if passed == len(results) else 1


if __name__ == "__main__":
    sys.exit(main())

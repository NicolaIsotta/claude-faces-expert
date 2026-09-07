"""Drives `/faces-review` over a staged fixture and judges the resulting report.

A fixture is a real Faces webapp under `fixtures/<name>/project/` with violations
planted on purpose, plus an `expected.json` naming the findings the report must
contain (`must`) and the false positives it must not (`must_not`).

Each run stages the fixture into a temp directory, copies the WORKING TREE
`.claude/faces` and `.claude/skills` beside it, and points `CLAUDE_CONFIG_DIR` at
a throwaway directory. That combination is what makes the run measure this
branch: `--setting-sources project` resolves the staged skill, and the empty
config directory keeps any user-scope install of the same rules out of context.

Both steps shell out to the `claude` CLI, so the only Python dependency is pytest.
"""

import json
import os
import shutil
import subprocess
from pathlib import Path

REVIEW_MODEL = os.environ.get("FACES_IT_MODEL", "sonnet")
JUDGE_MODEL = os.environ.get("FACES_IT_JUDGE_MODEL", "claude-haiku-4-5-20251001")
REVIEW_BUDGET_USD = os.environ.get("FACES_IT_REVIEW_BUDGET", "1.50")
JUDGE_BUDGET_USD = os.environ.get("FACES_IT_JUDGE_BUDGET", "0.25")
TIMEOUT_SECONDS = int(os.environ.get("FACES_IT_TIMEOUT", "900"))

JUDGE_SCHEMA = {
    "type": "object",
    "properties": {
        "detected_faces_version": {
            "type": "string",
            "description": "The runtime Faces version the report states it detected, e.g. '4.1' or '2.3'. Empty string if the report never states one.",
        },
        "verdicts": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "id": {"type": "string"},
                    "present": {"type": "boolean"},
                    "evidence": {"type": "string"},
                },
                "required": ["id", "present", "evidence"],
            },
        },
    },
    "required": ["detected_faces_version", "verdicts"],
}

JUDGE_PROMPT = """You are grading a Jakarta Faces code review report against a checklist.

For every checklist item, decide whether the report contains a finding matching \
that description. Judge on substance, not wording: the report may name the rule \
differently, or fold the finding into a larger one. A finding counts as present \
only when the report actually asserts it about the code under review; merely \
mentioning the topic in passing does not count.

Return one verdict per checklist id, plus the runtime Faces version the report \
states it detected.

Quote the sentence you based each verdict on in `evidence`, or say what you \
looked for and did not find.

## Checklist

{checklist}

## Report

{report}
"""


def stage(fixture_dir: Path, repo_root: Path, workdir: Path) -> Path:
    """Copy the fixture project and the working-tree knowledge base into workdir."""
    project = workdir / "project"
    shutil.copytree(fixture_dir / "project", project)

    claude = project / ".claude"
    shutil.copytree(repo_root / ".claude" / "faces", claude / "faces")
    shutil.copytree(repo_root / ".claude" / "skills", claude / "skills")

    claude_md = project / "CLAUDE.md"
    if not claude_md.exists():
        claude_md.write_text("# Project Rules\n\nJakarta Faces rules: @.claude/faces/rules.md\n")

    (workdir / "config").mkdir()
    return project


def _run(args: list[str], cwd: Path, config_dir: Path) -> dict:
    env = {**os.environ, "CLAUDE_CONFIG_DIR": str(config_dir)}
    proc = subprocess.run(
        args, cwd=cwd, env=env, capture_output=True, text=True, timeout=TIMEOUT_SECONDS
    )

    try:
        result = json.loads(proc.stdout)
    except json.JSONDecodeError as e:
        raise RuntimeError(
            f"claude exited {proc.returncode} without JSON output\n"
            f"stdout: {proc.stdout[:2000]}\nstderr: {proc.stderr[:2000]}"
        ) from e

    if result.get("is_error"):
        raise RuntimeError(result.get("result") or f"claude exited {proc.returncode}")

    return result


def review(project: Path, config_dir: Path) -> tuple[str, float]:
    """Run /faces-review over the staged project; return the report and its cost."""
    result = _run(
        [
            "claude", "-p", "/faces-review",
            "--setting-sources", "project",
            "--model", REVIEW_MODEL,
            "--output-format", "json",
            "--no-session-persistence",
            "--permission-prompts", "none",
            "--max-budget-usd", REVIEW_BUDGET_USD,
        ],
        cwd=project,
        config_dir=config_dir,
    )

    return result["result"], result.get("total_cost_usd", 0.0)


def judge(report: str, expected: dict, config_dir: Path, cwd: Path) -> tuple[dict, float]:
    """Grade the report against the fixture's checklist; return verdicts and cost."""
    items = [*expected["must"], *expected["must_not"]]
    checklist = "\n".join(f"- `{item['id']}`: {item['description']}" for item in items)

    result = _run(
        [
            "claude", "-p", JUDGE_PROMPT.format(checklist=checklist, report=report),
            "--bare",
            "--model", JUDGE_MODEL,
            "--output-format", "json",
            "--json-schema", json.dumps(JUDGE_SCHEMA),
            "--no-session-persistence",
            "--permission-prompts", "none",
            "--max-budget-usd", JUDGE_BUDGET_USD,
        ],
        cwd=cwd,
        config_dir=config_dir,
    )

    verdict = result["result"]
    return (json.loads(verdict) if isinstance(verdict, str) else verdict), result.get("total_cost_usd", 0.0)

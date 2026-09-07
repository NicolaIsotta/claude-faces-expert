#!/usr/bin/env bash
#
# Runs the /faces-review integration tests against the working tree.
#
# Usage:
#   ./it.sh                      # every fixture
#   ./it.sh faces41-plain        # fixtures whose name contains the argument
#
# Needs nothing beyond python3 and the claude CLI.
# Requires ANTHROPIC_API_KEY in .env.local; see DEVELOPERS.md.

set -a
[ -f .env.local ] && source .env.local
set +a

exec python3 "$(dirname "$0")/tests/run.py" "$@"

#!/bin/sh
#
# Installs Claude Faces Expert for OpenCode.
# This is a wrapper around install.sh that adds OpenCode-specific configuration.
#
# Usage:
#   # Project install (into ./.claude/ + ./opencode.json, default):
#   curl -sL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install-opencode.sh | sh
#
#   # User install (into ~/.claude/ + ~/.config/opencode/opencode.json, applies to all projects):
#   curl -sL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install-opencode.sh | sh -s -- --user
#

set -e

if [ "$1" = "--user" ]; then
    SCOPE="user"
    TARGET="$HOME/.config/opencode"
    curl -fsSL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install.sh | sh -s -- --user
else
    SCOPE="project"
    TARGET="."
    curl -fsSL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install.sh | sh
fi

OPENCODE_JSON="$TARGET/opencode.json"
AGENTS_MD="$TARGET/AGENTS.md"

if [ "$SCOPE" = "user" ]; then
    INSTRUCTIONS="$HOME/.claude/faces/rules.md"
else
    INSTRUCTIONS=".claude/faces/rules.md"
fi

echo "Configuring OpenCode..."

if [ ! -f "$OPENCODE_JSON" ]; then
    mkdir -p "$TARGET"
    printf '{\n  "instructions": ["%s"]\n}\n' "$INSTRUCTIONS" > "$OPENCODE_JSON"
    echo "Created $OPENCODE_JSON"
elif ! grep -qF "$INSTRUCTIONS" "$OPENCODE_JSON"; then
    echo "WARNING: $OPENCODE_JSON already exists. Manual step required:" >&2
    echo '  If "instructions" already exists, append: "'"$INSTRUCTIONS"'"' >&2
    echo '  Otherwise add: "instructions": ["'"$INSTRUCTIONS"'"]' >&2
else
    echo "$OPENCODE_JSON already references Faces rules."
fi

if [ -f "$AGENTS_MD" ] && grep -qF "<!-- BEGIN Jakarta Faces Expert -->" "$AGENTS_MD"; then
    echo "$AGENTS_MD already has the rules inlined by install-codex.sh; skipping pointer."
elif [ ! -f "$AGENTS_MD" ]; then
    printf '# Agent Notes\n\nBefore answering any question about Jakarta Faces (JSF), conceptual ones included, first read `%s` and follow it.\n' "$INSTRUCTIONS" > "$AGENTS_MD"
    echo "Created $AGENTS_MD"
elif ! grep -qF "$INSTRUCTIONS" "$AGENTS_MD"; then
    printf '\n## Jakarta Faces\n\nBefore answering any question about Jakarta Faces (JSF), conceptual ones included, first read `%s` and follow it.\n' "$INSTRUCTIONS" >> "$AGENTS_MD"
    echo "Updated $AGENTS_MD"
else
    echo "$AGENTS_MD already references Faces rules."
fi

echo "OpenCode configuration complete ($SCOPE scope)"
echo ""
echo "Note: AGENTS.md is read by OpenCode, CLAUDE.md by Claude Code."
echo "Both reference the same rules in $INSTRUCTIONS"

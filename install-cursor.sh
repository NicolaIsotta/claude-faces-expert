#!/bin/sh
#
# Installs Claude Faces Expert for Cursor.
# This is a wrapper around install.sh that adds Cursor-specific configuration.
#
# Usage:
#   # Project install (into ./.claude/ + ./.cursor/rules/, default):
#   curl -sL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install-cursor.sh | sh
#
#   # User install (into ~/.claude/, applies to all projects):
#   curl -sL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install-cursor.sh | sh -s -- --user
#

set -e

if [ "$1" = "--user" ]; then
    SCOPE="user"
    INSTRUCTIONS="~/.claude/faces/rules.md"
    curl -fsSL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install.sh | sh -s -- --user
else
    SCOPE="project"
    INSTRUCTIONS=".claude/faces/rules.md"
    curl -fsSL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install.sh | sh
fi

echo "Configuring Cursor..."

if [ "$SCOPE" = "user" ]; then
    echo "WARNING: Cursor has no user-scope rules directory. Manual step required:" >&2
    echo "  Open Customize -> Rules and add this line to User Rules:" >&2
    echo "    Before answering any question about Jakarta Faces (JSF), conceptual ones included, first read $INSTRUCTIONS and follow it." >&2
else
    RULES_MDC=".cursor/rules/jakarta-faces.mdc"

    if [ ! -f "$RULES_MDC" ]; then
        mkdir -p "$(dirname "$RULES_MDC")"
        cat > "$RULES_MDC" <<EOF
---
description: Jakarta Faces (JSF) expert rules
alwaysApply: true
---

@$INSTRUCTIONS
EOF
        echo "Created $RULES_MDC"
    elif ! grep -qF "$INSTRUCTIONS" "$RULES_MDC"; then
        printf '\n@%s\n' "$INSTRUCTIONS" >> "$RULES_MDC"
        echo "Updated $RULES_MDC"
    else
        echo "$RULES_MDC already references Faces rules."
    fi
fi

echo "Cursor configuration complete ($SCOPE scope)"
echo ""
echo "The /faces-review and /faces-migrate skills need no configuration;"
echo "Cursor discovers them in .claude/skills/ and ~/.claude/skills/."

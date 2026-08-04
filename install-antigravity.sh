#!/bin/sh
#
# Installs Claude Faces Expert for Google Antigravity.
# This is a wrapper around install.sh that adds Antigravity-specific configuration.
#
# Antigravity caps a rule file at 12,000 characters, which the knowledge base is
# several times over, so the rule instructs the agent to read .claude/faces/rules.md
# with its file tool rather than inlining it or pulling it in with an @ reference.
#
# Usage:
#   # Project install (into ./.claude/ + ./.agents/rules/ + ./.agents/skills/):
#   curl -sL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install-antigravity.sh | sh
#
#   # User install (into ~/.claude/ + ~/.gemini/GEMINI.md + ~/.gemini/*/skills/):
#   curl -sL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install-antigravity.sh | sh -s -- --user
#

set -e

if [ "$1" = "--user" ]; then
    SCOPE="user"
    INSTRUCTIONS="$HOME/.claude/faces/rules.md"
    SKILLS_SRC="$HOME/.claude/skills"
    curl -fsSL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install.sh | sh -s -- --user
else
    SCOPE="project"
    INSTRUCTIONS=".claude/faces/rules.md"
    SKILLS_SRC=".claude/skills"
    curl -fsSL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install.sh | sh
fi

POINTER="Before answering any question about Jakarta Faces (JSF), conceptual ones included, first read \`$INSTRUCTIONS\` and follow it."

install_skills() {
    mkdir -p "$1"
    cp -r "$SKILLS_SRC/"* "$1/"
    echo "Copied skills to $1/"
}

echo "Configuring Antigravity..."

if [ "$SCOPE" = "user" ]; then
    GEMINI_MD="$HOME/.gemini/GEMINI.md"

    if [ ! -f "$GEMINI_MD" ]; then
        mkdir -p "$(dirname "$GEMINI_MD")"
        printf '# Global Rules\n\n%s\n' "$POINTER" > "$GEMINI_MD"
        echo "Created $GEMINI_MD"
    elif ! grep -qF "$INSTRUCTIONS" "$GEMINI_MD"; then
        printf '\n## Jakarta Faces\n\n%s\n' "$POINTER" >> "$GEMINI_MD"
        echo "Updated $GEMINI_MD"
    else
        echo "$GEMINI_MD already references Faces rules."
    fi

    install_skills "$HOME/.gemini/antigravity/skills"
    install_skills "$HOME/.gemini/config/skills"
else
    RULES_MD=".agents/rules/jakarta-faces.md"

    if [ ! -f "$RULES_MD" ]; then
        mkdir -p "$(dirname "$RULES_MD")"
        cat > "$RULES_MD" <<EOF
---
trigger: always_on
description: Jakarta Faces (JSF) expert rules
---

$POINTER
EOF
        echo "Created $RULES_MD"
    elif ! grep -qF "$INSTRUCTIONS" "$RULES_MD"; then
        printf '\n%s\n' "$POINTER" >> "$RULES_MD"
        echo "Updated $RULES_MD"
    else
        echo "$RULES_MD already references Faces rules."
    fi

    install_skills ".agents/skills"
fi

echo "Antigravity configuration complete ($SCOPE scope)"
echo ""
echo "Antigravity does not read .claude/skills/, so the skills are copied to"
echo "the directories above; re-run this installer to update them."

if [ "$SCOPE" = "user" ]; then
    echo ""
    echo "Note: ~/.gemini/GEMINI.md is shared with the Gemini CLI, which picks the"
    echo "rules up as well."
fi

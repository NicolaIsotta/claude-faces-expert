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

REPO="https://github.com/omnifaces/claude-faces-expert.git"
TMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Check dependencies
command -v git >/dev/null 2>&1 || { echo "Error: git is required but not installed." >&2; exit 1; }

if [ "$1" = "--user" ]; then
    SCOPE="user"
    # Run install.sh in user mode first (installs to ~/.claude/)
    echo "Installing Claude Faces Expert (user scope)..."
    curl -sL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install.sh | sh -s -- --user
    
    OPENCODE_CONFIG_DIR="$HOME/.config/opencode"
    OPENCODE_JSON="$OPENCODE_CONFIG_DIR/opencode.json"
    AGENTS_MD="$OPENCODE_CONFIG_DIR/AGENTS.md"
    CLAUDE_MD="$HOME/.claude/CLAUDE.md"
    INSTRUCTIONS_PATH="~/.claude/faces/rules.md"
else
    SCOPE="project"
    # Run install.sh in project mode first (installs to ./.claude/)
    echo "Installing Claude Faces Expert (project scope)..."
    curl -sL https://raw.githubusercontent.com/omnifaces/claude-faces-expert/main/install.sh | sh
    
    OPENCODE_JSON="./opencode.json"
    AGENTS_MD="./AGENTS.md"
    CLAUDE_MD="./CLAUDE.md"
    INSTRUCTIONS_PATH=".claude/faces/rules.md"
fi

# Create or update opencode.json with merge strategy
echo "Configuring OpenCode..."

if [ -f "$OPENCODE_JSON" ]; then
    # File exists - check if instructions field exists
    if grep -q '"instructions"' "$OPENCODE_JSON"; then
        # instructions field exists - check if our path is already there
        if ! grep -q "$INSTRUCTIONS_PATH" "$OPENCODE_JSON"; then
            # Add our instructions to the array
            # This is a simple sed replacement - assumes instructions is an array
            sed -i.bak "s|\"instructions\":\s*\[|\"instructions\": [\"$INSTRUCTIONS_PATH\", |" "$OPENCODE_JSON"
            rm -f "$OPENCODE_JSON.bak"
            echo "Added instructions to existing $OPENCODE_JSON"
        else
            echo "Instructions already present in $OPENCODE_JSON"
        fi
    else
        # instructions field doesn't exist - add it before the closing brace
        sed -i.bak 's|}\s*$|,\n  "instructions": ["'"$INSTRUCTIONS_PATH"'"]\n}|' "$OPENCODE_JSON"
        rm -f "$OPENCODE_JSON.bak"
        echo "Added instructions field to existing $OPENCODE_JSON"
    fi
else
    # File doesn't exist - create new
    if [ "$SCOPE" = "user" ]; then
        mkdir -p "$OPENCODE_CONFIG_DIR"
    fi
    cat > "$OPENCODE_JSON" << EOF
{
  "instructions": ["$INSTRUCTIONS_PATH"]
}
EOF
    echo "Created $OPENCODE_JSON"
fi

# Create or update AGENTS.md
if [ -f "$AGENTS_MD" ]; then
    if ! grep -q "@.claude/faces/rules.md" "$AGENTS_MD" && ! grep -q "@~/.claude/faces/rules.md" "$AGENTS_MD"; then
        printf "\n## Jakarta Faces\n\nSee [%s](%s) for Jakarta Faces expert rules.\n\nJakarta Faces rules: @%s\n" "$CLAUDE_MD" "$CLAUDE_MD" "$INSTRUCTIONS_PATH" >> "$AGENTS_MD"
        echo "Updated $AGENTS_MD"
    else
        echo "$AGENTS_MD already references Faces rules"
    fi
else
    cat > "$AGENTS_MD" << EOF
# Agent Notes

See [$CLAUDE_MD]($CLAUDE_MD) for Jakarta Faces expert rules.

Jakarta Faces rules: @$INSTRUCTIONS_PATH
EOF
    echo "Created $AGENTS_MD"
fi

echo "OpenCode configuration complete ($SCOPE scope)"
echo ""
echo "Files configured:"
echo "  - $OPENCODE_JSON"
echo "  - $AGENTS_MD"
echo "  - $CLAUDE_MD (via install.sh)"
echo "  - .claude/faces/ (via install.sh)"

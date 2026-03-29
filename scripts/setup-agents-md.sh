#!/bin/bash
# Add MuninnDB instructions to agents.md
# Usage: setup-agents-md.sh [directory|file]
# If a file is passed, use that. If a directory is passed, use directory/agents.md
# If nothing passed, uses current directory

TARGET="${1:-.}"

# If TARGET is a file, use it directly. If directory, append agents.md
if [ -f "$TARGET" ]; then
    AGENTS_MD="$TARGET"
elif [ -d "$TARGET" ]; then
    AGENTS_MD="$TARGET/agents.md"
else
    # Assume it's a path, use as directory
    AGENTS_MD="$TARGET/agents.md"
fi

# MuninnDB instructions to add
MUNINN_SECTION='## MuninnDB Memory

Before responding to user queries, proactively check MuninnDB for relevant knowledge:
- Query the project vault (or vaults defined below) for context related to the task
- If information is not known, state that clearly rather than guessing
- Use MuninnDB recall to find relevant memories before answering

### Vaults
- default'

# Check if agents.md exists
if [ ! -f "$AGENTS_MD" ]; then
    echo "Creating $AGENTS_MD with MuninnDB instructions..."
    echo "$MUNINN_SECTION" > "$AGENTS_MD"
    echo "Created $AGENTS_MD"
    exit 0
fi

# Check if MuninnDB section already exists
if grep -q "## MuninnDB Memory" "$AGENTS_MD"; then
    echo "MuninnDB section already exists in $AGENTS_MD"
    exit 0
fi

# Append MuninnDB section
echo "" >> "$AGENTS_MD"
echo "$MUNINN_SECTION" >> "$AGENTS_MD"
echo "Added MuninnDB section to $AGENTS_MD"

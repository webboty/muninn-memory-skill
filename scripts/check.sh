#!/bin/bash
# MuninnDB Check Script - checks if MuninnDB is installed and running

MUNINN_PATH=""
RUNNING=false

# Check if muninn is installed
if command -v muninn &> /dev/null; then
    MUNINN_PATH=$(command -v muninn)
elif [ -x "$HOME/.local/bin/muninn" ]; then
    MUNINN_PATH="$HOME/.local/bin/muninn"
elif [ -x "/usr/local/bin/muninn" ]; then
    MUNINN_PATH="/usr/local/bin/muninn"
fi

# Check if running
if curl -s http://localhost:8475/api/stats &>/dev/null; then
    RUNNING=true
fi

# Output status
if [ -n "$MUNINN_PATH" ]; then
    echo "INSTALLED: $MUNINN_PATH"
else
    echo "INSTALLED: false"
fi

if [ "$RUNNING" = true ]; then
    echo "RUNNING: true"
else
    echo "RUNNING: false"
fi

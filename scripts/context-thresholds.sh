#!/usr/bin/env bash
# context-thresholds.sh — shared config for context monitoring hooks
# Source this file from context-prompt-check.sh and context-monitor.sh
# to keep thresholds in one place.

CONTEXT_WARN_PCT=40      # UserPromptSubmit: ask user to wrap
CONTEXT_EMERGENCY_PCT=70 # PostToolUse: hard stop

#!/usr/bin/env bash
# Preserve the command's failure while retaining readable evidence for CI.
set -uo pipefail
log_path=$1
shift
mkdir -p "$(dirname "$log_path")"
"$@" 2>&1 | tee "$log_path"
command_exit=${PIPESTATUS[0]}
printf '\nexit=%s\n' "$command_exit" | tee -a "$log_path"
exit "$command_exit"

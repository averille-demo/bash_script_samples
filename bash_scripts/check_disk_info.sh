#!/bin/bash
# updated: 2023-02-25
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
ROOT_CWD=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
printf "%s starting: %s\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")"
LOG_FILE="$ROOT_CWD/script_output/${SCRIPT_NAME::-3}_output.log"
mkdir -p "$(dirname "$LOG_FILE")"

USER_HOST="$(whoami)@$(hostname)"
COMMANDS=("udisksctl status"  "sudo blkid" "cat /etc/fstab")
printf "running %02d commands on %s\n" "${#COMMANDS[@]}" "$(hostname)"| tee "$LOG_FILE"

for CMD in "${COMMANDS[@]}"; do
    printf "\n%s: %s\n" "$USER_HOST" "$CMD" | tee -a "$LOG_FILE"
    eval "$CMD" | tee -a "$LOG_FILE"
done

printf "%s completed: %s\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")"

#!/bin/bash
# updated: 2022-03-01
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
ROOT_CWD=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
printf "%s starting: %s\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")"
LOG_FILE="$ROOT_CWD/script_output/${SCRIPT_NAME::-3}_output.log"
mkdir -p "$(dirname "$LOG_FILE")"

USER_HOST="$(whoami)@$(hostname)"
SERVICES=("docker" "openvpn" "ssh" "ufw")
printf "checking %d services on %s\n" "${#SERVICES[@]}" "$USER_HOST"| tee "$LOG_FILE"

for SERVICE in "${SERVICES[@]}"; do
    CMD_STR="sudo systemctl status -l $SERVICE.service --no-pager"
    printf "\n%s: %s\n" "$USER_HOST" "$CMD_STR" | tee -a "$LOG_FILE"
    # run command in shell
    eval "$CMD_STR" | tee -a "$LOG_FILE"
done

printf "%s completed: %s\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")"

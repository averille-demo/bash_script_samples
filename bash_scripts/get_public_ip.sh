#!/usr/bin/env bash
# updated: 2023-03-01
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
ROOT_CWD=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LOG_FILE="$ROOT_CWD/script_output/${SCRIPT_NAME::-3}_output.log"
mkdir -p "$(dirname "$LOG_FILE")"

# dependency
# sudo apt-get install jq -y

EXTERNAL_IP="$(curl --silent ifconfig.co)"
printf " ip_address: %s\n" "$EXTERNAL_IP" | tee "$LOG_FILE"

GEOLOCATION="$(curl --silent http://ip-api.com/json/ | jq .)"
printf "geolocation: %s\n" "$GEOLOCATION" | tee -a "$LOG_FILE"

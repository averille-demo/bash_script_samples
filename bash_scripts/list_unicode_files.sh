#!/bin/bash
# updated: 2022-03-01
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
ROOT_CWD=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
printf "%s starting: %s\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")"
LOG_FILE="$ROOT_CWD/script_output/${SCRIPT_NAME::-3}_output.log"
mkdir -p "$(dirname "$LOG_FILE")"

printf "searching non-ASCII chars in filenames:\n%s\n" "$ROOT_CWD" | tee "$LOG_FILE"
START=$(date +%s.%N)
COUNTER=0
N_FOLDERS="${#SUBFOLDER_PATH_LIST[@]}"

ROOT_PATHS=("$(find "$ROOT_CWD" -maxdepth 1 -type d -exec readlink -f {} \; | sort)")
# split into array on newlines
readarray -t SUBFOLDER_PATH_LIST <<< "${ROOT_PATHS[@]}"
printf "found %d directories\n" "${#SUBFOLDER_PATH_LIST[@]}"

for DIR_PATH in "${SUBFOLDER_PATH_LIST[@]}"
do
    ((COUNTER++))
    printf "  folder_%02d_of_%02d: %s\n" "$COUNTER" "$N_FOLDERS" "$DIR_PATH" | tee -a "$LOG_FILE"
    NON_ASCII_PATH="$(LC_ALL=C find "$DIR_PATH" -maxdepth 1 -type f -name '*[! -~]*')"
    PATH_LEN=${#NON_ASCII_PATH}
    if [ "$PATH_LEN" -gt 4 ]
    then
        printf "    %s\n" "$(basename -- "$NON_ASCII_PATH")" | tee -a "$LOG_FILE"
        # optional: remove invalid chars
        # https://linux.die.net/man/1/detox
        # detox -v "$NON_ASCII_PATH"
    fi
done

END=$(date +%s.%N)
BENCHMARK=$(echo "$END" - "$START" | bc)
printf "%s completed: %s (%0.03f seconds)\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")" "$BENCHMARK"

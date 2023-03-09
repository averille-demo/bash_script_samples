#!/usr/bin/env bash
# updated: 2023-02-08
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
ROOT_CWD=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
printf "%s starting: %s\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")"
LOG_FILE="$ROOT_CWD/script_output/${SCRIPT_NAME::-3}_output.log"
mkdir -p "$(dirname "$LOG_FILE")"

# dependency
# sudo apt-get install dos2unix -y
USER=sysadmin
GROUP=sysadmin
FILE_PERM_LEVEL=0660
DIR_PERM_LEVEL=0770
SCRIPT_PERM_LEVEL=0770
USER_ID="$(getent passwd "$(whoami)" | cut -d: -f3)"

printf "
user: %s:%s
files:   %s
dirs:    %s
scripts: %s
perms:
  0 = ---
  1 = --x
  2 = -w-
  3 = -wx
  4 = r-
  5 = r-x
  6 = rw-
  7 = rwx
" "$USER" "$USER_ID" "$FILE_PERM_LEVEL" "$DIR_PERM_LEVEL" "$SCRIPT_PERM_LEVEL"

# resolve symbolic links
ROOT_PATHS=("$(find "$ROOT_CWD" -maxdepth 1 -type d -exec readlink -f {} \; | sort)")
# split into array on newlines
readarray -t SUBFOLDER_PATH_LIST <<< "${ROOT_PATHS[@]}"

# add whitespace padding for string formatting
PADDING="                                           "
COUNTER=0
N_FOLDERS="${#SUBFOLDER_PATH_LIST[@]}"

for FOLDER in "${SUBFOLDER_PATH_LIST[@]}"
do
    START=$(date +%s.%N)
    ((COUNTER++))
    cd "$FOLDER" || return
    FOLDER_NAME=$(basename "$FOLDER")

    printf "\nprocessing: '%s'\n" "$FOLDER_NAME"
    # fix ownership/groups (recursively)
    sudo chgrp -R "$GROUP" "$FOLDER"
    sudo chown -R "$USER":"$GROUP" "$FOLDER"

    # fix folder permissions (recursively)
    sudo find "$FOLDER" -type d -exec chmod -R "$DIR_PERM_LEVEL" {} \;
    # fix file permissions (recursively)
    sudo find "$FOLDER" -type f -name "*" -exec chmod -R "$FILE_PERM_LEVEL" {} \;
    sudo find "$FOLDER" -type f -name "*.sh" -exec chmod -R "$SCRIPT_PERM_LEVEL" {} \;

    # flip windows newlines to LF
    sudo find . -type f -name "*.log" -exec dos2unix {} \;

    END=$(date +%s.%N)
    BENCHMARK=$(echo "$END" - "$START" | bc)
    stat -c "%A %a  %U:%u   %n   (%s bytes)" ./*
    printf "processed: %03d_of_%03d\t '%s'%s (%0.03f seconds)\n" "$COUNTER" "$N_FOLDERS" "$FOLDER_NAME" "${PADDING:${#FOLDER_NAME}}" "$BENCHMARK"
done

printf "%s completed: %s\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")"

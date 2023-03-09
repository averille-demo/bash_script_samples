#!/usr/bin/env bash
# updated: 2022-02-03
SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
ROOT_CWD=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
printf "%s starting: %s\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")"
LOG_FILE="$ROOT_CWD/script_output/${SCRIPT_NAME::-3}_output.log"
mkdir -p "$(dirname "$LOG_FILE")"

printf "%s starting: %s\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")"

# resolve symbolic links
ROOT_PATHS=("$(find "$ROOT_CWD" -maxdepth 1 -type d -exec readlink -f {} \; | sort)")
# split into array on newlines
readarray -t SUBFOLDER_PATH_LIST <<< "${ROOT_PATHS[@]}"
# remove first project path
unset "SUBFOLDER_PATH_LIST[0]"

# parent level hidden folders
declare -a SKIP_SUBSTRINGS=( "lost+found" ".Trash-" "RECYCLE.BIN" "System Volume Information" )
COUNTER=0
PADDING="             "

printf "source_folder: %s\n" "$ROOT_CWD" | tee "$LOG_FILE"

for FOLDER in "${SUBFOLDER_PATH_LIST[@]}"
do
    FOLDER_NAME=$(basename "$FOLDER")
    # default: include folder unless in skip list
    IS_VALID=true
    for substr in "${SKIP_SUBSTRINGS[@]}"
    do
        # wildcard substring pattern match
        if [[ "$FOLDER_NAME" == *"$substr"* ]]; then
            printf "    ignore: '%s'\n" "$FOLDER_NAME"
            # stop on first match
            IS_VALID=false
            break
        fi
    done

    if $IS_VALID; then
        ((COUNTER++))
        cd "$FOLDER" || return
        # ignore developer subfolders
        FILE_EXTENSIONS="$(find . -type f -not -path '*/.git/*' -not -path '*/.venv/*' -not -path '*/node_modules/*' -not -path '*static*'  | grep -i -E -o "\.\w*$" | sort | uniq -c)"
        readarray -t FILE_EXT_LIST <<< "${FILE_EXTENSIONS[@]}"
        MAX_LEN="${#FILE_EXT_LIST[@]}"
        printf "\n%s: (%d extensions)\n" "$FOLDER_NAME" "$MAX_LEN" | tee -a "$LOG_FILE"
        for n_file_ext in "${FILE_EXT_LIST[@]}"
        do
            # internal field separator: word splitting on whitespace
            IFS=' ' read -ra NFE_ARR <<< "$n_file_ext"
            unique_count="${NFE_ARR[0]}"
            file_ext="${NFE_ARR[1]}"
            printf "   (%s)%s%s\n" "$unique_count" "${PADDING:${#unique_count}}" "$file_ext" | tee -a "$LOG_FILE"
        done
      fi
done

printf "%s completed: %s\n" "$SCRIPT_NAME" "$(date "+%Y-%m-%d %H:%M:%S %p")"

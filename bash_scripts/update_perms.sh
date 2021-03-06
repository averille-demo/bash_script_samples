#!/usr/bin/env bash
CURR_PWD="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
printf "%s %s\n" "${BASH_SOURCE[0]}"

USER=sysadmin
GROUP=t330-admins
FILE_PERM_LEVEL=0660
DIR_PERM_LEVEL=0770
SCRIPT_PERM_LEVEL=0770

printf "
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
" "$FILE_PERM_LEVEL" "$DIR_PERM_LEVEL" "$SCRIPT_PERM_LEVEL"

# ls -d $(pwd)/*/
PWD_DIRS_ARR=("$(find "$CURR_PWD" -type d -exec readlink -f {} \;)")
#PWD_DIRS_ARR=("$(ls -d "$CURR_PWD"/*/)")
# split array on newlines
readarray -t SPLIT_ARR <<< "${PWD_DIRS_ARR[@]}"
#SPLIT_ARR=(${PWD_DIRS_ARR//$'\n'/ })

for SHARE in "${SPLIT_ARR[@]}"
do
    cd "$SHARE" || return
    printf "\nupdating: '%s'\n" "$SHARE"
    sudo chgrp -R "$GROUP" "$SHARE"
    sudo chown -R "$USER":"$GROUP" "$SHARE"
    #sudo find $INPUT_DIR -type f -name "*.sh" -exec dos2unix {} \;
    #sudo find $INPUT_DIR -type f -name "*.txt" -exec dos2unix {} \;
    sudo find "$SHARE" -type d -exec chmod -R "$DIR_PERM_LEVEL" {} \;
    sudo find "$SHARE" -type f -name "*" -exec chmod -R "$FILE_PERM_LEVEL" {} \;
    sudo find "$SHARE" -type f -name "*.sh" -exec chmod -R "$SCRIPT_PERM_LEVEL" {} \;
    ls -al
done

printf "%s complete...\n" "${BASH_SOURCE[0]}"

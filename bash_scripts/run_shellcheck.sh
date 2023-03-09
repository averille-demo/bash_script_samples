#!/usr/bin/env bash
# updated: 2023-03-01

# change into current working directory, regardless where script is called
cd "$(dirname "${BASH_SOURCE[0]}")" || exit

# https://www.mankier.com/1/shellcheck
SHELLCHECK_CMD="shellcheck -x -C -s bash -f gcc ./*.sh"
printf "%s\n" "$SHELLCHECK_CMD"
eval "$SHELLCHECK_CMD"

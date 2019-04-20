#!/usr/bin/env bash
set -Eeuxo pipefail

# Move files to the Trash folder instead of deleting.

trash_dir="${HOME}/.Trash/"
if [[ -d "$trash_dir" ]]
then
    mkdir -p "$trash_dir"
fi
mv "$@" "$trash_dir"
unset -v trash_dir

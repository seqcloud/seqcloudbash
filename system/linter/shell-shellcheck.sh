#!/usr/bin/env bash
set -Eeu -o pipefail

# Recursively run shellcheck on all scripts in a directory.
# Updated 2019-10-07.

# shellcheck source=/dev/null
source "${KOOPA_HOME}/shell/posix/include/functions.sh"

script_bn="$(_acid_basename_sans_ext "$0")"

# Skip test if shellcheck is not installed.
# Currently, Travis CI does not have shellcheck installed for macOS.
if ! _acid_is_installed shellcheck
then
    printf "NOTE | %s\n" "$script_bn"
    printf "     |   shellcheck missing.\n"
    exit 0
fi

path="${1:-$KOOPA_HOME}"

exclude_dirs=(
    "${KOOPA_HOME}/cellar"
    "${KOOPA_HOME}/conda"
    "${KOOPA_HOME}/dotfiles"
    "${KOOPA_HOME}/shell/zsh/functions"
    ".git"
)

# Full path exclusion seems to only work on macOS.
if ! _acid_is_darwin
then
    for i in "${!exclude_dirs[@]}"
    do
        exclude_dirs[$i]="$(basename "${exclude_dirs[$i]}")"
    done
fi

# Prepend the '--exclude-dir=' flag.
exclude_dirs=("${exclude_dirs[@]/#/--exclude-dir=}")

# This step recursively grep matches files with regular expressions.
# Here we're checking for the shebang, rather than relying on file extension.
grep -Elr \
    --binary-files="without-match" \
    "${exclude_dirs[@]}" \
    '^#!/.*\b(ba)?sh\b$' \
    "$path" | \
    xargs -I {} shellcheck -x {}

printf "  OK | %s\n" "$script_bn"
exit 0

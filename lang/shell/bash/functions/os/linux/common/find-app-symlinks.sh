#!/usr/bin/env bash

# FIXME Confirm that this works, after changing koopa::find.
koopa::linux_find_app_symlinks() { # {{{1
    # """
    # Find application symlinks.
    # @note Updated 2022-02-17.
    # """
    local app dict symlink symlinks
    koopa::assert_has_args_le "$#" 2
    declare -A app=(
        [grep]="$(koopa::locate_grep)"
        [realpath]="$(koopa::locate_realpath)"
        [sort]="$(koopa::locate_sort)"
        [tail]="$(koopa::locate_tail)"
        [xargs]="$(koopa::locate_xargs)"
    )
    declare -A dict=(
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [make_prefix]="$(koopa::make_prefix)"
        [name]="${1:?}"
        [version]="${2:-}"
    )
    # Automatically detect version, if left unset.
    dict[app_prefix]="$(koopa::app_prefix)/${dict[name]}"
    koopa::assert_is_dir "${dict[app_prefix]}"
    if [[ -n "${dict[version]}" ]]
    then
        dict[app_prefix]="${dict[app_prefix]}/${dict[version]}"
    else
        dict[app_prefix]="$( \
            koopa::find \
                --max-depth=1 \
                --prefix="${dict[app_prefix]}" \
                --sort \
                --type='d' \
            | "${app[tail]}" -n 1 \
        )"
    fi
    koopa::assert_is_dir "${dict[app_prefix]}"
    readarray -t -d '' symlinks < <(
        koopa::find \
            --prefix="${dict[make_prefix]}" \
            --print0 \
            --type='l' \
        | "${app[xargs]}" \
            --no-run-if-empty \
            --null \
            "${app[realpath]}" --zero \
        | "${app[grep]}" \
            --extended-regexp \
            --null \
            --null-data \
            "^${dict[app_prefix]}/" \
        | "${app[sort]}" --zero-terminated \
    )
    if koopa::is_array_empty "${symlinks[@]}"
    then
        koopa::stop "Failed to find symlinks for '${dict[name]}'."
    fi
    for symlink in "${symlinks[@]}"
    do
        koopa::print "${symlink//${dict[app_prefix]}/${dict[make_prefix]}}"
    done
    return 0
}

#!/usr/bin/env bash

main() {
    # """
    # Install Fish shell.
    # @note Updated 2022-08-11.
    #
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    koopa_activate_opt_prefix 'ncurses'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
    )
    [[ -x "${app[cmake]}" ]] || return 1
    declare -A dict=(
        [bin_prefix]="$(koopa_bin_prefix)"
        [jobs]="$(koopa_cpu_count)"
        [name]='fish'
        [prefix]="${INSTALL_PREFIX:?}"
        [shared_ext]="$(koopa_shared_ext)"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[ncurses]="$(koopa_app_prefix 'ncurses')"
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://github.com/${dict[name]}-shell/${dict[name]}-shell/\
releases/download/${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
        "-DCURSES_INCLUDE_PATH=${dict[ncurses]}/include"
        "-DCURSES_LIBRARY=${dict[ncurses]}/lib/libncursesw.${dict[shared_ext]}"
    )
    "${app[cmake]}" \
        -S '.' \
        -B 'build' \
        "${cmake_args[@]}"
    "${app[cmake]}" \
        --build 'build' \
        --parallel "${dict[jobs]}"
    "${app[cmake]}" --install 'build'
    if koopa_is_shared_install
    then
        koopa_enable_shell_for_all_users "${dict[bin_prefix]}/${dict[name]}"
    fi
    return 0
}

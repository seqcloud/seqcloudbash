#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install rsync.
    # @note Updated 2022-04-11.
    #
    # @seealso
    # - https://github.com/WayneD/rsync/blob/master/INSTALL.md
     # - https://bugs.gentoo.org/729186
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='rsync'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://download.samba.org/pub/${dict[name]}/src/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-lz4'
        '--disable-openssl'
        '--disable-xxhash'
        '--disable-zstd'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

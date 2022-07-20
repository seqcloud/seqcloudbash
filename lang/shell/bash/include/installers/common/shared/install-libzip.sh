#!/usr/bin/env bash

# Consider requiring: liblzma, zstd, and xz?.

main() {
    # """
    # Install libzip.
    # @note Updated 2022-07-20.
    #
    # @seealso
    # - https://libzip.org/download/
    # - https://noknow.info/it/os/install_libzip_from_source?lang=en
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake' 'pkg-config'
    koopa_activate_opt_prefix \
        'zlib' \
        'nettle' \
        'openssl3' \
        'perl' \
        'zstd'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[cmake]}" ]] || return 1
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libzip'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://libzip.org/download/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
    )
    if koopa_is_linux
    then
        dict[zlib]="$(koopa_realpath "${dict[opt_prefix]}/zlib")"
        cmake_args+=(
            "-DZLIB_INCLUDE_DIR=${dict[zlib]}/include"
            "-DZLIB_LIBRARY=${dict[zlib]}/lib/libz.so"
        )
    fi
    "${app[cmake]}" .. "${cmake_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

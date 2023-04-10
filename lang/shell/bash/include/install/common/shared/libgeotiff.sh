#!/usr/bin/env bash

main() {
    # """
    # Install libgeotiff.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/OSGeo/libgeotiff
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     libgeotiff.rb
    # """
    local -A app dict
    koopa_activate_app --build-only \
        'libtool' \
        'make' \
        'pkg-config'
    koopa_activate_app \
        'curl' \
        'zlib' \
        'zstd' \
        'libjpeg-turbo' \
        'libtiff' \
        'sqlite' \
        'proj'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='libgeotiff'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://github.com/OSGeo/${dict['name']}/releases/download/\
${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        '--disable-dependency-tracking'
        "--prefix=${dict['prefix']}"
        '--with-jpeg'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

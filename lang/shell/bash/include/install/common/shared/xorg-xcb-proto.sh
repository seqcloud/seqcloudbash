#!/usr/bin/env bash

main() {
    # """
    # Install xcb-proto.
    # @note Updated 2022-04-26.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/xcb-proto.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config' 'python'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='xcb-proto'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://xorg.freedesktop.org/archive/individual/\
proto/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-silent-rules'
        'PYTHON=python3'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

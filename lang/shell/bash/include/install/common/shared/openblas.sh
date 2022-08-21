#!/usr/bin/env bash

main() {
    # """
    # Install OpenBLAS.
    # @note Updated 2022-08-16.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     openblas.rb
    # - https://ports.macports.org/port/OpenBLAS/details/
    # - https://iq.opengenus.org/install-openblas-from-source/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix 'gcc'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        [name]='OpenBLAS'
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict['version']}.tar.gz"
    dict[url]="https://github.com/xianyi/${dict['name']}/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    "${app['make']}" \
        --jobs="${dict['jobs']}" \
        'FC=gfortran' \
        'libs' 'netlib' 'shared'
    "${app['make']}" "PREFIX=${dict['prefix']}" install
    return 0
}

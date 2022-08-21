#!/usr/bin/env bash

main() {
    # """
    # Install HDF5.
    # @note Updated 2022-08-12.
    #
    # Using gcc here for gfortran.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'zlib' 'gcc'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='hdf5'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
        [zlib]="$(koopa_app_prefix 'zlib')"
    )
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict['version']}")"
    dict[file]="${dict['name']}-${dict['version']}.tar.gz"
    dict[url]="https://support.hdfgroup.org/ftp/HDF5/releases/\
${dict['name']}-${dict['maj_min_ver']}/${dict['name']}-${dict['version']}/\
src/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-build-mode=production'
        '--enable-cxx'
        '--enable-fortran'
        "--with-zlib=${dict['zlib']}"
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # > "${app['make']}" check
    "${app['make']}" install
    return 0
}

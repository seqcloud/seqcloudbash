#!/usr/bin/env bash

# NOTE This is currently failing to build on Ubuntu 20.

# FIXME Consider installing:
# - boost 1.54
# - cmake 2.8.0

main() {
    # """
    # Install bcl2fastq from source.
    # @note Updated 2022-03-14.
    #
    # This uses CMake to install.
    # ARM is not yet supported for this.
    #
    # @seealso
    # - https://gist.github.com/jblachly/f8dc0f328d66659d9ee005548a5a2d2e
    # - https://sarahpenir.github.io/linux/Installing-bcl2fastq/
    # - https://github.com/rossigng/easybuild-easyconfigs/blob/main/
    #     easybuild/easyconfigs/b/bcl2fastq2/
    # - https://github.com/perllb/ctg-wgs/blob/master/
    #     container/ngs-tools-builder
    # - https://github.com/AlexsLemonade/alsf-scpca/blob/main/images/
    #     cellranger/install-bcl2fastq.sh
    # """
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_not_aarch64
    deps=('zlib' 'ncurses' 'openssl3')
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['make']="$(koopa_locate_make)"
        ['python']="$(koopa_locate_python311 --realpath)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['icu4c']="$(koopa_app_prefix 'icu4c')"
        ['installers_base']="$(koopa_private_installers_s3_uri)"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='bcl2fastq'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['c_include_path']="/usr/include/${dict['arch']}-linux-gnu"
    koopa_assert_is_dir "${dict['c_include_path']}"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['file']="${dict['version']}.tar.zip"
    dict['url']="${dict['installers_base']}/${dict['name']}/src/${dict['file']}"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_extract "${dict['name']}${dict['maj_ver']}-"*"-Source.tar.gz"
    # Install CMake 2.8.9 from redist.
    (
        local bootstrap_args
        bootstrap_args=(
            "--parallel=${dict['jobs']}"
            "--prefix=${dict['libexec']}/cmake"
            '--'
            '-DCMAKE_BUILD_TYPE=RELEASE'
            "-DCMAKE_PREFIX_PATH=${dict['openssl']}"
        )
        koopa_cp \
            'bcl2fastq/redist/cmake-2.8.9.tar.gz' \
            'cmake-2.8.9.tar.gz'
        koopa_extract 'cmake-2.8.9.tar.gz'
        koopa_cd 'cmake-2.8.9'
        ./bootstrap "${bootstrap_args[@]}"
        "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
        "${app['make']}" install
    )
    # Install Boost 1.54.0 from redist.
    (
        local b2_args bootstrap_args
        bootstrap_args=(
            "--prefix=${dict['libexec']}/boost"
            "--with-icu=${dict['icu4c']}"
            "--with-python=${app['python']}"
        )
        b2_args=(
            "--prefix=${dict['libexec']}/boost"
            '-d2'
            "-j${dict['jobs']}"
            'install'
            'link=static'
            'threading=multi'
        )
        koopa_cp \
            'bcl2fastq/redist/boost_1_54_0.tar.bz2' \
            'boost_1_54_0.tar.bz2'
        koopa_extract 'boost_1_54_0.tar.bz2'
        koopa_cd 'boost_1_54_0'
        ./bootstrap.sh "${bootstrap_args[@]}"
        ./b2 headers
        ./b2 "${b2_args[@]}"
    )
    koopa_cd "${dict['name']}"
    koopa_mkdir "${dict['name']}-build"
    koopa_cd "${dict['name']}-build"
    export C_INCLUDE_PATH="${dict['c_include_path']}"
    koopa_print_env
    conf_args=(
        '--build-type=Release'
        "--parallel=${dict['jobs']}"
        "--prefix=${dict['prefix']}"
        '--verbose'
        "--with-cmake=${dict['libexec']}/cmake/bin/cmake"
        '--without-unit-tests'
        "BOOST_ROOT=${dict['libexec']}/boost"
    )
    ../src/configure --help
    ../src/configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    koopa_rm "${dict['prefix']}/bin/test"
    return 0
}

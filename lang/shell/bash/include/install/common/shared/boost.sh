#!/usr/bin/env bash

main() {
    # """
    # Install Boost library.
    # @note Updated 2023-03-14.
    #
    # @seealso
    # - https://www.boost.org/users/download/
    # - https://github.com/conda-forge/boost-feedstock/blob/main/recipe/build.sh
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/boost.rb
    # """
    local b2_args bootstrap_args deps dict
    koopa_assert_has_no_args "$#"
    deps=(
        'bzip2'
        'icu4c'
        'xz'
        'zlib'
        'zstd'
    )
    koopa_activate_app "${deps[@]}"
    declare -A dict=(
        ['icu4c']="$(koopa_app_prefix 'icu4c')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='boost'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    if koopa_is_macos
    then
        dict['toolset']='clang'
    else
        dict['toolset']='gcc'
    fi
    dict['snake_version']="$(koopa_snake_case_simple "${dict['version']}")"
    dict['file']="${dict['name']}_${dict['snake_version']}.tar.bz2"
    dict['url']="https://boostorg.jfrog.io/artifactory/main/release/\
${dict['version']}/source/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}_${dict['snake_version']}"
    bootstrap_args=(
        "--prefix=${dict['prefix']}"
        "--libdir=${dict['prefix']}/lib"
        "--with-toolset=${dict['toolset']}"
        "--with-icu=${dict['icu4c']}"
        '--without-libraries=log,mpi,python'
    )
    b2_args=(
        '-q'
        # Show commands as they are executed.
        '-d+2'
        "-j${dict['jobs']}"
        "--prefix=${dict['prefix']}"
        "--libdir=${dict['prefix']}/lib"
        "toolset=${dict['toolset']}"
        'variant=release'
        'link=shared,static'
        'threading=multi'
        'runtime-link=shared'
        "cxxflags=${CPPFLAGS:?}"
        "linkflags=${LDFLAGS:?}"
        'install'
    )
    koopa_print_env
    ./bootstrap.sh --help
    ./bootstrap.sh "${bootstrap_args[@]}"
    ./b2 --help
    ./b2 "${b2_args[@]}"
    return 0
}

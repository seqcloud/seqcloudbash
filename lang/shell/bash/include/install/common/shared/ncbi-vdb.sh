#!/usr/bin/env bash

# FIXME This currently fails to build on Apple Silicon.
# Workaround to allow clang/aarch64 build to use the gcc/arm64 directory
# Issue ref: https://github.com/ncbi/ncbi-vdb/issues/65
# ln_s "../gcc/arm64", buildpath/"ncbi-vdb-source/interfaces/cc/clang/arm64" if Hardware::CPU.arm?

main() {
    # """
    # Install NCBI VDB.
    # @note Updated 2023-04-06.
    #
    # VDB is the database engine that all SRA tools use.
    #
    # @seealso
    # - https://github.com/ncbi/ncbi-vdb/wiki/
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/ncbi-vdb
    # """
    local app cmake_args deps dict
    local -A app dict
    koopa_assert_has_no_args "$#"
    deps=('bison' 'flex' 'hdf5' 'python3.11')
    koopa_activate_app "${deps[@]}"
    app['cmake']="$(koopa_locate_cmake)"
    app['python']="$(koopa_locate_python311 --realpath)"
    [[ -x "${app['cmake']}" ]] || exit 1
    [[ -x "${app['python']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['openjdk']="$(koopa_app_prefix 'openjdk')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['openjdk']}"
    export JAVA_HOME="${dict['openjdk']}"
    CFLAGS="-DH5_USE_110_API ${CFLAGS:-}"
    export CFLAGS
    cmake_args=(
        '-DLIBS_ONLY=OFF'
        "-DPython3_EXECUTABLE=${app['python']}"
    )
    dict['url']="https://github.com/ncbi/ncbi-vdb/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    if koopa_is_root
    then
        # Disable creation of these files:
        # - /etc/ncbi/
        # - /etc/profile.d/ncbi-vdb.csh
        # - /etc/profile.d/ncbi-vdb.sh
        # shellcheck disable=SC2016
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='[ "$EUID" -eq 0 ]' \
            --replacement='[ "$EUID" -eq -1 ]' \
            'build/install-root.sh'
        # shellcheck disable=SC2016
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='[ "$EUID" -eq 0 ]' \
            --replacement='[ "$EUID" -eq -1 ]' \
            'libs/kfg/install.sh'
    fi
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

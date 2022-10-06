#!/usr/bin/env bash

main() {
    # """
    # Install Neovim.
    # @note Updated 2022-09-11.
    #
    # Homebrew is currently required for this to build on macOS.
    #
    # @seealso
    # - https://github.com/neovim/neovim/wiki/Building-Neovim
    # - https://github.com/neovim/neovim/wiki/Installing-Neovim
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/neovim.rb
    # - https://github.com/neovim/neovim/issues/11192
    # - https://carlosahs.medium.com/how-to-install-neovim-from-source-on-
    #     ubuntu-20-04-lts-524b3a91b4c4
    # - https://github.com/neovim/neovim/blob/master/cmake/FindLibIntl.cmake
    # - https://github.com/facebook/hhvm/blob/master/CMake/FindLibIntl.cmake
    # - https://github.com/neovim/neovim/blob/master/cmake.deps/
    #     cmake/BuildLuarocks.cmake
    # - https://github.com/neovim/neovim/issues/930
    # - https://leafo.net/guides/customizing-the-luarocks-tree.html
    # - Notes on 'terminal.c' build failure:
    #   https://github.com/neovim/neovim/issues/16217
    #   https://github.com/neovim/neovim/pull/17329
    # - Issues related to libluv linkage:
    #   https://github.com/NixOS/nixpkgs/issues/81206
    # - https://github.com/neovim/neovim/blob/master/runtime/CMakeLists.txt
    # - https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_RPATH.html
    # """
    local app build_deps deps dict
    koopa_assert_has_no_args "$#"
    build_deps=(
        'autoconf'
        'automake'
        'cmake'
        'libtool'
        'ninja'
        'pkg-config'
    )
    koopa_activate_build_opt_prefix "${build_deps[@]}"
    deps=(
        'm4'
        'zlib'
        'gettext'
        'libiconv'
        'ncurses'
        'python'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['gettext']="$(koopa_app_prefix 'gettext')"
        ['jobs']="$(koopa_cpu_count)"
        ['libiconv']="$(koopa_app_prefix 'libiconv')"
        ['name']='neovim'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    read -r -d '' "dict[local_mk]" << END || true
CMAKE_BUILD_TYPE := RelWithDebInfo
DEPS_CMAKE_FLAGS += -DUSE_BUNDLED=ON
CMAKE_EXTRA_FLAGS += "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
CMAKE_EXTRA_FLAGS += "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
CMAKE_EXTRA_FLAGS += "-DCMAKE_C_FLAGS=${CFLAGS:-}"
# > CMAKE_EXTRA_FLAGS += "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
CMAKE_EXTRA_FLAGS += "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
CMAKE_EXTRA_FLAGS += "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
CMAKE_EXTRA_FLAGS += "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
CMAKE_EXTRA_FLAGS += "-DICONV_INCLUDE_DIR=${dict['libiconv']}/include"
CMAKE_EXTRA_FLAGS += "-DICONV_LIBRARY=${dict['libiconv']}/lib/libiconv.${dict['shared_ext']}"
CMAKE_EXTRA_FLAGS += "-DLibIntl_INCLUDE_DIR=${dict['gettext']}/include"
CMAKE_EXTRA_FLAGS += "-DLibIntl_LIBRARY=${dict['gettext']}/lib/libintl.${dict['shared_ext']}"
CMAKE_EXTRA_FLAGS += "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
CMAKE_EXTRA_FLAGS += "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
END
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_write_string \
        --file='local.mk' \
        --string="${dict['local_mk']}"
    koopa_print_env
    "${app['make']}" distclean
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

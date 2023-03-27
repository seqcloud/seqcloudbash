#!/usr/bin/env bash

# NOTE Consider not writing files into '/etc/profile.d'.

# NOTE Lmod activation is disabled by default for root user. Can override with
# 'LMOD_ALLOW_ROOT_USE' environment variable in profile activation.

main() {
    # """
    # Install Lmod.
    # @note Updated 2022-10-06.
    #
    # @seealso
    # - https://lmod.readthedocs.io/en/latest/030_installing.html
    # """
    local app dict rock rocks
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'lua' \
        'luarocks' \
        'tcl-tk'
    declare -A app=(
        ['lua']="$(koopa_locate_lua --realpath)"
        ['luac']="$(koopa_locate_luac --realpath)"
        ['luarocks']="$(koopa_locate_luarocks --realpath)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['lua']}" ]] || return 1
    [[ -x "${app['luarocks']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['lua']="$(koopa_app_prefix 'lua')"
        ['name']='lmod'
        ['name2']='Lmod'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['apps_dir']="${dict['prefix']}/apps"
    dict['data_dir']="${dict['libexec']}/moduleData"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/TACC/${dict['name2']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name2']}-${dict['version']}"
    # > if koopa_is_macos
    # > then
    # >     export CFLAGS="${CFLAGS:-}"
    # >     CFLAGS_BAK="$CFLAGS"
    # >     # This fix is needed for Lua mpack rock to build.
    # >     CFLAGS="-D_DARWIN_C_SOURCE ${CFLAGS:-}"
    # > fi
    rocks=('luaposix' 'luafilesystem')
    for rock in "${rocks[@]}"
    do
        "${app['luarocks']}" \
            --lua-dir="${dict['lua']}" \
            install \
                --tree "${dict['libexec']}" \
                "$rock"
    done
    # > if koopa_is_macos
    # > then
    # >     CFLAGS="$CFLAGS_BAK"
    # > fi
    # This step sets 'LUA_PATH' and 'LUA_CPATH' environment variables.
    # But it also puts '/usr/local' into path, so disabling this approach.
    # > eval "$( \
    # >     "${app['luarocks']}" \
    # >         --lua-dir="${dict['luajit']}" \
    # >         path \
    # > )"
    dict['lua_ver']="$(koopa_get_version "${app['lua']}")"
    dict['lua_compat_ver']="$(koopa_major_minor_version "${dict['lua_ver']}")"
    lua_path_arr=(
        # > './?.lua'
        "${dict['libexec']}/share/lua/${dict['lua_compat_ver']}/?.lua"
        "${dict['libexec']}/share/lua/${dict['lua_compat_ver']}/?/init.lua"
        "${dict['lua']}/share/lua/${dict['lua_compat_ver']}/?.lua"
        "${dict['lua']}/share/lua/${dict['lua_compat_ver']}/?/init.lua"
    )
    lua_cpath_arr=(
        # > './?.so'
        "${dict['libexec']}/lib/lua/${dict['lua_compat_ver']}/?.so"
        "${dict['lua']}/lib/lua/${dict['lua_compat_ver']}/?.so"
    )
    LUAROCKS_PREFIX="${dict['libexec']}"
    LUA_PATH="$(printf '%s;' "${lua_path_arr[@]}")"
    LUA_CPATH="$(printf '%s;' "${lua_cpath_arr[@]}")"
    export LUAROCKS_PREFIX LUA_PATH LUA_CPATH
    "${app['lua']}" -e 'print(package.path)'
    "${app['lua']}" -e 'print(package.cpath)'
    conf_args=(
        "--prefix=${dict['apps_dir']}"
        '--with-allowRootUse=no'
        "--with-lua=${app['lua']}"
        "--with-luac=${app['luac']}"
        "--with-spiderCacheDir=${dict['data_dir']}/cacheDir"
        "--with-updateSystemFn=${dict['data_dir']}/system.txt"
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    if koopa_is_admin
    then
        koopa_linux_configure_lmod "${dict['prefix']}"
    fi
    return 0
}

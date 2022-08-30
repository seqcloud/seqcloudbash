#!/usr/bin/env bash

# FIXME Can we set 'lib' instead of 'lib64' on Linux?

# Consider adding support for:
# - cairo
# - gobject-introspection
# - graphite2

main() {
    # """
    # Install HarfBuzz.
    # @note Updated 2022-07-24.
    #
    # @seealso
    # - https://harfbuzz.github.io/building.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     harfbuzz.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/harfbuzz.html
    # - https://github.com/harfbuzz/harfbuzz/blob/main/.circleci/config.yml
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix \
        'pkg-config' \
        'cmake' \
        'meson' \
        'ninja'
    # glib deps: zlib, gettext, libffi, pcre.
    koopa_activate_opt_prefix \
        'zlib' \
        'gettext' \
        'libffi' \
        'pcre' \
        'glib' \
        'freetype' \
        'icu4c'
    declare -A app=(
        ['meson']="$(koopa_locate_meson)"
        ['ninja']="$(koopa_locate_ninja)"
    )
    [[ -x "${app['meson']}" ]] || return 1
    [[ -x "${app['ninja']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='harfbuzz'
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    meson_args=(
        "--prefix=${dict['prefix']}"
        '--buildtype=release'
        '--default-library=both'
        '-Dcairo=disabled'
        '-Dcoretext=enabled' # FIXME Check on Linux.
        '-Dfreetype=enabled'
        '-Dglib=enabled'
        '-Dgobject=disabled'
        '-Dgraphite=disabled'
        '-Dicu=enabled'
        '-Dintrospection=disabled'
    )
    "${app['meson']}" "${meson_args[@]}" build
    # Alternate build approach using meson.
    # > "${app['meson']}" compile -C build
    # > "${app['meson']}" test -C build
    # Using ninja instead, as it's faster.
    "${app['ninja']}" -j "${dict['jobs']}" -C 'build'
    # > "${app['ninja']}" test
    "${app['ninja']}" -C 'build' install
    return 0
}

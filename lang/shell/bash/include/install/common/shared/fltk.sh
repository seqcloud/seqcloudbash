#!/usr/bin/env bash

# NOTE Consider adding support for libxft.
# https://gitlab.freedesktop.org/xorg/lib/libxft

main() {
    # """
    # Install FLTK.
    # @note Updated 2023-03-28.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/fltk.rb
    # - https://courses.cs.washington.edu/courses/csep557/14au/tools/
    #     fltk_install.html
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    if koopa_is_linux
    then
        koopa_activate_app \
            'freetype' \
            'xorg-xorgproto' \
            'xorg-xtrans' \
            'xorg-libpthread-stubs' \
            'xorg-libxau' \
            'xorg-libxdmcp' \
            'xorg-libxcb' \
            'xorg-libx11'
    fi
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || exit 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='fltk'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}-source.tar.gz"
    dict['url']="https://www.${dict['name']}.org/pub/${dict['name']}/\
${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-cairo'
        '--disable-xft'
        '--enable-shared'
        '--enable-threads'
    )
    if koopa_is_linux
    then
        dict['x11']="$(koopa_app_prefix 'xorg-libx11')"
        conf_args+=(
            '--enable-x11'
            "--x-includes=${dict['x11']}/include"
            "--x-libraries=${dict['x11']}/lib"
        )
    elif koopa_is_macos
    then
        conf_args+=('--disable-x11')
    fi
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

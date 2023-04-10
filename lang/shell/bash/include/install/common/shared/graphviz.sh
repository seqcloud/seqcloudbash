#!/usr/bin/env bash

# NOTE Consider adding support for: expat, fontconfig, freetype2, openjdk,
# tcl-tk, zlib, X11.
#
# > options:
# >   fontconfig:    No (missing fontconfig-config)
# >   freetype:      No (missing freetype-config)
# >   glut:          No (missing GL/glut.h)
# >   ann:           No (no ann.pc found)
# >   gts:           No (gts library not available)
# >   swig:          No (swig not available) (  )
# >   qt:            No (qmake not found)

main() {
    # """
    # Install graphviz.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://graphviz.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     graphviz.rb
    # - https://ports.macports.org/port/graphviz/details/
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug'
        '--disable-man-pdfs'
        '--disable-static'
        '--enable-shared'
        "--prefix=${dict['prefix']}"
    )
    koopa_mkdir "${dict['prefix']}/lib"
    dict['url']="https://gitlab.com/api/v4/projects/4207231/packages/generic/\
graphviz-releases/${dict['version']}/graphviz-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}

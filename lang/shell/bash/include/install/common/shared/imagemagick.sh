#!/usr/bin/env bash

# NOTE Don't include graphviz here, as it can cause conflicts with Rgraphviz
# package in R, which bundles a very old version (2.28.0) currently.

main() {
    # """
    # Install ImageMagick.
    # @note Updated 2023-04-10.
    #
    # Also consider requiring:
    # - ghostscript
    # - libheif
    # - liblqr
    # - libraw
    # - little-cms2
    # - openexr
    # - openjpeg
    # - perl
    # - webp
    #
    # If using clang on macOS, need to include libomp, or ensure that
    # use has run 'koopa install system r-openmp'.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     imagemagick.rb
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/libomp.rb
    # - https://imagemagick.org/script/install-source.php
    # - https://imagemagick.org/script/advanced-linux-installation.php
    # - https://download.imagemagick.org/ImageMagick/download/releases/
    # """
    local -A dict
    local -a conf_args deps
    koopa_activate_app --build-only 'pkg-config'
    deps=(
        'zlib'
        'zstd'
        'bzip2'
        'xz'
        'freetype'
        'jpeg'
        'libpng'
        'libtiff'
        'libtool'
        'libxml2'
        'libzip'
        'fontconfig'
        'xorg-xorgproto'
        'xorg-xcb-proto'
        'xorg-libpthread-stubs'
        'xorg-libice'
        'xorg-libsm'
        'xorg-libxau'
        'xorg-libxdmcp'
        'xorg-libxcb'
        'xorg-libx11'
        'xorg-libxext'
        'xorg-libxrender'
        'xorg-libxt'
    )
    # Using system clang on macOS to avoid '-lopenmp' issues when building
    # R from source.
    if koopa_is_linux
    then
        # gcc deps: gmp, mpfr, mpc.
        deps+=('gcc')
    fi
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['mmp_ver']="$(koopa_major_minor_patch_version "${dict['version']}")"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-modules'
    )
    dict['url']="https://imagemagick.org/archive/releases/\
ImageMagick-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}

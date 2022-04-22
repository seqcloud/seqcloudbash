#!/usr/bin/env bash

# FIXME tex step is erroring on macOS:
# I can't find file `texinfo.tex'.

# FIXME This requires libXt...
# checking for X11/Intrinsic.h... no
# configure: error: --with-x=yes (default) and X11 headers/libs are not available

# FIXME PDF rendering issue:
# /opt/koopa/app/texinfo/6.8/bin/texi2dvi: texinfo.tex appears to be broken.
# This may be due to the environment variable TEX set to something

main() { # {{{1
    # """
    # Install R.
    # @note Updated 2022-04-22.
    #
    # @section gfortran configuration on macOS:
    #
    # fxcoudert's gfortran works more reliably than using Homebrew gcc
    # See also:
    # - https://mac.r-project.org
    # - https://github.com/fxcoudert/gfortran-for-macOS/releases
    # - https://developer.r-project.org/Blog/public/2020/11/02/
    #     will-r-work-on-apple-silicon/index.html
    # - https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
    #
    # @section Recommended Debian packages (for Dockerfile):
    #
    # - 'bash-completion'
    # - 'bison'
    # - 'debhelper'
    # - 'default-jdk'
    # - 'g++'
    # - 'gcc'
    # - 'gdb'
    # - 'gfortran'
    # - 'groff-base'
    # - 'libblas-dev'
    # - 'libbz2-dev'
    # - 'libcairo2-dev'
    # - 'libcurl4-openssl-dev'
    # - 'libjpeg-dev'
    # - 'liblapack-dev'
    # - 'liblzma-dev'
    # - 'libncurses5-dev'
    # - 'libpango1.0-dev'
    # - 'libpcre3-dev'
    # - 'libpng-dev'
    # - 'libreadline-dev'
    # - 'libtiff5-dev'
    # - 'libx11-dev'
    # - 'libxt-dev'
    # - 'mpack'
    # - 'subversion'
    # - 'tcl8.6-dev'
    # - 'texinfo'
    # - 'texlive-base'
    # - 'texlive-extra-utils'
    # - 'texlive-fonts-extra'
    # - 'texlive-fonts-recommended'
    # - 'texlive-latex-base'
    # - 'texlive-latex-extra'
    # - 'texlive-latex-recommended'
    # - 'tk8.6-dev'
    # - 'x11proto-core-dev'
    # - 'xauth'
    # - 'xdg-utils'
    # - 'xfonts-base'
    # - 'xvfb'
    # - 'zlib1g-dev'
    #
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # - https://hub.docker.com/r/rocker/r-devel/dockerfile
    # - https://developer.r-project.org/
    # - https://svn.r-project.org/R/
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #       R-admin.html#Getting-patched-and-development-versions
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://svn.r-project.org/R/trunk/Makefile.in
    # - https://github.com/archlinux/svntogit-packages/blob/
    #     b3c63075d83c8dea993b8d776b8f9970c58791fe/r/trunk/PKGBUILD
    # """
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    deps=(
        # > 'bzip2'
        # > 'perl'
        # > 'unzip'
        # > 'which'
        # > 'zip'
        'cairo'
        'curl'
        'fontconfig' # cairo
        'freetype' # cairo
        'gettext'
        'glib' # cairo
        'icu4c'
        'lapack'
        'libffi'
        'libice' # x11
        'libjpeg-turbo'
        'libpng'
        'libpthread-stubs' # x11
        'libsm' # x11
        'libtiff'
        'libx11' # x11
        'libxau' # x11
        'libxcb' # x11
        'libxdmcp' # x11
        'libxext' # x11
        'libxml2'
        'libxrender' # x11
        'libxt' # x11
        'libxt' # x11
        'lzo' # cairo
        'openblas'
        'pcre2'
        'pixman' # cairo
        'pkg-config'
        'readline'
        'tcl-tk'
        'texinfo'
        'xcb-proto' # x11
        'xorgproto' # x11
        'xz'
        'zlib'
    )
    if koopa_is_linux
    then
        deps+=('openjdk')
    elif koopa_is_macos
    then
        # We're using Adoptium Temurin LTS on macOS.
        koopa_activate_prefix '/usr/local/gfortran'
        koopa_add_to_path_start '/Library/TeX/texbin'
    fi
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [pkg_config]="$(koopa_locate_pkg_config)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=(
        # > '--enable-BLAS-shlib' # Linux only?
        "--prefix=${dict[prefix]}"
        '--enable-R-profiling'
        '--enable-R-shlib'
        '--enable-byte-compiled-packages'
        '--enable-fast-install'
        '--enable-java'
        '--enable-memory-profiling'
        '--enable-shared'
        '--enable-static'
        "--with-ICU=$( \
            "${app[pkg_config]}" --libs \
                'icu-i18n' \
                'icu-io' \
                'icu-uc' \
        )"
        "--with-blas=$( \
            "${app[pkg_config]}" --libs 'openblas' \
        )"
        "--with-cairo=$( \
            "${app[pkg_config]}" --libs \
                'cairo' \
                'cairo-fc' \
                'cairo-ft' \
                'cairo-pdf' \
                'cairo-png' \
                'cairo-ps' \
                'cairo-quartz' \
                'cairo-quartz-font' \
                'cairo-script' \
                'cairo-svg' \
                'cairo-xcb' \
                'cairo-xcb-shm' \
                'cairo-xlib' \
                'cairo-xlib-xrender' \
        )"
        '--with-static-cairo=no' # FIXME Check this on macOS?
        "--with-jpeglib=$( \
            "${app[pkg_config]}" --libs 'libjpeg' \
        )"
        "--with-lapack=$( \
            "${app[pkg_config]}" --libs 'lapack' \
        )"
        "--with-libpng=$( \
            "${app[pkg_config]}" --libs 'libpng' \
        )"
        "--with-libtiff=$( \
            "${app[pkg_config]}" --libs 'libtiff-4' \
        )"
        "--with-pcre2=$( \
            "${app[pkg_config]}" --libs \
                'libpcre2-8' \
                'libpcre2-16' \
                'libpcre2-32' \
                'libpcre2-posix' \
        )"
        "--with-readline=$( \
            "${app[pkg_config]}" --libs 'readline' \
        )"
        # For Tcl/Tk, alternatively can use:
        # > "--with-tcltk=$( \
        # >     "${app[pkg_config]}" --libs 'tcl' 'tk' \
        # > )"
        "--with-tcl-config=${dict[opt_prefix]}/tcl-tk/lib/tclConfig.sh"
        "--with-tk-config=${dict[opt_prefix]}/tcl-tk/lib/tkConfig.sh"
        '--with-x'
    )
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        conf_args+=('--without-recommended-packages')
    else
        conf_args+=('--with-recommended-packages')
    fi
    if koopa_is_macos
    then
        conf_args+=('--without-aqua')
        export CFLAGS='-Wno-error=implicit-function-declaration'
    fi
    koopa_dl 'configure args' "${conf_args[*]}"
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        app[svn]="$(koopa_locate_svn)"
        dict[rtop]="$(koopa_init_dir 'svn/r')"
        dict[svn_url]='https://svn.r-project.org/R/trunk'
        dict[trust_cert]='unknown-ca,cn-mismatch,expired,not-yet-valid,other'
        # Can debug subversion linkage with:
        # > "${app[svn]}" --version --verbose
        "${app[svn]}" \
            --non-interactive \
            --trust-server-cert-failures="${dict[trust_cert]}" \
            checkout \
                --revision="${dict[version]}" \
                "${dict[svn_url]}" \
                "${dict[rtop]}"
        koopa_cd "${dict[rtop]}"
        # Edge case for 'Makefile:107' issue.
        if koopa_is_macos
        then
            koopa_print "Revision: ${dict[version]}" > 'SVNINFO'
        fi
    else
        dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
        dict[file]="R-${dict[version]}.tar.gz"
        dict[url]="https://cloud.r-project.org/src/base/\
R-${dict[maj_ver]}/${dict[file]}"
        koopa_download "${dict[url]}" "${dict[file]}"
        koopa_extract "${dict[file]}"
        koopa_cd "R-${dict[version]}"
    fi
    export TZ='America/New_York'
    unset -v R_HOME
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    # > "${app[make]}" 'pdf'
    "${app[make]}" 'info'
    "${app[make]}" install
    app[r]="${dict[prefix]}/bin/R"
    app[rscript]="${app[r]}script"
    koopa_assert_is_installed "${app[r]}" "${app[rscript]}"
    koopa_configure_r "${app[r]}"
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        koopa_link_in_bin "${app[r]}" 'R-devel'
    fi
    "${app[rscript]}" -e 'capabilities()'
    return 0
}

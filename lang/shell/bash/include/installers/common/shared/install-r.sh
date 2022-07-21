#!/usr/bin/env bash

main() {
    # """
    # Install R.
    # @note Updated 2022-07-20.
    #
    # @section gfortran configuration on macOS:
    #
    # - https://mac.r-project.org
    # - https://github.com/fxcoudert/gfortran-for-macOS/releases
    # - https://github.com/Rdatatable/data.table/wiki/Installation/
    # - https://developer.r-project.org/Blog/public/2020/11/02/
    #     will-r-work-on-apple-silicon/index.html
    # - https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
    #
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://cran.r-project.org/doc/manuals/r-release/
    #     R-admin.html#macOS-packages
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #     R-exts.html#Using-Makevars
    # - https://stat.ethz.ch/R-manual/R-devel/library/base/
    #     html/capabilities.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # - https://developer.r-project.org/
    # - https://svn.r-project.org/R/
    # - https://www.gnu.org/software/make/manual/make.html#Using-Implicit
    # - https://www.gnu.org/software/make/manual/html_node/
    #     Implicit-Variables.html
    # - https://bookdown.org/lionel/contributing/building-r.html
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://hub.docker.com/r/rocker/r-devel/dockerfile
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #       R-admin.html#Getting-patched-and-development-versions
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://svn.r-project.org/R/trunk/Makefile.in
    # - https://github.com/archlinux/svntogit-packages/blob/
    #     b3c63075d83c8dea993b8d776b8f9970c58791fe/r/trunk/PKGBUILD
    # """
    local app conf_args deps dict flibs i libs
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [dirname]="$(koopa_locate_dirname)"
        [make]="$(koopa_locate_make)"
        [pkg_config]="$(koopa_locate_pkg_config)"
        [sort]="$(koopa_locate_sort)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app[dirname]}" ]] || return 1
    [[ -x "${app[make]}" ]] || return 1
    [[ -x "${app[pkg_config]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [jobs]="$(koopa_cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    koopa_activate_build_opt_prefix 'pkg-config'
    deps=(
        # zlib deps: none.
        'zlib'
        # zstd deps: none.
        'zstd'
        # m4 deps: none.
        # > 'm4'
        # gmp deps: m4.
        # > 'gmp'
        # mpfr deps: gmp.
        # > 'mpfr'
        # mpc deps: gmp, mpfr.
        # > 'mpc'
        # gcc deps: gmp, mpfr, mpc.
        'gcc'
        # bzip2 deps: none.
        'bzip2'
        # icu4c deps: none.
        'icu4c'
        # ncurses deps: none.
        'ncurses'
        # readline deps: ncurses.
        'readline'
        # libxml2 deps: icu4c, readline.
        'libxml2'
        # gettext deps: ncurses, libxml2.
        'gettext'
        # xz deps: none.
        'xz'
        # openssl3 deps: zlib.
        'openssl3'
        # curl deps: openssl3.
        'curl'
        # lapack deps: gcc.
        'lapack'
        # libffi deps: none.
        'libffi'
        # libjpeg-turbo deps: none.
        'libjpeg-turbo'
        # libpng deps: zlib.
        'libpng'
        # libtiff deps: libjpeg-turbo, zstd.
        'libtiff'
        # openblas deps: gcc.
        'openblas'
        # openjdk deps: none.
        'openjdk'
        # pcre deps: zlib, bzip2.
        'pcre'
        # pcre2 deps: zlib, bzip2.
        'pcre2'
        # perl deps: none.
        'perl'
        # texinfo deps: gettext, ncurses, perl.
        'texinfo'
        # glib deps: zlib, gettext, libffi, pcre.
        'glib'
        # freetype deps: none.
        'freetype'
        # gperf deps: none.
        'gperf'
        # fontconfig deps: gperf, freetype, libxml2.
        'fontconfig'
        # lzo deps: none.
        'lzo'
        # pixman deps: none.
        'pixman'
        # fribidi deps: none.
        'fribidi'
        # graphviz deps: none.
        'graphviz'
        # harfbuzz deps: freetype, icu4c.
        'harfbuzz'
        # libtool deps: m4.
        'libtool'
        # imagemagick deps: libtool.
        'imagemagick'
        # libssh2 deps: openssl3.
        'libssh2'
        # libgit2 deps: openssl3, libssh2.
        'libgit2'
        # sqlite deps: readline.
        'sqlite'
        # python deps: zlib, libffi, openssl3.
        'python'
        # hdf5 deps: gcc.
        'hdf5'
        # geos deps: none.
        'geos'
        # proj deps: curl, libtiff, python, sqlite.
        'proj'
        # gdal deps: curl, geos, hdf5, libxml2, openssl3, pcre2, sqlite,
        # libtiff, proj, xz, zstd.
        'gdal'
        # X11.
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
        # cairo deps: gettext, freetype, libxml2, fontconfig, libffi,
        # pcre, glib, libpng, lzo, pixman, X11.
        'cairo'
        # tcl-tk deps: X11.
        'tcl-tk'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    if koopa_is_macos
    then
        dict[texbin]='/Library/TeX/texbin'
        koopa_add_to_path_start "${dict[texbin]}"
    fi
    dict[lapack]="$(koopa_realpath "${dict[opt_prefix]}/lapack")"
    dict[openjdk]="$(koopa_realpath "${dict[opt_prefix]}/openjdk")"
    dict[tcl_tk]="$(koopa_realpath "${dict[opt_prefix]}/tcl-tk")"
    conf_args=(
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
        # On macOS, consider including: 'cairo-quartz', 'cairo-quartz-font'.
        "--with-cairo=$( \
            "${app[pkg_config]}" --libs \
                'cairo' \
                'cairo-fc' \
                'cairo-ft' \
                'cairo-pdf' \
                'cairo-png' \
                'cairo-ps' \
                'cairo-script' \
                'cairo-svg' \
                'cairo-xcb' \
                'cairo-xcb-shm' \
                'cairo-xlib' \
                'cairo-xlib-xrender' \
        )"
        '--with-static-cairo=no'
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
        "--with-tcl-config=${dict[tcl_tk]}/lib/tclConfig.sh"
        "--with-tk-config=${dict[tcl_tk]}/lib/tkConfig.sh"
    )
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        conf_args+=('--without-recommended-packages')
    else
        conf_args+=('--with-recommended-packages')
    fi
    dict[gcc_prefix]="$(koopa_realpath "${dict[opt_prefix]}/gcc")"
    if koopa_is_macos
    then
        # Clang tends to compile a number of tricky RStudio packages better.
        app[cc]='/usr/bin/clang'
        app[cxx]='/usr/bin/clang++'
    else
        # Alternatively, can use system GCC here.
        # > app[cc]='/usr/bin/gcc'
        # > app[cxx]='/usr/bin/g++'
        app[cc]="${dict[gcc_prefix]}/bin/gcc"
        app[cxx]="${dict[gcc_prefix]}/bin/g++"
    fi
    app[fc]="${dict[gcc_prefix]}/bin/gfortran"
    app[jar]="${dict[openjdk]}/bin/jar"
    app[java]="${dict[openjdk]}/bin/java"
    app[javac]="${dict[openjdk]}/bin/javac"
    koopa_assert_is_installed \
        "${app[cc]}" \
        "${app[cxx]}" \
        "${app[fc]}" \
        "${app[jar]}" \
        "${app[java]}" \
        "${app[javac]}"
    # Configure fortran FLIBS to link GCC correctly.
    readarray -t libs <<< "$( \
        koopa_find \
            --prefix="${dict[gcc_prefix]}" \
            --pattern='*.a' \
            --type 'f' \
        | "${app[xargs]}" -I '{}' "${app[dirname]}" '{}' \
        | "${app[sort]}" --unique \
    )"
    koopa_assert_is_array_non_empty "${libs[@]:-}"
    flibs=()
    for i in "${!libs[@]}"
    do
        flibs+=("-L${libs[i]}")
    done
    flibs+=('-lgfortran')
    # quadmath is not yet supported for ARM.
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=96016
    case "${dict[arch]}" in
        'x86_64')
            flibs+=('-lquadmath')
            ;;
    esac
    # NOTE Consider also including '-lemutls_w' here, which is recommended
    # by default macOS build config.
    flibs+=('-lm')
    dict[cc]="${app[cc]}"
    dict[cxx]="${app[cxx]}"
    dict[f77]="${app[fc]}"
    dict[fc]="${app[fc]}"
    dict[flibs]="${flibs[*]}"
    dict[jar]="${app[jar]}"
    dict[java]="${app[java]}"
    dict[java_home]="${dict[openjdk]}"
    dict[javac]="${app[javac]}"
    dict[objc]="${app[cc]}"
    dict[objcxx]="${app[cxx]}"
    if koopa_is_linux
    then
        dict[cc]="${dict[cc]} -fopenmp"
    fi
    conf_args+=(
        "CC=${dict[cc]}"
        "CXX=${dict[cxx]}"
        "F77=${dict[f77]}"
        "FC=${dict[fc]}"
        "FLIBS=${dict[flibs]}"
        "JAR=${dict[jar]}"
        "JAVA=${dict[java]}"
        "JAVAC=${dict[javac]}"
        "JAVA_HOME=${dict[java_home]}"
        "OBJC=${dict[objc]}"
        "OBJCXX=${dict[objcxx]}"
        # Ensure that OpenMP is enabled.
        # https://stackoverflow.com/a/12307488/3911732
        # NOTE Only 'CFLAGS', 'CXXFLAGS', and 'FFLAGS' getting picked up
        # in macOS 'Makeconf' file. May be safe to remove 'FCFLAGS' here.
        'SHLIB_OPENMP_CFLAGS=-fopenmp'
        'SHLIB_OPENMP_CXXFLAGS=-fopenmp'
        # > 'SHLIB_OPENMP_FCFLAGS=-fopenmp'
        'SHLIB_OPENMP_FFLAGS=-fopenmp'
    )
    if koopa_is_macos
    then
        conf_args+=('--without-aqua')
        export CFLAGS="-Wno-error=implicit-function-declaration ${CFLAGS:-}"
    else
        conf_args+=('--with-x')
    fi
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        app[svn]="$(koopa_locate_svn)"
        [[ -x "${app[svn]}" ]] || return 1
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
    unset -v R_HOME
    # > export TZ='America/New_York'
    # Need to burn LAPACK in rpath, otherwise grDevices will fail to build.
    koopa_add_rpath_to_ldflags "${dict[lapack]}/lib"
    ./configure --help
    koopa_dl 'configure args' "${conf_args[*]}"
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
    # NOTE libxml is now expected to return FALSE as of R 4.2.
    "${app[rscript]}" -e 'capabilities()'
    return 0
}

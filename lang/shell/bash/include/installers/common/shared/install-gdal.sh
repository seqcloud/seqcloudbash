#!/usr/bin/env bash

# FIXME Should we include openssl here?

# FIXME make is erroring on macOS:
# Must remake target 'lib'.
# Successfully remade target file 'lib'.
# make[1]: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20220421-101201-CKCJuCU0OD/gdal-3.4.2/ogr'
# Reaping winning child 0x600000a34000 PID 73531
# Removing child 0x600000a34000 PID 73531 from chain.

main() { # {{{1
    # """
    # Install GDAL.
    # @note Updated 2022-04-21.
    #
    # Use 'configure --help' for build options.
    #
    # Use OpenJPEG instead of Jasper.
    # This is particularly important for CentOS builds.
    #
    # @seealso
    # - https://gdal.org/build_hints.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/gdal.rb
    # - https://trac.osgeo.org/gdal/wiki/BuildingOnUnix
    # - https://trac.osgeo.org/gdal/wiki/BuildingOnUnixGDAL25dev
    # - https://github.com/OSGeo/gdal/issues/1259
    # - https://github.com/OSGeo/gdal/issues/2402
    # - https://github.com/OSGeo/gdal/issues/1708
    # - https://stackoverflow.com/questions/53511533/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    if koopa_is_linux
    then
        koopa_assert_is_non_existing \
            '/usr/bin/gdal-config' \
            '/usr/include/gdal'
    fi
    # Consider adding:
    # - libpng (for '--with-png')
    koopa_activate_build_opt_prefix 'cmake' 'pkg-config'
    koopa_activate_opt_prefix \
        'geos' \
        'hdf5' \
        'jpeg' \
        'libgeotiff' \
        'libpng' \
        'libtiff' \
        'libtool' \
        'libxml2' \
        'openssl' \
        'pcre2' \
        'proj' \
        'sqlite' \
        'xz' \
        'zstd'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [make_prefix]="$(koopa_make_prefix)"
        [name]='gdal'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/OSGeo/${dict[name]}/releases/download/\
v${dict[version]}/${dict[file]}"
    koopa_alert_coffee_time
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        # Base configuration.
        "--prefix=${dict[prefix]}"
        '--enable-shared'
        # > '--enable-static'
        '--disable-debug'
        '--with-libtool'
        "--with-local=${dict[prefix]}"
        '--with-threads'
        # GDAL native backends.
        '--with-libjson-c=internal'
        '--with-pam'
        '--with-pcidsk=internal'
        '--with-pcraster=internal'
        # Koopa opt backends.
        "--with-curl=${dict[opt_prefix]}/curl/bin/curl-config"
        "--with-geos=${dict[opt_prefix]}/geos/bin/geos-config"
        "--with-geotiff=${dict[opt_prefix]}/libgeotiff"
        "--with-hdf5=${dict[opt_prefix]}/hdf5"
        "--with-jpeg=${dict[opt_prefix]}/jpeg"
        "--with-libtiff=${dict[opt_prefix]}/libtiff"
        "--with-pcre2=${dict[opt_prefix]}/pcre2"
        "--with-png=${dict[opt_prefix]}/libpng"
        "--with-proj=${dict[opt_prefix]}/proj"
        "--with-sqlite3=${dict[opt_prefix]}/sqlite"
        "--with-zstd=${dict[opt_prefix]}/zstd"
        # Features that are supported in Homebrew, but which we don't currently
        # have recipe support in Koopa.
        '--with-cfitsio=no'
        '--with-dods-root=no'
        # > '--with-epsilon=no'
        '--with-expat=no'
        '--with-freexl=no'
        '--with-gif=no'
        '--with-liblzma=no'
        '--with-netcdf=no'
        '--with-odbc=no'
        '--with-openjpeg=no'
        '--with-pg=no'
        '--with-poppler=no'
        '--with-spatialite=no'
        '--with-webp=no'
        '--with-xerces=no'
        # Explicitly disable some features.
        '--with-armadillo=no'
        '--with-qhull=no'
        '--without-exr'
        '--without-grass'
        '--without-jasper'
        '--without-jpeg12'
        '--without-libgrass'
        '--without-mysql'
        '--without-perl'
        '--without-python'
        # Unsupported backends are either proprietary or have no compatible
        # version in Koopa. Podofo is disabled because Poppler provides the same
        # functionality and then some.
        '--without-ecw'
        '--without-fgdb'
        '--without-fme'
        '--without-gta'
        '--without-hdf4'
        '--without-idb'
        '--without-ingres'
        '--without-jp2mrsid'
        '--without-kakadu'
        '--without-mrsid'
        '--without-mrsid_lidar'
        '--without-msg'
        '--without-oci'
        '--without-ogdi'
        '--without-podofo'
        '--without-rasdaman'
        # > '--without-sde'
        '--without-sosi'
    )
    if koopa_is_macos
    then
        conf_args+=('--with-opencl')
    fi
    koopa_mkdir "${dict[prefix]}/include"
    koopa_add_rpath_to_ldflags "${dict[prefix]}/lib"
    ./configure "${conf_args[@]}"
    # Use '-d' flag for more verbose debug mode.
    "${app[make]}" V=1 -d --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

#!/usr/bin/env bash

# FIXME This needs scons to be installed first.

main() { # {{{1
    # """
    # Install Apache Serf.
    # @note Updated 2022-04-09.
    #
    # Required by subversion for HTTPS connections.
    #
    # @seealso
    # - https://serf.apache.org/download
    # - https://www.linuxfromscratch.org/blfs/view/svn/basicnet/serf.html
    # - https://github.com/apache/serf/blob/trunk/README
    # """
    local app dict scons_args
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'apr' 'apr-util' 'openssl'
    declare -A app=(
        [patch]="$(koopa_locate_patch)"
        [scons]="$(koopa_locate_scons)"
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        [name]='serf'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://www.apache.org/dist/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # Download patch required for OpenSSL 3 compatibility.
    koopa_download "https://www.linuxfromscratch.org/patches/blfs/svn/\
serf-1.3.9-openssl3_fixes-1.patch"
    "${app[patch]}" -Np1 -i 'serf-1.3.9-openssl3_fixes-1.patch'
    # These steps require GNU sed.
    "${app[sed]}" -i "/Append/s:RPATH=libdir,::" 'SConstruct'
    "${app[sed]}" -i "/Default/s:lib_static,::"  'SConstruct'
    "${app[sed]}" -i "/Alias/s:install_static,::" 'SConstruct'
    "${app[sed]}" -i "/  print/{s/print/print(/; s/$/)/}" 'SConstruct'
    "${app[sed]}" -i "/get_contents()/s/,/.decode()&/" 'SConstruct'
    scons_args=(
        "APR=${dict[opt_prefix]}/apr"
        "APU=${dict[opt_prefix]}/apr-util"
        "OPENSSL=${dict[opt_prefix]}/openssl"
        "PREFIX=${dict[prefix]}"
    )
    "${app[scons]}" "${scons_args[@]}"
    "${app[scons]}" "${scons_args[@]}" install
    return 0
}

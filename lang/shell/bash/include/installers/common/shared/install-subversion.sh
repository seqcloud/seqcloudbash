#!/usr/bin/env bash

# FIXME Need to be able to install APR from source here.

main() { # {{{1
    # """
    # Install Subversion.
    # @note Updated 2022-04-09.
    #
    # Requires Apache Portable Runtime (APR) library and Apache Portable Runtime
    # Utility (APRUTIL) library.
    #
    # @seealso
    # - https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
    # - https://subversion.apache.org/download.cgi
    # - https://subversion.apache.org/source-code.html
    # - Need to use serf to support HTTPS URLs.
    #   https://serverfault.com/questions/522646/
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    # Also requires 'apr', which is provided by macOS CLT.
    koopa_activate_opt_prefix \
        'perl' \
        'python' \
        'ruby' \
        'sqlite'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='subversion'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--with-serf' # Required for HTTPS URLs.
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://mirrors.ocf.berkeley.edu/apache/\
${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

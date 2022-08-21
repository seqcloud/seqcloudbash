#!/usr/bin/env bash

main() {
    # """
    # Install libev.
    # @note Updated 2022-08-19.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libev.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libev'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict['name']}-${dict['version']}.tar.gz"
    dict[url]="http://dist.schmorp.de/${dict['name']}/Attic/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

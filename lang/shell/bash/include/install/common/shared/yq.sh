#!/usr/bin/env bash

main() {
    # """
    # Install yq.
    # @note Updated 2022-09-23.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/yq.rb
    # - go help build
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go'
    declare -A app=(
        ['go']="$(koopa_locate_go)"
    )
    [[ -x "${app['go']}" ]] || return 1
    declare -A dict=(
        ['gopath']="$(koopa_init_dir 'go')"
        ['name']='yq'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    export GOPATH="${dict['gopath']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/mikefarah/yq/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    "${app['go']}" build \
        -o "${dict['prefix']}/bin/yq"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

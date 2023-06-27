#!/usr/bin/env bash

main() {
    # """
    # Install Node.js package using npm.
    # @note Updated 2023-06-27.
    #
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # """
    local -A app dict
    local -a install_args
    app['node']="$(koopa_locate_node)"
    app['npm']="$(koopa_locate_npm)"
    koopa_assert_is_executable "${app[@]}"
    app['node']="$(koopa_realpath "${app['node']}")"
    dict['cache_prefix']="$(koopa_tmp_dir)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_add_to_path_start "$(koopa_dirname "${app['node']}")"
    export NPM_CONFIG_PREFIX="${dict['prefix']}"
    export NPM_CONFIG_UPDATE_NOTIFIER=false
    install_args=(
        "--cache=${dict['cache_prefix']}"
        '--location=global'
        '--no-audit'
        '--no-fund'
    )
    install_args+=("${dict['name']}@${dict['version']}")
    case "${dict['name']}" in
        'prettier')
            install_args+=('prettier-plugin-sort-json')
            ;;
    esac
    "${app['npm']}" install "${install_args[@]}" 2>&1
    koopa_rm "${dict['cache_prefix']}"
    return 0
}

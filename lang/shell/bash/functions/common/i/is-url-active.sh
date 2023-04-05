#!/usr/bin/env bash

# FIXME This check is breaking when bootstrapping koopa.

koopa_is_url_active() {
    # """
    # Check if input is a URL and is active.
    # @note Updated 2022-09-01.
    #
    # @section cURL approach:
    #
    # Can also use "--range '0-0'" instead of '--head' here.
    #
    # @section wget approach:
    #
    # > "${app['wget']}" --spider "$url" 2>/dev/null || exit 1
    #
    # @seealso
    # - https://stackoverflow.com/questions/12199059/
    #
    # @examples
    # # TRUE:
    # > koopa_is_url_active 'https://google.com/'
    #
    # # FALSE:
    # > koopa_is_url_active 'https://google.com/asdf'
    # """
    local app url
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict
    app['curl']="$(koopa_locate_curl --allow-system)"
    [[ -x "${app['curl']}" ]] || exit 1
    dict['url_pattern']='://'
    for url in "$@"
    do
        koopa_str_detect_fixed \
            --pattern="${dict['url_pattern']}" \
            --string="$url" \
            || return 1
        "${app['curl']}" \
            --disable \
            --fail \
            --head \
            --location \
            --output /dev/null \
            --silent \
            "$url" \
            || return 1
        continue
    done
    return 0
}

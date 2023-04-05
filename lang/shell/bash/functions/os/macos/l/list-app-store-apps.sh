#!/usr/bin/env bash

koopa_macos_list_app_store_apps() {
    # """
    # List applications installed via the Mac App Store.
    # @note Updated 2023-03-29.
    # 
    # @seealso
    # - https://osxdaily.com/2013/09/28/list-mac-app-store-apps-terminal/
    # """
    local app string
    declare -A app
    app['find']="$(koopa_locate_find --allow-system)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    app['sort']="$(koopa_locate_sort --allow-system)"
    [[ -x "${app['find']}" ]] || exit 1
    [[ -x "${app['sed']}" ]] || exit 1
    [[ -x "${app['sort']}" ]] || exit 1
    string="$( \
        "${app['find']}" \
            '/Applications' \
            -maxdepth 4 \
            -path '*Contents/_MASReceipt/receipt' \
            -print \
        | "${app['sed']}" \
            -e 's#.app/Contents/_MASReceipt/receipt#.app#g' \
            -e 's#/Applications/##' \
        | "${app['sort']}" \
    )"
    [[ -n "$string" ]] || return 1
    koopa_print "$string"
    return 0
}

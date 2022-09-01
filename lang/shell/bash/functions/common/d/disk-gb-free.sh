#!/usr/bin/env bash

koopa_disk_gb_free() {
    # """
    # Available free disk space in GB.
    # @note Updated 2022-09-01.
    #
    # @examples
    # > koopa_disk_gb_free '/'
    # # 226
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['df']="$(koopa_locate_df)"
        ['head']="$(koopa_locate_head)"
        ['sed']="$(koopa_locate_sed)"
    )
    [[ -x "${app['df']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    declare -A dict
    dict['disk']="${1:?}"
    koopa_assert_is_readable "${dict['disk']}"
    # shellcheck disable=SC2016
    dict['str']="$( \
        POSIXLY_CORRECT=0 \
        "${app['df']}" --block-size='G' "${dict['disk']}" \
            | "${app['head']}" -n 2 \
            | "${app['sed']}" -n '2p' \
            | "${app['awk']}" '{print $4}' \
            | "${app['sed']}" 's/G$//' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

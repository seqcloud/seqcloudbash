#!/usr/bin/env bash

koopa_stat_user_name() {
    # """
    # Get the current user name of a file or directory.
    # @note Updated 2023-03-27.
    #
    # @examples
    # > koopa_stat_user_name '/tmp' "${HOME:?}"
    # # root
    # # mike
    # """
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    declare -A app dict
    if koopa_is_macos
    then
        app['stat']='/usr/bin/stat'
        dict['format_flag']='-f'
        dict['format_string']='%Su'
    else
        app['stat']="$(koopa_locate_stat --allow-system)"
        dict['format_flag']='--format'
        dict['format_string']='%U'
    fi
    [[ -x "${app['stat']}" ]] || return 1
    dict['out']="$( \
        "${app['stat']}" \
            "${dict['format_flag']}" \
            "${dict['format_string']}" \
            "$@" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}

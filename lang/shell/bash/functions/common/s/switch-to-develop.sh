#!/usr/bin/env bash

koopa_switch_to_develop() {
    # """
    # Switch koopa install to development version.
    # @note Updated 2023-05-14.
    #
    # @seealso
    # - https://stackoverflow.com/questions/49297153/
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['branch']='develop'
    dict['origin']='origin'
    dict['prefix']="$(koopa_koopa_prefix)"
    dict['remote_url']='git@github.com:acidgenomics/koopa.git'
    dict['user']="$(koopa_user_name)"
    koopa_alert "Switching koopa at '${dict['prefix']}' to '${dict['branch']}'."
    (
        koopa_cd "${dict['prefix']}"
        if [[ "$(koopa_git_branch "${PWD:?}")" == 'develop' ]]
        then
            koopa_alert_note "Already on 'develop' branch."
            return 0
        fi
        if koopa_is_github_ssh_enabled
        then
            "${app['git']}" remote set-url \
                "${dict['origin']}" "${dict['remote_url']}"
        fi
        "${app['git']}" remote set-branches \
            --add "${dict['origin']}" "${dict['branch']}"
        "${app['git']}" fetch "${dict['origin']}"
        "${app['git']}" checkout --track "${dict['origin']}/${dict['branch']}"
    )
    koopa_zsh_compaudit_set_permissions
    return 0
}

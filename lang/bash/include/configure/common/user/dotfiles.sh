#!/usr/bin/env bash

main() {
    # """
    # Configure dotfiles for current user.
    # @note Updated 2024-06-26.
    #
    # This also configures chezmoi to use our koopa managed dotfiles repo.
    #
    # Alternative approach:
    # > chezmoi init \
    # >     --apply \
    # >     --verbose \
    # >     https://github.com/acidgenomics/dotfiles.git
    #
    # For private repo, may need to pass '--ssh' flag.
    #
    # @seealso
    # - https://www.chezmoi.io/user-guide/setup/
    # - https://www.chezmoi.io/user-guide/include-files-from-elsewhere/
    # - https://www.chezmoi.io/reference/configuration-file/variables/
    # - https://blog.lazkani.io/posts/dotfiles-with-chezmoi/
    # """
    local -A app bool dict
    koopa_assert_has_args_le "$#" 1
    app['bash']="$(koopa_locate_bash --allow-bootstrap)"
    koopa_assert_is_executable "${app[@]}"
    bool['auto_config']=0
    dict['cm_prefix']="$(koopa_xdg_data_home)/chezmoi"
    dict['prefix']="${1:-}"
    if [[ -z "${dict['prefix']}" ]]
    then
        bool['auto_config']=1``
        dict['prefix']="$(koopa_dotfiles_prefix)"
    fi
    koopa_assert_is_dir "${dict['prefix']}"
    dict['install_script']="${dict['prefix']}/install"
    koopa_assert_is_file "${dict['install_script']}"
    # Link chezmoi to koopa dotfiles, when appropriate.
    if [[ ! -d "${dict['cm_prefix']}" ]]
    then
        koopa_ln "${dict['prefix']}" "${dict['cm_prefix']}"
    fi
    koopa_add_config_link "${dict['prefix']}" 'dotfiles'
    koopa_add_to_path_start "$(koopa_dirname "${app['bash']}")"
    "${app['bash']}" "${dict['install_script']}"
    if [[ "${bool['auto_config']}" -eq 1 ]]
    then
        dict['private_prefix']="$(koopa_dotfiles_private_prefix)"
        dict['private_install_script']="${dict['private_prefix']}/install"
        if [[ -f "${dict['private_install_script']}" ]]
        then
            "${app['bash']}" "${dict['private_install_script']}"
        fi
    fi
    return 0
}

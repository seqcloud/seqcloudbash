#!/usr/bin/env bash

# FIXME Let's use apt instead of gdebi here.

main() {
    # """
    # Install RStudio Server binary.
    # @note Updated 2023-03-21.
    #
    # RStudio Server Pro was renamed to Workbench in 2021-06.
    #
    # Verify install:
    # > sudo rstudio-server stop
    # > sudo rstudio-server verify-installation
    # > sudo rstudio-server start
    # > sudo rstudio-server status
    #
    # System config: /etc/rstudio
    #
    # @seealso
    # - https://docs.rstudio.com/rsp/installation/
    # - https://rstudio.com/products/rstudio/download-commercial/
    # - https://rstudio.com/products/rstudio/download-server/debian-ubuntu/
    # - https://rstudio.com/products/rstudio/download-server/redhat-centos/
    # Docker recipes:
    # - https://hub.docker.com/r/rocker/rstudio/dockerfile
    # - https://github.com/rocker-org/rocker-versioned/tree/master/rstudio
    # """
    local app conf_lines dict
    koopa_assert_has_no_args "$#"
    declare -A app
    app['r']="$(koopa_locate_system_r --realpath)"
    [[ -x "${app['r']}" ]] || return 1
    declare -A dict=(
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    if koopa_is_debian_like
    then
        app['fun']='koopa_debian_gdebi_install'
        dict['arch']="$(koopa_arch2)" # e.g 'amd64'.
        dict['distro']="$(koopa_debian_os_codename)"
        case "${dict['distro']}" in
            'jammy')
                ;;
            *)
                dict['distro']='bionic'
                ;;
        esac
        dict['file_ext']='deb'
    elif koopa_is_fedora_like
    then
        app['fun']='koopa_fedora_dnf_install'
        dict['arch']="$(koopa_arch)" # e.g. 'x86_64'.
        dict['distro']='centos8'
        dict['file_ext']='rpm'
        dict['init_dir']='/etc/init.d'
        if [[ ! -d "${dict['init_dir']}" ]]
        then
            koopa_mkdir --sudo "${dict['init_dir']}"
        fi
    else
        koopa_stop 'Unsupported Linux distro.'
    fi
    dict['file_stem']="${dict['name']}"
    if koopa_is_fedora_like
    then
        dict['file_stem']="${dict['file_stem']}-rhel"
    fi
    dict['file']="${dict['file_stem']}-${dict['version']}-\
${dict['arch']}.${dict['file_ext']}"
    dict['url']="https://download2.rstudio.org/server/${dict['distro']}/\
${dict['arch']}/${dict['file']}"
    # Ensure '+' gets converted to '-'.
    dict['url']="$( \
        koopa_gsub \
            --fixed \
            --pattern='+' \
            --replacement='-' \
            "${dict['url']}" \
    )"
    koopa_add_to_path_start "$(koopa_dirname "${app['r']}")"
    koopa_download "${dict['url']}" "${dict['file']}"
    "${app['fun']}" "${dict['file']}"
    # Don't enclose values in quotes in the conf file.
    conf_lines=()
    # Ensure RStudio Server is using our recommended version of R.
    conf_lines+=("rsession-which-r=${app['r']}")
    # Allow root user to log in without password, when applicable. This is
    # currently used by Latch Pods.
    if koopa_is_root
    then
        conf_lines+=(
            'auth-minimum-user-id=0'
            'auth-none=1'
        )
    fi
    dict['conf_string']="$(koopa_print "${conf_lines[@]}")"
    dict['conf_file']='/etc/rstudio/rserver.conf'
    koopa_sudo_write_string \
        --file="${dict['conf_file']}" \
        --string="${dict['conf_string']}"
    return 0
}

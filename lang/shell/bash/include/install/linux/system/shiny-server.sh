#!/usr/bin/env bash

main() {
    # """
    # Install Shiny Server binary.
    # @note Updated 2022-09-12.
    #
    # Currently Debian/Ubuntu and Fedora/RHEL are supported.
    # Currently only "amd64" (x86) architecture is supported here.
    #
    # @seealso
    # - https://www.rstudio.com/products/shiny/download-server/ubuntu/
    # - https://www.rstudio.com/products/shiny/download-server/redhat-centos/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['r']="$(koopa_locate_system_r)"
    )
    [[ -x "${app['r']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)" # e.g. 'x86_64'.
        ['arch2']="$(koopa_arch2)" # e.g. 'amd64'.
        ['name']='shiny-server'
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    if koopa_is_debian_like
    then
        app['fun']='koopa_debian_install_from_deb'
        # Changed from 14.04 to 18.04 in 2022-04.
        dict['distro']='ubuntu-18.04'
        dict['file_arch']="${dict['arch2']}"
        dict['file_ext']='deb'
    elif koopa_is_fedora_like
    then
        app['fun']='koopa_fedora_install_from_rpm'
        dict['distro']='centos7'
        dict['file_arch']="${dict['arch']}"
        dict['file_ext']='rpm'
    else
        koopa_stop 'Unsupported Linux distro.'
    fi
    dict['file']="${dict['name']}-${dict['version']}-\
${dict['file_arch']}.${dict['file_ext']}"
    dict['url']="https://download3.rstudio.org/${dict['distro']}/\
${dict['arch']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_configure_r "${app['r']}"
    if ! koopa_is_r_package_installed 'shiny'
    then
        koopa_alert 'Installing shiny R package.'
        "${app['r']}" -e 'install.packages("shiny")'
    fi
    "${app['fun']}" "${dict['file']}"
    return 0
}

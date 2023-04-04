#!/usr/bin/env bash

koopa_r_migrate_non_base_packages() {
    # """
    # Migrate non-base (i.e. "recommended") packages from R system library
    # to site library.
    # @note Updated 2023-04-04.
    # """
    local app pkgs
    declare -A app
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    readarray -t pkgs <<< "$( \
        koopa_r_system_packages_non_base "${app['r']}"
    )"
    if koopa_array_is_empty "${pkgs[@]:-}"
    then
        return 0
    fi
    koopa_alert_info 'Migrating non-base packages to site library.'
    koopa_dl 'Packages' "$(koopa_to_string "${pkgs[@]}")"
    koopa_r_install_packages_in_site_library "${app['r']}" "${pkgs[@]}"
    koopa_r_remove_packages_in_system_library "${app['r']}" "${pkgs[@]}"
    return 0
}

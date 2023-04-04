#!/usr/bin/env bash

koopa_r_install_packages_in_site_library() {
    # """
    # Install packages into R site library.
    # @note Updated 2023-04-04.
    # """
    local app dict
    declare -A app dict
    koopa_assert_has_args_ge "$#" 2
    app['r']="${1:?}"
    app['rscript']="${app['r']}script"
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['rscript']}" ]] || return 1
    shift 1
    dict['script']="$(koopa_koopa_prefix)/lang/r/\
install-packages-in-site-library.R"
    koopa_assert_is_file "${dict['script']}"
    "${app['rscript']}" "${dict['script']}" "$@"
    return 0
}

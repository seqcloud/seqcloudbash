#!/usr/bin/env bash

main() {
    # """
    # Install full Anaconda distribution.
    # @note Updated 2022-12-01.
    # """
    local -A app dict
    app['bash']="$(koopa_locate_bash --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch)"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['os_type']="$(koopa_os_type)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['py_maj_ver']='3'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    case "${dict['os_type']}" in
        'darwin'*)
            dict['os_type']='MacOSX'
            ;;
        'linux'*)
            dict['os_type']='Linux'
            ;;
        *)
            koopa_stop "'${dict['os_type']}' is not supported."
            ;;
    esac
    dict['file']="Anaconda${dict['py_maj_ver']}-${dict['version']}-\
${dict['os_type']}-${dict['arch']}.sh"
    dict['url']="https://repo.anaconda.com/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    # Need to include this on macOS, or we'll fail to locate md5.
    koopa_add_to_path_end '/sbin'
    koopa_print_env
    "${app['bash']}" "${dict['file']}" -bf -p "${dict['prefix']}"
    koopa_ln \
        "${dict['koopa_prefix']}/etc/conda/condarc" \
        "${dict['prefix']}/.condarc"
    return 0
}

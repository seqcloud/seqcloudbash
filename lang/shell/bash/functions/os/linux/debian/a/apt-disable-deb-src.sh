#!/usr/bin/env bash

koopa_debian_apt_disable_deb_src() {
    # """
    # Disable 'deb-src' source packages.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    koopa_assert_is_admin
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    app['sed']="$(koopa_locate_sed)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    dict['file']="${1:-}"
    [[ -z "${dict['file']}" ]] && \
        dict['file']="$(koopa_debian_apt_sources_file)"
    koopa_assert_is_file "${dict['file']}"
    koopa_alert "Disabling Debian sources in '${dict['file']}'."
    if ! koopa_file_detect_regex \
        --file="${dict['file']}" \
        --pattern='^deb-src '
    then
        koopa_alert_note "No lines to comment in '${dict['file']}'."
        return 0
    fi
    "${app['sudo']}" "${app['sed']}" \
        -E \
        -i.bak \
        's/^deb-src /# deb-src /' \
        "${dict['file']}"
    "${app['sudo']}" "${app['apt_get']}" update
    return 0
}

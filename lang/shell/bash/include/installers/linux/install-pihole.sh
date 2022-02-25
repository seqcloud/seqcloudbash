#!/usr/bin/env bash

linux_install_pihole() { # {{{1
    # """
    # Install Pi-hole.
    # @note Updated 2022-01-31.
    #
    # @seealso
    # - https://pi-hole.net
    # - https://github.com/pi-hole/pi-hole/#one-step-automated-install
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A dict=(
        [file]='pihole.sh'
        [url]='https://install.pi-hole.net'
    )
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    "./${dict[file]}"
    return 0
}

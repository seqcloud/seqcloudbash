#!/usr/bin/env bash

koopa:::macos_update_system() { # {{{1
    # """
    # Update macOS system.
    # @note Updated 2022-01-27.
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        # > [mas]="$(koopa::macos_locate_mas)"
        [softwareupdate]="$(koopa::macos_locate_softwareupdate)"
        [sudo]="$(koopa::locate_sudo)"
    )
    koopa::update_system
    # Updates using mas-cli are currently bugging on Monterey.
    # > koopa::alert "Updating App Store apps via '${app[mas]}'."
    # > "${app[mas]}" upgrade
    koopa::alert "Updating macOS via '${app[softwareupdate]}'."
    koopa::alert_note 'Restart may be required.'
    "${app[sudo]}" "${app[softwareupdate]}" \
        --install \
        --recommended \
        --restart
    return 0
}

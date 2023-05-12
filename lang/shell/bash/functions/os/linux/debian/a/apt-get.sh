#!/usr/bin/env bash

koopa_debian_apt_get() {
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2023-05-12.
    #
    # Ubuntu 22 is annoying about needrestart triggers breaking
    # non-interactive scripts.
    #
    # Currently intended for:
    # - dist-upgrade
    # - install
    #
    # @seealso
    # - man apt-get
    # - https://manpages.ubuntu.com/manpages/jammy/en/man8/apt-get.8.html
    # - https://manpages.ubuntu.com/manpages/jammy/man7/debconf.7.html
    # - https://manpages.ubuntu.com/manpages/xenial/man1/dpkg.1.html
    # - https://www.cyberciti.biz/faq/explain-debian_frontend-apt-get-variable-
    #     for-ubuntu-debian/
    # - https://github.com/moby/moby/issues/27988#issuecomment-462809153
    # """
    local -A app
    local -a apt_args
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['debconf_set_selections']="$( \
        koopa_debian_locate_debconf_set_selections \
    )"
    koopa_assert_is_executable "${app[@]}"
    apt_args=(
        '--assume-yes'
        '--no-install-recommends'
        '--quiet'
        '-o' 'Dpkg::Options::=--force-confdef'
        '-o' 'Dpkg::Options::=--force-confold'
    )
    # Dropping into a subshell here so we don't inherit any shell changes.
    (
        koopa_add_to_path_end '/usr/sbin' '/sbin'
        export DEBCONF_NONINTERACTIVE_SEEN='true'
        export DEBIAN_FRONTEND='noninteractive'
        export DEBIAN_PRIORITY='critical'
        export NEEDRESTART_MODE='a'
        "${app['cat']}" << END | koopa_sudo "${app['debconf_set_selections']}"
debconf debconf/frontend select Noninteractive
END
        koopa_sudo "${app['apt_get']}" "${apt_args[@]}" "$@"
    )
    return 0
}

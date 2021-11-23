#!/usr/bin/env bash

koopa:::install_git() { # {{{1
    # """
    # Install Git.
    # @note Updated 2021-11-23.
    #
    # If system doesn't have gettext (msgfmt) installed:
    # Note that this doesn't work on Ubuntu 18 LTS.
    # NO_GETTEXT=YesPlease
    #
    # Git source code releases on GitHub:
    # > file="v${version}.tar.gz"
    # > url="https://github.com/git/${name}/archive/${file}"
    # """
    local app dict
    if koopa::is_macos
    then
        koopa::activate_opt_prefix 'autoconf'
    fi
    declare -A app=(
        [make]="$(koopa::locate_make)"
        [openssl]="$(koopa::locate_openssl)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [mirror_url]='https://mirrors.edge.kernel.org/pub/software/scm/'
        [name]='git'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="${dict[mirror_url]}/${dict[name]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    "${app[make]}" configure
    ./configure \
        --prefix="${dict[prefix]}" \
        --with-openssl="${app[openssl]}"
    "${app[make]}" --jobs="${dict[jobs]}" V=1
    "${app[make]}" install
    return 0
}

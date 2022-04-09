#!/usr/bin/env bash

# FIXME If we set CPPFLAGS and LDFLAGS in opt_prefix, this should improve
# the install stack better...

main() { # {{{1
    # """
    # Install Git.
    # @note Updated 2022-04-09.
    #
    # If system doesn't have gettext (msgfmt) installed:
    # Note that this doesn't work on Ubuntu 18 LTS.
    # NO_GETTEXT=YesPlease
    #
    # Git source code releases on GitHub:
    # > file="v${version}.tar.gz"
    # > url="https://github.com/git/${name}/archive/${file}"
    #
    # @seealso
    # - https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/git.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'autoconf' 'openssl'
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [openssl]="$(koopa_locate_openssl)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [mirror_url]='https://mirrors.edge.kernel.org/pub/software/scm'
        [name]='git'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="${dict[mirror_url]}/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    "${app[make]}" configure
    ./configure --prefix="${dict[prefix]}"
    # Additional features here require 'asciidoc' to be installed.
    "${app[make]}" --jobs="${dict[jobs]}" # 'all' 'doc' 'info'
    "${app[make]}" install # 'install-doc' 'install-html' 'install-info'
    # Install the macOS keychain credential helper.
    if koopa_is_macos
    then
        (
            koopa_cd 'contrib/credential/osxkeychain'
            "${app[make]}" --jobs="${dict[jobs]}"
            "${app[make]}" install
        )
    fi
    return 0
}

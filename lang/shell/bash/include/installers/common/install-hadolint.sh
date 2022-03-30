#!/usr/bin/env bash

install_hadolint() { # {{{1
    # """
    # Install hadolint.
    # @note Updated 2022-03-29.
    #
    # @seealso
    # - https://github.com/hadolint/hadolint
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     hadolint.rb
    # """
    local app dict ghc_args
    declare -A app=(
        [stack]="$(koopa_locate_stack)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='hadolint'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/\
archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ghc_args=(
        '--no-install-ghc'
        '--skip-ghc-check'
        '--system-ghc'
    )
    "${app[stack]}" \
        --jobs="${dict[jobs]}" \
        build \
        "${ghc_args[@]}"
    "${app[stack]}" \
        --jobs="${dict[jobs]}" \
        --local-bin-path="${dict[prefix]}/bin" \
        install \
        "${ghc_args[@]}"
    return 0
}

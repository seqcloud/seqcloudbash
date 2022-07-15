#!/usr/bin/env bash

# FIXME Not yet suppored for ARM.

# FIXME Running into '-lgmp' linker issue on Ubuntu.
# https://github.com/commercialhaskell/stack/issues/5027

main() {
    # """
    # Install Haskell Stack.
    # @note Updated 2022-07-12.
    #
    # GHC will be installed at:
    # libexec/root/programs/x86_64-osx/ghc-9.0.2/bin
    #
    # Potentially useful arguments:
    # * '--allow-different-user'
    # * '--local-bin-path'
    # * '--stack-root'
    #
    # @seealso
    # - stack --help
    # - stack path
    # - stack exec env
    # - stack ghc, stack ghci, stack runghc, or stack exec
    # - https://docs.haskellstack.org/en/stable/install_and_upgrade/
    # - https://github.com/commercialhaskell/stack/releases
    # - GMP debugging info:
    #   https://github.com/commercialhaskell/stack/issues/2028
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'gmp'
    declare -A app
    declare -A dict=(
        [arch]="$(koopa_arch)" # e.g. 'x86_64'.
        [jobs]="$(koopa_cpu_count)"
        [name]='stack'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    app[stack]="${dict[prefix]}/bin/stack"
    if koopa_is_linux
    then
        dict[platform]='linux'
    elif koopa_is_macos
    then
        dict[platform]='osx'
    fi
    dict[root]="${dict[prefix]}/libexec"
    dict[file]="${dict[name]}-${dict[version]}-${dict[platform]}-\
${dict[arch]}-bin"
    dict[url]="https://github.com/commercialhaskell/${dict[name]}/releases/\
download/v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    koopa_cp "${dict[file]}" "${app[stack]}"
    unset -v STACK_ROOT
    koopa_rm "${HOME:?}/.stack"

    # FIXME This approach doesn't work.
    dict[opt_prefix]="$(koopa_opt_prefix)"
    dict[gmp]="$(koopa_realpath "${dict[opt_prefix]}/gmp")"
    export LIBRARY_PATH="${dict[gmp]}"

    "${app[stack]}" \
        --jobs="${dict[jobs]}" \
        --stack-root="${dict[root]}" \
        setup
    # NOTE Can install a specific GHC version here with:
    # > app[stack]="${dict[prefix]}/bin/stack"
    # > koopa_assert_is_installed "${app[stack]}"
    # > "${app[stack]}" install 'ghc-9.0.2'
    return 0
}

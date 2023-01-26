#!/usr/bin/env bash

main() {
    # """
    # Install Pandoc.
    # @note Updated 2023-01-26.
    #
    # @seealso
    # - https://hackage.haskell.org/package/pandoc
    # - https://hackage.haskell.org/package/pandoc-cli
    # - https://github.com/jgm/pandoc/blob/main/CONTRIBUTING.md
    # - https://github.com/jgm/pandoc/blob/main/INSTALL.md
    # - https://cabal.readthedocs.io/
    # - https://cabal.readthedocs.io/en/latest/nix-local-build-overview.html
    # - https://cabal.readthedocs.io/en/stable/cabal-project.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pandoc.rb
    # """
    local app build_deps dict
    koopa_assert_is_not_aarch64
    build_deps=('git' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    declare -A app=(
        ['cabal']="$(koopa_locate_cabal)"
        ['ghcup']="$(koopa_locate_ghcup)"
    )
    [[ -x "${app['cabal']}" ]] || return 1
    [[ -x "${app['ghcup']}" ]] || return 1
    declare -A dict=(
        ['ghc_version']='9.4.4'
        ['ghcup_prefix']="$(koopa_init_dir 'ghcup')"
        ['jobs']="$(koopa_cpu_count)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    case "${dict['version']}" in
        '3.0')
            dict['cli_version']='0.1'
            ;;
    esac
    koopa_assert_is_dir "${dict['zlib']}"
    dict['cabal_dir']="$(koopa_init_dir "${dict['prefix']}/libexec/cabal")"
    dict['ghc_prefix']="$(koopa_init_dir "ghc-${dict['ghc_version']}")"
    export CABAL_DIR="${dict['cabal_dir']}"
    export GHCUP_INSTALL_BASE_PREFIX="${dict['ghcup_prefix']}"
    koopa_print_env
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    koopa_add_to_path_start "${dict['ghc_prefix']}/bin"
    koopa_init_dir "${dict['prefix']}/bin"
    "${app['cabal']}" update
    dict['cabal_config_file']="${dict['cabal_dir']}/config"
    koopa_assert_is_file "${dict['cabal_config']}"
    read -r -d '' "dict[cabal_config_string]" << END || true
extra-include-dirs: ${dict['zlib']}/include
extra-lib-dirs: ${dict['zlib']}/lib
END
    koopa_append_string \
        --file="${dict['cabal_config_file']}" \
        --string="${dict['cabal_config_string']}"
    "${app['cabal']}" install \
        --install-method='copy' \
        --installdir="${dict['prefix']}/bin" \
        --jobs="${dict['jobs']}" \
        --verbose \
        "pandoc-${dict['version']}" \
        "pandoc-cli-${dict['cli_version']}"
    return 0
}

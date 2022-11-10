#!/usr/bin/env bash

# FIXME Hitting this issue with hadolint 2.12.0:
# 2022-11-09 14:01:18.632683: [debug] Asking for a supported GHC version
# 2022-11-09 14:01:18.632763: [debug] Resolving package entries
# 2022-11-09 14:01:18.632814: [debug] Parsing the targets
# 2022-11-09 14:01:18.634837: [error] Error parsing targets: The specified targets matched no packages.
# Perhaps you need to run 'stack init'?

main() {
    # """
    # Install hadolint.
    # @note Updated 2022-11-10.
    #
    # @seealso
    # - https://github.com/hadolint/hadolint
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     hadolint.rb
    # - https://github.com/commercialhaskell/stack/issues/4408
    # """
    local app dict
    koopa_activate_app --build-only 'haskell-stack'
    declare -A app=(
        ['stack']="$(koopa_locate_stack)"
    )
    [[ -x "${app['stack']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='hadolint'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['stack_root']="$(koopa_init_dir 'stack')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    # FIXME Need to run something like this for hadolint 2.11.0, 2.12.0...
    # May need to add "--resolver='nightly'" to the 'init' call.
    # > "${app['stack']}" \
    # >     --stack-root="${dict['stack_root']}" \
    # >     --verbose \
    # >     init --force
    "${app['stack']}" \
        --jobs="${dict['jobs']}" \
        --stack-root="${dict['stack_root']}" \
        --verbose \
        build
    "${app['stack']}" \
        --jobs="${dict['jobs']}" \
        --stack-root="${dict['stack_root']}" \
        --verbose \
        install \
            --local-bin-path="${dict['prefix']}/bin"
    return 0
}

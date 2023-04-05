#!/usr/bin/env bash

main() {
    # """
    # Install Rust (via rustup).
    # @note Updated 2022-11-03.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
    )
    [[ -x "${app['cut']}" ]] || exit 1
    [[ -x "${app['head']}" ]] || exit 1
    declare -A dict=(
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['tmp_prefix']='rustup'
        ['version']="${KOOPA_INSTALL_VERSION:?}" # or 'stable' toolchain
    )
    dict['cargo_home']="${dict['tmp_prefix']}"
    dict['rustup_home']="${dict['tmp_prefix']}"
    CARGO_HOME="${dict['cargo_home']}"
    RUSTUP_HOME="${dict['rustup_home']}"
    RUSTUP_INIT_SKIP_PATH_CHECK='yes'
    export CARGO_HOME RUSTUP_HOME RUSTUP_INIT_SKIP_PATH_CHECK
    koopa_mkdir "${dict['rustup_home']}"
    dict['url']='https://sh.rustup.rs'
    dict['file']='rustup.sh'
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod 'u+x' "${dict['file']}"
    "./${dict['file']}" -v -y \
        --default-toolchain 'none' \
        --no-modify-path
    app['rustup']="${dict['tmp_prefix']}/bin/rustup"
    koopa_assert_is_installed "${app['rustup']}"
    koopa_add_to_path_start "$(koopa_realpath "${dict['tmp_prefix']}/bin")"
    koopa_print_env
    "${app['rustup']}" install "${dict['version']}"
    "${app['rustup']}" default "${dict['version']}"
    dict['toolchain']="$( \
        "${app['rustup']}" toolchain list \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '1' \
    )"
    dict['toolchain_prefix']="${dict['tmp_prefix']}/toolchains/\
${dict['toolchain']}"
    koopa_assert_is_dir "${dict['toolchain_prefix']}"
    koopa_cp "${dict['toolchain_prefix']}" "${dict['prefix']}"
    return 0
}

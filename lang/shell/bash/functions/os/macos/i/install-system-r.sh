#!/usr/bin/env bash

koopa_macos_install_system_r() {
    koopa_install_app \
        --link-in-bin='R' \
        --link-in-bin='Rscript' \
        --name='r' \
        --no-prefix-check \
        --platform='macos' \
        --prefix="$(koopa_macos_r_prefix)" \
        --system \
        "$@"
}

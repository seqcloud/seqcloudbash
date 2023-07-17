#!/usr/bin/env bash

main() {
    koopa_activate_app --build-only 'cmake'
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='starship'
}

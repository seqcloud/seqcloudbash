#!/usr/bin/env bash

koopa_install_system_tex_packages() {
    koopa_install_app \
        --name='tex-packages' \
        --system \
        "$@"
}

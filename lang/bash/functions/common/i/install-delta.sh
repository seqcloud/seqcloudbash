#!/usr/bin/env bash

koopa_install_delta() {
    koopa_install_app \
        --installer='rust-package' \
        --name='delta' \
        "$@"
}

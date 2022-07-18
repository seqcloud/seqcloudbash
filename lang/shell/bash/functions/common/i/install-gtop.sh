#!/usr/bin/env bash

koopa_install_gtop() {
    koopa_install_app \
        --installer='node-package' \
        --link-in-bin='gtop' \
        --name='gtop' \
        "$@"
}

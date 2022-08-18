#!/usr/bin/env bash

koopa_install_parallel() {
    koopa_install_app \
        --link-in-bin='parallel' \
        --name='parallel' \
        "$@"
}

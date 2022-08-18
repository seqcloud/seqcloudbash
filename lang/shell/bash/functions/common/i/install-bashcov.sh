#!/usr/bin/env bash

koopa_install_bashcov() {
    koopa_install_app \
        --link-in-bin='bashcov' \
        --name='bashcov' \
        "$@"
}

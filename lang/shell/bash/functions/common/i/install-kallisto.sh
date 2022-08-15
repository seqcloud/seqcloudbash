#!/usr/bin/env bash

koopa_install_kallisto() {
    koopa_install_app \
        --link-in-bin='kallisto' \
        --name='kallisto' \
        "$@"
}

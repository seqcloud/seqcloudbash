#!/usr/bin/env bash

koopa_uninstall_openssl() {
    koopa_uninstall_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        "$@"
}

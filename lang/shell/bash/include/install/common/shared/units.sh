#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix 'readline'
    koopa_install_app_passthrough \
        --installer='gnu-app' \
        --name='units' \
        -D '--program-prefix=g' \
        "$@"

}

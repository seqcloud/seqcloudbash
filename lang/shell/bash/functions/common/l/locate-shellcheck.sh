#!/usr/bin/env bash

koopa_locate_shellcheck() {
    koopa_locate_app \
        --app-name='shellcheck' \
        --bin-name='shellcheck' \
        "$@" 
}

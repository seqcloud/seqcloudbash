#!/usr/bin/env bash

koopa_locate_emacs() {
    koopa_locate_app \
        --app-name='texi2cvi' \
        --bin-name='texinfo' \
        "$@"
}

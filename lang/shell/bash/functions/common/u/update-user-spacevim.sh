#!/usr/bin/env bash

koopa_update_user_spacevim() {
    koopa_update_app \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        "$@"
}

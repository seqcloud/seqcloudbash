#!/usr/bin/env bash

koopa_install_bowtie2() {
    koopa_install_app \
        --link-in-bin='bowtie2' \
        --name='bowtie2' \
        "$@"
}

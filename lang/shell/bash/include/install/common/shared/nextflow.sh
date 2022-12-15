#!/usr/bin/env bash

# FIXME Rework this to install from https://get.nextflow.io, rather than using
# bioconda, which is often out of date.
# FIXME Can pin to our internal openjdk.
# FIXME OpenJDK > 18 is not currently supported.

main() {
    koopa_install_app_subshell \
        --installer='conda-env' \
        --name='nextflow' \
        "$@"
}

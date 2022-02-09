#!/usr/bin/env bash

koopa:::install_r_packages() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2022-02-09.
    # """
    koopa::configure_r
    koopa::r_koopa 'cliInstallRPackages' "$@"
    return 0
}

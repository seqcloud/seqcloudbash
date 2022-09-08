#!/usr/bin/env bash

# FIXME Rework this.
# FIXME This command needs to be run at end of 'koopa install r'.
# Need to include: processx, rlang.

# LANG=""
# LC_ALL=
# LC_COLLATE="C"
# LC_CTYPE="C"
# LC_MESSAGES="C"
# LC_MONETARY="C"
# LC_NUMERIC="C"
# LC_TIME="C"

koopa_install_r_koopa() {
    # """
    # Install koopa R package.
    # @note Updated 2022-09-08.
    # """
    local app
    koopa_assert_has_args_le "$#" 1
    declare -A app
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    app['rscript']="${app['r']}script"
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['rscript']}" ]] || return 1
    "${app['rscript']}" -e " \
        if (!requireNamespace('BiocManager', quietly = TRUE)) { ; \
            install.packages('BiocManager') ; \
        } ; \
        install.packages(
            pkgs = 'koopa',
            repos = c(
                'https://r.acidgenomics.com',
                BiocManager::repositories()
            ),
            dependencies = TRUE
        ); \
    "
    return 0
}

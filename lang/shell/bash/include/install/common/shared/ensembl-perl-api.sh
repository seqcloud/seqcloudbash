#!/usr/bin/env bash

main() {
    # """
    # Install Ensembl Perl API.
    # @note Updated 2022-07-15.
    #
    # @seealso
    # - https://useast.ensembl.org/info/docs/api/api_installation.html
    # """
    local dict repo repos
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    koopa_git_clone \
        --branch='release-1-6-924' \
        --prefix="${dict['prefix']}/bioperl-live" \
        --url='https://github.com/bioperl/bioperl-live.git'
    # Can't version pin here easily.
    repos=(
        'ensembl-git-tools'
    )
    for repo in "${repos[@]}"
    do
        koopa_git_clone \
            --branch='main' \
            --prefix="${dict['prefix']}/${repo}" \
            --url="https://github.com/Ensembl/${repo}.git"
    done
    # Pin these to Ensembl release defined as version.
    repos=(
        'ensembl'
        'ensembl-compara'
        'ensembl-funcgen'
        'ensembl-io'
        'ensembl-variation'
    )
    for repo in "${repos[@]}"
    do
        koopa_git_clone \
            --branch="release/${dict['version']}" \
            --prefix="${dict['prefix']}/${repo}" \
            --url="https://github.com/Ensembl/${repo}.git"
    done
    return 0
}

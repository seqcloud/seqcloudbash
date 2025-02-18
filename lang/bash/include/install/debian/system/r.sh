#!/usr/bin/env bash

main() {
    # """
    # Install latest version of R from CRAN.
    # @note Updated 2025-02-18.
    #
    # In case of missing files in '/etc/R', such as ldpaths or Makeconf:
    # > sudo apt purge r-base-core
    # > sudo apt install r-base-core
    #
    # For additional cleanup, consider removing '/etc/R', '/usr/lib/R',
    # and '/usr/local/lib/R'.
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/
    # """
    local -A app bool dict
    local -a dep_pkgs pkgs
    bool['std_umask']=1
    ! koopa_has_standard_umask && bool['std_umask']=0
    if [[ "${bool['std_umask']}" -eq 0 ]]
    then
        app['umask']="$(koopa_locate_umask)"
        koopa_assert_is_executable "${app[@]}"
        dict['default_umask']="$("${app['umask']}")"
    fi
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dep_pkgs=(
        'autoconf'
        'bash'
        'bash-completion'
        'bc'
        'bison'
        'build-essential'
        'bzip2'
        'ca-certificates'
        'coreutils'
        'curl'
        'debhelper'
        'default-jdk'
        'findutils'
        'gdb'
        'gettext'
        'gfortran'
        'git'
        'gnupg'
        'groff-base'
        'less'
        'libblas-dev'
        'libbz2-dev'
        'libcairo2-dev'
        'libcurl4-openssl-dev'
        'libglpk-dev'
        'libjpeg-dev'
        'liblapack-dev'
        'liblzma-dev'
        'libncurses-dev'
        'libncurses5-dev'
        'libpango1.0-dev'
        'libpcre3-dev'
        'libpng-dev'
        'libreadline-dev'
        'libssl-dev'
        'libtiff5-dev'
        'libx11-dev'
        'libxml2-dev'
        'libxt-dev'
        'locales'
        'lsb-release'
        'man-db'
        'mpack'
        'pandoc'
        'python3'
        'python3-venv'
        'subversion'
        'sudo'
        'tcl8.6-dev'
        'texinfo'
        'texlive-base'
        'texlive-extra-utils'
        'texlive-fonts-extra'
        'texlive-fonts-recommended'
        'texlive-latex-base'
        'texlive-latex-extra'
        'texlive-latex-recommended'
        'tk8.6-dev'
        'tzdata'
        'unzip'
        'wget'
        'x11proto-core-dev'
        'xauth'
        'xdg-utils'
        'xfonts-base'
        'xvfb'
        'xz-utils'
        'zlib1g-dev'
    )
    if [[ "${bool['std_umask']}" -eq 0 ]]
    then
        "${app['umask']}" 0022
    fi
    koopa_debian_apt_install "${dep_pkgs[@]}"
    koopa_debian_apt_add_r_repo "${dict['version']}"
    pkgs=('r-base' 'r-base-dev')
    koopa_debian_apt_install "${pkgs[@]}"
    app['r']='/usr/bin/R'
    koopa_assert_is_executable "${app['r']}"
    koopa_configure_r "${app['r']}"
    if [[ "${bool['std_umask']}" -eq 0 ]]
    then
        "${app['umask']}" "${dict['default_umask']}"
    fi
    return 0
}

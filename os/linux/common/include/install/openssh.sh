#!/usr/bin/env bash

install_openssh() { # {{{1
    # """
    # Install OpenSSH.
    # @note Updated 2021-04-29.
    # """
    local file jobs prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    file="openssh-${version}.tar.gz"
    url="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/\
portable/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "openssh-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    make install
    return 0
}

install_openssh "$@"

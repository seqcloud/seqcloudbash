#!/usr/bin/env bash

install_ruby() { # {{{1
    # """
    # Install Ruby.
    # @note Updated 2021-04-29.
    # @seealso
    # - https://www.ruby-lang.org/en/downloads/
    # """
    local file jobs prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    # Ensure '2.7.1p83' becomes '2.7.1' here, for example.
    version="$(koopa::sanitize_version "$version")"
    minor_version="$(koopa::major_minor_version "$version")"
    file="ruby-${version}.tar.gz"
    url="https://cache.ruby-lang.org/pub/ruby/${minor_version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "ruby-${version}"
    # This will fail on Ubuntu 18 otherwise.
    # https://github.com/rbenv/ruby-build/issues/156
    # https://github.com/rbenv/ruby-build/issues/729
    export RUBY_CONFIGURE_OPTS='--disable-install-doc'
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    make install
    return 0
}

install_ruby "$@"

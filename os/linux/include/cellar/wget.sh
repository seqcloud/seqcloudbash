#!/usr/bin/env bash
# shellcheck disable=SC2154

file="${name}-${version}.tar.xz"
url="${gnu_mirror}/${name}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./configure --prefix="$prefix" --with-ssl="openssl"
make --jobs="$jobs"
make install

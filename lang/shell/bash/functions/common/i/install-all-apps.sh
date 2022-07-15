#!/usr/bin/env bash

koopa_install_all_apps() {
    # ""
    # Install all shared apps as binary packages.
    # @note Updated 2022-07-15.
    # """
    local pkgs
    koopa_assert_has_no_args "$#"
    pkgs=(
        'ack'
        'anaconda'
        'apr'
        'apr-util'
        'armadillo'
        'aspell'
        'autoconf'
        'automake'
        'aws-cli'
        'azure-cli'
        'bash'
        'bash-language-server'
        'bashcov'
        'bat'
        'bc'
        'binutils'
        'bison'
        'black'
        'boost'
        'bpytop'
        'broot'
        'bzip2'
        'cairo'
        'chemacs'
        'chezmoi'
        'cmake'
        'colorls'
        'conda'
        'coreutils'
        'cpufetch'
        'curl'
        'delta'
        'difftastic'
        'dotfiles'
        'du-dust'
        'emacs'
        'ensembl-perl-api'
        'exa'
        'exiftool'
        'fd-find'
        'ffmpeg'
        'ffq'
        'findutils'
        'fish'
        'flac'
        'flake8'
        'fltk'
        'fontconfig'
        'freetype'
        'fribidi'
        'fzf'
        'gawk'
        'gcc'
        'gdal'
        'gdbm'
        'geos'
        'gettext'
        'gget'
        'git'
        'glances'
        'glib'
        'gmp'
        'gnupg'
        'gnutls'
        'go'
        'google-cloud-sdk'
        'gperf'
        'graphviz'
        'grep'
        'groff'
        'gsl'
        'gtop'
        'gzip'
        'hadolint'
        'harfbuzz'
        'haskell-stack'
        'hdf5'
        'htop'
        'hyperfine'
        'icu4c'
        'imagemagick'
        'ipython'
        'isort'
        'jpeg'
        'jq'
        'julia'
        'kallisto'
        'lame'
        'lapack'
        'latch'
        'less'
        'lesspipe'
        'libedit'
        'libevent'
        'libffi'
        'libgeotiff'
        'libgit2'
        'libidn'
        'libjpeg-turbo'
        'libpipeline'
        'libpng'
        'libssh2'
        'libtasn1'
        'libtiff'
        'libtool'
        'libunistring'
        'libuv'
        'libxml2'
        'libzip'
        'lua'
        'luarocks'
        'lz4'
        'lzma'
        'lzo'
        'm4'
        'make'
        'man-db'
        'mcfly'
        'mdcat'
        'meson'
        'mpc'
        'mpfr'
        'ncurses'
        'neofetch'
        'neovim'
        'nettle'
        'nim'
        'ninja'
        'node'
        'oniguruma'
        'openblas'
        'openjdk'
        'openssh'
        'openssl1'
        'openssl3'
        'pandoc'
        'parallel'
        'password-store'
        'patch'
        'pcre'
        'pcre2'
        'perl'
        'pipx'
        'pixman'
        'pkg-config'
        'poetry'
        'prettier'
        'procs'
        'proj'
        'pyflakes'
        'pygments'
        'pylint'
        'pytaglib'
        'pytest'
        'python'
        'r'
        'ranger-fm'
        'readline'
        'rename'
        'ripgrep'
        'ronn'
        'rsync'
        'ruby'
        'rust'
        'salmon'
        'scons'
        'sed'
        'serf'
        'shellcheck'
        'shunit2'
        'snakemake'
        'sox'
        'sqlite'
        'starship'
        'stow'
        'subversion'
        'taglib'
        'tar'
        'tcl-tk'
        'tealdeer'
        'texinfo'
        'tmux'
        'tokei'
        'tree'
        'tuc'
        'udunits'
        'units'
        'utf8proc'
        'vim'
        'wget'
        'which'
        'xorg-libice'
        'xorg-libpthread-stubs'
        'xorg-libsm'
        'xorg-libx11'
        'xorg-libxau'
        'xorg-libxcb'
        'xorg-libxdmcp'
        'xorg-libxext'
        'xorg-libxrandr'
        'xorg-libxrender'
        'xorg-libxt'
        'xorg-xcb-proto'
        'xorg-xorgproto'
        'xorg-xtrans'
        'xsv'
        'xxhash'
        'xz'
        'yt-dlp'
        'zellij'
        'zoxide'
        'zsh'
        'zstd'
    )
    koopa_cli_install --binary --reinstall "${pkgs[@]}"
    return 0
}

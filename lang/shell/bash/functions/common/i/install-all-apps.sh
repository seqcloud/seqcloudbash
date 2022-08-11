#!/usr/bin/env bash

koopa_install_all_apps() {
    # ""
    # Install all shared apps as binary packages.
    # @note Updated 2022-08-11.
    #
    # This will currently fail for platforms where not all apps can be
    # successfully compiled, such as ARM.
    #
    # Need to install PCRE libraries before grep.
    # """
    local pkgs
    koopa_assert_has_no_args "$#"
    pkgs=(
        # Priority -------------------------------------------------------------
        'openssl1'
        'openssl3'
        'curl'
        'pcre'
        'pcre2'
        'grep'
        # Alphabetical ---------------------------------------------------------
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
        'bamtools'
        'bash'
        'bash-language-server'
        'bashcov'
        'bat'
        'bc'
        'bedtools'
        'binutils'
        'bioawk'
        'bison'
        'black'
        'boost'
        'bowtie2'
        'bpytop'
        'broot'
        'bustools'
        'bzip2'
        'ca-certificates'
        'cairo'
        'cheat'
        'chemacs'
        'chezmoi'
        'cmake'
        'colorls'
        'conda'
        'coreutils'
        'cpufetch'
        # > 'curl'
        'deeptools'
        'delta'
        'difftastic'
        'dotfiles'
        'du-dust'
        'emacs'
        'ensembl-perl-api'
        'entrez-direct'
        'exa'
        'exiftool'
        'expat'
        'fastqc'
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
        'gffutils'
        'gget'
        'ghostscript'
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
        # > 'grep'
        'groff'
        'gseapy'
        'gsl'
        'gtop'
        'gzip'
        'hadolint'
        'harfbuzz'
        'haskell-stack'
        'hdf5'
        'hisat2'
        'htop'
        'hyperfine'
        'icu4c'
        'imagemagick'
        'ipython'
        'isort'
        'jpeg'
        'jq'
        'julia'
        'jupyterlab'
        'kallisto'
        'lame'
        'lapack'
        'latch'
        'less'
        'lesspipe'
        'libassuan'
        'libedit'
        'libevent'
        'libffi'
        'libgcrypt'
        'libgeotiff'
        'libgit2'
        'libgpg-error'
        'libidn'
        'libjpeg-turbo'
        'libksba'
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
        'lzo'
        'm4'
        'make'
        'man-db'
        'mcfly'
        'mdcat'
        'meson'
        'mpc'
        'mpfr'
        'multiqc'
        'ncurses'
        'neofetch'
        'neovim'
        'nettle'
        'nextflow'
        'nim'
        'ninja'
        'node'
        'npth'
        'oniguruma'
        'openblas'
        'openjdk'
        # > 'openssl1'
        # > 'openssl3'
        'openssh'
        'pandoc'
        'parallel'
        'password-store'
        'patch'
        # > 'pcre'
        # > 'pcre2'
        'perl'
        'pipx'
        'pixman'
        'pkg-config'
        'poetry'
        'prettier'
        'procs'
        'proj'
        'pyenv'
        'pyflakes'
        'pygments'
        'pylint'
        'pytaglib'
        'pytest'
        'python'
        'r'
        'r-devel'
        'ranger-fm'
        'rbenv'
        'readline'
        'rename'
        'ripgrep'
        'ronn'
        'rsync'
        'ruby'
        'rust'
        'salmon'
        'sambamba'
        'samtools'
        'scons'
        'sed'
        'serf'
        'shellcheck'
        'shunit2'
        'snakemake'
        'sox'
        'sqlite'
        'sra-tools'
        'star'
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
        'visidata'
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
        'yq'
        'yt-dlp'
        'zellij'
        'zlib'
        'zoxide'
        'zsh'
        'zstd'
    )
    if koopa_is_linux
    then
        pkgs+=(
            'apptainer'
            'aspera-connect'
            'docker-credential-pass'
            'lmod'
            'pinentry'
        )
    fi
    koopa_cli_install --binary "${pkgs[@]}"
    return 0
}

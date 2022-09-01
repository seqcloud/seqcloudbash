#!/usr/bin/env bash

# FIXME Rework this to parse app.json file instead.

koopa_install_all_apps() {
    # ""
    # Install all shared apps as binary packages.
    # @note Updated 2022-09-01.
    #
    # This will currently fail for platforms where not all apps can be
    # successfully compiled, such as ARM.
    #
    # Need to install PCRE libraries before grep.
    # """
    local dict pkgs
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['blocks']="$(koopa_disk_512k_blocks '/')"
        ['large']=0
    )
    [[ "${dict['blocks']}" -ge 500000000 ]] && dict['large']=1
    pkgs=()
    # Priority -----------------------------------------------------------------
    pkgs+=(
        'zlib'
        'openssl1'
        'openssl3'
        'curl'
        'pcre'
        'pcre2'
        'grep'
    )
    # Alphabetical -------------------------------------------------------------
    pkgs+=(
        'ack'
        'apr'
        'apr-util'
        'armadillo'
        'asdf'
        'aspell'
        'autoconf'
        'autoflake'
        'automake'
        'aws-cli'
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
        'c-ares'
        'ca-certificates'
        'cairo'
        'cheat'
        'chemacs'
        'chezmoi'
        'cmake'
        'colorls'
        'conda'
        'convmv'
        'coreutils'
        'cpufetch'
        'delta'
        'difftastic'
        'dog'
        'dotfiles'
        'du-dust'
        'editorconfig'
        'emacs'
        'ensembl-perl-api'
        'entrez-direct'
        'exa'
        'exiftool'
        'expat'
        'fd-find'
        'ffmpeg'
        'ffq'
        'findutils'
        'fish'
        'flac'
        'flake8'
        'flex'
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
        'ghostscript'
        'git'
        'glances'
        'glib'
        'gmp'
        'gnupg'
        'gnutls'
        'gperf'
        'graphviz'
        'groff'
        'gsl'
        'gtop'
        'gzip'
        'hadolint'
        'harfbuzz'
        'hdf5'
        'htop'
        'hyperfine'
        'icu4c'
        'imagemagick'
        'ipython'
        'isort'
        'jemalloc'
        'jpeg'
        'jq'
        'jupyterlab'
        'lame'
        'lapack'
        'less'
        'lesspipe'
        'libassuan'
        'libedit'
        'libev'
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
        'markdownlint-cli'
        'mcfly'
        'mdcat'
        'meson'
        'mpc'
        'mpfr'
        'ncurses'
        'neofetch'
        'neovim'
        'nettle'
        'nghttp2'
        'ninja'
        'nmap'
        'node'
        'npth'
        'oniguruma'
        'openblas'
        'openjdk'
        'openssh'
        'pandoc'
        'parallel'
        'password-store'
        'patch'
        'perl'
        'pipx'
        'pixman'
        'pkg-config'
        'poetry'
        'prettier'
        'procs'
        'proj'
        'pycodestyle'
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
        'ripgrep-all'
        'rmate'
        'ronn'
        'rsync'
        'ruby'
        'ruff'
        'scons'
        'sed'
        'serf'
        'shellcheck'
        'shunit2'
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
        'unzip'
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
        'yarn'
        'yq'
        'yt-dlp'
        'zellij'
        'zoxide'
        'zsh'
        'zstd'
    )
    # Platform-specific --------------------------------------------------------
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
    # Large machines only ------------------------------------------------------
    # NOTE Consider defining these in app.json.
    if [[ "${dict['large']}" -eq 1 ]]
    then
        pkgs+=(
            'anaconda'
            'sambamba'
            'samtools'
            'salmon'
            'bamtools'
            'bedtools'
            'htseq'
            'julia'
            'multiqc'
            'nextflow'
            'star'
            'bioawk'
            'bustools'
            'gffutils'
            'kallisto'
            'azure-cli'
            'bioconda-utils'
            'bowtie2'
            'deeptools'
            'fastqc'
            'gget'
            'go'
            'google-cloud-sdk'
            'gseapy'
            'haskell-stack'
            'hisat2'
            'latch'
            'nim'
            'rust'
            'snakemake'
            'sra-tools'
        )
    fi
    for pkg in "${pkgs[@]}"
    do
        PATH="${KOOPA_PREFIX:?}/bootstrap/bin:${PATH:-}" \
            koopa install --binary "$pkg" || true
    done
    return 0
}

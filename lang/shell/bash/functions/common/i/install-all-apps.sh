#!/usr/bin/env bash

koopa_install_all_apps() {
    # ""
    # Install all shared apps as binary packages.
    # @note Updated 2022-09-09.
    #
    # This will currently fail for platforms where not all apps can be
    # successfully compiled, such as ARM.
    #
    # Need to install PCRE libraries before grep.
    # """
    local app_name apps dict
    koopa_assert_has_no_args "$#"
    declare -A app
    app['koopa']="$(koopa_locate_koopa)"
    [[ -x "${app['koopa']}" ]] || return 1
    declare -A dict=(
        ['blocks']="$(koopa_disk_512k_blocks '/')"
        ['bs_bin_prefix']="$(koopa_bootstrap_bin_prefix)"
        ['large']=0
    )
    [[ "${dict['blocks']}" -ge 500000000 ]] && dict['large']=1
    apps=()
    # Priority -----------------------------------------------------------------
    koopa_is_linux && apps+=('attr')
    apps+=(
        'zlib'
        'zstd'
        'bzip2'
        'ca-certificates'
        'openssl1'
        'openssl3'
        'curl'
        'm4'
        'gmp'
        'coreutils'
        'findutils'
        'pcre'
        'pcre2'
        'grep'
        'sed'
    )
    # Alphabetical -------------------------------------------------------------
    apps+=(
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
        'c-ares'
        'cairo'
        'cheat'
        'chemacs'
        'chezmoi'
        'cmake'
        'colorls'
        'conda'
        'convmv'
        'cpufetch'
        'delta'
        'difftastic'
        'dog'
        'dotfiles'
        'du-dust'
        'editorconfig'
        'emacs'
        'entrez-direct'
        'exa'
        'exiftool'
        'expat'
        'fd-find'
        'ffmpeg'
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
        'libiconv'
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
        'make'
        'man-db'
        'markdownlint-cli'
        'mcfly'
        'mdcat'
        'meson'
        'mpc'
        'mpfr'
        'msgpack'
        'ncurses'
        'neofetch'
        'neovim'
        'nettle'
        'nghttp2'
        'ninja'
        'nmap'
        'node'
        'npth'
        'nushell'
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
        'py-spy'
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
        'serf'
        'shellcheck'
        'shunit2'
        'sox'
        'sqlite'
        'starship'
        'stow'
        'subversion'
        'swig'
        'taglib'
        'tar'
        'tcl-tk'
        'tealdeer'
        'texinfo'
        'tmux'
        'tokei'
        'tree'
        'tree-sitter'
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
    )
    # Platform-specific --------------------------------------------------------
    if koopa_is_linux
    then
        apps+=(
            'apptainer'
            'aspera-connect'
            'docker-credential-pass'
            'elfutils'
            'lmod'
            'pinentry'
        )
    fi
    # Large machines only ------------------------------------------------------
    # NOTE Consider defining these in app.json.
    if [[ "${dict['large']}" -eq 1 ]]
    then
        apps+=(
            'anaconda'
            'azure-cli'
            'bamtools'
            'bedtools'
            'bioawk'
            'bioconda-utils'
            'bowtie2'
            'bustools'
            'deeptools'
            'ensembl-perl-api'
            'fastqc'
            'ffq'
            'gffutils'
            'gget'
            'go'
            'google-cloud-sdk'
            'gseapy'
            'haskell-stack'
            'hisat2'
            'htseq'
            'julia'
            'kallisto'
            'latch'
            'llvm'
            'multiqc'
            'nextflow'
            'nim'
            'rust'
            'salmon'
            'sambamba'
            'samtools'
            'snakefmt'
            'snakemake'
            'sra-tools'
            'star'
        )
    fi
    for app_name in "${apps[@]}"
    do
        PATH="${dict['bs_bin_prefix']}:${PATH:-}" \
            "${app['koopa']}" install --binary "$app_name"
    done
    return 0
}

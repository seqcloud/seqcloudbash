#!/usr/bin/env bash

koopa_install_all_apps() {
    # """
    # Build and install all koopa apps from source.
    # @note Updated 2022-12-15.
    #
    # The approach calling 'koopa_cli_install' internally on apps array
    # can run into weird compilation issues on macOS.
    # """
    local app app_name apps bool push_apps
    koopa_assert_has_no_args "$#"
    declare -A app
    app['koopa']="$(koopa_locate_koopa)"
    [[ -x "${app['koopa']}" ]] || return 1
    declare -A bool
    bool['large']=0
    koopa_has_large_system_disk && bool['large']=1
    apps=()
    apps+=(
        'make'
        'pkg-config'
    )
    koopa_is_linux && apps+=('attr')
    apps+=(
        'zlib'
        'patch'
        'tar'
        'xz'
        'bzip2'
        'm4'
        'gmp'
        'gperf'
        'mpfr'
        'mpc'
        'gcc'
        'autoconf'
        'automake'
        'libtool'
        'unzip'
        'zip'
        'bison'
        'coreutils'
        'findutils'
        'sed'
        'ncurses'
        'icu4c'
        'readline'
        'libiconv'
        'libunistring'
        'libxml2'
        'gettext'
        'nano'
        'ca-certificates'
        'openssl1'
        'openssl3'
        'cmake'
        'zstd'
        'curl'
        # NOTE This requires bootstrap on macOS.
        'bash'
        'git'
        'lapack'
        'libffi'
        'libjpeg-turbo'
        'libpng'
        'libtiff'
        'openblas'
        'pcre'
        'pcre2'
        'expat'
        'gdbm'
        'sqlite'
        'mpdecimal'
        'xorg-xorgproto'
        'xorg-xcb-proto'
        'xorg-libpthread-stubs'
        'xorg-xtrans'
        'xorg-libice'
        'xorg-libsm'
        'xorg-libxau'
        'xorg-libxdmcp'
        'xorg-libxcb'
        'xorg-libx11'
        'xorg-libxext'
        'xorg-libxrender'
        'xorg-libxt'
        'xorg-libxrandr'
        'tcl-tk'
        'libedit'
        'python3.10'
        'python3.11'
        'perl'
        'texinfo'
        'meson'
        'ninja'
        'glib'
        'freetype'
        'fontconfig'
        'lzo'
        'pixman'
        'cairo'
        'hdf5'
        'openjdk'
        'libssh2'
        'libgit2'
        'jpeg'
        'nettle'
        'libzip'
        'imagemagick'
        'graphviz'
        'geos'
        'proj'
        'gdal'
        'fribidi'
        'harfbuzz'
        'gawk'
        'libuv'
        'udunits'
        'gzip'
        'less'
        'r'
        'apr'
        'apr-util'
        'armadillo'
        'aspell'
        'bc'
        'flex'
        'binutils'
        'cpufetch'
        'exiftool'
        'libtasn1'
        'texinfo'
        'gnutls'
        'emacs'
        'vim'
        'lua'
        # > 'luajit'
        'luarocks'
        'libevent'
        'utf8proc'
        'tmux'
        'htop'
        'boost'
        'fish'
        'zsh'
        'lame'
        'ffmpeg'
        'flac'
        'fltk'
        'libgpg-error'
        'libgcrypt'
        'libassuan'
        'libksba'
        'npth'
    )
    koopa_is_linux && apps+=('pinentry')
    apps+=(
        'gnupg'
        'grep'
        'groff'
        'gsl'
        'oniguruma'
        'jq'
        'lesspipe'
        'libidn'
        'libpipeline'
        'lz4'
        'man-db'
        'neofetch'
        'parallel'
        'password-store'
        'taglib'
        'pytaglib'
        'pytest'
        'xxhash'
        'rsync'
        'scons'
        'serf'
        'ruby'
        'subversion'
        'r-devel'
        'shellcheck'
        'shunit2'
        'sox'
        'stow'
        'tree'
        'units'
        'wget'
        'which'
        'libgeotiff'
        'swig'
    )
    koopa_is_linux && apps+=('elfutils')
    apps+=(
        'go'
        'chezmoi'
        'fzf'
        'git-lfs'
        'aws-cli'
        'autoflake'
        'black'
        'bpytop'
        'flake8'
        'glances'
        'httpie'
        'ipython'
        'isort'
        'latch'
        'pipx'
        'poetry'
        'py-spy'
        'pycodestyle'
        'pyflakes'
        'pygments'
        'pylint'
        'radian'
        'ranger-fm'
        'ruff'
        'visidata'
        'yt-dlp'
        'openssh'
        'c-ares'
        'jemalloc'
        'libev'
        'nghttp2'
        'node'
        'rust'
        'bat'
        'broot'
        'delta'
        'difftastic'
        'dog'
        'du-dust'
        'exa'
        'fd-find'
        'hyperfine'
        'lsd'
        'mcfly'
        'mdcat'
        'nushell'
        'procs'
        'ripgrep'
        'ripgrep-all'
        'starship'
        'tealdeer'
        'tokei'
        'tree-sitter'
        'tuc'
        'xsv'
        'zellij'
        'zoxide'
        'chemacs'
        'cheat'
        'gum'
        'yq'
        'bash-language-server'
        'gtop'
        'prettier'
        'ack'
        'rename'
        'bashcov'
        'colorls'
        'ronn'
        'pyenv'
        'rbenv'
        'dotfiles'
        'yarn'
        'asdf'
        'bfg'
        'convmv'
        'editorconfig'
        'markdownlint-cli'
        'nmap'
        'rmate'
        # > 'libluv'
        # > 'libtermkey'
        # > 'libvterm'
        # > 'msgpack'
        # > 'tree-sitter'
        # > 'unibilium'
        'neovim'
        'csvkit'
        'csvtk'
        'vulture'
        'diff-so-fancy'
        'bottom'
        'grex'
        'hexyl'
        'sd'
        'hugo'
        'llama'
    )
    if koopa_is_linux
    then
        apps+=(
            'apptainer' # FIXME large.
            'lmod' # FIXME large.
        )
        if ! koopa_is_aarch64
        then
            apps+=(
                'aspera-connect' # FIXME large.
                'docker-credential-pass'
            )
        fi
    fi
    # Build mamba (experimental).
    apps+=(
        'cli11'
        'fmt'
        'googletest'
        'libarchive'
        'libsolv'
        'nlohmann-json'
        'pybind11'
        'reproc'
        'spdlog'
        'termcolor'
        'tl-expected'
        'yaml-cpp'
        'mamba'
    )
    if [[ "${bool['large']}" -eq 1 ]]
    then
        apps+=(
            'apache-airflow'
            'apache-spark'
            'azure-cli'
            'ensembl-perl-api'
            'google-cloud-sdk'
            'gseapy'
            'haskell-ghcup'
            'haskell-cabal'
            'llvm'
            'julia'
            'nim'
        )
        if ! koopa_is_aarch64
        then
            apps+=(
                'haskell-stack'
                'hadolint'
                'pandoc'
                'agat'
                'conda'
                'anaconda'
                'autodock'
                'autodock-vina'
                'bioconda-utils'
                'bamtools'
                'bedtools'
                'bioawk'
                'bowtie2'
                'bustools'
                'deeptools'
                'entrez-direct'
                'fastqc'
                'ffq'
                'fq'
                'gatk'
                'gffutils'
                'gget'
                'ghostscript'
                'hisat2'
                'htseq'
                'jupyterlab'
                'kallisto'
                'multiqc'
                'nanopolish'
                'nextflow'
                'openbb'
                'salmon'
                'sambamba'
                'samtools'
                'snakefmt'
                'snakemake'
                'star'
                'sra-tools'
            )
        fi
    fi
    koopa_add_to_path_start '/usr/local/bin'
    for app_name in "${apps[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix --allow-missing "$app_name")"
        koopa_alert "$prefix"
        [[ -d "$prefix" ]] && continue
        "${app['koopa']}" install "$app_name"
        push_apps+=("$app_name")
    done
    if koopa_can_install_binary && \
        koopa_is_array_non_empty "${push_apps[@]:-}"
    then
        for app_name in "${push_apps[@]}"
        do
            koopa_push_app_build "$app_name"
        done
    fi
    return 0
}

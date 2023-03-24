#!/usr/bin/env bash

# NOTE Consider adding support for '--no-push' flag.

koopa_install_all_apps() {
    # """
    # Build and install all koopa apps from source.
    # @note Updated 2023-03-24.
    #
    # The approach calling 'koopa_cli_install' internally on apps array
    # can run into weird compilation issues on macOS.
    # """
    local app app_name apps bool dict push_apps
    koopa_assert_has_no_args "$#"
    declare -A app
    app['koopa']="$(koopa_locate_koopa)"
    [[ -x "${app['koopa']}" ]] || return 1
    declare -A bool
    bool['large']=0
    koopa_has_large_system_disk && bool['large']=1
    declare -A dict=(
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=14
    )
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "${dict['mem_gb_cutoff']} GB of RAM is required."
    fi
    apps=()
    apps+=('make' 'pkg-config')
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
        'isl'
        'ca-certificates'
        'openssl1'
        'openssl3'
        'cmake'
        'lz4'
        'zstd'
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
        'curl'
        'curl7'
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
        'libedit'
        'python3.10'
        'python3.11'
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
        'groff'
        'less'
        'quarto'
        'r'
        'apr'
        'apr-util'
        'armadillo'
        'aspell'
        'lzip'
        'ed'
        'bc'
        'flex'
        'binutils'
        'cpufetch'
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
        'gsl'
        'oniguruma'
        'jq'
        'lesspipe'
        'libidn'
        'libpipeline'
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
        'libyaml'
        'ruby'
        'subversion'
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
        'gh'
        'git-lfs'
        'miller'
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
        'yapf'
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
        'ack'
        'exiftool'
        'rename'
        'bash-language-server'
        'gtop'
        'prettier'
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
        if ! koopa_is_aarch64
        then
            apps+=('docker-credential-pass')
        fi
    # > elif koopa_is_macos
    # > then
    # >     apps+=('trash')
    fi
    if [[ "${bool['large']}" -eq 1 ]]
    then
        apps+=(
            'r-devel'
            'apache-airflow'
            'apache-spark'
            'azure-cli'
            'ensembl-perl-api'
            'google-cloud-sdk'
            'haskell-ghcup'
            'haskell-cabal'
            'llvm'
            'julia'
            # > 'nim'
            'ghostscript'
            # > 'haskell-stack'
            'hadolint'
            'pandoc'
            'shellcheck'
            'conda'
            'anaconda'
        )
        if ! koopa_is_aarch64
        then
            apps+=(
                'agat'
                'autodock'
                'autodock-vina'
                # > 'bioconda-utils'
                'bamtools'
                'bedtools'
                'bioawk'
                'bowtie2'
                'bustools'
                'deeptools'
                'entrez-direct'
                'fastqc'
                'ffq'
                'fgbio'
                'fq'
                'fqtk'
                'gatk'
                'gffutils'
                'gget'
                'gseapy'
                'hisat2'
                'htseq'
                'jupyterlab'
                'kallisto'
                'minimap2'
                # > 'misopy'
                'multiqc'
                'nanopolish'
                'nextflow'
                'openbb'
                'picard'
                'rsem'
                'salmon'
                'sambamba'
                'samtools'
                'seqkit'
                'snakefmt'
                'snakemake'
                'star'
                'star-fusion'
                'subread'
                'sra-tools'
                'scalene'
                'umis'
            )
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
        if koopa_is_linux
        then
            apps+=(
                'apptainer'
                'aspera-connect'
                'lmod'
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

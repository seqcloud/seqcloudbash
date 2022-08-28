#!/usr/bin/env bash

koopa_build_all_apps() {
    # """
    # Build and install all koopa apps from source.
    # @note Updated 2022-08-16.
    #
    # The approach calling 'koopa_cli_install' internally on pkgs array
    # can run into weird compilation issues on macOS.
    #
    # @section Bootstrap workaround for macOS:
    # > /opt/koopa/include/bootstrap.sh
    # > PATH="${TMPDIR}/koopa-bootstrap/bin:${PATH}"
    # """
    local app dict pkg pkgs
    koopa_assert_has_no_args "$#"
    [[ -n "${KOOPA_AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" ]] || return 1
    declare -A app=(
        ['koopa']="$(koopa_locate_koopa)"
    )
    [[ -x "${app['koopa']}" ]] || return 1
    declare -A dict=(
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    pkgs=()
    pkgs+=(
        # deps: make (system).
        'pkg-config'
        # deps: make (system).
        'make'
    )
    koopa_is_linux && pkgs+=(
        # deps: make, pkg-config.
        'attr'
    )
    pkgs+=(
        # deps: attr (linux), make.
        'patch'
        # deps: make, pkg-config.
        'xz'
        # deps: make.
        'm4'
        # deps: m4, make, pkg-config.
        'gmp'
        # deps: make.
        'gperf'
        # deps: gmp, make, pkg-config.
        'mpfr'
        # deps: gmp, make, mpfr.
        'mpc'
        # deps: gmp, make, mpc, mpfr.
        'gcc'
        # deps: m4, make.
        'autoconf'
        # deps: autoconf, make.
        'automake'
        # deps: m4, make.
        'libtool'
        # deps: m4, make.
        'bison'
        # deps: make, patch, pkg-config.
        'bash'
        # deps: attr (linux), gmp, gperf, make.
        'coreutils'
        # deps: make.
        'findutils'
        # deps: make.
        'sed'
        # deps: make, pkg-config.
        'ncurses'
        # deps: make, pkg-config.
        'icu4c'
        # deps: make, ncurses, pkg-config.
        'readline'
        # deps: icu4c, make, pkg-config, readline.
        'libxml2'
        # deps: libxml2 (linux), make, ncurses (linux), pkg-config.
        'gettext'
        # deps: make, pkg-config.
        'zlib'
        # deps: none.
        'ca-certificates'
        # deps: ca-certificates, make, pkg-config.
        'openssl1'
        # deps: ca-certificates, make, pkg-config.
        'openssl3'
        # deps: make, ncurses, openssl3.
        'cmake'
        # deps: cmake.
        'zstd'
        # deps: ca-certificates, make, openssl3, pkg-config, zlib, zstd.
        'curl'
        # deps: autoconf, curl, gettext, make, openssl3, zlib.
        'git'
        # deps: cmake, gcc, pkg-config.
        'lapack'
        # deps: make, pkg-config.
        'libffi'
        # deps: cmake, make, pkg-config.
        'libjpeg-turbo'
        # deps: make, pkg-config, zlib.
        'libpng'
        # deps: libjpeg-turbo, make, pkg-config, zstd.
        'libtiff'
        # deps: gcc, make, pkg-config.
        'openblas'
        # deps: make.
        'bzip2'
        # deps: autoconf, automake, bzip2, libtool, make, pkg-config, zlib.
        'pcre'
        # deps: autoconf, automake, bzip2, libtool, make, pkg-config, zlib.
        'pcre2'
        # deps: make, pkg-config.
        'expat'
        # deps: make, readline.
        'gdbm'
        # deps: make, pkg-config, readline, zlib.
        'sqlite'
        # deps: bzip2, expat, gdbm, libffi, make, ncurses, openssl3, pkg-config,
        # readline, sqlite, xz, zlib.
        'python'
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
        'r'
        'conda'
        'apr'
        'apr-util'
        'armadillo'
        'aspell'
        'bc'
        'binutils'
        'cpufetch'
        'exiftool'
        'libtasn1'
        'libunistring'
        'texinfo'
        'gnutls'
        'emacs'
        'vim'
        'lua'
        'luarocks'
        'neovim'
        # NOTE Consider moving these up in the install order.
        'libevent'
        'utf8proc'
        # deps: libevent, utf8proc.
        'tmux'
        'htop'
        'boost'
        'fish'
        'zsh'
        'gawk'
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
    koopa_is_linux && pkgs+=('pinentry')
    pkgs+=(
        'gnupg'
        'grep'
        'groff'
        'gsl'
        'gzip'
        'oniguruma'
        'jq'
        'less'
        'lesspipe'
        'libidn'
        'libpipeline'
        'libuv'
        'lz4'
        'man-db'
        'neofetch'
        'nim'
        'parallel'
        'password-store'
        'taglib'
        'pytaglib'
        'pytest'
        'xxhash'
        'rsync'
        'scons'
        'serf' # deps: scons.
        'ruby' # deps: openssl3, zlib.
        'subversion' # deps: ruby, serf.
        'r-devel' # deps: subversion.
        'shellcheck'
        'shunit2'
        'sox'
        'stow'
        'tar'
        'tree'
        'udunits'
        'units'
        'wget'
        'which'
        'libgeotiff'
        # FIXME Need to finish out recipe here.
        # Install Go packages.
        'go'
        'chezmoi' # deps: go
        'fzf' # deps: go
        # Install Cloud SDKs.
        'aws-cli'
        'azure-cli'
        'google-cloud-sdk'
        # Install Python packages.
        'black'
        'bpytop'
        'flake8'
        'glances'
        'ipython'
        'isort'
        'latch'
        'poetry'
        'pipx'
        'pyflakes'
        'pygments'
        'ranger-fm'
        'yt-dlp'
        'libedit'
        'openssh' # deps: libedit
        'node'
        'bash-language-server' # deps: node
        'gtop' # deps: node
        'prettier' # deps: node
        # Install Perl packages.
        'ack' # deps: perl
        'rename' # deps: perl
        # Install Ruby packages.
        'bashcov' # deps: ruby
        'colorls' # deps: ruby
        'ronn' # deps: ruby
        'rust' # deps: ruby
        'bat' # deps: rust
        'broot' # deps: rust
        'delta' # deps: rust
        'difftastic' # deps: rust
        # > 'dog' # deps: rust
        'du-dust' # deps: rust
        'exa' # deps: rust
        'fd-find' # deps: rust
        'hyperfine' # deps: rust
        'mcfly' # deps: rust
        'mdcat' # deps: rust
        'procs' # deps: rust
        'ripgrep' # deps: rust
        'ripgrep-all' # deps: rust
        'starship' # deps: rust
        'tealdeer' # deps: rust
        'tokei' # deps: rust
        'tuc' # deps: rust
        'xsv' # deps: rust
        'zellij' # deps: rust
        'zoxide' # deps: rust
        # FIXME 1.8.0 is currently very hard to build.
        # > 'julia'
        'ffq' # deps: conda
        'ensembl-perl-api' # deps: none.
        'pyenv' # deps: none.
        'rbenv' # deps: none.
        'cheat' # deps: go.
        'pylint' # deps: python.
        'yq' # deps: go.
        # deps: cmake, gcc, hdf5, libxml2, python.
        'sra-tools'
        # deps: go.
        'chemacs'
        # deps: chemacs (to configure).
        'dotfiles'
    )
    if ! koopa_is_aarch64
    then
        pkgs+=(
            'anaconda'
            'haskell-stack'
            'hadolint' # deps: haskell-stack
            'pandoc' # deps: haskell-stack
            'bamtools' # deps: conda
            'bedtools' # deps: conda
            'bioawk' # deps: conda
            'bowtie2' # deps: conda
            'bustools' # deps: conda
            'deeptools' # deps: conda
            'entrez-direct' # deps: conda
            'fastqc' # deps: conda
            'gffutils' # deps: conda
            'gget' # deps: conda
            'ghostscript' # deps: conda
            'gseapy' # deps: conda
            'hisat2' # deps: conda
            'jupyterlab' # deps: conda
            'kallisto' # deps: conda
            'multiqc' # deps: conda
            'nextflow' # deps: conda
            'salmon' # deps: conda
            'sambamba' # deps: conda
            'samtools' # deps: conda
            'snakemake' # deps: conda
            'star' # deps: conda
            'visidata' # deps: conda
        )
    fi
    if koopa_is_linux
    then
        pkgs+=(
            'apptainer'
            'lmod'
        )
        if ! koopa_is_aarch64
        then
            pkgs+=(
                'aspera-connect'
                # FIXME Rename this to 'docker-credential-helpers'.
                'docker-credential-pass'
            )
        fi
    fi
    for pkg in "${pkgs[@]}"
    do
        koopa_is_symlink "${dict['opt_prefix']}/${pkg}" && continue
        "${app['koopa']}" install "$pkg"
    done
    koopa_push_all_app_builds
    return 0
}

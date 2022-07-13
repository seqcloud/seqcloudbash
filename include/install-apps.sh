#!/usr/bin/env bash
set -Eeuo pipefail

# """
# Install koopa.
# Updated 2022-07-08.
# """

# > curl -sSL 'https://koopa.acidgenomics.com/install' \
# >     | bash -s -- \
# >         --non-interactive \
# >         --verbose

# FIXME aspera-connect (Needs a rework for ARM)
# FIXME docker-credential-pass -> docker-credential-helpers

pkgs=(
    'pkg-config'
    'make'
    'xz'
    'm4'
    'gmp'
    'gperf'
    'coreutils'
    'patch'
    'bash'
    'mpfr'
    'mpc'
    'gcc'
    'autoconf'
    'automake'
    'bison'
    'libtool'
    'bash'
    'attr'
    'coreutils'
    'findutils'
    'sed'
    'ncurses'
    'icu4c'
    'readline'
    'libxml2'
    'gettext'
    'zlib'
    'openssl1'
    'openssl3'
    'cmake'
    'curl'
    'git'
    'lapack'
    'libffi'
    'libjpeg-turbo'
    'libpng'
    'zstd'
    'libtiff'
    'openblas'
    'bzip2'
    'pcre'
    'pcre2'
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
    'imagemagick'
    'graphviz'
    'geos'
    'proj'
    'gdal'
    'r'
    'conda'
    'sqlite'
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
    'nettle'
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
    'tmux'
    'htop'
    'boost'
    'fish'
    'zsh'
    'gawk'
    # FIXME This doesn't currently work on Ubuntu Arm. Need to rethink.
    'aspera-connect'
    # FIXME Not yet supported for ARM.
    'docker-credential-pass'
    'lame'
    'ffmpeg'
    'flac'
    'fltk'
    'fribidi'
    'gdbm'
    'gnupg'
    'grep'
    'groff'
    'gsl'
    'gzip'
    'harfbuzz'
    'hyperfine'
    'jpeg'
    'oniguruma'
    'jq'
    'less'
    'lesspipe'
    'libidn'
    'libpipeline'
    'libuv'
    'libzip'
    'lz4'
    # FIXME This doesn't work on ARM.
    # Need to manually specify build type.
    'lzma'
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
    'serf'
    'subversion'
    'shellcheck'
    'shunit2'
    'sox'
    'stow'
    'tar'
    'tokei'
    'tree'
    'tuc'
    'udunits'
    'units'
    'wget'
    'which'
    'yt-dlp'
    'libgeotiff'






    # Install Go packages.
    'go'
    'apptainer'
    'chezmoi'
    'fzf'
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
    'scons'
    'serf'
    # Install Mode packages.
    'node-binary'
    'bash-language-server'
    'gtop'
    'prettier'
    # Install Perl packages.
    'ack'
    'rename'
    # Install Ruby packages.
    'ruby'
    'bashcov'
    'colorls'
    'ronn'
    # Install Rust packages.
    'rust'
    'bat'
    'broot'
    'delta'
    'difftastic'
    # > 'dog'
    'du-dust'
    'exa'
    'mcfly'
    'mdcat'
    'procs'
    'ripgrep'
    'starship'
    'tealdeer'
    'tokei'
    'xsv'
    'zellij'
    'zoxide'
    # Install Julia packages.
    'julia'
    'julia-packages'
    # Install conda packages.
    'ffq'
    'gget'
    # FIXME Reorganize this with user-specific installs at the end.
    'chemacs'
    'dotfiles'
)
if ! koopa_is_aarch64
then
    pkgs+=(
        'anaconda'
        # FIXME This is erroring due to '-lgmp' issue on Ubuntu.
        'haskell-stack'
        'hadolint'
        'pandoc'
        'kallisto'
        'salmon'
        'snakemake'
    )
fi
if koopa_is_linux
then
    pkgs+=('julia-binary')
else
    # Binary install not yet supported on macOS.
    pkgs+=('julia')
fi

# FIXME This step will currently fail due to DepMapAnalysis.
# Use this to resolve:
# > Rscript -e 'AcidDevTools::installFromGitHub("acidgenomics/r-koopa", branch = "develop")'
# > Rscript -e 'AcidDevTools::installFromGitHub("acidgenomics/r-depmapanalysis", branch = "develop")'

pkgs+=('r-packages')
if koopa_is_linux
then
    pkgs+=(
        # FIXME Note that tcl/tk needs to be installed.
        'lmod'
        'rstudio-server'
        'shiny-server'
    )
fi
for pkg in "${pkgs[@]}"
do
    koopa install "$pkg"
done

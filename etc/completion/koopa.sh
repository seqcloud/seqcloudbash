#!/usr/bin/env bash
# shellcheck disable=SC2207

__koopa_complete() {
    # """
    # Bash/Zsh TAB completion for primary 'koopa' program.
    # Updated 2022-11-04.
    #
    # Keep all of these commands in a single file.
    # Sourcing multiple scripts doesn't work reliably.
    #
    # Multi-level bash completion:
    # - https://stackoverflow.com/questions/17879322/
    # - https://stackoverflow.com/questions/5302650/
    #
    # @seealso
    # - https://github.com/scop/bash-completion/
    # - https://www.gnu.org/software/bash/manual/html_node/
    #     A-Programmable-Completion-Example.html
    # - https://iridakos.com/programming/2018/03/01/
    #     bash-programmable-completion-tutorial
    # - https://devmanual.gentoo.org/tasks-reference/completion/index.html
    # """
    local args
    COMPREPLY=()
    case "${COMP_CWORD:-}" in
        '1')
            args=(
                '--help'
                '--version'
                'app'
                'configure'
                'header'
                'install'
                'reinstall'
                'system'
                'uninstall'
                'update'
            )
            ;;
        '2')
            case "${COMP_WORDS[COMP_CWORD-1]}" in
                'app')
                    args=(
                        'aws'
                        'bioconda'
                        'bowtie2'
                        'brew'
                        'conda'
                        'docker'
                        'ftp'
                        'git'
                        'gpg'
                        'kallisto'
                        'rnaeditingindexer'
                        'salmon'
                        'sra'
                        'ssh'
                        'star'
                        'wget'
                    )
                    ;;
                'configure')
                    args=(
                        # > 'julia'
                        # > 'r'
                        'chemacs'
                        'dotfiles'
                    )
                    ;;
                'header')
                    args=(
                        'bash'
                        'posix'
                        'r'
                        'zsh'
                    )
                    ;;
                'install' | \
                'reinstall' | \
                'uninstall')
                    args=(
                        'ack'
                        'anaconda'
                        'apache-airflow'
                        'apache-spark'
                        'apr'
                        'apr-util'
                        'armadillo'
                        'asdf'
                        'aspell'
                        'attr'
                        'autoconf'
                        'autodock'
                        'autodock-adfr'
                        'autodock-vina'
                        'autoflake'
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
                        'bfg'
                        'binutils'
                        'bioawk'
                        'bioconda-utils'
                        'bison'
                        'black'
                        'boost'
                        'bowtie2'
                        'bpytop'
                        'broot'
                        'brotli'
                        'bustools'
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
                        'coreutils'
                        'cpufetch'
                        'csvkit'
                        'csvtk'
                        'curl'
                        'deeptools'
                        'delta'
                        'diff-so-fancy'
                        'difftastic'
                        'dotfiles'
                        'du-dust'
                        'editorconfig'
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
                        'flex'
                        'fltk'
                        'fmt'
                        'fontconfig'
                        'freetype'
                        'fribidi'
                        'fzf'
                        'gatk'
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
                        'googletest'
                        'gperf'
                        'graphviz'
                        'grep'
                        'groff'
                        'gseapy'
                        'gsl'
                        'gtop'
                        'gum'
                        'gzip'
                        'hadolint'
                        'harfbuzz'
                        'haskell-ghcup'
                        'haskell-stack'
                        'hdf5'
                        'hisat2'
                        'htop'
                        'htseq'
                        'httpie'
                        'hyperfine'
                        'icu4c'
                        'imagemagick'
                        'ipython'
                        'isort'
                        'jemalloc'
                        'jpeg'
                        'jq'
                        'julia'
                        'julia-packages'
                        'jupyterlab'
                        'kallisto'
                        'koopa'
                        'lame'
                        'lapack'
                        'latch'
                        'lesspipe'
                        'libarchive'
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
                        'libjpeg-turbo'
                        'libksba'
                        'libluv'
                        'libpipeline'
                        'libpng'
                        # > 'libsodium' # FIXME
                        'libsolv'
                        'libssh2'
                        'libtasn1'
                        'libtermkey'
                        'libtiff'
                        'libtool'
                        'libunistring'
                        'libuv'
                        'libvterm'
                        'libxml2'
                        'libzip'
                        'llvm'
                        'lsd'
                        'lua'
                        'luajit'
                        'luarocks'
                        'lz4'
                        'lzo'
                        'm4'
                        'make'
                        'mamba'
                        'man-db'
                        'markdownlint-cli'
                        'mcfly'
                        'mdcat'
                        'meson'
                        'mpc'
                        'mpdecimal'
                        'mpfr'
                        'msgpack'
                        'multiqc'
                        'nanopolish'
                        'ncurses'
                        'neofetch'
                        'neovim'
                        'nettle'
                        'nextflow'
                        'nghttp2'
                        'nim'
                        'ninja'
                        'nmap'
                        'node'
                        'npth'
                        'nushell'
                        'oniguruma'
                        'openbb'
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
                        'py-spy'
                        'pybind11'
                        'pycodestyle'
                        'pyenv'
                        'pyflakes'
                        'pygments'
                        'pylint'
                        'pytaglib'
                        'pytest'
                        'python3.10'
                        'python3.11'
                        'r'
                        'r-devel'
                        'r-koopa'
                        'r-packages'
                        'radian'
                        'ranger-fm'
                        'rbenv'
                        'readline'
                        'rename'
                        'reproc'
                        'ripgrep'
                        'ripgrep-all'
                        'rmate'
                        'ronn'
                        'rsync'
                        'ruby'
                        'ruby-packages'
                        'ruff'
                        'rust'
                        'salmon'
                        'sambamba'
                        'samtools'
                        'scons'
                        'sed'
                        'serf'
                        'shellcheck'
                        'shunit2'
                        'snakefmt'
                        'snakemake'
                        'sox'
                        'spdlog'
                        'sqlite'
                        'sra-tools'
                        'star'
                        'starship'
                        'stow'
                        'subversion'
                        'swig'
                        'system'
                        'taglib'
                        'tar'
                        'tcl-tk'
                        'tealdeer'
                        'texinfo'
                        'tl-expected'
                        'tmux'
                        'tokei'
                        'tree'
                        'tree-sitter'
                        'tuc'
                        'udunits'
                        'unibilium'
                        'units'
                        'unzip'
                        'user'
                        'utf8proc'
                        'vim'
                        'visidata'
                        'vulture'
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
                        'yaml-cpp'
                        'yarn'
                        'yt-dlp'
                        'zellij'
                        'zip'
                        'zlib'
                        'zoxide'
                        'zsh'
                        'zstd'
                    )
                    if koopa_is_linux
                    then
                        args+=(
                            'apptainer'
                            'aspera-connect'
                            'bcbio-nextgen'
                            'bcbio-nextgen-vm'
                            'bcl2fastq'
                            'cellranger'
                            'cloudbiolinux'
                            'docker-credential-pass'
                            'elfutils'
                            'lmod'
                            'pinentry'
                        )
                    fi
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'install')
                            args+=('--all' '--all-binary')
                            ;;
                        'reinstall')
                            args+=('--all-revdeps')
                            ;;
                    esac
                    ;;
                'system')
                    args=(
                        'cache-functions'
                        'check'
                        'delete-cache'
                        'disable-passwordless-sudo'
                        'enable-passwordless-sudo'
                        'find-non-symlinked-make-files'
                        'fix-sudo-setrlimit-error'
                        'fix-zsh-permissions'
                        'host-id'
                        'info'
                        'log'
                        'os-string'
                        'prefix'
                        'push-app-build'
                        'reload-shell'
                        'roff'
                        'set-permissions'
                        'switch-to-develop'
                        'test'
                        'version'
                        'which'
                        'yq'
                    )
                    if koopa_is_macos
                    then
                        args+=(
                            'clean-launch-services'
                            'create-dmg'
                            'disable-touch-id-sudo'
                            'enable-touch-id-sudo'
                            'flush-dns'
                            'force-eject'
                            'ifactive'
                            'reload-autofs'
                            'spotlight'
                        )
                    fi
                    ;;
                'update')
                    args=(
                        'koopa'
                        'r-packages'
                        'system'
                    )
                    ;;
                *)
                    ;;
            esac
            ;;
        '3')
            case "${COMP_WORDS[COMP_CWORD-2]}" in
                'install' | \
                'reinstall' | \
                'uninstall')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'system')
                            args+=(
                                'base'
                                'homebrew'
                                'homebrew-bundle'
                                'tex-packages'
                                'vscode-server'
                            )
                            if koopa_is_linux
                            then
                                args+=(
                                    'pihole'
                                    'pivpn'
                                    'wine'
                                )
                                if koopa_is_debian_like || koopa_is_fedora_like
                                then
                                    args+=(
                                        'azure-cli'
                                        'google-cloud-sdk'
                                        'rstudio-server'
                                        'shiny-server'
                                    )
                                fi 
                                if koopa_is_debian_like
                                then
                                    args+=(
                                        'builder-base'
                                        'docker'
                                        'llvm'
                                        'pandoc'
                                        'r'
                                    )
                                elif koopa_is_fedora_like
                                then
                                    args+=(
                                        'oracle-instant-client'
                                    )
                                fi
                            elif koopa_is_macos
                            then
                                args+=(
                                    'defaults'
                                    'python'
                                    'r'
                                    'r-openmp'
                                    'xcode-clt'
                                )
                            fi
                            ;;
                        'user')
                            args+=(
                                'doom-emacs'
                                'prelude-emacs'
                                'spacemacs'
                                'spacevim'
                            )
                            if koopa_is_macos
                            then
                                args+=('defaults')
                            fi
                            ;;
                        esac
                        ;;
                'update')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'system')
                            args+=(
                                'homebrew'
                                'homebrew-bundle'
                                'tex-packages'
                            )
                            ;;
                        esac
                        ;;
                'system')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'list')
                            args=(
                                'app-versions'
                                'dotfiles'
                                'path-priority'
                                'programs'
                            )
                            if koopa_is_macos
                            then
                                args+=('launch-agents')
                            fi
                            ;;
                        esac
                        ;;
                'app')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'aws')
                            args=(
                                'batch'
                                'ec2'
                                's3'
                            )
                            ;;
                        'bioconda')
                            args=(
                                'autobump-recipe'
                            )
                            ;;
                        'bowtie2' | \
                        'star')
                            args=(
                                'align'
                                'index'
                            )
                            ;;
                        'brew')
                            args=(
                                'cleanup'
                                'dump-brewfile'
                                'outdated'
                                'reset-core-repo'
                                'reset-permissions'
                                'uninstall-all-brews'
                                'upgrade-brews'
                                'version'
                            )
                            ;;
                        'conda')
                            args=(
                                'create-env'
                                'remove-env'
                            )
                            ;;
                        'docker')
                            args=(
                                'build'
                                'build-all-images'
                                'build-all-tags'
                                'prune-all-images'
                                'prune-all-stale-tags'
                                'prune-old-images'
                                'prune-stale-tags'
                                'push'
                                'remove'
                                'run'
                                'tag'
                            )
                            ;;
                        'ftp')
                            args=(
                                'mirror'
                            )
                            ;;
                        'git')
                            args=(
                                'checkout-recursive'
                                'pull'
                                'pull-recursive'
                                'push-recursive'
                                'push-submodules'
                                'rename-master-to-main'
                                'reset'
                                'reset-fork-to-upstream'
                                'rm-submodule'
                                'rm-untracked'
                                'status-recursive'
                            )
                            ;;
                        'gpg')
                            args=(
                                'prompt'
                                'reload'
                                'restart'
                            )
                            ;;
                        'jekyll')
                            args=(
                                'serve'
                            )
                            ;;
                        'kallisto' | \
                        'salmon')
                            args=(
                                'index'
                                'quant'
                            )
                            ;;
                        'md5sum')
                            args=(
                                'check-to-new-md5-file'
                            )
                            ;;
                        'sra')
                            args=(
                                'download-accession-list'
                                'download-run-info-table'
                                'fastq-dump'
                                'prefetch'
                            )
                            ;;
                        'ssh')
                            args=(
                                'generate-key'
                            )
                            ;;
                        'wget')
                            args=(
                                'recursive'
                            )
                            ;;
                    esac
                    ;;
            esac
            ;;
        '4')
            case "${COMP_WORDS[COMP_CWORD-3]}" in
                'app')
                    case "${COMP_WORDS[COMP_CWORD-2]}" in
                        'aws')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'batch')
                                    args=(
                                        'fetch-and-run'
                                        'list-jobs'
                                    )
                                    ;;
                                'ec2')
                                    args=(
                                        'instance-id'
                                        'suspend'
                                        # > 'terminate'
                                    )
                                    ;;
                                's3')
                                    args=(
                                        'delete-versioned-glacier-objects'
                                        'find'
                                        'list-large-files'
                                        'ls'
                                        'mv-to-parent'
                                        'sync'
                                    )
                                    ;;
                            esac
                            ;;
                        'kallisto' | \
                        'salmon')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'quant')
                                    args=(
                                        'paired-end'
                                        'single-end'
                                    )
                                    ;;
                            esac
                            ;;
                        'star')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'align')
                                    args=(
                                        'paired-end'
                                        'single-end'
                                    )
                                    ;;
                            esac
                            ;;
                    esac
                    ;;
            esac
            ;;
    esac
    # Quoting inside the array doesn't work for Bash, but does for Zsh.
    COMPREPLY=($(compgen -W "${args[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
    return 0
}

complete -F __koopa_complete koopa

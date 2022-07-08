#!/usr/bin/env bash
# shellcheck disable=SC2207

__koopa_complete() {
    # """
    # Bash/Zsh TAB completion for primary 'koopa' program.
    # Updated 2022-07-08.
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
                        'chemacs'
                        'chezmoi'
                        'dotfiles'
                        'go'
                        'julia'
                        'nim'
                        'node'
                        'perl'
                        'python'
                        'r'
                        'ruby'
                        'rust'
                        'system'
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
                        # > 'ripgrep-all'
                        # > 'unzip'
                        # > 'zip'
                        'ack'
                        'anaconda'
                        'apr'
                        'apr-util'
                        'armadillo'
                        'asdf'
                        'aspell'
                        'attr'
                        'autoconf'
                        'automake'
                        'aws-cli'
                        'azure-cli'
                        'bash'
                        'bash-language-server'
                        'bat'
                        'bc'
                        'bedtools'
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
                        'conda'
                        'coreutils'
                        'cpufetch'
                        'curl'
                        'delta'
                        'difftastic'
                        'doom-emacs'
                        'dotfiles'
                        'du-dust'
                        'emacs'
                        'ensembl-perl-api'
                        'entrez-direct'
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
                        'ghostscript'
                        'git'
                        'glances'
                        'glib'
                        'gmp'
                        'gnupg'
                        'go'
                        'google-cloud-sdk'
                        'gperf'
                        'grep'
                        'groff'
                        'gsl'
                        'gtop'
                        'gzip'
                        'hadolint'
                        'harfbuzz'
                        'haskell-stack'
                        'hdf5'
                        'homebrew'
                        'homebrew-bundle'
                        'htop'
                        'hyperfine'
                        'icu4c'
                        'imagemagick'
                        'ipython'
                        'isort'
                        'jpeg'
                        'jq'
                        'julia'
                        'julia-packages'
                        'kallisto'
                        'koopa'
                        'lame'
                        'lapack'
                        'latch'
                        'lesspipe'
                        'libevent'
                        'libffi'
                        'libgeotiff'
                        'libgit2'
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
                        'mamba'
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
                        'nim-packages'
                        'ninja'
                        'node'
                        'node-binary'
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
                        'perlbrew'
                        'pipx'
                        'pixman'
                        'pkg-config'
                        'poetry'
                        'prelude-emacs'
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
                        'r-packages'
                        'ranger-fm'
                        'rbenv'
                        'readline'
                        'rename'
                        'ripgrep'
                        'rmate'
                        'rsync'
                        'ruby'
                        'ruby-packages'
                        'rust'
                        'salmon'
                        'samtools'
                        'scons'
                        'sed'
                        'serf'
                        'shellcheck'
                        'shunit2'
                        'snakemake'
                        'sox'
                        'spacemacs'
                        'spacevim'
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
                            'azure-cli-binary'
                            'base-system'
                            'bcbio-nextgen'
                            'bcl2fastq'
                            'cellranger'
                            'cloudbiolinux'
                            'docker-credential-pass'
                            'google-cloud-sdk-binary'
                            'julia-binary'
                            'lmod'
                            'node-binary'
                            'pihole'
                            'pivpn'
                            'wine'
                        )
                        if koopa_is_debian_like || koopa_is_fedora_like
                        then
                            args+=(
                                'rstudio-server'
                                'shiny-server'
                            )
                            if koopa_is_debian_like
                            then
                                args+=(
                                    'bcbio-nextgen-vm'
                                    'pandoc-binary'
                                    'r-binary'
                                )
                            elif koopa_is_fedora_like
                            then
                                args+=(
                                    'oracle-instant-client'
                                )
                            fi
                        fi 
                    fi
                    if koopa_is_macos
                    then
                        args+=(
                            'neovim-binary'
                            'python-binary'
                            'r-binary'
                            'r-gfortran'
                            'r-openmp'
                            'xcode-clt'
                        )
                    fi
                    # Handle 'install' or 'uninstall'-specific arguments.
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'install' | \
                        'reinstall')
                            args+=(
                                'homebrew-bundle'
                                'tex-packages'
                            )
                            ;;
                        'uninstall')
                            args+=(
                                'koopa'
                            )
                            ;;
                    esac
                    ;;
                'system')
                    args=(
                        'brew-dump-brewfile'
                        'brew-outdated'
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
                        'list'
                        'log'
                        'os-string'
                        'prefix'
                        'push-app-build'
                        'reload-shell'
                        'roff'
                        'set-permissions'
                        'switch-to-develop'
                        'test'
                        'variables'
                        'version'
                        'which'
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
                        'chemacs'
                        'doom-emacs'
                        'dotfiles'
                        'google-cloud-sdk'
                        'homebrew'
                        'julia-packages'
                        'koopa'
                        'mamba'
                        'nim-packages'
                        'node-packages'
                        'prelude-emacs'
                        'python-packages'
                        'r-packages'
                        'ruby-packages'
                        'rust-packages'
                        'spacemacs'
                        'spacevim'
                        'system'
                        'tex-packages'
                    )
                    if koopa_is_linux
                    then
                        args+=(
                            'google-cloud-sdk'
                        )
                    elif koopa_is_macos
                    then
                        args+=(
                            'defaults'
                            'microsoft-office'
                        )
                    fi
                    ;;
                *)
                    ;;
            esac
            ;;
        '3')
            case "${COMP_WORDS[COMP_CWORD-2]}" in
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

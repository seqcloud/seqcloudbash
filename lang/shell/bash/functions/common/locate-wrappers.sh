#!/usr/bin/env bash

koopa_locate_7z() { # {{{1
    koopa_locate_app \
        --app-name='7z' \
        --opt-name='p7zip'
}

koopa_locate_anaconda() { # {{{1
    koopa_locate_app \
        --app-name='conda' \
        --opt-name='anaconda'
}

koopa_locate_ascp() { # {{{1
    koopa_locate_app \
        --app-name='ascp' \
        --opt-name='aspera-connect'
}

koopa_locate_autoreconf() { # {{{1
    koopa_locate_app \
        --app-name='autoreconf' \
        --opt-name='autoconf'
}

koopa_locate_awk() { # {{{1
    koopa_locate_app \
        --app-name='awk' \
        --opt-name='gawk'
}

koopa_locate_aws() { # {{{1
    koopa_locate_app \
        --app-name='aws' \
        --opt-name='aws-cli'
}

koopa_locate_basename() { # {{{1
    koopa_locate_app \
        --app-name='basename' \
        --opt-name='coreutils'
}

koopa_locate_bash() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='bash' \
        --opt-name='bash'
}

# FIXME Rework this to require GNU bc.
koopa_locate_bc() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='bc' \
        --opt-name='bc'
}

koopa_locate_bedtools() { # {{{1
    koopa_locate_conda_app 'bedtools'
}

koopa_locate_bpytop() { # {{{1
    koopa_locate_app \
        --app-name='bpytop' \
        --opt-name='python-packages'
}

koopa_locate_brew() { # {{{1
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        "$(koopa_homebrew_prefix)/Homebrew/bin/brew" \
        "$@"
}

koopa_locate_bundle() { # {{{1
    koopa_locate_app \
        --app-name='bundle' \
        --opt-name='ruby-packages'
}

koopa_locate_bzip2() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='bzip2' \
        --opt-name='bzip2'
}

koopa_locate_cargo() { # {{{1
    koopa_locate_app \
        --app-name='cargo' \
        --opt-name='rust'
}

koopa_locate_cat() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='cat' \
        --opt-name='coreutils'
}

koopa_locate_chgrp() { # {{{1
    koopa_locate_app '/usr/bin/chgrp'
}

koopa_locate_chmod() { # {{{1
    koopa_locate_app '/bin/chmod'
}

koopa_locate_chown() { # {{{1
    local os_id str
    os_id="$(koopa_os_id)"
    case "$os_id" in
        'macos')
            str='/usr/sbin/chown'
            ;;
        *)
            str='/bin/chown'
            ;;
    esac
    koopa_locate_app "$str"
}

koopa_locate_cmake() { # {{{1
    koopa_locate_app \
        --app-name='cmake' \
        --opt-name='cmake'
}

koopa_locate_conda() { # {{{1
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='conda' \
        --opt-name='conda' \
        "$@"
}

koopa_locate_convmv() { # {{{1
    koopa_locate_app 'convmv'
}

koopa_locate_cp() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='cp' \
        --opt-name='coreutils'
}

koopa_locate_cpan() { # {{{1
    koopa_locate_app \
        --app-name='cpan' \
        --opt-name='perl'
}

koopa_locate_cpanm() { # {{{1
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='cpanm' \
        --opt-name='perl-packages' \
        "$@"
}

koopa_locate_curl() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='curl' \
        --opt-name='curl'
}

koopa_locate_cut() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='cut' \
        --opt-name='coreutils'
}

koopa_locate_date() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='date' \
        --opt-name='coreutils'
}

koopa_locate_df() { # {{{1
    koopa_locate_app \
        --app-name='df' \
        --opt-name='coreutils'
}

koopa_locate_dig() { # {{{1
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='dig' \
        --opt-name='bind' \
        "$@"
}

koopa_locate_dirname() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='dirname' \
        --opt-name='coreutils'
}

koopa_locate_docker() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='docker'
}

koopa_locate_doom() { # {{{1
    koopa_locate_app "$(koopa_doom_emacs_prefix)/bin/doom"
}

koopa_locate_du() { # {{{1
    koopa_locate_app \
        --app-name='du' \
        --opt-name='coreutils'
}

koopa_locate_efetch() { # {{{1
    koopa_locate_conda_app \
        --app-name='efetch' \
        --env-name='entrez-direct'
}

koopa_locate_esearch() { # {{{1
    koopa_locate_conda_app \
        --app-name='esearch' \
        --env-name='entrez-direct'
}

koopa_locate_emacs() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='emacs'
}

# FIXME Need to add recipe support for this.
koopa_locate_exiftool() { # {{{1
    koopa_locate_app \
        --app-name='exiftool' \
        --opt-name='exiftool'
}

# FIXME Need to add recipe support for this, or switch to conda.
koopa_locate_fasterq_dump() { # {{{1
    koopa_locate_app \
        --app-name='fasterq-dump' \
        --opt-name='sratoolkit'
}

koopa_locate_fd() { # {{{1
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='fd' \
        --opt-name='fd-find' \
        "$@"
}

# FIXME Need to add recipe support for this.
koopa_locate_ffmpeg() { # {{{1
    koopa_locate_app \
        --app-name='ffmpeg' \
        --opt-name='ffmpeg'
}

koopa_locate_find() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='find' \
        --opt-name='findutils'
}

koopa_locate_fish() { # {{{1
    koopa_locate_app \
        --app-name='fish' \
        --opt-name='fish'
}

koopa_locate_gcc() { # {{{1
    local dict
    declare -A dict=(
        [name]='gcc'
    )
    dict[version]="$(koopa_variable "${dict[name]}")"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    koopa_locate_app \
        --allow-in-path \
        --app-name="${dict[name]}-${dict[maj_ver]}" \
        --opt-name="${dict[name]}@${dict[maj_ver]}"
}

koopa_locate_gcloud() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='gcloud'
}

koopa_locate_gdal_config() { # {{{1
    koopa_locate_app \
        --app-name='gdal-config' \
        --opt-name='gdal'
}

koopa_locate_gem() { # {{{1
    koopa_locate_app \
        --app-name='gem' \
        --opt-name='ruby'
}

koopa_locate_geos_config() { # {{{1
    koopa_locate_app \
        --app-name='geos-config' \
        --opt-name='geos'
}

koopa_locate_git() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='git' \
        --opt-name='git'
}

koopa_locate_go() { # {{{1
    koopa_locate_app \
        --app-name='go' \
        --opt-name='go'
}

koopa_locate_gpg() { # {{{1
    koopa_locate_app \
        --app-name='gpg' \
        --opt-name='gnupg'
}

koopa_locate_gpg_agent() { # {{{1
    koopa_locate_app \
        --app-name='gpg-agent' \
        --opt-name='gnupg'
}

koopa_locate_gpgconf() { # {{{1
    koopa_locate_app \
        --app-name='gpgconf' \
        --opt-name='gnupg'
}

koopa_locate_grep() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='grep' \
        --opt-name='grep' \
        "$@"
}

koopa_locate_groups() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='groups' \
        --opt-name='coreutils'
}

# FIXME Need to add recipe support for this.
koopa_locate_gs() { # {{{1
    koopa_locate_app \
        --app-name='gs' \
        --opt-name='ghostscript'
}

# FIXME Need to add updated recipe support for this.
# https://www.gnu.org/software/gzip/
koopa_locate_gzip() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='gzip' \
        --opt-name='gzip'
}

koopa_locate_h5cc() { # {{{1
    koopa_locate_app \
        --app-name='h5cc' \
        --opt-name='hdf5'
}

koopa_locate_head() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='head' \
        --opt-name='coreutils'
}

koopa_locate_hostname() {
    koopa_locate_app '/bin/hostname'
}

koopa_locate_id() { # {{{1
    koopa_locate_app \
        --app-name='id' \
        --opt-name='coreutils'
}

koopa_locate_java() { # {{{1
    koopa_locate_app "$(koopa_java_prefix)/bin/java"
}

# FIXME Need to add recipe support for this.
koopa_locate_jq() { # {{{1
    koopa_locate_app \
        --app-name='jq' \
        --opt-name='jq'
}

koopa_locate_julia() { # {{{1
    koopa_locate_app \
        --app-name='julia' \
        --opt-name='julia'
}

koopa_locate_kallisto() { # {{{1
    koopa_locate_conda_app 'kallisto'
}

koopa_locate_ldd() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='ldd'
}

koopa_locate_libtoolize() { # {{{1
    koopa_locate_app \
        --app-name='libtoolize' \
        --opt-name='libtool'
}

koopa_locate_less() { # {{{1
    koopa_locate_app \
        --app-name='less' \
        --opt-name='less'
}

koopa_locate_lesspipe() { # {{{1
    koopa_locate_app \
        --app-name='lesspipe.sh' \
        --opt-name='lesspipe'
}

koopa_locate_lua() { # {{{1
    koopa_locate_app \
        --app-name='lua' \
        --opt-name='lua'
}

koopa_locate_luarocks() { # {{{1
    koopa_locate_app \
        --app-name='luarocks' \
        --opt-name='luarocks'
}

koopa_locate_ln() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='ln' \
        --opt-name='coreutils'
}

koopa_locate_locale() { # {{{1
    koopa_locate_app '/usr/bin/locale'
}

koopa_locate_localedef() { # {{{1
    if koopa_is_alpine
    then
        koopa_alpine_locate_localedef
    else
        koopa_locate_app '/usr/bin/localedef'
    fi
}

koopa_locate_ls() { # {{{1
    koopa_locate_app \
        --app-name='ls' \
        --opt-name='coreutils'
}

koopa_locate_magick_core_config() { # {{{1
    koopa_locate_app \
        --app-name='MagickCore-config' \
        --opt-name='imagemagick'
}

koopa_locate_make() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='make' \
        --opt-name='make'
}

koopa_locate_mamba() { # {{{1
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='mamba' \
        --opt-name='conda' \
        "$@"
}

koopa_locate_mamba_or_conda() { # {{{1
    local str
    str="$(koopa_locate_mamba --allow-missing)"
    if [[ -x "$str" ]]
    then
        koopa_print "$str"
        return 0
    fi
    koopa_locate_conda --allow-missing
}

# FIXME Need to add recipe support for this.
koopa_locate_man() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='man' \
        --opt-name='man-db'
}

koopa_locate_mashmap() { # {{{1
    koopa_locate_conda_app 'mashmap'
}

koopa_locate_md5sum() { # {{{1
    koopa_locate_app \
        --app-name='md5sum' \
        --opt-name='coreutils'
}

koopa_locate_meson() { # {{{1
    koopa_locate_app \
        --app-name='meson' \
        --opt-name='meson'
}

koopa_locate_mkdir() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='mkdir' \
        --opt-name='coreutils'
}

koopa_locate_mktemp() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='mktemp' \
        --opt-name='coreutils'
}

koopa_locate_mv() { # {{{1
    # """
    # @note macOS gmv currently has issues on NFS shares.
    # """
    if koopa_is_macos
    then
        koopa_locate_app '/bin/mv'
    else
        koopa_locate_app \
            --allow-in-path \
            --app-name='mv' \
            --opt-name='coreutils'
    fi
}

koopa_locate_neofetch() { # {{{1
    koopa_locate_app \
        --app-name='neofetch' \
        --opt-name='neofetch'
}

koopa_locate_newgrp() { # {{{1
    koopa_locate_app '/usr/bin/newgrp'
}

koopa_locate_nim() { # {{{1
    koopa_locate_app \
        --app-name='nim' \
        --opt-name='nim'
}

koopa_locate_nimble() { # {{{1
    koopa_locate_app \
        --app-name='nimble' \
        --opt-name='nim'
}

koopa_locate_ninja() { # {{{1
    koopa_locate_app \
        --app-name='ninja' \
        --opt-name='ninja'
}

koopa_locate_node() { # {{{1
    koopa_locate_app \
        --app-name='node' \
        --opt-name='node'
}

koopa_locate_npm() { # {{{1
    koopa_locate_app \
        --app-name='npm' \
        --opt-name='node'
}

koopa_locate_nproc() { # {{{1
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='nproc' \
        --opt-name='coreutils' \
        "$@"
}

koopa_locate_od() { # {{{1
    koopa_locate_app \
        --app-name='od' \
        --opt-name='coreutils'
}

koopa_locate_openssl() { # {{{1
    koopa_locate_app \
        --app-name='openssl' \
        --opt-name='openssl'
}

koopa_locate_parallel() { # {{{1
    koopa_locate_app \
        --app-name='parallel' \
        --opt-name='coreutils'
}

koopa_locate_passwd() { # {{{1
    koopa_locate_app '/usr/bin/passwd'
}

koopa_locate_paste() { # {{{1
    koopa_locate_app \
        --app-name='paste' \
        --opt-name='coreutils'
}

koopa_locate_patch() { # {{{1
    koopa_locate_app \
        --app-name='patch' \
        --opt-name='patch'
}

koopa_locate_pcregrep() { # {{{1
    koopa_locate_app \
        --app-name='pcre2grep' \
        --opt-name='pcre2'
}

koopa_locate_perl() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='perl' \
        --opt-name='perl'
}

koopa_locate_perlbrew() { # {{{1
    koopa_locate_app \
        --app-name='perlbrew' \
        --opt-name='perlbrew'
}

koopa_locate_pkg_config() { # {{{1
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='pkg-config' \
        --opt-name='pkg-config' \
        "$@"
}

koopa_locate_prefetch() { # {{{1
    koopa_locate_app \
        --app-name='prefetch' \
        --opt-name='sratoolkit'
}

koopa_locate_proj() { # {{{1
    koopa_locate_app \
        --app-name='proj' \
        --opt-name='proj'
}

koopa_locate_pyenv() { # {{{1
    koopa_locate_app \
        --app-name='pyenv' \
        --opt-name='pyenv'
}

koopa_locate_python() { # {{{1
    local dict
    declare -A dict=(
        [name]='python'
    )
    dict[version]="$(koopa_variable "${dict[name]}")"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    dict[python]="${dict[name]}${dict[maj_ver]}"
    koopa_locate_app \
        --app-name="${dict[python]}" \
        --opt-name='python'
}

koopa_locate_r() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='R' \
        --opt-name='r'
}

koopa_locate_rbenv() { # {{{1
    koopa_locate_app 'rbenv'
}

koopa_locate_rscript() { # {{{1
    local app
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    app[rscript]="${app[r]}script"
    koopa_locate_app "${app[rscript]}"
}

koopa_locate_readlink() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='readlink' \
        --opt-name='coreutils'
}

koopa_locate_realpath() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='realpath' \
        --opt-name='coreutils'
}

koopa_locate_rename() { # {{{1
    koopa_locate_app \
        --app-name='rename' \
        --koopa-opt-name='perl-packages'
}

koopa_locate_rg() { # {{{1
    # """
    # Allowing passthrough of '--allow-missing' here.
    # """
    koopa_locate_app \
        --app-name='rg' \
        --opt-name='ripgrep' \
        "$@"
}

koopa_locate_rm() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='rm' \
        --opt-name='coreutils'
}

koopa_locate_rsync() { # {{{1
    koopa_locate_app \
        --app-name='rsync' \
        --opt-name='rsync'
}

koopa_locate_ruby() { # {{{1
    koopa_locate_app \
        --app-name='ruby' \
        --opt-name='ruby'
}

koopa_locate_rustc() { # {{{1
    koopa_locate_app \
        --app-name='rustc' \
        --opt-name='rust'
}

koopa_locate_rustup() { # {{{1
    koopa_locate_app \
        --app-name='rustup' \
        --opt-name='rust'
}

koopa_locate_salmon() { # {{{1
    koopa_locate_conda_app 'salmon'
}

koopa_locate_scons() { # {{{1
    koopa_locate_app \
        --app-name='scons' \
        --opt-name='scons'
}

koopa_locate_scp() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='scp' \
        --opt-name='openssh'
}

# FIXME Rework the '-i.bak' internal calls after this change.
koopa_locate_sed() { # {{{1
    koopa_locate_app \
        --app-name='sed' \
        --opt-name='sed'
}

koopa_locate_shellcheck() { # {{{1
    koopa_locate_app \
        --app-name='shellcheck' \
        --opt-name='shellcheck'
}

koopa_locate_shunit2() { # {{{1
    koopa_locate_app \
        --app-name='shunit2' \
        --opt-name='shunit2'
}

koopa_locate_sshfs() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='sshfs'
}

koopa_locate_sort() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='sort' \
        --opt-name='coreutils'
}

# FIXME Need to add recipe support for this.
koopa_locate_sox() { # {{{1
    koopa_locate_app \
        --app-name='sox' \
        --opt-name='sox'
}

koopa_locate_sqlplus() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='sqlplus'
}

koopa_locate_ssh() { # {{{1
    koopa_locate_app \
        --app-name='ssh' \
        --opt-name='openssh'
}

koopa_locate_ssh_add() { # {{{1
    if koopa_is_macos
    then
        koopa_locate_app '/usr/bin/ssh-add'
    else
        koopa_locate_app \
            --app-name='ssh-add' \
            --opt-name='openssh'
    fi
}

koopa_locate_ssh_keygen() { # {{{1
    koopa_locate_app \
        --app-name='ssh-keygen' \
        --opt-name='openssh'
}

koopa_locate_stack() { # {{{1
    koopa_locate_app \
        --app-name='stack' \
        --opt-name='haskell-stack'
}

koopa_locate_star() { # {{{1
    koopa_locate_conda_app \
        --app-name='STAR' \
        --env-name='star'
}

koopa_locate_stat() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='stat' \
        --opt-name='coreutils'
}

koopa_locate_sudo() { # {{{1
    koopa_locate_app '/usr/bin/sudo'
}

koopa_locate_svn() { # {{{1
    koopa_locate_app \
        --app-name='svn' \
        --opt-name='subversion'
}

koopa_locate_tac() { # {{{1
    koopa_locate_app \
        --app-name='tac' \
        --opt-name='coreutils'
}

koopa_locate_tail() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='tail' \
        --opt-name='coreutils'
}

koopa_locate_tar() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='tar' \
        --opt-name='tar'
}

koopa_locate_tee() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='tee' \
        --opt-name='coreutils'
}

koopa_locate_tex() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='tex'
}

koopa_locate_tlmgr() { # {{{1
    if koopa_is_macos
    then
        koopa_locate_app '/Library/TeX/texbin/tlmgr'
    else
        koopa_locate_app \
            --allow-in-path \
            --app-name='tlmgr'
    fi
}

koopa_locate_touch() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='touch' \
        --opt-name='coreutils'
}

koopa_locate_tr() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='tr' \
        --opt-name='coreutils'
}

# FIXME Need to add recipe support for this.
koopa_locate_uncompress() { # {{{1
    koopa_locate_app \
        --app-name='uncompress' \
        --opt-name='gzip'
}

koopa_locate_uname() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='uname' \
        --opt-name='coreutils'
}

koopa_locate_uniq() { # {{{1
    koopa_locate_app \
        --app-name='uniq' \
        --opt-name='coreutils'
}

# FIXME Need to add recipe support for this.
koopa_locate_unzip() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='unzip'
}

koopa_locate_vim() { # {{{1
    koopa_locate_app \
        --app-name='vim' \
        --opt-name='vim'
}

koopa_locate_wc() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='wc' \
        --opt-name='coreutils'
}

koopa_locate_wget() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='wget' \
        --opt-name='wget'
}

koopa_locate_whoami() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='whoami' \
        --opt-name='coreutils'
}

koopa_locate_xargs() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='xargs' \
        --opt-name='findutils'
}

koopa_locate_xz() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='xz' \
        --opt-name='xz'
}

koopa_locate_yes() { # {{{1
    koopa_locate_app \
        --allow-in-path \
        --app-name='yes' \
        --opt-name='coreutils'
}

koopa_locate_zcat() { # {{{1
    koopa_locate_app \
        --app-name='zcat' \
        --opt-name='gzip'
}

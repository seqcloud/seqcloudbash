#!/bin/sh
# shellcheck disable=SC2039

_koopa_app_prefix() { # {{{1
    # """
    # Custom application install prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    if [ -n "${KOOPA_APP_PREFIX:-}" ]
    then
        prefix="$KOOPA_APP_PREFIX"
    elif _koopa_is_shared_install && _koopa_is_installed brew
    then
        prefix="$(_koopa_prefix)/opt"
    elif _koopa_is_shared_install
    then
        prefix="$(_koopa_make_prefix)/opt"
    else
        prefix="$(_koopa_local_app_prefix)"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_aspera_prefix() { # {{{1
    # """
    # Aspera Connect prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    if _koopa_is_shared_install
    then
        prefix="$(_koopa_app_prefix)/aspera-connect"
    else
        prefix="${HOME:?}/.aspera/connect"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_autojump_prefix() { # {{{1
    # """
    # autojump prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    local make_prefix prefix
    make_prefix="$(_koopa_make_prefix)"
    # Shared installation (Linux).
    if [ -x "${make_prefix}/bin/autojump" ]
    then
        # This is the current target of cellar script.
        prefix="$make_prefix"
    elif [ -x "/usr/bin/autojump" ]
    then
        # Also support installation via package manager.
        prefix="/usr"
    else
        # Local user installation (macOS).
        prefix="${HOME:?}/.autojump"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_bcbio_prefix() { # {{{1
    # """
    # bcbio-nextgen prefix.
    # @note Updated 2020-07-01.
    [ "$#" -eq 0 ] || return 1
    _koopa_is_linux || return 1
    local host_id prefix
    host_id="$(_koopa_host_id)"
    if [ "$host_id" = "harvard-o2" ]
    then
        prefix="/n/app/bcbio/tools"
    elif [ "$host_id" = "harvard-odyssey" ]
    then
        prefix="/n/regal/hsph_bioinfo/bcbio_nextgen"
    else
        prefix="$(_koopa_app_prefix)/bcbio/stable/tools"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_cellar_prefix() { # {{{1
    # """
    # Cellar prefix.
    # @note Updated 2020-07-01.
    #
    # Currently only supported for Linux.
    # Use Homebrew on macOS instead.
    #
    # Ensure this points to a local mount (e.g. '/usr/local').
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_linux || return 1
    local prefix
    if [ -n "${KOOPA_CELLAR_PREFIX:-}" ]
    then
        prefix="$KOOPA_CELLAR_PREFIX"
    elif _koopa_is_shared_install && _koopa_is_installed brew
    then
        prefix="$(_koopa_prefix)/cellar"
    else
        prefix="$(_koopa_make_prefix)/cellar"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_conda_prefix() { # {{{1
    # """
    # Conda prefix.
    # @note Updated 2020-07-01.
    # @seealso conda info --base
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    if [ -n "${CONDA_EXE:-}" ]
    then
        prefix="$(cd "$(dirname "$CONDA_EXE")/.." &>/dev/null && pwd -P)"
    else
        prefix="$(_koopa_app_prefix)/conda"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_config_prefix() { # {{{1
    # """
    # Local koopa config directory.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "${XDG_CONFIG_HOME:-"${HOME:?}/.config"}/koopa"
    return 0
}

_koopa_data_disk_link_prefix() { # {{{1
    # """
    # Data disk symlink prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_linux || return 1
    _koopa_print "/n"
    return 0
}

_koopa_docker_prefix() { # {{{1
    # """
    # Docker prefix.
    # @note Updated 2020-02-15.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_config_prefix)/docker"
    return 0
}

_koopa_docker_private_prefix() { # {{{1
    # """
    # Private Docker prefix.
    # @note Updated 2020-03-05.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_config_prefix)/docker-private"
    return 0
}

_koopa_dotfiles_prefix() { # {{{1
    # """
    # Koopa system dotfiles prefix.
    # @note Updated 2020-05-05.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_prefix)/dotfiles"
    return 0
}

_koopa_dotfiles_private_prefix() { # {{{1
    # """
    # Private user dotfiles prefix.
    # @note Updated 2020-02-15.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_config_prefix)/dotfiles-private"
    return 0
}

_koopa_emacs_prefix() { # {{{1
    # """
    # Default Emacs prefix.
    # @note Updated 2020-06-29.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "${HOME}/.emacs.d"
    return 0
}

_koopa_ensembl_perl_api_prefix() { # {{{1
    # """
    # Ensembl Perl API prefix.
    # @note Updated 2019-11-15.
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_app_prefix)/ensembl"
    return 0
}

_koopa_fzf_prefix() { # {{{1
    # """
    # fzf prefix.
    # @note Updated 2020-03-16.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_app_prefix)/fzf"
    return 0
}

_koopa_go_gopath() { # {{{1
    # """
    # Go GOPATH, for building from source.
    # @note Updated 2020-07-01.
    #
    # This must be different from go root.
    #
    # @seealso
    # - go help gopath
    # - go env GOPATH
    # - go env GOROOT
    # - https://golang.org/wiki/SettingGOPATH to set a custom GOPATH
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    if [ -n "${GOPATH:-}" ]
    then
        prefix="$GOPATH"
    else
        prefix="$(_koopa_app_prefix)/go/gopath"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_homebrew_cellar_prefix() { # {{{1
    # """
    # Homebrew cellar prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_homebrew_prefix)/Cellar"
    return 0
}

_koopa_homebrew_prefix() { # {{{1
    # """
    # Homebrew prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    prefix="${HOMEBREW_PREFIX:-/usr/local}"
    _koopa_print "$prefix"
    return 0
}

_koopa_homebrew_ruby_gems_prefix() { # {{{1
    # """
    # Homebrew Ruby gems prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed ruby || return 0
    local homebrew_prefix
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    local api_version
    api_version="$(_koopa_ruby_api_version)"
    local prefix
    prefix="${homebrew_prefix}/lib/ruby/gems/${api_version}/bin"
    _koopa_print "$prefix"
    return 0
}

_koopa_include_prefix() { # {{{1
    # """
    # Koopa system includes prefix.
    # @note Updated 2020-06-24.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_prefix)/system/include"
    return 0
}

_koopa_java_prefix() { # {{{1
    # """
    # Java prefix.
    # @note Updated 2020-07-01.
    #
    # See also:
    # - https://www.mkyong.com/java/
    #       how-to-set-java_home-environment-variable-on-mac-os-x/
    # - https://stackoverflow.com/questions/22290554
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    if [ -n "${JAVA_HOME:-}" ]
    then
        # Allow user to override default.
        prefix="$JAVA_HOME"
    elif [ -x "/usr/libexec/java_home" ]
    then
        # Handle macOS config.
        prefix="$(/usr/libexec/java_home)"
    else
        # Otherwise assume latest OpenJDK.
        # This works on Linux installs, including Docker images.
        prefix="$(_koopa_openjdk_prefix)/latest"
    fi
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
    return 0
}

_koopa_local_app_prefix() { # {{{1
    # """
    # Local user application install prefix.
    # @note Updated 2020-07-01.
    #
    # This is the default app path when koopa is installed per user.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "${XDG_DATA_HOME:?}"
    return 0
}

_koopa_make_prefix() { # {{{1
    # """
    # Return the installation prefix to use.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    if [ -n "${KOOPA_MAKE_PREFIX:-}" ]
    then
        prefix="$KOOPA_MAKE_PREFIX"
    elif _koopa_is_shared_install
    then
        prefix="/usr/local"
    else
        prefix="$(dirname "${XDG_DATA_HOME:?}")"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_msigdb_prefix() { # {{{1
    # """
    # MSigDB prefix.
    # @note Updated 2020-05-05.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_refdata_prefix)/msigdb"
    return 0
}

_koopa_openjdk_prefix() { # {{{1
    # """
    # OpenJDK prefix.
    # @note Updated 2020-02-27.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_app_prefix)/java/openjdk"
    return 0
}

_koopa_perlbrew_prefix() { # {{{1
    # """
    # Perlbrew prefix.
    # @note Updated 2020-01-12.
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    if [ -n "${PERLBREW_ROOT:-}" ]
    then
        prefix="$PERLBREW_ROOT"
    else
        prefix="$(_koopa_app_prefix)/perl/perlbrew"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_prefix() { # {{{1
    # """
    # Koopa prefix (home).
    # @note Updated 2020-01-12.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "${KOOPA_PREFIX:?}"
    return 0
}

_koopa_pyenv_prefix() { # {{{1
    # """
    # Python pyenv prefix.
    # @note Updated 2020-05-05.
    #
    # See also approach used for rbenv.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_app_prefix)/python/pyenv"
    return 0
}

_koopa_python_site_packages_prefix() {
    # """
    # Python site packages library location.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -le 1 ] || return 1
    local python
    python="${1:-"python3"}"
    _koopa_assert_is_installed "$python"
    local x
    x="$("$python" -c "import site; print(site.getsitepackages()[0])")"
    _koopa_print "$x"
    return 0
}

_koopa_rbenv_prefix() { # {{{1
    # """
    # Ruby rbenv prefix.
    # @note Updated 2020-05-05.
    #
    # See also:
    # - RBENV_ROOT
    # - https://gist.github.com/saegey/5499096
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_app_prefix)/ruby/rbenv"
    return 0
}

_koopa_refdata_prefix() { # {{{1
    # """
    # Reference data prefix.
    # @note Updated 2020-05-05.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_data_disk_link_prefix)/refdata"
    return 0
}

_koopa_rust_cargo_prefix() { # {{{1
    # """
    # Rust cargo install prefix.
    # @note Updated 2020-01-12.
    #
    # See also:
    # - https://github.com/rust-lang/rustup#environment-variables
    # - CARGO_HOME
    # - RUSTUP_HOME
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    if _koopa_is_shared_install
    then
        prefix="$(_koopa_app_prefix)/rust/cargo"
    else
        prefix="${HOME:?}/.cargo"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_r_prefix() { # {{{1
    # """
    # R prefix.
    # @note Updated 2020-07-01.
    #
    # We're suppressing errors here that can pop up if 'etc' isn't linked yet
    # after a clean install. Can warn about ldpaths missing.
    # """
    [ "$#" -eq 0 ] || return 1
    local rscript_exe
    rscript_exe="${1:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    local prefix
    prefix="$( \
        "$rscript_exe" \
            --vanilla \
            -e 'cat(normalizePath(Sys.getenv("R_HOME")))' \
        2>/dev/null \
    )"
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
    return 0
}

_koopa_r_library_prefix() { # {{{1
    # """
    # R default library prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -le 1 ] || return 1
    local rscript_exe
    rscript_exe="${1:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    local prefix
    prefix="$( \
        "$rscript_exe" \
            -e 'cat(normalizePath(.libPaths()[[1L]]))' \
    )"
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
    return 0
}

_koopa_r_system_library_prefix() { # {{{1
    # """
    # R system library prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -le 1 ] || return 1
    local rscript_exe
    rscript_exe="${1:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    local prefix
    prefix="$( \
        "$rscript_exe" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
    return 0
}

_koopa_rust_rustup_prefix() { # {{{1
    # """
    # Rust rustup install prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix
    if _koopa_is_shared_install
    then
        prefix="$(_koopa_app_prefix)/rust/rustup"
    else
        prefix="${HOME:?}/.rustup"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_scripts_private_prefix() { # {{{1
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_config_prefix)/scripts-private"
    return 0
}

_koopa_tests_prefix() { # {{{1
    # """
    # Unit tests prefix.
    # @note Updated 2020-06-24.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_prefix)/tests"
    return 0
}

_koopa_venv_prefix() { # {{{1
    # """
    # Python venv prefix.
    # @note Updated 2020-05-05.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_app_prefix)/python/virtualenvs"
    return 0
}

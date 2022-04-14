#!/bin/sh

# Csh is not supported, primarily due to lack of functions.
# > csh -l or csh -i
[ "$0" = 'csh' ] && \
    printf '%s\n' 'koopa does not support csh.' && \
    exit 1

# Tcsh is not supported, primarily due to lack of functions.
# > tcsh -l or tcsh -i
[ "$0" = 'tcsh' ] && \
    printf '%s\n' 'koopa does not support tcsh.' && \
    exit 1

# Ksh is not supported, primarily due to lack of 'local' variables.
# > ksh -il
if [ "$0" = 'ksh' ] || [ -n "${KSH_VERSION:-}" ]
then
    printf '%s\n' 'koopa does not support ksh.'
    return 1
fi

__koopa_activate_usage() { # {{{1
    # """
    # Koopa activation usage triggered by '--help' flag.
    # @note Updated 2021-10-25.
    # """
    cat << END
usage: activate [--help|-h]

Activate koopa.

supported environment variables:
    KOOPA_FORCE=1
        Force activation inside of non-interactive shells.
        Not generally recommended, but used by koopa installer.
    KOOPA_MINIMAL=1
        Minimal mode.
        Simply load koopa programs into PATH.
        Skips additional program and shell configuration.
    KOOPA_SKIP=1
        Skip activation in current shell session.
        Recommended for users who want to selectively disable activation
        of shared koopa installation.
    KOOPA_TEST=1
        Enable verbose test mode.
        Used for Travis CI checks.

details:
    Bash or Zsh is currently recommended.
    Also supports Ash, Busybox, and Dash POSIX shells.

    For system-wide configuration on Linux, this should be called inside
    '/etc/profile.d/zzz-koopa.sh', owned by root.

    Sourcing of POSIX shell scripts via '.' (POSIX) or 'source' (bash, zsh)
    requires that arguments are passed in at the beginning of the call, rather
    than as positional arguments or flags. Refer to the working examples.

examples:
    # Default mode.
    . /usr/local/koopa/activate

    # Minimal mode.
    export KOOPA_MINIMAL=1
    . /usr/local/koopa/activate
END
}

__koopa_bash_source() { # {{{1
    # """
    # Bash source file location.
    # @note Updated 2021-05-07.
    # """
    # shellcheck disable=SC3028,SC3054
    __koopa_print "${BASH_SOURCE[0]}"
    return 0
}

__koopa_check_zsh() { # {{{1
    # """
    # Check that current Zsh configuration is supported.
    # @note Updated 2021-05-25.
    #
    # Zsh currently requires presence of '~/.zshrc' for clean activation.
    # This check will intentionally force early return when activation is
    # attempted from '/etc/profile.d'.
    #
    # Note that sourcing in '/etc/profile' doesn't return script path in
    # '0', which is commonly recommended online in place of 'BASH_SOURCE'.
    # '0' in this case instead returns '_src_etc_profile'.
    #
    # This approach covers both '_src_etc_profile' and '_src_etc_profile_d'.
    #
    # @seealso
    # - https://stackoverflow.com/a/23259585/3911732
    [ -n "${ZSH_VERSION:-}" ] || return 0
    case "$0" in
        '_src_etc_profile'*)
            return 1
            ;;
    esac
    return 0
}

__koopa_export_koopa_prefix() { # {{{1
    # """
    # Export 'KOOPA_PREFIX' variable.
    # @note Updated 2021-05-25.
    # """
    local prefix script shell
    shell="$(__koopa_shell_name)"
    script="$("__koopa_${shell}_source")"
    if [ ! -x "$script" ]
    then
        __koopa_warn 'Failed to locate koopa activate script.'
        return 1
    fi
    # Note that running realpath on the file instead of the directory will
    # properly resolve '~/.config/koopa/activate' symlink case.
    if [ -L "$script" ]
    then
        script="$(__koopa_realpath "$script")"
    fi
    prefix="$(__koopa_realpath "$(dirname "$script")")"
    KOOPA_PREFIX="$prefix"
    export KOOPA_PREFIX
    return 0
}

__koopa_export_koopa_subshell() { # {{{1
    # """
    # Export 'KOOPA_SUBSHELL' variable.
    # @note Updated 2021-05-26.
    #
    # This function evaluates whether 'KOOPA_PREFIX' is defined, which should be
    # the case only inside a subshell.
    # """
    [ -z "${KOOPA_PREFIX:-}" ] && return 0
    KOOPA_SUBSHELL=1
    export KOOPA_SUBSHELL
    return 0
}

__koopa_header() { # {{{1
    # """
    # Shared shell header file location.
    # @note Updated 2021-05-25.
    # """
    local file prefix shell
    prefix="${KOOPA_PREFIX:?}/lang/shell"
    shell="$(__koopa_shell_name)"
    file="${prefix}/${shell}/include/header.sh"
    [ -f "$file" ] || return 1
    __koopa_print "$file"
    return 0
}

__koopa_is_installed() { # {{{1
    # """
    # Are all of the requested programs installed?
    # @note Updated 2021-05-07.
    # """
    local cmd
    for cmd in "$@"
    do
        command -v "$cmd" >/dev/null || return 1
    done
    return 0
}

__koopa_is_interactive() { # {{{1
    # """
    # Is the current shell interactive?
    # @note Updated 2021-10-25.
    # """
    __koopa_str_detect_posix "$-" 'i'
}

__koopa_posix_source() { # {{{1
    # """
    # POSIX source file location.
    # @note Updated 2021-05-10.
    #
    # POSIX doesn't support file path resolution of sourced dot scripts.
    # """
    local prefix
    prefix="${KOOPA_PREFIX:-}"
    if [ ! "$prefix" ] && [ -d '/opt/koopa' ]
    then
        prefix='/opt/koopa'
    fi
    if [ ! -d "$prefix" ]
    then
        __koopa_warn \
            'Failed to locate koopa activation script.' \
            "Required 'KOOPA_PREFIX' variable is unset."
        return 1
    fi
    __koopa_print "${prefix:?}/activate"
    return 0
}

__koopa_preflight() { # {{{1
    # """
    # Run pre-flight checks.
    # @note Updated 2021-10-25.
    # """
    [ "${KOOPA_SKIP:-0}" -eq 1 ] && return 1
    [ "${KOOPA_FORCE:-0}" -eq 1 ] && return 0
    __koopa_check_zsh || return 1
    __koopa_is_interactive || return 1
    return 0
}

__koopa_print() { # {{{1
    # """
    # Print a string.
    # @note Updated 2021-05-07.
    # """
    local string
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

__koopa_realpath() { # {{{1
    # """
    # Resolve file path.
    # @note Updated 2022-04-10.
    # """
    local readlink x
    readlink='readlink'
    if ! __koopa_is_installed "$readlink"
    then
        local brew_readlink_1 brew_readlink_2
        local koopa_readlink
        local make_readlink_1 make_readlink_2
        brew_readlink_1='/opt/homebrew/opt/coreutils/libexec/bin/readlink'
        brew_readlink_2='/usr/local/opt/coreutils/libexec/bin/readlink'
        koopa_readlink='/opt/koopa/opt/coreutils/bin/readlink'
        make_readlink_1='/usr/local/bin/readlink'
        make_readlink_2='/usr/local/bin/greadlink'
        if [ -x "$koopa_readlink" ]
        then
            readlink="$koopa_readlink"
        elif [ -x "$make_readlink_1" ]
        then
            readlink="$make_readlink_1"
        elif [ -x "$make_readlink_2" ]
        then
            readlink="$make_readlink_2"
        elif [ -x "$brew_readlink_1" ]
        then
            readlink="$brew_readlink_1"
        elif [ -x "$brew_readlink_2" ]
        then
            readlink="$brew_readlink_2"
        else
            __koopa_warn 'GNU coreutils is required.'
            return 1
        fi
    fi
    x="$("$readlink" -f "$@")"
    [ -n "$x" ] || return 1
    __koopa_print "$x"
    return 0
}

__koopa_shell_name() { # {{{1
    # """
    # Shell name.
    # @note Updated 2021-05-25.
    # """
    if [ -n "${BASH_VERSION:-}" ]
    then
        shell='bash'
    elif [ -n "${ZSH_VERSION:-}" ]
    then
        shell='zsh'
    else
        shell='posix'
    fi
    __koopa_print "$shell"
}

__koopa_str_detect_posix() { # {{{1
    # """
    # Evaluate whether a string contains a desired value.
    # @note Updated 2022-01-10.
    # """
    test "${1#*"$2"}" != "$1"
}

__koopa_warn() { # {{{1
    # """
    # Print a warning message to the console.
    # @note Updated 2021-05-14.
    # """
    local string
    for string in "$@"
    do
        printf '%b\n' "$string" >&2
    done
    return 0
}

__koopa_zsh_source() { # {{{1
    # """
    # Zsh source file location.
    # @note Updated 2021-11-18.
    #
    # Use '%x' not '%N' when called inside function.
    # https://stackoverflow.com/a/23259585/3911732
    # """
    # shellcheck disable=SC2296
    __koopa_print "${(%):-%x}"
    return 0
}

__koopa_activate() { # {{{1
    # """
    # Activate koopa bootloader inside shell session.
    # @note Updated 2022-02-25.
    # """
    case "${1:-}" in
        '--help' | '-h')
            __koopa_activate_usage
            return 0
            ;;
    esac
    __koopa_preflight || return 0
    __koopa_export_koopa_subshell || return 1
    __koopa_export_koopa_prefix || return 1
    export KOOPA_ACTIVATE=1
    # shellcheck source=/dev/null
    . "$(__koopa_header)" || return 1
    unset -v KOOPA_ACTIVATE
    return 0
}

__koopa_activate "$@"

# NOTE Don't attempt to unset functions here, can cause hash table warnings
# with active interactive Zsh session.

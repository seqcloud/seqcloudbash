#!/bin/sh



# Pre-flight checks                                                         {{{1
# ==============================================================================

# Operating system                                                          {{{2
# ------------------------------------------------------------------------------

# Bash sets the shell variable OSTYPE (e.g. linux-gnu).
# However, this doesn't work consistently with zsh, so use uname instead.

case "$(uname -s)" in
    Darwin)
        ;;
    Linux)
        ;;
    *)
        >&2 printf "Error: Unsupported operating system.\n"
        return 1
        ;;
esac

# Bad settings                                                              {{{2
# ------------------------------------------------------------------------------

# Note that we're skipping this checks inside RStudio shell.
if [ -z "${RSTUDIO:-}" ]
then
    _acid_warn_if_export "JAVA_HOME" "LD_LIBRARY_PATH" "PYTHONHOME" "R_HOME"
fi



# XDG base directory specification                                          {{{1
# ==============================================================================

# XDG_RUNTIME_DIR:
# - Can only exist for the duration of the user's login.
# - Updated every 6 hours or set sticky bit if persistence is desired.
# - Should not store large files as it may be mounted as a tmpfs.

# > if [ ! -d "$XDG_RUNTIME_DIR" ]
# > then
# >     mkdir -pv "$XDG_RUNTIME_DIR"
# >     chown "$USER" "$XDG_RUNTIME_DIR"
# >     chmod 0700 "$XDG_RUNTIME_DIR"
# > fi

# See also:
# - https://developer.gnome.org/basedir-spec/
# - https://wiki.archlinux.org/index.php/XDG_Base_Directory

if [ -z "${XDG_CACHE_HOME:-}" ]
then
    XDG_CACHE_HOME="${HOME}/.cache"
fi

if [ -z "${XDG_CONFIG_HOME:-}" ]
then
    XDG_CONFIG_HOME="${HOME}/.config"
fi

if [ -z "${XDG_DATA_HOME:-}" ]
then
    XDG_DATA_HOME="${HOME}/.local/share"
fi

if [ -z "${XDG_RUNTIME_DIR:-}" ]
then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    if _acid_is_darwin
    then
        XDG_RUNTIME_DIR="/tmp${XDG_RUNTIME_DIR}"
    fi
fi

if [ -z "${XDG_DATA_DIRS:-}" ]
then
    XDG_DATA_DIRS="/usr/local/share:/usr/share"
fi

if [ -z "${XDG_CONFIG_DIRS:-}" ]
then
    XDG_CONFIG_DIRS="/etc/xdg"
fi

export XDG_CACHE_HOME
export XDG_CONFIG_DIRS
export XDG_CONFIG_HOME
export XDG_DATA_DIRS
export XDG_DATA_HOME
export XDG_RUNTIME_DIR

mkdir -p "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"



# Standard globals                                                          {{{1
# ==============================================================================

# This variables are used by some koopa scripts, so ensure they're always
# consistently exported across platforms.

# HOSTNAME
if [ -z "${HOSTNAME:-}" ]
then
    HOSTNAME="$(uname -n)"
    export HOSTNAME
fi

# OSTYPE
# Automatically set by bash and zsh.
if [ -z "${OSTYPE:-}" ]
then
    OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
    export OSTYPE
fi

# SHELL
# Note that this doesn't currently get set by RStudio terminal.
SHELL="$(_acid_realpath "$KOOPA_SHELL")"
export SHELL

# TERM
# Terminal color mode. This should normally be set by the terminal client.
if [ -z "${TERM:-}" ]
then
    export TERM="screen-256color"
fi

# TMPDIR
if [ -z "${TMPDIR:-}" ]
then
    export TMPDIR="/tmp"
fi

# TODAY
# Current date. Alternatively, can use '%F' shorthand.
if [ -z "${TODAY:-}" ]
then
    TODAY="$(date +%Y-%m-%d)"
    export TODAY
fi

# USER
if [ -z "${USER:-}" ]
then
    USER="$(whoami)"
    export USER
fi



# History                                                                   {{{1
# ==============================================================================

if [ -z "${HISTFILE:-}" ]
then
    HISTFILE="${HOME}/.$(_acid_shell)-history"
    export HISTFILE
fi

if [ -z "${HISTSIZE:-}" ]
then
    export HISTSIZE=100000
fi

if [ -z "${SAVEHIST:-}" ]
then
    export SAVEHIST=100000
fi

if [ -z "${HISTCONTROL:-}" ]
then
    export HISTCONTROL="ignoredups"
fi

if [ -z "${HISTIGNORE:-}" ]
then
    export HISTIGNORE="&:ls:[bf]g:exit"
fi

# Add the date/time to 'history' command output.
# Note that on macOS bash will fail if 'set -e' is set and this isn't exported.
if [ -z "${HISTTIMEFORMAT:-}" ]
then
    export HISTTIMEFORMAT="%Y%m%d %T  "
fi

# For bash users, autojump keeps track of directories by modifying
# '$PROMPT_COMMAND'. Do not overwrite '$PROMPT_COMMAND':
# https://github.com/wting/autojump
# > export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"
if [ -z "${PROMPT_COMMAND:-}" ]
then
    export PROMPT_COMMAND="history -a"
fi



# Locale / encoding                                                         {{{1
# ==============================================================================

# Force UTF-8 to avoid encoding issues for users with broken locale settings.
# https://github.com/Homebrew/brew/blob/master/Library/Homebrew/brew.sh
# > export LC_ALL="C"

if [ "$(locale charmap 2>/dev/null)" != "UTF-8" ]
then
    export LC_ALL="en_US.UTF-8"
fi



# CPU count                                                                 {{{1
# ==============================================================================

# Get the number of cores (CPUs) available.
# Updated 2019-09-18.
if _acid_is_darwin
then
    CPU_COUNT="$(sysctl -n hw.ncpu)"
elif _acid_is_linux
then
    CPU_COUNT="$(getconf _NPROCESSORS_ONLN)"
else
    # Otherwise assume single threaded.
    CPU_COUNT=1
fi
# Set to n-1 cores, if applicable.
# We're leaving a core free to monitor remote sessions.
if [ "$CPU_COUNT" -gt 1 ]
then
    CPU_COUNT=$((CPU_COUNT - 1))
fi
export CPU_COUNT



# PATH                                                                      {{{1
# ==============================================================================

# Note that here we're making sure local binaries are included.
# Inspect '/etc/profile' if system PATH appears misconfigured.

# See also:
# - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard

# Standard paths                                                            {{{2
# ------------------------------------------------------------------------------

_acid_add_to_path_end "/usr/local/bin"
_acid_add_to_path_end "/usr/bin"
_acid_add_to_path_end "/bin"

_acid_has_sudo &&
    _acid_add_to_path_end "/usr/local/sbin"
_acid_has_sudo &&
    _acid_add_to_path_end "/usr/sbin"

_acid_add_to_path_start "${HOME}/bin"
_acid_add_to_path_start "${HOME}/local/bin"
_acid_add_to_path_start "${HOME}/.local/bin"

# Koopa paths                                                               {{{2
# ------------------------------------------------------------------------------

_acid_add_bins_to_path
_acid_add_bins_to_path "shell/${KOOPA_SHELL}"

# - ID="amzn"
#   ID_LIKE="centos rhel fedora"
# - ID="rhel"
#   ID_LIKE="fedora"
# - ID="ubuntu"
#   ID_LIKE=debian

if _acid_is_linux
then
    _acid_add_bins_to_path "os/linux"
    id_like="$(grep "ID_LIKE" /etc/os-release | cut -d "=" -f 2)"
    if echo "$id_like" | grep -q "debian"
    then
        id_like="debian"
    elif echo "$id_like" | grep -q "fedora"
    then
        id_like="fedora"
    else
        id_like=
    fi
    if [ -n "${id_like:-}" ]
    then
        _acid_add_bins_to_path "os/${id_like}"
    fi
    unset -v id_like
fi

_acid_add_bins_to_path "os/$(_acid_os_type)"
_acid_add_bins_to_path "host/$(_acid_host_type)"

# Private scripts                                                           {{{2
# ------------------------------------------------------------------------------

_acid_add_to_path_start "$(_acid_config_dir)/docker/bin"
_acid_add_to_path_start "$(_acid_config_dir)/scripts-private/bin"



# MANPATH                                                                   {{{1
# ==============================================================================

_acid_force_add_to_manpath_start "${KOOPA_HOME}/man"

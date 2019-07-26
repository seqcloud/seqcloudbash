#!/bin/sh

## Activate Python "default" virtual environment.
## Updated 2019-06-27.

## Note that we're using this instead of conda as our default interactive
## Python environment, so we can easily use pip.

## Only attempt to autoload for bash or zsh.
koopa shell | grep -Eq "^(bash|zsh)$" || return 0

env_name="default"

[ -z "${PYTHON_EXE:-}" ] && \
    [ -f "${HOME}/.virtualenvs/${env_name}/bin/python" ] && \
    PYTHON_EXE="${HOME}/.virtualenvs/${env_name}/bin/python"

## Early return if we don't detect an installation.
[ -z "${PYTHON_EXE:-}" ] && 
    unset -v env_name &&
    return

export PYTHON_EXE

## Don't allow Python to change the prompt string.
export VIRTUAL_ENV_DISABLE_PROMPT=1

## Now we're ready to activate.
virtualenv_bin_dir="$(dirname "$PYTHON_EXE")"

## Avoid PATH duplication when spawning inside tmux.
if ! echo "$PATH" | grep -q "$virtualenv_bin_dir"
then
    ## shellcheck source=/dev/null
    . "${virtualenv_bin_dir}/activate"
fi

unset -v env_name virtualenv_bin_dir

#!/usr/bin/env bash

koopa:::list_path_priority() { # {{{1
    # """
    # Split PATH string by ':' delim into lines.
    # @note Updated 2021-01-20.
    #
    # Alternate approach using tr:
    # > tr="$(koopa::locate_tr)"
    # > x="$("$tr" ':' '\n' <<< "$str")"
    #
    # Bash parameter expansion approach:
    # > koopa::print "${PATH//:/$'\n'}"
    #
    # see also:
    # - https://askubuntu.com/questions/600018
    # - https://stackoverflow.com/questions/26849247
    # - https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html
    # - https://www.unix.com/shell-programming-and-scripting/
    #       77199-splitting-string-awk.html
    # """
    local str
    koopa::assert_has_args_le "$#" 1
    str="${1:-$PATH}"
    str="$(koopa::print "${str//:/$'\n'}")"
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
    return 0
}

koopa:::list_path_priority_unique() { # {{{1
    # """
    # Split PATH string by ':' delim into lines but only return uniques.
    # @note Updated 2022-02-11.
    # """
    local app str
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [tac]="$(koopa::locate_tac)"
    )
    # shellcheck disable=SC2016
    str="$( \
        koopa:::list_path_priority "$@" \
            | "${app[tac]}" \
            | "${app[awk]}" '!a[$0]++' \
            | "${app[tac]}" \
    )"
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
    return 0
}

koopa::list_app_versions() { # {{{1
    # """
    # List installed application versions.
    # @note Updated 2022-02-11.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="$(koopa::app_prefix)"
    )
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa::alert_note "No apps are installed in '${dict[prefix]}'."
        return 0
    fi
    dict[str]="$( \
        koopa::find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict[prefix]}" \
            --sort \
            --type='d' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa::print "${dict[str]}"
    return 0
}

koopa::list_dotfiles() { # {{{1
    # """
    # List dotfiles.
    # @note Updated 2022-02-11.
    # """
    koopa::assert_has_no_args "$#"
    koopa::h1 "Listing dotfiles in '${HOME:?}'."
    koopa::find_dotfiles d 'Directories'
    koopa::find_dotfiles f 'Files'
    # FIXME We can't use the 'l' argument currently with Rust fd...rework.
    # > koopa::find_dotfiles l 'Symlinks'
}

# FIXME Rework using app/dict approach.
koopa::list_path_priority() { # {{{1
    # """
    # List path priority.
    # @note Updated 2021-05-24.
    # """
    local all all_arr awk n_all n_dupes n_unique str unique
    awk="$(koopa::locate_awk)"
    all="$(koopa:::list_path_priority "$@")"
    [[ -n "$all" ]] || return 1
    readarray -t all_arr <<< "$(koopa::print "$all")"
    # shellcheck disable=SC2016
    unique="$( \
        koopa::print "$all" \
        | "$awk" '!a[$0]++' \
    )"
    readarray -t unique_arr <<< "$(koopa::print "$unique")"
    n_all="${#all_arr[@]}"
    n_unique="${#unique_arr[@]}"
    n_dupes="$((n_all - n_unique))"
    if [[ "$n_dupes" -gt 0 ]]
    then
        str="$(koopa::ngettext "${n_dupes}" 'duplicate' 'duplicates')"
        koopa::alert_note "${n_dupes} ${str} detected."
    fi
    koopa::print "$all"
    return 0
}

koopa::list_programs() { # {{{1
    # """
    # List koopa programs available in PATH.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::r_koopa --vanilla 'cliListPrograms'
    return 0
}

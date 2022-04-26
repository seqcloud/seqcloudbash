#!/usr/bin/env bash

koopa_macos_brew_cask_outdated() { # {{{
    # """
    # List outdated Homebrew casks.
    # @note Updated 2021-10-27.
    #
    # Need help with capturing output:
    # - https://stackoverflow.com/questions/58344963/
    # - https://unix.stackexchange.com/questions/253101/
    #
    # Syntax changed from 'brew cask outdated' to 'brew outdated --cask' in
    # 2020-09.
    #
    # @seealso
    # - brew leaves
    # - brew deps --installed --tree
    # - brew list --versions
    # - brew info
    # """
    local app keep_latest tmp_file x
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
        [cut]="$(koopa_locate_cut)"
    )
    # Whether we want to keep unversioned 'latest' casks returned with
    # '--greedy'. This tends to include font casks and the Google Cloud SDK,
    # which are annoying to have reinstall with each update, so disabling
    # here by default.
    keep_latest=0
    # This approach keeps the version information, which we can parse.
    tmp_file="$(koopa_tmp_file)"
    script -q "$tmp_file" \
        "${app[brew]}" outdated --cask --greedy >/dev/null
    if [[ "$keep_latest" -eq 1 ]]
    then
        x="$("${app[cut]}" -d ' ' -f '1' < "$tmp_file")"
    else
        x="$( \
            koopa_grep \
                --file="$tmp_file" \
                --invert-match \
                --pattern='(latest)' \
            | "${app[cut]}" -d ' ' -f '1' \
        )"
    fi
    koopa_rm "$tmp_file"
    [[ -n "$x" ]] || return 0
    koopa_print "$x"
    return 0
}

koopa_macos_brew_cask_quarantine_fix() { # {{{1
    # """
    # Homebrew cask fix for macOS quarantine.
    # @note Updated 2021-10-27.
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [xattr]="$(koopa_macos_locate_xattr)"
    )
    "${app[sudo]}" "${app[xattr]}" -r -d \
        'com.apple.quarantine' \
        '/Applications/'*'.app'
    return 0
}

koopa_macos_brew_upgrade_casks() { # {{{1
    # """
    # Upgrade Homebrew casks.
    # @note Updated 2022-04-24.
    #
    # Note that additional cask flags are set globally using the
    # 'HOMEBREW_CASK_OPTS' global, declared in our main Homebrew activation
    # function.
    # """
    local app cask casks
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    readarray -t casks <<< "$(koopa_macos_brew_cask_outdated)"
    koopa_is_array_non_empty "${casks[@]:-}" || return 0
    koopa_dl \
        "$(koopa_ngettext \
            --num="${#casks[@]}" \
            --msg1='outdated cask' \
            --msg2='outdated casks' \
        )" \
        "$(koopa_to_string "${casks[@]}")"
    for cask in "${casks[@]}"
    do
        case "$cask" in
            'docker')
                cask='homebrew/cask/docker'
                ;;
            'macvim')
                cask='homebrew/cask/macvim'
                ;;
        esac
        "${app[brew]}" reinstall --cask --force "$cask" || true
        case "$cask" in
            'adoptopenjdk' | \
            'openjdk' | \
            'r' | \
            'temurin')
                app[r]="$(koopa_macos_r_prefix)/bin/R"
                koopa_configure_r "${app[r]}"
                ;;
            # > 'emacs')
            # >     "${app[brew]}" unlink 'emacs'
            # >     "${app[brew]}" link 'emacs'
            # >     ;;
            'google-'*)
                # Currently in 'google-chrome' and 'google-drive' recipes.
                koopa_macos_disable_google_keystone || true
                ;;
            'gpg-suite'*)
                koopa_macos_disable_gpg_updater
                ;;
            'macvim')
                "${app[brew]}" unlink 'vim'
                "${app[brew]}" link 'vim'
                ;;
            'microsoft-teams')
                koopa_macos_disable_microsoft_teams_updater
                ;;
        esac
    done
    return 0
}


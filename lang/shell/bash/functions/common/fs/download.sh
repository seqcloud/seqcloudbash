#!/usr/bin/env bash

koopa_download() { # {{{1
    # """
    # Download a file.
    # @note Updated 2022-02-17.
    #
    # @section curl:
    #
    # Potentially useful arguments:
    # * --connect-timeout <seconds>
    # * --progress-bar
    # * --silent
    # * --stderr
    # * -q, --disable: Disable '.curlrc' file.
    #
    # Note that '--fail-early' flag is useful, but not supported on old versions
    # of curl (e.g. 7.29.0; RHEL 7).
    #
    # @section wget:
    #
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # """
    local app dict download_args
    koopa_assert_has_args_le "$#" 2
    declare -A dict=(
        [url]="${1:?}"
        [file]="${2:-}"
    )
    if koopa_is_qemu
    then
        dict[engine]='wget'
    else
        dict[engine]='curl'
    fi
    declare -A app=(
        [download]="$("koopa_locate_${dict[engine]}")"
    )
    if [[ -z "${dict[file]}" ]]
    then
        dict[file]="$(koopa_basename "${dict[url]}")"
    fi
    if ! koopa_str_detect_fixed \
        --string="${dict[file]}" \
        --pattern='/'
    then
        dict[file]="$(pwd)/${dict[file]}"
    fi
    download_args=()
    case "${dict[engine]}" in
        'curl')
            download_args+=(
                '--disable'  # Ignore '~/.curlrc'. Must come first.
                '--create-dirs'
                '--fail'
                '--location'
                '--output' "${dict[file]}"
                '--retry' 5
                '--show-error'
            )
            ;;
        'wget')
            download_args+=(
                "--output-document=${dict[file]}"
                '--no-verbose'
            )
            ;;
    esac
    download_args+=("${dict[url]}")
    koopa_alert "Downloading '${dict[url]}' to '${dict[file]}' \
using '${dict[engine]}'."
    "${app[download]}" "${download_args[@]}"
    return 0
}

koopa_download_cran_latest() { # {{{1
    # """
    # Download CRAN latest.
    # @note Updated 2021-10-25.
    # """
    local app file name pattern url
    koopa_assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa_locate_head)"
    )
    for name in "$@"
    do
        url="https://cran.r-project.org/web/packages/${name}/"
        pattern="${name}_[-.0-9]+.tar.gz"
        file="$( \
            koopa_parse_url "$url" \
            | koopa_grep \
                --extended-regexp \
                --only-matching \
                --pattern="$pattern" \
            | "${app[head]}" --lines=1 \
        )"
        koopa_download "https://cran.r-project.org/src/contrib/${file}"
    done
    return 0
}

koopa_download_github_latest() { # {{{1
    # """
    # Download GitHub latest release.
    # @note Updated 2021-10-25.
    # """
    local api_url app repo tag tarball_url
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [tr]="$(koopa_locate_tr)"
    )
    for repo in "$@"
    do
        api_url="https://api.github.com/repos/${repo}/releases/latest"
        tarball_url="$( \
            koopa_parse_url "$api_url" \
            | koopa_grep --pattern='tarball_url' \
            | "${app[cut]}" --delimiter=':' --fields='2,3' \
            | "${app[tr]}" --delete ' ,"' \
        )"
        tag="$(koopa_basename "$tarball_url")"
        koopa_download "$tarball_url" "${tag}.tar.gz"
    done
    return 0
}

koopa_download_refdata_scsig() { # {{{1
    # """
    # Download MSigDB SCSig reference data (now archived).
    # @note Updated 2021-12-09.
    #
    # @seealso
    # - https://www.gsea-msigdb.org/gsea/msigdb/supplementary_genesets.jsp
    # """
    local basename basenames dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [base_url]='http://software.broadinstitute.org/gsea/msigdb/supplemental'
        [name_fancy]='MSigDB SCSig'
        [refdata_prefix]="$(koopa_refdata_prefix)"
        [version]='1.0.1'
    )
    dict[prefix]="${dict[refdata_prefix]}/scsig/${dict[version]}"
    koopa_assert_is_not_dir "${dict[prefix]}"
    koopa_alert "Downloading ${dict[name_fancy]} ${dict[version]} \
to ${dict[prefix]}."
    koopa_mkdir "${dict[prefix]}"
    basenames=(
        "scsig.all.v${dict[version]}.entrez.gmt"
        "scsig.all.v${dict[version]}.symbols.gmt"
        "scsig.v${dict[version]}.metadata.txt"
        "scsig.v${dict[version]}.metadata.xls"
    )
    for basename in "${basenames[@]}"
    do
        koopa_download \
            "${dict[base_url]}/${basename}" \
            "${dict[prefix]}/${basename]}"
    done
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    koopa_alert_success "Download of ${dict[name_fancy]} to \
${dict[prefix]} was successful."
    return 0
}

koopa_ftp_mirror() { # {{{1
    # """
    # Mirror contents from an FTP server.
    # @note Updated 2022-02-10.
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [wget]="$(koopa_locate_wget)"
    )
    declare -A dict=(
        [dir]=''
        [host]=''
        [user]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--dir='*)
                dict[dir]="${1#*=}"
                shift 1
                ;;
            '--dir')
                dict[dir]="${2:?}"
                shift 2
                ;;
            '--host='*)
                dict[host]="${1#*=}"
                shift 1
                ;;
            '--host')
                dict[host]="${2:?}"
                shift 2
                ;;
            '--user='*)
                dict[user]="${1#*=}"
                shift 1
                ;;
            '--user')
                dict[user]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--host' "${dict[host]}" \
        '--user' "${dict[user]}"
    if [[ -n "${dict[dir]}" ]]
    then
        dict[dir]="${dict[host]}/${dict[dir]}"
    else
        dict[dir]="${dict[host]}"
    fi
    "${app[wget]}" \
        --ask-password \
        --mirror \
        "ftp://${dict[user]}@${dict[dir]}/"*
    return 0
}

koopa_parse_url() { # {{{1
    # """
    # Parse a URL using cURL.
    # @note Updated 2022-02-10.
    # """
    local app curl_args dict pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [curl]="$(koopa_locate_curl)"
    )
    curl_args=(
        '--disable'  # Ignore '~/.curlrc'. Must come first.
        '--fail'
        '--location'
        '--retry' 5
        '--show-error'
        '--silent'
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--insecure' | \
            '--list-only')
                curl_args+=("$1")
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_eq "$#" 1
    curl_args+=("${1:?}")
    # NOTE Don't use 'koopa_print' here, since we need to pass binary output
    # in some cases for GPG key configuration.
    "${app[curl]}" "${curl_args[@]}"
    return 0
}

koopa_wget_recursive() { # {{{1
    # """
    # Download files with wget recursively.
    # @note Updated 2022-02-10.
    #
    # Note that we need to escape the wildcards in the password.
    # For direct input, can just use single quotes to escape.
    #
    # @seealso
    # - https://unix.stackexchange.com/questions/379181
    #
    # @examples
    # > koopa_wget_recursive \
    # >     --url='ftp://ftp.example.com/' \
    # >     --user='user' \
    # >     --password='pass'
    # """
    local app dict wget_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [wget]="$(koopa_locate_wget)"
    )
    declare -A dict=(
        [datetime]="$(koopa_datetime)"
        [password]=''
        [url]=''
        [user]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--password='*)
                dict[password]="${1#*=}"
                shift 1
                ;;
            '--password')
                dict[password]="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict[url]="${1#*=}"
                shift 1
                ;;
            '--url')
                dict[url]="${2:?}"
                shift 2
                ;;
            '--user='*)
                dict[user]="${1#*=}"
                shift 1
                ;;
            '--user')
                dict[user]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--password' "${dict[password]}" \
        '--url' "${dict[url]}" \
        '--user' "${dict[user]}"
    dict[log_file]="wget-${dict[datetime]}.log"
    dict[password]="${dict[password]@Q}"
    wget_args=(
        "--output-file=${dict[log_file]}"
        "--password=${dict[password]}"
        "--user=${dict[user]}"
        '--continue'
        '--debug'
        '--no-parent'
        '--recursive'
        "${dict[url]}"/*
    )
    "${app[wget]}" "${wget_args[@]}"
    return 0
}

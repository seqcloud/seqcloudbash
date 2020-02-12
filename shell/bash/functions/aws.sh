#!/usr/bin/env bash
# shellcheck disable=SC2039

# Better programmatic access:
# > aws s3api list-buckets --output json
# > aws s3api list-objects \
# >     --output json \
# >     --bucket tests.acidgenomics.com

_koopa_aws_s3_find() {                                                    # {{{1
    # """
    # Find files in AWS S3 bucket.
    # @note Updated 2020-02-11.
    #
    # @seealso
    # https://docs.aws.amazon.com/cli/latest/reference/s3/
    #
    # @examples
    # aws-s3-find \
    #     --include="*.bw$" \
    #     --exclude="antisense" \
    #     s3://cpi-bioinfo01/igv/
    # """
    _koopa_is_installed aws || return 1

    local exclude include
    exclude=
    include=

    local pos
    pos=()
    while (("$#"))
    do
        case "$1" in
            --exclude=*)
                exclude="${1#*=}"
                shift 1
                ;;
            --exclude)
                exclude="$2"
                shift 2
                ;;
            --include=*)
                include="${1#*=}"
                shift 1
                ;;
            --include)
                include="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    set -- "${pos[@]}"

    local x
    x="$(_koopa_aws_s3_ls --recursive "$@")"
    [[ -n "$x" ]] || return 1

    # Exclude pattern.
    if [[ -n "${exclude:-}" ]]
    then
        x="$(echo "$x" | grep -Ev "$exclude")"
        [[ -n "$x" ]] || return 1
    fi

    # Include pattern.
    if [[ -n "${include:-}" ]]
    then
        x="$(echo "$x" | grep -E "$include")"
        [[ -n "$x" ]] || return 1
    fi

    echo "$x"
    return 0
}

_koopa_aws_s3_ls() {                                                      # {{{1
    # """
    # List AWS S3 bucket.
    # @note Updated 2020-02-11.
    #
    # @seealso aws s3 ls help
    #
    # @examples
    # _koopa_aws_s3_ls s3://cpi-bioinfo01/
    # _koopa_aws_s3_ls cpi-bioinfo01/
    # 
    # # Directories only:
    # aws-s3-ls --type=f s3://cpi-bioinfo01/datasets/
    # """
    _koopa_is_installed aws || return 1

    local flags
    flags=()

    local recursive
    recursive=0

    local type
    type=

    local pos
    pos=()
    while (("$#"))
    do
        case "$1" in
            --recursive)
                recursive=1
                flags+=("--recursive")
                shift 1
                ;;
            --type=*)
                type="${1#*=}"
                shift 1
                ;;
            --type)
                type="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    set -- "${pos[@]}"

    # Don't allow '--type' argument when '--recursive' flag is set.
    if [[ "$recursive" -eq 1 ]] && [[ -n "$type" ]]
    then
        _koopa_stop "'--type' argument isn't supported for '--recursive' mode."
    fi

    local dirs files
    case "${type:-}" in
        d)
            dirs=1
            files=0
            ;;
        f)
            dirs=0
            files=1
            ;;
        *)
            dirs=1
            files=1
            ;;
    esac

    local prefix
    prefix="${1:?}"
    prefix="$(_koopa_strip_trailing_slash "$prefix")"
    prefix="${prefix}/"

    # Automatically add 's3://' if missing.
    if ! _koopa_is_matching_regex "$prefix" "^s3://"
    then
        prefix="s3://${prefix}"
    fi

    local x
    x="$(aws s3 ls "${flags[@]}" "$prefix")"

    # Recursive mode.
    # Note that in '--recursive' mode, 'aws s3 ls' returns the full path after
    # the bucket name.
    if [[ "$recursive" -eq 1 ]]
    then
        local bucket_prefix
        bucket_prefix="$(echo "$prefix" | grep -Eo '^s3://[^/]+')"
        files="$(echo "$x" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)"
        [[ -n "$files" ]] || return 0
        files="$( \
            echo "$files" \
                | grep -Eo '  [0-9]+ .+$' \
                | sed 's/^  [0-9]* //g' \
                | sed "s|^|${bucket_prefix}/|g" \
        )"
        echo "$files"
        return 0
    fi

    # Directories.
    if [[ "$dirs" -eq 1 ]]
    then
        dirs="$(echo "$x" | grep -Eo '  PRE .+$' || true)"
        if [[ -n "$dirs" ]]
        then
            dirs="$( \
                echo "$dirs" \
                    | sed 's/^  PRE //g' \
                    | sed "s|^|${prefix}|g" \
            )"
            echo "$dirs"
        fi
    fi

    # Files.
    if [[ "$files" -eq 1 ]]
    then
        files="$(echo "$x" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)"
        if [[ -n "$files" ]]
        then
            files="$( \
                echo "$files" \
                    | grep -Eo '  [0-9]+ .+$' \
                    | sed 's/^  [0-9]* //g' \
                    | sed "s|^|${prefix}|g" \
            )"
            echo "$files"
        fi
    fi

    return 0
}

_koopa_aws_s3_mv_to_parent() {                                            # {{{1
    # """
    # Move objects in S3 directory to parent directory.
    # @note Updated 2020-02-12.
    # """
    _koopa_is_installed aws || return 1
    local prefix
    prefix="${1:?}"
    local x
    x="$(aws-s3-ls "$prefix")"
    [[ -n "$x" ]] || return 0
    local files
    mapfile -t files <<< "$x"
    for file in "${files[@]}"
    do
        local bn dn1 dn2 target
        bn="$(basename "$file")"
        dn1="$(dirname "$file")"
        dn2="$(dirname "$dn1")"
        target="${dn2}/${bn}"
        aws s3 mv "$file" "$target"
    done
    # Remove the now empty input directory.
    # > aws s3 rm "$prefix"
    return 0
}

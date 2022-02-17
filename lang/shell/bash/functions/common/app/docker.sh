#!/usr/bin/env bash

koopa::docker_build() { # {{{1
    # """
    # Build and push a multi-architecture Docker image using buildx.
    # Updated 2022-01-20.
    #
    # Potentially useful arguments:
    # * --label='Descriptive metadata about the image'"
    # * --rm
    # * --squash
    # * This can be useful for R packages:
    #   --build-arg "GITHUB_PAT=${DOCKER_GITHUB_PAT:?}"
    #
    # Running the command 'docker buildx install' sets up docker builder
    # command as an alias to 'docker buildx'. This results in the ability to
    # have 'docker build' use the current buildx builder. To remove this
    # alias, run 'docker buildx uninstall'.
    #
    # See also:
    # - docker build --help
    # - https://docs.docker.com/buildx/working-with-buildx/
    # - https://docs.docker.com/config/containers/resource_constraints/
    # - https://docs.docker.com/engine/reference/builder/#arg
    # - https://docs.docker.com/engine/reference/commandline/buildx_build/
    # - https://docs.docker.com/engine/reference/commandline/builder_build/
    # - https://github.com/docker/buildx/issues/396
    # - https://phoenixnap.com/kb/docker-memory-and-cpu-limit
    # - https://jaimyn.com.au/how-to-build-multi-architecture-docker-images-
    #       on-an-m1-mac/
    # """
    local app dict pos
    koopa::assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [date]="$(koopa::locate_date)"
        [docker]="$(koopa::locate_docker)"
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [docker_dir]="$(koopa::docker_prefix)"
        [delete]=0
        [memory]=''
        [push]=1
        [server]='docker.io'
        [tag]='latest'
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--docker-dir='*)
                dict[docker_dir]="${1#*=}"
                shift 1
                ;;
            '--docker-dir')
                dict[docker_dir]="${2:?}"
                shift 2
                ;;
            '--memory='*)
                # e.g. use '8g' for 8 GB limit.
                dict[memory]="${1#*=}"
                shift 1
                ;;
            '--memory')
                dict[memory]="${2:?}"
                shift 2
                ;;
            '--server='*)
                dict[server]="${1#*=}"
                shift 1
                ;;
            '--server')
                dict[server]="${2:?}"
                shift 2
                ;;
            '--tag='*)
                dict[tag]="${1#*=}"
                shift 1
                ;;
            '--tag')
                dict[tag]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--delete')
                dict[delete]=1
                shift 1
                ;;
            '--no-delete')
                dict[delete]=0
                shift 1
                ;;
            '--no-push')
                dict[push]=0
                shift 1
                ;;
            '--push')
                dict[push]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    for image in "$@"
    do
        local build_args dict2 image_ids platforms tag tags
        declare -A dict2=(
            [image]="$image"
        )
        build_args=()
        platforms=()
        tags=()
        # Assume input is an Acid Genomics Docker recipe by default.
        if ! koopa::str_detect_fixed \
            --string="${dict2[image]}" \
            --pattern='/'
        then
            dict2[image]="acidgenomics/${dict2[image]}"
        fi
        # Handle tag support, if necessary.
        if koopa::str_detect_fixed \
            --string="${dict2[image]}" \
            --pattern=':'
        then
            dict2[tag]="$( \
                koopa::print "${dict2[image]}" \
                | "${app[cut]}" -d ':' -f 2 \
            )"
            dict2[image]="$( \
                koopa::print "${dict2[image]}" \
                | "${app[cut]}" -d ':' -f 1 \
            )"
        fi
        dict2[source_image]="${dict[docker_dir]}/${dict2[image]}/${dict2[tag]}"
        koopa::assert_is_dir "${dict2[source_image]}"
        # Tags.
        dict2[tags_file]="${dict2[source_image]}/tags.txt"
        if [[ -f "${dict2[tags_file]}" ]]
        then
            readarray -t tags < "${dict2[tags_file]}"
        fi
        if [[ -L "${dict2[source_image]}" ]]
        then
            tags+=("${dict2[tag]}")
            dict2[source_image]="$(koopa::realpath "${dict2[source_image]}")"
            dict2[tag]="$(koopa::basename "${dict2[source_image]}")"
        fi
        tags+=(
            "${dict2[tag]}"
            "${dict2[tag]}-$(${app[date]} '+%Y%m%d')"
        )
        # Ensure tags are sorted and unique.
        readarray -t tags <<< "$( \
            koopa::print "${tags[@]}" \
            | "${app[sort]}" -u \
        )"
        for tag in "${tags[@]}"
        do
            build_args+=("--tag=${dict2[image]}:${tag}")
        done
        # Platforms.
        # Assume x86 by default.
        platforms=('linux/amd64')
        dict2[platforms_file]="${dict2[source_image]}/platforms.txt"
        if [[ -f "${dict2[platforms_file]}" ]]
        then
            readarray -t platforms < "${dict2[platforms_file]}"
        fi
        # e.g. 'linux/amd64,linux/arm64'.
        dict2[platforms_string]="$(koopa::paste --sep=',' "${platforms[@]}")"
        build_args+=("--platform=${dict2[platforms_string]}")
        # Harden against buildx blowing up memory on a local machine.
        # Consider raising this when we deploy a more powerful build machine.
        # > local memory
        if [[ -n "${dict[memory]}" ]]
        then
            # If you don't want to use swap, give '--memory' and '--memory-swap'
            # the same values. Don't set '--memory-swap' to 0. Alternatively,
            # set '--memory-swap' to '-1' for unlimited swap.
            build_args+=(
                "--memory=${dict[memory]}"
                "--memory-swap=${dict[memory]}"
            )
        fi
        build_args+=(
            '--no-cache'
            '--progress=auto'
            '--pull'
        )
        if [[ "${dict[push]}" -eq 1 ]]
        then
            build_args+=('--push')
        fi
        build_args+=("$source_image")
        # Force remove any existing locally tagged images before building.
        if [[ "${dict[delete]}" -eq 1 ]]
        then
            koopa::alert "Pruning images '${dict2[image]}:${dict2[tag]}'."
            readarray -t image_ids <<< "$( \
                "${app[docker]}" image ls \
                    --filter reference="${dict2[image]}:${dict2[tag]}" \
                    --quiet \
            )"
            if koopa::is_array_non_empty "${image_ids[@]:-}"
            then
                "${app[docker]}" image rm --force "${image_ids[@]}"
            fi
        fi
        koopa::alert "Building '${dict2[source_image]}' Docker image."
        koopa::dl 'Build args' "${build_args[*]}"
        "${app[docker]}" login "${dict[server]}" >/dev/null || return 1
        dict2[build_name]="$(koopa::basename "${dict2[image]}")"
        # Ensure any previous build failres are removed.
        "${app[docker]}" buildx rm \
            "${dict2[build_name]}" \
            &>/dev/null \
            || true
        "${app[docker]}" buildx create \
            --name="${dict2[build_name]}" \
            --use \
            >/dev/null
        "${app[docker]}" buildx build "${build_args[@]}" || return 1
        "${app[docker]}" buildx rm "${dict2[build_name]}"
        "${app[docker]}" image ls \
            --filter \
            reference="${dict2[image]}:${dict2[tag]}"
        koopa::alert_success "Build of '${dict2[source_image]}' was successful."
    done
    return 0
}

koopa::docker_build_all_images() { # {{{1
    # """
    # Build all Docker images.
    # @note Updated 2022-02-16.
    # """
    local app build_file build_args image images
    local pos repo repos repo_name 
    declare -A app=(
        [basename]="$(koopa::locate_basename)"
        [docker]="$(koopa::locate_docker)"
        [xargs]="$(koopa::locate_xargs)"
    )
    declare -A dict=(
        [days]=7
        [docker_dir]="$(koopa::docker_prefix)"
        [force]=0
        [prune]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--days='*)
                dict[days]="${1#*=}"
                shift 1
                ;;
            '--days')
                dict[days]="${2:?}"
                shift 2
                ;;
            '--docker-dir='*)
                dict[docker_dir]="${1#*=}"
                shift 1
                ;;
            '--docker-dir')
                dict[docker_dir]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--force')
                dict[force]=1
                shift 1
                ;;
            '--prune')
                dict[prune]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    build_args=("--days=${dict[days]}")
    if [[ "${dict[force]}" -eq 1 ]]
    then
        build_args+=('--force')
    fi
    if [[ "$#" -gt 0 ]]
    then
        repos=("$@")
    else
        repos=("${dict[docker_dir]}/acidgenomics")
    fi
    koopa::assert_is_dir "${repos[@]}"
    if [[ "${dict[prune]}" -eq 1 ]]
    then
        koopa::docker_prune_all_images
    fi
    "${app[docker]}" login
    for repo in "${repos[@]}"
    do
        repo_name="$(koopa::basename "$(koopa::realpath "$repo")")"
        koopa::h1 "Building '${repo_name}' images."
        build_file="${repo}/build.txt"
        if [[ -f "$build_file" ]]
        then
            readarray -t images <<< "$( \
                koopa::grep \
                    --extended-regexp \
                    '^[-_a-z0-9]+$' \
                    "$build_file" \
            )"
        else
            readarray -t images <<< "$( \
                koopa::find \
                    --max-depth=1 \
                    --min-depth=1 \
                    --prefix="${PWD:?}" \
                    --print0 \
                    --sort \
                    --type='d' \
                | "${app[xargs]}" \
                    --max-args=1 \
                    --no-run-if-empty \
                    --null \
                    "${app[basename]}" \
            )"
        fi
        koopa::assert_is_array_non_empty "${images[@]:-}"
        koopa::dl \
            "${#images[@]} images" \
            "$(koopa::to_string "${images[@]}")"
        for image in "${images[@]}"
        do
            image="${repo_name}/${image}"
            # Skip image if pushed recently.
            if [[ "${dict[force]}" -eq 0 ]]
            then
                # NOTE This step currently pulls the image and checks the
                # timestamp locally. We likely can speed this step up
                # significantly by querying the DockerHub API directly instead.
                # Refer to 'docker-prune-stale-tags' approach for example code,
                # which is currently written in R instead of Bash.
                if koopa::docker_is_build_recent \
                    --days="${dict[days]}" \
                    "$image"
                then
                    koopa::alert_note "'${image}' was built recently. Skipping."
                    continue
                fi
            fi
            koopa::docker_build_all_tags "${build_args[@]}" "$image"
        done
    done
    [[ "${dict[prune]}" -eq 1 ]] && koopa::docker_prune_all_images
    koopa::alert_success 'All Docker images built successfully.'
    return 0
}

koopa::docker_ghcr_login() { # {{{1
    # """
    # Log in to GitHub Container Registry.
    # @note Updated 2022-01-20.
    #
    # User ('GHCR_USER') and PAT ('GHCR_PAT') are defined by exported globals.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    declare -A dict=(
        [pat]="${GHCR_PAT:?}"
        [server]='ghcr.io'
        [user]="${GHCR_USER:?}"
    )
    koopa::print "${dict[pat]}" \
        | "${app[docker]}" login \
            "${dict[server]}" \
            -u "${dict[user]}" \
            --password-stdin
    return 0
}

koopa::docker_ghcr_push() { # {{{
    # """
    # Push an image to GitHub Container Registry.
    # @note Updated 2022-01-20.
    #
    # @examples
    # koopa::docker_ghcr_push 'OWNER' 'IMAGE_NAME' 'VERSION'
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 3
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    declare -A dict=(
        [image_name]="${2:?}"
        [owner]="${1:?}"
        [server]='ghcr.io'
        [version]="${3:?}"
    )
    dict[url]="${dict[server]}/${dict[owner]}/\
${dict[image_name]}:${dict[version]}"
    koopa::docker_ghcr_login
    "${app[docker]}" push "${dict[url]}"
    return 0
}

koopa::docker_is_build_recent() { # {{{1
    # """
    # Has the requested Docker image been built recently?
    # @note Updated 2022-01-20.
    #
    # @seealso
    # - Corresponding 'isDockerBuildRecent()' R function.
    # - https://stackoverflow.com/questions/8903239/
    # - https://unix.stackexchange.com/questions/27013/
    # """
    local app dict image pos
    koopa::assert_has_args "$#"
    declare -A app=(
        [date]="$(koopa::locate_date)"
        [docker]="$(koopa::locate_docker)"
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [days]=7
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--days='*)
                dict[days]="${1#*=}"
                shift 1
                ;;
            '--days')
                dict[days]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    # 24 hours * 60 minutes * 60 seconds = 86400.
    dict[seconds]="$((dict[days] * 86400))"
    for image in "$@"
    do
        local dict2
        declare -A dict2=(
            [current]="$("${app[date]}" -u '+%s')"
            [image]="$image"
        )
        "${app[docker]}" pull "${dict2[image]}" >/dev/null
        dict2[json]="$( \
            "${app[docker]}" inspect \
                --format='{{json .Created}}' \
                "${dict2[image]}" \
        )"
        dict2[created]="$( \
            koopa::print "${dict2[json]}" \
                | koopa::grep \
                    --extended-regexp \
                    --only-matching \
                    '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}' \
                | "${app[sed]}" 's/T/ /' \
                | "${app[sed]}" 's/\$/ UTC/'
        )"
        dict2[created]="$("${app[date]}" -u -d "${dict2[created]}" '+%s')"
        dict2[diff]=$((dict2[current] - dict2[created]))
        [[ "${dict2[diff]}" -le "${dict[seconds]}" ]] && continue
        return 1
    done
    return 0
}

koopa::docker_prune_all_images() { # {{{1
    # """
    # Prune all Docker images.
    # @note Updated 2022-01-20.
    #
    # This is a nuclear option for resetting Docker.
    # """
    local app
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    koopa::alert 'Pruning Docker images.'
    "${app[docker]}" system prune --all --force || true
    "${app[docker]}" images
    koopa::alert 'Pruning Docker buildx.'
    "${app[docker]}" buildx prune --all --force || true
    "${app[docker]}" buildx ls
    return 0
}

koopa::docker_prune_old_images() { # {{{
    # """
    # Prune old Docker images.
    # @note Updated 2022-01-20.
    #
    # 2160h = 24 hours/day * 30 days/month * 3 months.
    #
    # @seealso
    # - https://docs.docker.com/config/pruning/#prune-images
    # - https://docs.docker.com/engine/reference/commandline/image_prune/
    # - https://stackoverflow.com/questions/32723111
    # """
    local app
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    koopa::alert 'Pruning Docker images older than 3 months.'
    "${app[docker]}" image prune \
        --all \
        --filter 'until=2160h' \
        --force \
        || true
    # Clean any remaining dangling images.
    "${app[docker]}" image prune --force || true
    return 0
}

koopa::docker_push() { # {{{1
    # """
    # Push a local Docker build.
    # Updated 2022-01-20.
    #
    # Useful if GPG agent causes push failure.
    #
    # @seealso
    # - https://docs.docker.com/config/formatting/
    #
    # @examples
    # docker-push acidgenomics/debian:latest
    # """
    local app dict pattern
    koopa::assert_has_args "$#"
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
        [sed]="$(koopa::locate_sed)"
        [sort]="$(koopa::locate_sort)"
        [tr]="$(koopa::locate_tr)"
    )
    declare -A dict=(
        # Consider allowing user to define, so we can support quay.io.
        [server]='docker.io'
    )
    for pattern in "$@"
    do
        local dict2 image images
        declare -A dict2=(
            [pattern]="$pattern"
        )
        koopa::assert_is_matching_regex "${dict2[pattern]}" '^.+/.+$'
        dict2[json]="$( \
            "${app[docker]}" inspect \
                --format="{{json .RepoTags}}" \
                "${dict2[pattern]}" \
        )"
        # Convert JSON to lines.
        readarray -t images <<< "$( \
            koopa::print "${dict2[json]}" \
                | "${app[tr]}" ',' '\n' \
                | "${app[sed]}" 's/^\[//' \
                | "${app[sed]}" 's/\]$//' \
                | "${app[sed]}" 's/^\"//g' \
                | "${app[sed]}" 's/\"$//g' \
                | "${app[sort]}" \
        )"
        if koopa::is_array_empty "${images[@]:-}"
        then
            koopa::stop "Failed to match any images with '${dict2[pattern]}'."
        fi
        for image in "${images[@]}"
        do
            koopa::alert "Pushing '${image}' to '${dict[server]}'."
            "${app[docker]}" push "${dict[server]}/${image}"
        done
    done
    return 0
}

koopa::docker_remove() { # {{{1
    # """
    # Remove docker images by pattern.
    # Updated 2022-02-16.
    # """
    local app pattern
    koopa::assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [docker]="$(koopa::locate_docker)"
        [xargs]="$(koopa::locate_xargs)"
    )
    for pattern in "$@"
    do
        # shellcheck disable=SC2016
        "${app[docker]}" images \
            | koopa::grep "$pattern" \
            | "${app[awk]}" '{print $1 ":" $2}' \
            | "${app[xargs]}" \
                --no-run-if-empty \
                --verbose \
                "${app[docker]}" rmi
    done
    return 0
}

koopa::docker_run() { # {{{1
    # """
    # Run Docker image.
    # @note Updated 2022-02-17.
    #
    # No longer using bind mounts by default.
    # Use named volumes, which have better cross-platform compatiblity, instead.
    #
    # @seealso
    # - https://docs.docker.com/storage/volumes/
    # - https://docs.docker.com/storage/bind-mounts/
    # """
    local app dict pos run_args
    koopa::assert_has_args "$#"
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    declare -A dict=(
        [arm]=0
        [bash]=0
        [bind]=0
        [workdir]='/mnt/work'
        [x86]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--arm')
                dict[arm]=1
                shift 1
                ;;
            '--bash')
                dict[bash]=1
                shift 1
                ;;
            '--bind')
                dict[bind]=1
                shift 1
                ;;
            '--x86')
                dict[x86]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args_eq "$#" 1
    dict[image]="${1:?}"
    "${app[docker]}" pull "${dict[image]}"
    run_args=(
        '--interactive'
        '--tty'
    )
    # Legacy bind mounts approach, now disabled by default.
    # Useful for quickly checking whether a local script will run.
    if [[ "${dict[bind]}" -eq 1 ]]
    then
        # This check helps prevent Docker from chewing up a bunch of CPU.
        if [[ "${HOME:?}" == "${PWD:?}" ]]
        then
            koopa::stop "Do not set '--bind' when running at HOME."
        fi
        run_args+=(
            "--volume=${PWD:?}:${dict[workdir]}"
            "--workdir=${dict[workdir]}"
        )
    fi
    # Manually override the platform, if desired.
    if [[ "${dict[arm]}" -eq 1 ]]
    then
        run_args+=('--platform=linux/arm64')
    elif [[ "${dict[x86]}" -eq 1 ]]
    then
        run_args+=('--platform=linux/amd64')
    fi
    run_args+=("${dict[image]}")
    # Enable an interactive Bash login session, if desired.
    if [[ "${dict[bash]}" -eq 1 ]]
    then
        run_args+=('bash' '-il')
    fi
    "${app[docker]}" run "${run_args[@]}"
    return 0
}

koopa::docker_tag() { # {{{1
    # """
    # Add Docker tag.
    # Updated 2022-01-20.
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [docker]="$(koopa::locate_docker)"
    )
    declare -A dict=(
        [dest_tag]="${3:-}"
        [image]="${1:?}"
        # Consider allowing this to be user-definable in the future.
        [server]='docker.io'
        [source_tag]="${2:?}"
    )
    [[ -z "${dict[dest_tag]}" ]] && dict[dest_tag]='latest'
    # Assume acidgenomics recipe by default.
    if ! koopa::str_detect_fixed \
        --string="${dict[image]}" \
        --pattern='/'
    then
        dict[image]="acidgenomics/${dict[image]}"
    fi
    if [[ "${dict[source_tag]}" == "${dict[dest_tag]}" ]]
    then
        koopa::alert_info "Source tag identical to destination \
('${dict[source_tag]}')."
        return 0
    fi
    koopa::alert "Tagging '${dict[image]}:${dict[source_tag]}' \
as '${dict[dest_tag]}'."
    "${app[docker]}" login "${dict[server]}"
    "${app[docker]}" pull "${dict[server]}/${dict[image]}:${dict[source_tag]}"
    "${app[docker]}" tag \
        "${dict[image]}:${dict[source_tag]}" \
        "${dict[image]}:${dict[dest_tag]}"
    "${app[docker]}" push "${dict[server]}/${dict[image]}:${dict[dest_tag]}"
    return 0
}

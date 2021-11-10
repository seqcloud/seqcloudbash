#!/usr/bin/env bash

koopa::debian_apt_add_key() {  #{{{1
    # """
    # Add a GPG key (and/or keyring) for apt.
    # @note Updated 2021-11-09.
    #
    # @section Hardening against insecure URL failure:
    # 
    # Using '--insecure' flag here to handle some servers
    # (e.g. download.opensuse.org) that can fail otherwise.
    #
    # @section Regarding apt-key deprecation:
    #
    # Although adding keys directly to '/etc/apt/trusted.gpg.d/' is suggested by
    # 'apt-key' deprecation message, as per Debian Wiki, GPG keys for third
    # party repositories should be added to '/usr/share/keyrings', and
    # referenced with the 'signed-by' option in the '/etc/apt/sources.list.d'
    # entry.
    #
    # @section Alternative approach using tee:
    #
    # > koopa::parse_url --insecure "${dict[url]}" \
    # >     | "${app[gpg]}" --dearmor \
    # >     | "${app[sudo]}" "${app[tee]}" "${dict[file]}" \
    # >         >/dev/null 2>&1 \
    # >     || true
    #
    # @seealso
    # - https://github.com/docker/docker.github.io/issues/11625
    # - https://github.com/docker/docker.github.io/issues/
    #     11625#issuecomment-751388087
    # """
    local app dict
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [gpg]="$(koopa::locate_gpg)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [name]=''
        [name_fancy]=''
        [prefix]="$(koopa::debian_apt_key_prefix)"
        [url]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--name-fancy='*)
                dict[name_fancy]="${1#*=}"
                shift 1
                ;;
            '--name-fancy')
                dict[name_fancy]="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
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
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_dir "${dict[prefix]}"
    dict[file]="${dict[prefix]}/koopa-${dict[name]}.gpg"
    [[ -f "${dict[file]}" ]] && return 0
    koopa::alert "Adding ${dict[name_fancy]} key at '${dict[file]}'."
    koopa::parse_url --insecure "${dict[url]}" \
        | "${app[sudo]}" "${app[gpg]}" \
            --dearmor \
            --output "${dict[file]}" \
            >/dev/null 2>&1 \
        || true
    koopa::assert_is_file "${dict[file]}"
    return 0
}

koopa::debian_apt_add_repo() {
    # """
    # Add an apt repo.
    # @note Updated 2021-11-09.
    #
    # @section Debian Repository Format:
    #
    # The sources.list man page specifies this package source format:
    # 
    # > deb uri distribution [component1] [component2] [...]
    #
    # and gives an example:
    #
    # > deb https://deb.debian.org/debian stable main contrib non-free
    #
    # The 'uri', in this case 'https://deb.debian.org/debian', specifies the
    # root of the archive. Often Debian archives are in the 'debian/' directory
    # on the server but can be anywhere else (many mirrors for example have it
    # in a 'pub/linux/debian' directory, for example).
    #
    # The 'distribution' part ('stable' in this case) specifies a subdirectory
    # in '$ARCHIVE_ROOT/dists'. It can contain additional slashes to specify
    # subdirectories nested deeper, eg. 'stable/updates'. 'distribution'
    # typically corresponds to 'Suite' or 'Codename' specified in the
    # 'Release' files.
    #
    # To download the index of the main component, apt would scan the 'Release'
    # file for hashes of files in the main directory.
    #
    # eg. 'https://deb.debian.org/debian/dists/testing/main/
    #      binary-i386/Packages.gz',
    # which would be listed in
    # 'https://deb.debian.org/debian/dists/testing/Release' as
    # 'main/binary-i386/Packages.gz'.
    #
    # Binary package indices are in 'binary-$arch' subdirectory of the component
    # directories. Source indices are in 'source' subdirectory.
    #
    # Package indices list specific source or binary packages relative to the
    # archive root.
    #
    # To avoid file duplication binary and source packages are usually kept in
    # the 'pool' subdirectory of the 'archive root'. The 'Packages' and
    # 'Sources' indices can list any path relative to 'archive root', however.
    # It is suggested that packages are placed in a subdirectory of 'archive
    # root' other than dists rather than directly in archive root. Placing
    # packages directly in the 'archive root' is not tested and some tools may
    # fail to index or retrieve packages placed there.
    #
    # The 'Contents' and 'Translation' indices are not architecture-specific and
    # are placed in 'dists/$DISTRIBUTION/$COMPONENT' directory, not architecture
    # subdirectory. 
    #
    # @seealso
    # - https://wiki.debian.org/DebianRepository/Format
    # """
    local components dict
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [arch]="$(koopa::arch2)"  # e.g. 'amd64'.
        [key_prefix]="$(koopa::debian_apt_key_prefix)"
        [prefix]="$(koopa::debian_apt_sources_prefix)"
    )
    components=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--component='*)
                components+=("${1#*=}")
                shift 1
                ;;
            '--component')
                components+=("${2:?}")
                shift 2
                ;;
            '--distribution='*)
                dict[distribution]="${1#*=}"
                shift 1
                ;;
            '--distribution')
                dict[distribution]="${2:?}"
                shift 2
                ;;
            '--key-name='*)
                dict[key_name]="${1#*=}"
                shift 1
                ;;
            '--key-name')
                dict[key_name]="${2:?}"
                shift 2
                ;;
            '--key-prefix='*)
                dict[key_prefix]="${1#*=}"
                shift 1
                ;;
            '--key-prefix')
                dict[key_prefix]="${2:?}"
                shift 2
                ;;
            '--name-fancy='*)
                dict[name_fancy]="${1#*=}"
                shift 1
                ;;
            '--name-fancy')
                dict[name_fancy]="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--signed-by='*)
                dict[signed_by]="${1#*=}"
                shift 1
                ;;
            '--signed-by')
                dict[signed_by]="${2:?}"
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
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict[key_name]:-}" ]]
    then
        dict[key_name]="${dict[name]}"
    fi
    koopa::assert_is_set \
        '--distribution' "${dict[distribution]:-}" \
        '--key-name' "${dict[key_name]:-}" \
        '--key-prefix' "${dict[key_prefix]:-}" \
        '--name' "${dict[name]:-}" \
        '--name-fancy' "${dict[name_fancy]:-}" \
        '--prefix' "${dict[prefix]:-}" \
        '--url' "${dict[url]:-}"
    koopa::assert_is_array_non_empty "${components[@]:-}"
    koopa::assert_is_dir \
        "${dict[key_prefix]}" \
        "${dict[prefix]}"
    dict[signed_by]="${dict[key_prefix]}/koopa-${dict[key_name]}.gpg"
    koopa::assert_is_file "${dict[signed_by]}"
    dict[file]="${dict[prefix]}/koopa-${dict[name]}.list"
    dict[string]="deb [arch=${dict[arch]} signed-by=${dict[signed_by]}] \
${dict[url]} ${dict[distribution]} ${components[*]}"
    if [[ -f "${dict[file]}" ]]
    then
        koopa::alert_info "${dict[name_fancy]} repo exists at '${dict[file]}'."
        return 0
    fi
    koopa::alert "Adding ${dict[name_fancy]} repo at '${dict[file]}'."
    koopa::sudo_write_string "${dict[string]}" "${dict[file]}"
    return 0
}

koopa::debian_apt_add_azure_cli_repo() { # {{{1
    # """
    # Add Microsoft Azure CLI apt repo.
    # @note Updated 2021-11-09.
    # """
    koopa::assert_has_no_args "$#"
    koopa::debian_apt_add_microsoft_key
    koopa::debian_apt_add_repo \
        --name-fancy='Microsoft Azure CLI' \
        --name='azure-cli' \
        --key-name='microsoft' \
        --url='https://packages.microsoft.com/repos/azure-cli/' \
        --distribution="$(koopa::os_codename)" \
        --component='main'
    return 0
}

koopa::debian_apt_add_docker_key() { # {{{1
    # """
    # Add the Docker key.
    # @note Updated 2021-11-09.
    #
    # @seealso
    # - https://docs.docker.com/engine/install/debian/
    # - https://docs.docker.com/engine/install/ubuntu/
    # """
    koopa::assert_has_no_args "$#"
    koopa::debian_apt_add_key \
        --name-fancy='Docker' \
        --name='docker' \
        --url="https://download.docker.com/linux/$(koopa::os_id)/gpg"
    return 0
}

koopa::debian_apt_add_docker_repo() { # {{{1
    # """
    # Add Docker apt repo.
    # @note Updated 2021-11-09.
    #
    # @seealso
    # - https://docs.docker.com/engine/install/debian/
    # - https://docs.docker.com/engine/install/ubuntu/
    # """
    koopa::assert_has_no_args "$#"
    koopa::debian_apt_add_docker_key
    koopa::debian_apt_add_repo \
        --name-fancy='Docker' \
        --name='docker' \
        --url="https://download.docker.com/linux/$(koopa::os_id)" \
        --distribution="$(koopa::os_codename)" \
        --component='stable'
    return 0
}

koopa::debian_apt_add_google_cloud_key() { # {{{1
    # """
    # Add the Google Cloud key.
    # @note Updated 2021-11-09.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install#deb
    # - https://github.com/docker/docker.github.io/issues/11625
    # """
    koopa::assert_has_no_args "$#"
    koopa::debian_apt_add_key \
        --name-fancy='Google Cloud' \
        --name='google-cloud' \
        --url='https://packages.cloud.google.com/apt/doc/apt-key.gpg'
    return 0
}

koopa::debian_apt_add_google_cloud_sdk_repo() { # {{{1
    # """
    # Add Google Cloud SDK apt repo.
    # @note Updated 2021-11-09.
    # """
    koopa::assert_has_no_args "$#"
    koopa::debian_apt_add_google_cloud_key
    koopa::debian_apt_add_repo \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --key-name='google-cloud' \
        --url='https://packages.cloud.google.com/apt' \
        --distribution='cloud-sdk' \
        --component='main'
    return 0
}

koopa::debian_apt_add_llvm_key() { # {{{1
    # """
    # Add the LLVM key.
    # @note Updated 2021-11-09.
    # """
    koopa::assert_has_no_args "$#"
    koopa::debian_apt_add_key \
        --name-fancy='LLVM' \
        --name='llvm' \
        --url='https://apt.llvm.org/llvm-snapshot.gpg.key'
    return 0
}

koopa::debian_apt_add_llvm_repo() { # {{{1
    # """
    # Add LLVM apt repo.
    # @note Updated 2021-11-10.
    # """
    koopa::assert_has_args_le "$#" 1
    declare -A dict=(
        [component]='main'
        [name]='llvm'
        [name_fancy]='LLVM'
        [os]="$(koopa::os_codename)"
        [version]="${1:-}"
    )
    if [[ -z "${dict[version]}" ]]
    then
        dict[version]="$(koopa::variable "${dict[name]}")"
    fi
    dict[url]="http://apt.llvm.org/${dict[os]}/"
    dict[version2]="$(koopa::major_version "${dict[version]}")"
    dict[distribution]="llvm-toolchain-${dict[os]}-${dict[version2]}"
    koopa::debian_apt_add_llvm_key
    koopa::debian_apt_add_repo \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[name]}" \
        --url="${dict[url]}" \
        --distribution="${dict[distribution]}" \
        --component="${dict[component]}"
    return 0
}

koopa::debian_apt_add_microsoft_key() {  #{{{1
    # """
    # Add the Microsoft GPG key (for Azure CLI).
    # @note Updated 2021-11-09.
    # """
    koopa::assert_has_no_args "$#"
    koopa::debian_apt_add_key \
        --name-fancy='Microsoft' \
        --name='microsoft' \
        --url='https://packages.microsoft.com/keys/microsoft.asc'
    return 0
}

koopa::debian_apt_add_r_key() { # {{{1
    # """
    # Add the R key.
    # @note Updated 2021-11-03.
    #
    # Addition of signing key via keyserver directly into /etc/apt/trusted.gpg'
    # file is deprecated in Debian, but currently the only supported method for
    # installation of R CRAN binaries. Consider reworking this approach for
    # future R releases, if possible.
    #
    # @section Previous archive key:
    #
    # Additional archive key (required as of 2020-09): 'FCAE2A0E115C3D8A'
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/
    # """
    local dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [key_name]='r'
        # Alternatively, can use 'keys.gnupg.net' keyserver.
        [keyserver]='keyserver.ubuntu.com'
        [prefix]="$(koopa::debian_apt_key_prefix)"
    )
    dict[file]="${dict[prefix]}/koopa-${dict[key_name]}.gpg"
    if koopa::is_ubuntu_like
    then
        # Ubuntu release is signed by Michael Rutter <marutter@gmail.com>.
        dict[key]='E298A3A825C0D65DFD57CBB651716619E084DAB9'
    else
        # Debian release is signed by Johannes Ranke <jranke@uni-bremen.de>.
        dict[key]='E19F5F87128899B192B1A2C2AD5F960A256A04AF'
    fi
    [[ -f "${dict[file]}" ]] && return 0
    koopa::gpg_download_key_from_keyserver \
        --file="${dict[file]}" \
        --key="${dict[key]}" \
        --keyserver="${dict[keyserver]}" \
        --sudo
    return 0
}

# FIXME This needs to call koopa:::debian_apt_add_repo.
koopa::debian_apt_add_r_repo() { # {{{1
    # """
    # Add R apt repo.
    # @note Updated 2021-11-03.
    # """
    local dict
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_admin
    declare -A dict=(
        [name]='r'
        [name_fancy]='R'
        [os_codename]="$(koopa::os_codename)"
        [version]="${1:-}"
    )
    if koopa::is_ubuntu_like
    then
        dict[os_id]='ubuntu'
    else
        dict[os_id]='debian'
    fi
    if [[ -z "${dict[version]}" ]]
    then
        dict[version]="$(koopa::variable "${dict[name]}")"
    fi
    dict[version2]="$(koopa::major_minor_version "${dict[version]}")"
    case "${dict[version2]}" in
        '4.1')
            dict[version2]='4.0'
            ;;
        '3.6')
            dict[version2]='3.5'
            ;;
    esac
    dict[version2]="$(koopa::gsub '\.' '' "${dict[version2]}")"
    dict[file]="${dict[repo_prefix]}/koopa-${dict[name]}.list"
    dict[url]="https://cloud.r-project.org/bin/linux/${dict[os_id]}"
    dict[signed_by]="${dict[key_prefix]}/koopa-${dict[key_name]}.gpg"
    dict[channel]="${dict[os_codename]}-cran${dict[version2]}/"
    dict[string]="deb [arch=${dict[arch]} signed-by=${dict[signed_by]}] \
${dict[url]} ${dict[channel]}"
    if [[ -f "${dict[file]}" ]]
    then
        # Early return if version matches and Debian source is enabled.
        if koopa::file_match_fixed "${dict[file]}" "${dict[version2]}"
        then
            return 0
        else
            koopa::rm --sudo "${dict[file]}"
        fi
    fi
    koopa::debian_apt_add_r_key
    koopa::alert "Adding ${dict[name_fancy]} repo at '${dict[file]}'."
    koopa::sudo_write_string "${dict[string]}" "${dict[file]}"
    return 0
}

koopa::debian_apt_add_wine_key() { # {{{1
    # """
    # Add the WineHQ key.
    # @note Updated 2021-11-09.
    #
    # Email: <wine-devel@winehq.org>
    #
    # - Debian:
    #   https://wiki.winehq.org/Debian
    # - Ubuntu:
    #   https://wiki.winehq.org/Ubuntu
    #
    # > wget -O - https://dl.winehq.org/wine-builds/winehq.key \
    # >     | sudo apt-key add -
    #
    # > wget -nc https://dl.winehq.org/wine-builds/winehq.key
    # > sudo apt-key add winehq.key
    # """
    koopa::assert_has_no_args "$#"
    koopa::debian_apt_add_key \
        --name-fancy='Wine' \
        --name='wine' \
        --url='https://dl.winehq.org/wine-builds/winehq.key'
    return 0
}


# FIXME This needs to call koopa:::debian_apt_add_repo.
koopa::debian_apt_add_wine_repo() { # {{{1
    # """
    # Add WineHQ repo.
    # @note Updated 2021-06-11.
    #
    # - Debian:
    #   https://wiki.winehq.org/Debian
    # - Ubuntu:
    #   https://wiki.winehq.org/Ubuntu
    # """
    local file os_codename os_id string url
    koopa::assert_has_no_args "$#"
    name='wine'
    name_fancy='Wine'
    # FIXME Rework using prefix variable.
    file="/etc/apt/sources.list.d/koopa-${name}.list"
    if [[ -f "$file" ]]
    then
        koopa::alert_info "${name_fancy} repo exists at '${file}'."
        return 0
    fi
    koopa::debian_apt_add_wine_key
    os_id="$(koopa::os_id)"
    os_codename="$(koopa::os_codename)"
    url="https://dl.winehq.org/wine-builds/${os_id}/"
    # FIXME Need to include arch and signed-by.
    string="deb ${url} ${os_codename} main"
    koopa::alert "Adding ${name_fancy} repo at '${file}'."
    koopa::sudo_write_string "$string" "$file"
    return 0
}

koopa::debian_apt_add_wine_obs_key() { # {{{1
    # """
    # Add the Wine OBS openSUSE key.
    # @note Updated 2021-11-09.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [name]='wine-obs'
        [name_fancy]='Wine OBS'
        [os_string]="$(koopa::os_string)"
    )
    # FIXME Need to add support for other Debian and Ubuntu releases here.
    case "${dict[os_string]}" in
        'debian-10')
            dict[subdir]='Debian_10'
            ;;
        'ubuntu-18')
            dict[subdir]='xUbuntu_18.04'
            ;;
        'ubuntu-20')
            dict[subdir]='xUbuntu_20.04'
            ;;
        *)
            koopa::stop "Unsupported OS: '${dict[os_string]}'."
            ;;
    esac
    dict[url]="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian/${dict[subdir]}/Release.key"
    koopa::debian_apt_add_key \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[wine_obs]}" \
        --url="${dict[url]}"
    return 0
}

# FIXME This needs to call koopa:::debian_apt_add_repo.
koopa::debian_apt_add_wine_obs_repo() { # {{{1
    # """
    # Add Wine OBS openSUSE repo.
    # @note Updated 2021-06-11.
    #
    # Required to install libfaudio0 dependency for Wine on Debian 10+.
    #
    # @seealso
    # - https://wiki.winehq.org/Debian
    # - https://forum.winehq.org/viewtopic.php?f=8&t=32192
    # """
    local base_url file name name_fancy os_string repo_url string
    koopa::assert_has_no_args "$#"
    name='wine-obs'
    name_fancy='Wine OBS'
    file="/etc/apt/sources.list.d/${name}.list"
    if [[ -f "$file" ]]
    then
        koopa::alert_info "${name_fancy} repo exists at '${file}'."
        return 0
    fi
    koopa::alert "Adding ${name_fancy} repo at '${file}'."
    koopa::debian_apt_add_wine_obs_key
    base_url="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian"
    os_string="$(koopa::os_string)"
    case "$os_string" in
        'debian-10')
            repo_url="${base_url}/Debian_10/"
            ;;
        'ubuntu-18')
            repo_url="${base_url}/xUbuntu_18.04/"
            ;;
        *)
            koopa::stop "Unsupported OS: '${os_string}'."
            ;;
    esac
    string="deb ${repo_url} ./"
    koopa::sudo_write_string "$string" "$file"
    return 0
}

koopa::debian_apt_clean() { # {{{1
    # """
    # Clean up apt after an install/uninstall call.
    # @note Updated 2021-11-02.
    #
    # Alternatively, can consider using 'autoclean' here, which is lighter
    # than calling 'clean'.

    # - 'clean': Cleans the packages and install script in
    #       '/var/cache/apt/archives/'.
    # - 'autoclean': Cleans obsolete deb-packages, less than 'clean'.
    # - 'autoremove': Removes orphaned packages which are not longer needed from
    #       the system, but not purges them, use the '--purge' option together
    #       with the command for that.
    #
    # @seealso
    # - https://askubuntu.com/questions/984797/
    # - https://askubuntu.com/questions/3167/
    # - https://github.com/hadolint/hadolint/wiki/DL3009
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --yes autoremove
    "${app[sudo]}" "${app[apt_get]}" --yes clean
    # > koopa::rm --sudo '/var/lib/apt/lists/'*
    return 0
}

koopa::debian_apt_configure_sources() { # {{{1
    # """
    # Configure apt sources.
    # @note Updated 2021-11-05.
    #
    # Look up currently enabled sources with:
    # > grep -Eq '^deb\s' '/etc/apt/sources.list'
    #
    # Debian Docker images can also use snapshots:
    # http://snapshot.debian.org/archive/debian/20210326T030000Z
    #
    # @section AWS AMI instances:
    #
    # Debian 11 x86 defaults:
    # > deb http://cdn-aws.deb.debian.org/debian
    #       bullseye main
    # > deb http://security.debian.org/debian-security
    #       bullseye-security main
    # > deb http://cdn-aws.deb.debian.org/debian
    #       bullseye-updates main
    # > deb http://cdn-aws.deb.debian.org/debian
    #       bullseye-backports main
    #
    # Debian 11 ARM defaults:
    # deb http://cdn-aws.deb.debian.org/debian
    #     bullseye main
    # deb http://security.debian.org/debian-security
    #     bullseye-security main
    # deb http://cdn-aws.deb.debian.org/debian
    #     bullseye-updates main
    # deb http://cdn-aws.deb.debian.org/debian
    #     bullseye-backports main
    #
    # Ubuntu 20 LTS x86 defaults:
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal main restricted
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-updates main restricted
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal universe
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-updates universe
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal multiverse
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-updates multiverse
    # > deb http://us-east-1.ec2.archive.ubuntu.com/ubuntu/
    #       focal-backports main restricted universe multiverse
    # > deb http://security.ubuntu.com/ubuntu
    #       focal-security main restricted
    # > deb http://security.ubuntu.com/ubuntu
    #       focal-security universe
    # > deb http://security.ubuntu.com/ubuntu
    #       focal-security multiverse
    #
    # Ubuntu ARM defaults:
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal main restricted
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-updates main restricted
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal universe
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-updates universe
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal multiverse
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-updates multiverse
    # > deb http://us-east-1.ec2.ports.ubuntu.com/ubuntu-ports/
    #       focal-backports main restricted universe multiverse
    # > deb http://ports.ubuntu.com/ubuntu-ports
    #       focal-security main restricted
    # > deb http://ports.ubuntu.com/ubuntu-ports
    #       focal-security universe
    # > deb http://ports.ubuntu.com/ubuntu-ports
    #       focal-security multiverse
    # """
    local app codenames repos urls
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [os_codename]="$(koopa::os_codename)"
        [os_id]="$(koopa::os_id)"
        [sources_list]="$(koopa::debian_apt_sources_file)"
        [sources_list_d]="$(koopa::debian_apt_sources_prefix)"
    )
    koopa::alert "Configuring apt sources in '${dict[sources_list]}'."
    koopa::assert_is_file "${dict[sources_list]}"
    declare -A codenames=(
        [main]="${dict[os_codename]}"
        [security]="${dict[os_codename]}-security"
        [updates]="${dict[os_codename]}-updates"
    )
    declare -A urls=(
        [main]="$( \
            koopa::grep \
                --extended-regexp \
                '^deb\s' \
                "${dict[sources_list]}" \
            | koopa::grep \
                --fixed-strings \
                " ${codenames[main]} main" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f 2 \
        )"
        [security]="$( \
            koopa::grep \
                --extended-regexp \
                    '^deb\s' \
                    "${dict[sources_list]}" \
            | koopa::grep \
                --fixed-strings \
                " ${codenames[security]} main" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f 2 \
        )"
    )
    if [[ -z "${urls[main]}" ]]
    then
        koopa::stop 'Failed to extract apt main URL.'
    fi
    if [[ -z "${urls[security]}" ]]
    then
        koopa::stop 'Failed to extract apt security URL.'
    fi
    urls[updates]="${urls[main]}"
    case "${dict[os_id]}" in
        'debian')
            # Can consider including 'backports' here.
            repos=('main')
            ;;
        'ubuntu')
            # Can consider including 'multiverse' here.
            repos=('main' 'restricted' 'universe')
            ;;
        *)
            koopa::stop "Unsupported OS: '${dict[os_id]}'."
            ;;
    esac
    # Configure primary apt sources.
    if [[ -L "${dict[sources_list]}" ]]
    then
        koopa::rm --sudo "${dict[sources_list]}"
    fi
    sudo "${app[tee]}" "${dict[sources_list]}" >/dev/null << END
deb ${urls[main]} ${codenames[main]} ${repos[*]}
deb ${urls[security]} ${codenames[security]} ${repos[*]}
deb ${urls[updates]} ${codenames[updates]} ${repos[*]}
END
    # Configure secondary apt sources.
    if [[ -L "${dict[sources_list_d]}" ]]
    then
        koopa::rm --sudo "${dict[sources_list_d]}"
    fi
    if [[ ! -d "${dict[sources_list_d]}" ]]
    then
        koopa::mkdir --sudo "${dict[sources_list_d]}"
    fi
    return 0
}

koopa::debian_apt_delete_repo() { # {{{1
    # """
    # Delete an apt repo file.
    # @note Updated 2021-11-05.
    # """
    local dict file name
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [prefix]="$(koopa::debian_apt_sources_prefix)"
    )
    for name in "$@"
    do
        file="${dict[prefix]}/koopa-${name}.list"
        koopa::assert_is_file "$file"
        koopa::rm --sudo "$file"
    done
    return 0
}

koopa::debian_apt_disable_deb_src() { # {{{1
    # """
    # Disable 'deb-src' source packages.
    # @note Updated 2021-11-05.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sed]="$(koopa::locate_sed)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [file]="${1:-}"
    )
    [[ -z "${dict[file]}" ]] && dict[file]="$(koopa::debian_apt_sources_file)"
    koopa::assert_is_file "${dict[file]}"
    koopa::alert "Disabling Debian sources in '${dict[file]}'."
    if ! koopa::file_match_regex "${dict[file]}" '^deb-src '
    then
        koopa::alert_note "No lines to comment in '${dict[file]}'."
        return 0
    fi
    "${app[sudo]}" "${app[sed]}" -Ei 's/^deb-src /# deb-src /' "${dict[file]}"
    "${app[sudo]}" "${app[apt_get]}" update
    return 0
}

koopa::debian_apt_enable_deb_src() { # {{{1
    # """
    # Enable 'deb-src' source packages.
    # @note Updated 2021-11-05.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sed]="$(koopa::locate_sed)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [file]="${1:-}"
    )
    [[ -z "${dict[file]}" ]] && dict[file]="$(koopa::debian_apt_sources_file)"
    koopa::assert_is_file "${dict[file]}"
    koopa::alert "Enabling Debian sources in '${dict[file]}'."
    if ! koopa::file_match_regex "${dict[file]}" '^# deb-src '
    then
        koopa::alert_note "No lines to uncomment in '${dict[file]}'."
        return 0
    fi
    "${app[sudo]}" "${app[sed]}" -Ei 's/^# deb-src /deb-src /' "${dict[file]}"
    "${app[sudo]}" "${app[apt_get]}" update
    return 0
}

koopa::debian_apt_enabled_repos() { # {{{1
    # """
    # Get a list of enabled default apt repos.
    # @note Updated 2021-11-05.
    # """
    local app file os_codename pattern x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
    )
    declare -A dict=(
        [file]="$(koopa::debian_apt_sources_file)"
        [os]="$(koopa::os_codename)"
    )
    dict[pattern]="^deb\s.+\s${dict[os]}\s.+$"
    x="$( \
        koopa::grep \
            --extended-regexp \
            "${dict[pattern]}" \
            "${dict[file]}" \
        | "${app[cut]}" -d ' ' -f '4-' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
}

koopa::debian_apt_get() { # {{{1
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2021-11-02.
    #
    # Currently intended for:
    # - dist-upgrade
    # - install
    # """
    local app
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" update
    "${app[sudo]}" DEBIAN_FRONTEND='noninteractive' \
        "${app[apt_get]}" \
            --no-install-recommends \
            --quiet \
            --yes \
            "$@"
    return 0
}

koopa::debian_apt_install() { # {{{1
    # """
    # Install Debian apt package.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    koopa::debian_apt_get install "$@"
}

koopa::debian_apt_is_key_imported() { # {{{1
    # """
    # Is a GPG key imported for apt?
    # @note Updated 2021-11-02.
    #
    # sed only supports up to 9 elements in replacement, even though our
    # input contains 10. Need to switch to awk or another approach to make
    # this matching even more exact.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [apt_key]="$(koopa::debian_locate_apt_key)"
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [key]="${1:?}"
    )
    dict[key_pattern]="$( \
        koopa::print "${dict[key]}" \
        | "${app[sed]}" 's/ //g' \
        | "${app[sed]}" -E "s/^(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})\
(.{4})(.{4})(.{4})\$/\1 \2 \3 \4 \5  \6 \7 \8 \9/" \
    )"
    dict[string]="$("${app[apt_key]}" list 2>&1 || true)"
    koopa::str_match_fixed "${dict[string]}" "${dict[key_pattern]}"
}

koopa::debian_apt_key_prefix() { # {{{1
    # """
    # Debian apt key prefix.
    # @note Updated 2021-11-02.
    # @seealso
    # - '/etc/apt/trusted.gpg.d' (alternate location for apt).
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '/usr/share/keyrings'
}

koopa::debian_apt_remove() { # {{{1
    # """
    # Remove Debian apt package.
    # @note Updated 2021-11-02.
    # """
    local app
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --yes remove --purge "$@"
    koopa::debian_apt_clean
    return 0
}

koopa::debian_apt_sources_file() { # {{{1
    # """
    # Debian apt sources file.
    # @note Updated 2021-11-02.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '/etc/apt/sources.list'
}

koopa::debian_apt_sources_prefix() { # {{{1
    # """
    # Debian apt sources directory.
    # @note Updated 2021-11-02.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '/etc/apt/sources.list.d'
}

koopa::debian_apt_space_used_by() { # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2021-11-02.
    #
    # Alternate approach that doesn't attempt to grep match.
    # """
    local app
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --assume-no autoremove "$@"
    return 0
}

koopa::debian_apt_space_used_by_grep() { # {{{1
    # """
    # Check installed apt package size, with dependencies.
    # @note Updated 2021-11-02.
    #
    # See also:
    # https://askubuntu.com/questions/490945
    # """
    local app x
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [cut]="$(koopa::locate_cut)"
        [sudo]="$(koopa::locate_sudo)"
    )
    x="$( \
        "${app[sudo]}" "${app[apt_get]}" \
            --assume-no \
            autoremove "$@" \
        | koopa::grep 'freed' \
        | "${app[cut]}" -d ' ' -f '4-5' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::debian_apt_space_used_by_no_deps() { # {{{1
    # """
    # Check install apt package size, without dependencies.
    # @note Updated 2021-11-02.
    # """
    local app x
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt]="$(koopa::debian_locate_apt)"
        [sudo]="$(koopa::locate_sudo)"
    )
    x="$( \
        "${app[sudo]}" "${app[apt]}" show "$@" 2>/dev/null \
            | koopa::grep 'Size' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::debian_install_from_deb() { # {{{1
    # """
    # Install directly from a '.deb' file.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_admin
    declare -A app=(
        [gdebi]="$(koopa::debian_locate_gdebi)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [file]="${1:?}"
    )
    "${app[sudo]}" "${app[gdebi]}" --non-interactive "${dict[file]}"
    return 0
}

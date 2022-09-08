#!/usr/bin/env bash

koopa_install_app() {
    # """
    # Install application in a versioned directory structure.
    # @note Updated 2022-09-08.
    # """
    local bin_arr bool dict i man1_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A bool=(
        # When enabled, this will change permissions on the top level directory
        # of the automatically generated prefix.
        ['auto_prefix']=0
        # Download pre-built binary from our S3 bucket. Inspired by the
        # Homebrew bottle approach.
        ['binary']=0
        # Should we copy the log file into the install prefix?
        ['copy_log_file']=0
        # Will any individual programs be linked into koopa 'bin/'?
        ['link_in_bin']=''
        # Link corresponding man1 documentation files for app in bin.
        ['link_in_man1']=''
        # Create an unversioned symlink in koopa 'opt/' directory.
        ['link_in_opt']=''
        # This override is useful for app packages configuration.
        ['prefix_check']=1
        # Push completed build to AWS S3 bucket.
        ['push']=0
        # This is useful for avoiding duplicate alert messages inside of
        # nested install calls (e.g. Emacs installer handoff to GNU app).
        ['quiet']=0
        ['reinstall']=0
        ['update_ldconfig']=0
        ['verbose']=0
    )
    declare -A dict=(
        ['app_prefix']="$(koopa_app_prefix)"
        ['installer']=''
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['log_file']="$(koopa_tmp_log_file)"
        ['mode']='shared'
        ['name']=''
        ['platform']='common'
        ['prefix']=''
        ['version']=''
        ['version_key']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--installer='*)
                dict['installer']="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict['installer']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            '--version-key='*)
                dict['version_key']="${1#*=}"
                shift 1
                ;;
            '--version-key')
                dict['version_key']="${2:?}"
                shift 2
                ;;
            # CLI user-accessible flags ----------------------------------------
            '--binary')
                bool['binary']=1
                shift 1
                ;;
            '--push')
                bool['push']=1
                shift 1
                ;;
            '--reinstall')
                bool['reinstall']=1
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            # Internal flags ---------------------------------------------------
            '--no-link-in-bin')
                bool['link_in_bin']=0
                shift 1
                ;;
            '--no-link-in-man1')
                bool['link_in_man1']=0
                shift 1
                ;;
            '--no-link-in-opt')
                bool['link_in_opt']=0
                shift 1
                ;;
            '--no-prefix-check')
                bool['prefix_check']=0
                shift 1
                ;;
            '--quiet')
                bool['quiet']=1
                shift 1
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            # Configuration passthrough support --------------------------------
            # Inspired by CMake approach using '-D' prefix.
            '-D')
                pos+=("${1:?}" "${2:?}")
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '')
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--name' "${dict['name']}"
    [[ "${bool['verbose']}" -eq 1 ]] && set -o xtrace
    [[ -z "${dict['version_key']}" ]] && dict['version_key']="${dict['name']}"
    dict['current_version']="$(\
        koopa_app_json_version "${dict['version_key']}" \
            2>/dev/null || true \
    )"
    [[ -z "${dict['version']}" ]] && \
        dict['version']="${dict['current_version']}"
    case "${dict['mode']}" in
        'shared')
            if [[ -z "${dict['prefix']}" ]]
            then
                bool['auto_prefix']=1
                dict['version2']="${dict['version']}"
                # Shorten git commit to 7 characters.
                [[ "${#dict['version']}" == 40 ]] && \
                    dict['version2']="${dict['version2']:0:7}"
                dict['prefix']="${dict['app_prefix']}/${dict['name']}/\
${dict['version2']}"
            fi
            if [[ "${dict['version']}" != "${dict['current_version']}" ]]
            then
                bool['link_in_bin']=0
                bool['link_in_man1']=0
                bool['link_in_opt']=0
            else
                [[ -z "${bool['link_in_bin']}" ]] && bool['link_in_bin']=1
                [[ -z "${bool['link_in_man1']}" ]] && bool['link_in_man1']=1
                [[ -z "${bool['link_in_opt']}" ]] && bool['link_in_opt']=1
            fi
            ;;
        'system')
            koopa_assert_is_admin
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            koopa_is_linux && bool['update_ldconfig']=1
            ;;
        'user')
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            ;;
    esac
    [[ -d "${dict['prefix']}" ]] && \
        dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    if [[ -n "${dict['prefix']}" ]] && [[ "${bool['prefix_check']}" -eq 1 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            koopa_is_empty_dir "${dict['prefix']}" && bool['reinstall']=1
            if [[ "${bool['reinstall']}" -eq 1 ]]
            then
                [[ "${bool['quiet']}" -eq 0 ]] && \
                    koopa_alert_uninstall_start \
                        "${dict['name']}" "${dict['prefix']}"
                case "${dict['mode']}" in
                    'system')
                        koopa_rm --sudo "${dict['prefix']}"
                        ;;
                    *)
                        koopa_rm "${dict['prefix']}"
                        ;;
                esac
            fi
            if [[ -d "${dict['prefix']}" ]]
            then
                [[ "${bool['quiet']}" -eq 0 ]] && \
                    koopa_alert_is_installed \
                        "${dict['name']}" "${dict['prefix']}"
                return 0
            fi
        fi
        case "${dict['mode']}" in
            'system')
                dict['prefix']="$(koopa_init_dir --sudo "${dict['prefix']}")"
                ;;
            *)
                dict['prefix']="$(koopa_init_dir "${dict['prefix']}")"
                ;;
        esac
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -n "${dict['prefix']}" ]]
        then
            # FIXME Rework this to support empty prefix.
            koopa_alert_install_start "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_install_start "${dict['name']}"
        fi
    fi
    case "${bool['binary']}" in
        '0')
            local app env_vars path_arr
            declare -A app
            app['bash']="$(koopa_locate_bash --allow-system)"
            app['env']="$(koopa_locate_env --allow-system)"
            app['tee']="$(koopa_locate_tee --allow-system)"
            [[ -x "${app['bash']}" ]] || return 1
            [[ -x "${app['env']}" ]] || return 1
            [[ -x "${app['tee']}" ]] || return 1
            # Configure 'PATH' string.
            path_arr=(
                # > "${dict['koopa_prefix']}/bin"
                # > "${dict['koopa_prefix']}/bootstrap/bin"
                '/usr/bin'
                '/bin'
            )
            # Configure 'PKG_CONFIG_PATH' string.
            PKG_CONFIG_PATH=''
            if koopa_is_linux && [[ -x '/usr/bin/pkg-config' ]]
            then
                koopa_activate_pkg_config '/usr/bin/pkg-config'
            fi
            # Refer to 'locale' for desired LC settings.
            env_vars=(
                "HOME=${HOME:?}"
                'KOOPA_ACTIVATE=0'
                "LANG=${LANG:-}"
                "LC_ALL=${LC_ALL:-}"
                "LC_COLLATE=${LC_COLLATE:-}"
                "LC_CTYPE=${LC_CTYPE:-}"
                "LC_MESSAGES=${LC_MESSAGES:-}"
                "LC_MONETARY=${LC_MONETARY:-}"
                "LC_NUMERIC=${LC_NUMERIC:-}"
                "LC_TIME=${LC_TIME:-}"
                "PATH=$(koopa_paste --sep=':' "${path_arr[@]}")"
                "PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-}"
                "TMPDIR=${TMPDIR:-/tmp}"
            )
            if [[ -d "${dict['prefix']}" ]] && \
                [[ "${dict['mode']}" != 'system' ]]
            then
                bool['copy_log_file']=1
            fi
            "${app['env']}" -i \
                "${env_vars[@]}" \
                "${app['bash']}" \
                    --noprofile \
                    --norc \
                    -o errexit \
                    -o errtrace \
                    -o nounset \
                    -o pipefail \
                    -c "source '${dict['koopa_prefix']}/lang/shell/bash/include/header.sh'; \
                        koopa_install_app_subshell \
                            --installer=${dict['installer']} \
                            --mode=${dict['mode']} \
                            --name=${dict['name']} \
                            --platform=${dict['platform']} \
                            --prefix=${dict['prefix']} \
                            --version=${dict['version']} \
                            ${*}" \
                2>&1 | "${app['tee']}" "${dict['log_file']}"
            if [[ "${bool['copy_log_file']}" -eq 1 ]]
            then
                koopa_cp \
                    "${dict['log_file']}" \
                    "${dict['prefix']}/.koopa-install.log"
            fi
            ;;
        '1')
            [[ "${dict['mode']}" == 'shared' ]] || return 1
            [[ -n "${dict['prefix']}" ]] || return 1
            koopa_install_app_from_binary_package "${dict['prefix']}"
            ;;
    esac
    case "${dict['mode']}" in
        'shared')
            [[ "${bool['auto_prefix']}" -eq 1 ]] && \
                koopa_sys_set_permissions "$(koopa_dirname "${dict['prefix']}")"
            koopa_sys_set_permissions --recursive "${dict['prefix']}"
            [[ "${bool['link_in_opt']}" -eq 1 ]] && \
                koopa_link_in_opt \
                    --name="${dict['name']}" \
                    --source="${dict['prefix']}"
            if [[ "${bool['link_in_bin']}" -eq 1 ]]
            then
                # FIXME Rework this as a function.
                readarray -t bin_arr <<< "$( \
                    koopa_app_json_bin "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if koopa_is_array_non_empty "${bin_arr[@]:-}"
                then
                    for i in "${!bin_arr[@]}"
                    do
                        local dict2
                        declare -A dict2
                        dict2['name']="${bin_arr[$i]}"
                        dict2['source']="${dict['prefix']}/bin/${dict2['name']}"
                        koopa_link_in_bin \
                            --name="${dict2['name']}" \
                            --source="${dict2['source']}"
                    done
                fi
            fi
            if [[ "${bool['link_in_man1']}" -eq 1 ]]
            then
                # FIXME Rework this as a function.
                readarray -t man1_arr <<< "$( \
                    koopa_app_json_man1 "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if koopa_is_array_non_empty "${man1_arr[@]:-}"
                then
                    for i in "${!man1_arr[@]}"
                    do
                        local dict2
                        declare -A dict2
                        dict2['name']="${man1_arr[$i]}"
                        dict2['mf1']="${dict['prefix']}/share/man/\
man1/${dict2['name']}"
                        dict2['mf2']="${dict['prefix']}/man/\
man1/${dict2['name']}"
                        if [[ -f "${dict2['mf1']}" ]]
                        then
                            koopa_link_in_man1 \
                                --name="${dict2['name']}" \
                                --source="${dict2['mf1']}"
                        elif [[ -f "${dict2['mf2']}" ]]
                        then
                            koopa_link_in_man1 \
                                --name="${dict2['name']}" \
                                --source="${dict2['mf2']}"
                        fi
                    done
                fi
            fi
            [[ "${bool['push']}" -eq 1 ]] && \
                koopa_push_app_build "${dict['name']}"
            ;;
        'system')
            [[ "${bool['update_ldconfig']}" -eq 1 ]] && \
                koopa_linux_update_ldconfig
            ;;
        'user')
            [[ -d "${dict['prefix']}" ]] && \
                koopa_sys_set_permissions --recursive --user "${dict['prefix']}"
            ;;
    esac
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            # FIXME Rework this to support empty prefix.
            koopa_alert_install_success "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_install_success "${dict['name']}"
        fi
    fi
    return 0
}

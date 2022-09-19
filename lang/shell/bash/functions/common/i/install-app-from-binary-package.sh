#!/usr/bin/env bash

koopa_install_app_from_binary_package() {
    # """
    # Install app from pre-built binary package.
    # @note Updated 2022-09-19.
    #
    # @examples
    # > koopa_install_app_from_binary_package \
    # >     '/opt/koopa/app/aws-cli/2.7.7' \
    # >     '/opt/koopa/app/bash/5.1.16'
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['aws']="$(koopa_locate_aws --allow-system)"
        ['tar']="$(koopa_locate_tar --allow-system)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['tar']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. 'amd64'.
        ['aws_profile']="${AWS_PROFILE:-acidgenomics}"
        ['binary_prefix']='/opt/koopa'
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['os_string']="$(koopa_os_string)"
        ['s3_bucket']="s3://app.koopa.acidgenomics.com"
        ['tmp_dir']="$(koopa_tmp_dir)"
    )
    if [[ "${dict['koopa_prefix']}" != "${dict['binary_prefix']}" ]]
    then
        koopa_stop "Binary package installation not supported for koopa \
install located at '${dict['koopa_prefix']}'. Koopa must be installed at \
default '${dict['binary_prefix']}' location."
    fi
    koopa_assert_is_dir "$@"
    (
        koopa_cd "${dict['tmp_dir']}"
        for prefix in "$@"
        do
            local dict2
            declare -A dict2
            dict2['prefix']="$(koopa_realpath "$prefix")"
            dict2['name']="$( \
                koopa_print "${dict2['prefix']}" \
                    | koopa_dirname \
                    | koopa_basename \
            )"
            dict2['version']="$(koopa_basename "$prefix")"
            dict2['tar_file']="${dict2['name']}-${dict2['version']}.tar.gz"
            dict2['tar_url']="${dict['url_stem']}/${dict['os_string']}/\
${dict['arch']}/${dict2['name']}/${dict2['version']}.tar.gz"
            if ! koopa_is_url_active "${dict2['tar_url']}"
            then
                koopa_stop "No package at '${dict2['tar_url']}'."
            fi
            aws --profile="${dict['aws_profile']}" \
                s3 cp "${dict2['tar_url']}" "${dict2['tar_file']}"
            "${app['tar']}" -Pxzf "${dict2['tar_file']}"
            koopa_touch "${prefix}/.koopa-binary"
        done
    )
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

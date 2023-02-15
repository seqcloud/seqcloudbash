#!/usr/bin/env bash

koopa_star_align_single_end() {
    # """
    # Run STAR aligner on multiple single-end FASTQs in a directory.
    # @note Updated 2022-03-25.
    #
    # @examples
    # > koopa_star_align_single_end \
    # >     --aws-bucket='s3://bioinfo/rnaseq' \
    # >     --fastq-dir='fastq' \
    # >     --fastq-tail='_001.fastq.gz' \
    # >     --index-dir='star-index' \
    # >     --output-dir='star'
    # """
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        ['aws_bucket']=''
        ['aws_profile']="${AWS_PROFILE:-default}"
        # e.g. 'fastq'.
        ['fastq_dir']=''
        # e.g. '_001.fastq.gz'.
        ['fastq_tail']=''
        # e.g. 'star-index'.
        ['index_dir']=''
        ['mode']='single-end'
        # e.g. 'star'.
        ['output_dir']=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--aws-bucket='*)
                dict['aws_bucket']="${1#*=}"
                shift 1
                ;;
            '--aws-bucket')
                dict['aws_bucket']="${2:?}"
                shift 2
                ;;
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -n "${dict['aws_bucket']}" ]]
    then
        dict['aws_bucket']="$( \
            koopa_strip_trailing_slash "${dict['aws_bucket']}" \
        )"
    fi
    koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running STAR aligner.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ tail' "${dict['fastq_tail']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        koopa_star_align_single_end_per_sample \
            --aws-bucket="${dict['aws_bucket']}" \
            --aws-profile="${dict['aws_profile']}" \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict['fastq_tail']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict['output_dir']}"
    done
    koopa_alert_success 'STAR alignment was successful.'
    return 0
}

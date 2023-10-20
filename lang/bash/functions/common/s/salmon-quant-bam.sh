#!/usr/bin/env bash

# TODO Add support for BAM directory directly from S3.

koopa_salmon_quant_bam() {
    # """
    # Run salmon quant on multiple transcriptome-aligned BAMs in a directory.
    # @note Updated 2023-10-20.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    #   #quantifying-in-alignment-based-mode
    #
    # @examples
    # > koopa_salmon_quant_bam \
    # >     --bam-dir='bam' \
    # >     --output-dir='quant/salmon-gencode' \
    # >     --transcriptome-fasta-file='gencode.v44.transcripts_fixed.fa.gz'
    # """
    local -A app bool dict
    local -a bam_files
    local bam_file
    koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    # e.g. 'bam'.
    dict['bam_dir']=''
    # Detect library fragment type (strandedness) automatically.
    dict['lib_type']='A'
    # e.g. 'salmon'.
    dict['output_dir']=''
    # e.g. 'gencode.v44.transcripts_fixed.fa.gz'.
    dict['transcriptome_fasta_file']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--bam-dir='*)
                dict['bam_dir']="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                dict['bam_dir']="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
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
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bam-dir' "${dict['bam_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    koopa_assert_is_dir "${dict['bam_dir']}"
    koopa_assert_is_file "${dict['transcriptome_fasta_file']}"
    dict['bam_dir']="$(koopa_realpath "${dict['bam_dir']}")"
    dict['transcriptome_fasta_file']="$( \
        koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    if koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(koopa_locate_aws --allow-system)"
        koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running salmon quant.'
    koopa_dl \
        'Transcriptome FASTA' "${dict['transcriptome_fasta_file']}" \
        'BAM dir' "${dict['bam_dir']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t bam_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*.bam" \
            --prefix="${dict['bam_dir']}" \
            --sort \
    )"
    if koopa_is_array_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dict['bam_dir']}'."
    fi
    koopa_assert_is_file "${bam_files[@]}"
    koopa_alert_info "$(koopa_ngettext \
        --num="${#bam_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for bam_file in "${bam_files[@]}"
    do
        local -A dict2
        dict2['bam_file']="$bam_file"
        dict2['sample_id']="$(koopa_basename_sans_ext "${dict2['bam_file']}")"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        koopa_salmon_quant_bam_per_sample \
            --bam-file="${dict2['bam_file']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict2['output_dir']}" \
            --transcriptome-fasta-file="${dict['transcriptome_fasta_file']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            koopa_rm "${dict2['output_dir']}"
            koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        koopa_rm "${dict['output_dir']}"
    fi
    koopa_alert_success 'salmon quant was successful.'
    return 0
}

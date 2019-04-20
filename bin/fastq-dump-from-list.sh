#!/usr/bin/env bash
set -Eeuxo pipefail

# FASTQ dump from Sequence Read Archive (SRA) accession list.

# TODO Need to allow the user to pass arguments to fastq-dump here.
# Consider using --`split-3` instead of `--split-files` by default.

# 10X Genomics Cell Ranger data
# https://kb.10xgenomics.com/hc/en-us/articles/115003802691

# This script requires sra-tools.
# https://github.com/ncbi/sra-tools
command -v fastq-dump >/dev/null 2>&1 || { echo >&2 "fastq-dump missing."; exit 1; }

filelist="SRR_Acc_List.txt"
if [[ ! -f "$filelist" ]]; then
    echo "${filelist} does not exist."
    exit 1
fi

# This loops across an SRA accession list.
# id: Accession ID.
# Note that this will skip FASTQ files that have already been extracted.
# This is useful because fastq-dump can take a long time and get interrupted.
# SC2162: read without -r will mangle backslashes.
while read -r id; do
    if [[ ! -f "${id}.fastq.gz" ]] && [[ ! -f "${id}_1.fastq.gz" ]]; then
        echo "SRA Accession: ${id}"
        fastq-dump --gzip --split-files "${id}"
    fi
done < "$filelist"
unset -v filelist

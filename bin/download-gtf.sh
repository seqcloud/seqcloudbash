#!/usr/bin/env bash
set -Eeuxo pipefail

# Download GTF file.

organism="$1"
baseurl="${ENSEMBL_RELEASE_URL}/gtf"

if [[ "$organism" == "hsapiens" ]]; then
    echo "Homo sapiens (Ensembl GRCh38)"
    url="${baseurl}/homo_sapiens/Homo_sapiens.GRCh38.${ENSEMBL_RELEASE}.gtf.gz"
elif [[ "$organism" == "mmusculus" ]]; then
    echo "Mus musculus (Ensembl GRCm38)"
    url="${baseurl}/mus_musculus/Mus_musculus.GRCm38.${ENSEMBL_RELEASE}.gtf.gz"
elif [[ "$organism" == "celegans" ]]; then
    echo "Caenorhabditis elegans (Ensembl WBcel235)"
    url="${baseurl}/caenorhabditis_elegans/Caenorhabditis_elegans.WBcel235.${ENSEMBL_RELEASE}.gtf.gz"
elif [[ "$organism" == "dmelanogaster" ]]; then
    # D. melanogaster Ensembl annotations are out of date.
    # Using the FlyBase annotations instead.
    echo "Drosophila melanogaster (FlyBase ${FLYBASE_RELEASE_DATE} ${FLYBASE_RELEASE_VERSION})"
    url="${FLYBASE_RELEASE_URL}/gtf/dmel-all-${FLYBASE_RELEASE_VERSION}.gtf.gz"
fi

file=$(basename "$url")
# Error if the file exists.
if [[ -f "$file" ]]; then
    echo "${file} has already been downloaded."
    exit 1
fi

echo "Downloading ${file}."
curl -O "$url"
# Decompress but also keep the original compressed file.
echo "Decompressing ${file}."
gunzip -c "$file" > "${file%.*}"

unset -v baseurl file organism url

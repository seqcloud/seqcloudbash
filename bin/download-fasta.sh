#!/usr/bin/env bash
set -Eeuxo pipefail

# Download FASTA file.

organism="$1"
type="$2"

# Default to Ensembl.
baseurl="${ENSEMBL_RELEASE_URL}/fasta"

# Warn and exit on legacy "transcriptome" usage.
if [[ "$type" == "transcriptome" ]]; then
    echo "Use \"cdna\" instead of \"transcriptome\""
    exit 1
fi

if [[ "$organism" == "hsapiens" ]]; then
    echo "Homo sapiens (Ensembl GRCh38)"
    if [[ "$type" == "dna" ]]; then
        url="${baseurl}/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
    elif [[ "$type" == "cdna" ]]; then
        url="${baseurl}/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz"
    fi
elif [[ $organism == "mmusculus" ]]; then
    echo "Mus musculus (Ensembl GRCm38)"
    if [[ "$type" == "dna" ]]; then
        url="${baseurl}/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz"
    elif [[ "$type" == "cdna" ]]; then
        url="${baseurl}/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz"
    fi
elif [[ "$organism" == "celegans" ]]; then
    echo "Caenorhabditis elegans (Ensembl WBcel235)"
    if [[ "$type" == "dna" ]]; then
        url="${baseurl}/caenorhabditis_elegans/dna/Caenorhabditis_elegans.WBcel235.dna.toplevel.fa.gz"
        # url="ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/sequence/genomic/c_elegans.canonical_bioproject.current.genomic.fa.gz"
    elif [[ "$type" == "cdna" ]]; then
        url="${baseurl}/caenorhabditis_elegans/cdna/Caenorhabditis_elegans.WBcel235.cdna.all.fa.gz"
        # url="ftp://ftp.wormbase.org/pub/wormbase/species/c_elegans/sequence/transcripts/c_elegans.canonical_bioproject.current.mRNA_transcripts.fa.gz"
    fi
elif [[ "$organism" == "dmelanogaster" ]]; then
    # D. melanogaster Ensembl annotations are out of date.
    # Using the FlyBase annotations instead.
    echo "Drosophila melanogaster (FlyBase ${FLYBASE_RELEASE_DATE} ${FLYBASE_RELEASE_VERSION})"
    baseurl="$FLYBASE_RELEASE_URL/fasta"
    version="$FLYBASE_RELEASE_VERSION"
    if [[ "$type" == "dna" ]]; then
        url="${baseurl}/dmel-all-aligned-${version}.fasta.gz"
    elif [[ "$type" == "cdna" ]]; then
        echo "Downloading FlyBase FASTA files..."
        curl -O "${baseurl}/dmel-all-transcript-${version}.fasta.gz"
        curl -O "${baseurl}/dmel-all-miRNA-${version}.fasta.gz"
        curl -O "${baseurl}/dmel-all-miscRNA-${version}.fasta.gz"
        curl -O "${baseurl}/dmel-all-ncRNA-${version}.fasta.gz"
        curl -O "${baseurl}/dmel-all-pseudogene-${version}.fasta.gz"
        curl -O "${baseurl}/dmel-all-tRNA-${version}.fasta.gz"
        # Concatenate into single FASTA.
        file="dmel-transcriptome-${version}.fasta.gz"
        echo "Concatenating FlyBase FASTA files..."
        cat "dmel-all-"*"-${version}.fasta.gz" > "$file"
        unset -v version
        exit 1
    fi
elif [[ "$organism" == "nfurzeri" ]]; then
    echo "Nothobranchius furzeri (turquoise killifish)"
    echo "NFINgb GRZ Assembly"
    baseurl="http://nfingb.leibniz-fli.de/data/raw/notho4"
    if [[ "$type" == "dna" ]]; then
        url="${baseurl}/Nfu_20150522.softmasked_genome.fa.gz"
        # $url="http://africanturquoisekillifishbrowser.org/NotFur1_genome_draft.fa.tar.gz"
    elif [[ "$type" == "cdna" ]]; then
        url="${baseurl}/Nfu_20150522.genes_20150922.transcripts.fa.gz"
    fi
fi

if [[ -z "$url" ]]; then
    echo "Failed to set URL"
    exit 1
fi

file=$(basename "$url")
# Error if the file exists.
if [[ -f "$file" ]]; then
    echo "${file} has already been downloaded"
    exit 1
fi

echo "Downloading ${file}..."
curl -O "$url"
# Decompress but also keep the original compressed file.
echo "Decompressing ${file}..."
gunzip -c "$file" > "${file%.*}"

unset -v baseurl file organism type url

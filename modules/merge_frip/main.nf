#!/usr/bin/env nextflow

process MERGE_FRIP {
    input:
    path(frip_files)

    output:
    path "all_samples_frip.tsv"

    """
    echo -e "sample\tin_peaks\ttotal_reads\tfrip" > all_samples_frip.tsv
    grep -hv '^sample' ${frip_files} >> all_samples_frip.tsv
    """
}


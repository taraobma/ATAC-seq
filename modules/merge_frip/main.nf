#!/usr/bin/env nextflow

process MERGE_FRIP {
    label 'process_low'
    publishDir params.outdir, mode: 'copy'

    input:
    path(frip_files)

    output:
    path "all_samples_frip.tsv"

    """
    echo -e "sample\tin_peaks\ttotal_reads\tfrip" > all_samples_frip.tsv
    grep -hv '^sample' ${frip_files} >> all_samples_frip.tsv
    """
}


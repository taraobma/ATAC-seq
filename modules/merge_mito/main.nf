#!/usr/bin/env nextflow

process MERGE_MITO_FRACTION {
    label 'process_low'
    publishDir params.outdir, mode: 'copy'

    input:
    val dummy

    output:
    path "all_mito_fraction.tsv"

    script:
    """
    echo -e "sample\ttotal_reads\tmito_reads\tmito_fraction" > all_mito_fraction.tsv
    grep -hv '^sample' ${params.outdir}/*_mito_fraction.txt >> all_mito_fraction.tsv
    """
}
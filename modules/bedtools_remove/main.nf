#!/usr/bin/env nextflow

process BEDTOOLS_REMOVE {

    label 'process_high'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(peaks_bed)
    path(blacklist)

    output:
    tuple val(sample), path("${sample}_filteredpeaks.bed"), emit: filtered_peaks

    script:
    """
    bedtools intersect -a ${peaks_bed} -b $blacklist -v > ${sample}_filteredpeaks.bed
    """

    stub:
    """
    touch ${sample}_filteredpeaks.bed
    """
}

// -v is to excludes any peaks overlapping the blacklist regions
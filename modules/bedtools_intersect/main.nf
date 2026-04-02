#!/usr/bin/env nextflow

process BEDTOOLS_INTERSECT {
    
    label 'process_high'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(bed1), path(bed2)

    output:
    tuple val(sample), path("${sample}_repr_peaks.bed"), emit: peaks_bed

    script:
    """
    bedtools intersect -a ${bed1} -b  ${bed2} -f 0.2 -r > ${sample}_repr_peaks.bed
    """

    stub:
    """
    touch ${sample}_repr_peaks.bed
    """
}                                         
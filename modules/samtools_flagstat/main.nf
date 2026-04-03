#!/usr/bin/env nextflow

process SAMTOOLS_FLAGSTAT {

    label 'process_single'
    container 'quay.io/biocontainers/samtools:1.18--h50ea8bc_1'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path (bam)

    output:
    path("${sample}_flagstat.txt")

    script:
    """
    samtools flagstat $bam > ${sample}_flagstat.txt
    """

    stub:
    """
    touch ${sample_id}_flagstat.txt
    """
}
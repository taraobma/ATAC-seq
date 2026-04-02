#!/usr/bin/env nextflow

process SAMTOOLS_SORT {
    
    label 'process_single'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir, mode: 'copy'

input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path("${sample}_sorted.bam")

    script:
    """
    samtools sort -o ${sample}_sorted.bam ${bam}
    """

    // stub:
    // """
    // touch ${sample_id}.stub.sorted.bam
    // """
}
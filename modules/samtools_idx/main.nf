#!/usr/bin/env nextflow

process SAMTOOLS_IDX {

    label 'process_single'
    container 'quay.io/biocontainers/samtools:1.18--h50ea8bc_1'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path(bam), path("${bam}.bai")

    script:
    """
    samtools index ${bam}
    """   

    // stub:
    // """
    // touch ${sample_id}.stub.sorted.bam.bai
    // """
}
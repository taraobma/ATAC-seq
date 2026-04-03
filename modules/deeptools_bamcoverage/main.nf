#!/usr/bin/env nextflow

process BAMCOVERAGE {

    label 'process_medium'
    container 'quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(sorted_bam), path(bai)

    output:
    tuple val(sample), path("${sample}.bw"), emit: bw

    script:
    """
    bamCoverage -b ${sorted_bam} -o ${sample}.bw -p $task.cpus
    """

    // stub:
    // """
    // touch ${sample_id}.bw
    // """
}


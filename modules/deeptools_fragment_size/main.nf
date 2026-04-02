#!/usr/bin/env nextflow

process FRAGMENT_SIZE {
    label 'process_medium'
    container 'docker://quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(bam), path(bai)

    output:
    tuple val(sample), path("${sample}_fragment_size.png"), emit: plot
    tuple val(sample), path("${sample}_fragment_size.txt"),  emit: table

    script:
    """
    python -m deeptools.bamPEFragmentSize \
        -b ${bam} \
        --histogram ${sample}_fragment_size.png \
        --outRawFragmentLengths ${sample}_fragment_size.txt \
        -p ${task.cpus}
    """
}
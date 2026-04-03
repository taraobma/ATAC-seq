#!/usr/bin/env nextflow

process FASTQC {

    label 'process_low'
    container 'quay.io/biocontainers/fastqc:0.11.9--0'

    publishDir params.outdir, mode: "copy"

    input:
    tuple val(sample_id), path(reads)
    
    output:
    tuple val(sample_id), path('*.zip'), emit: zip
    tuple val(sample_id), path("*.html"), emit: html

    script:
    """
    fastqc $reads -t $task.cpus
    """

    stub:
    """
    touch stub_${sample_id}_fastqc.zip
    touch stub_${sample_id}_fastqc.html
    """
}

#!/usr/bin/env nextflow
process DOWNLOAD {
    publishDir "${params.outdir}/raw_fastq", mode: "copy"
    
    input:
    tuple val(sample), val(url)

    output:
    tuple val(sample), path("${sample}.fastq.gz")

    script:
    """
    wget $url -O ${sample}.fastq.gz
    """
}
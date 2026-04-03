#!/usr/bin/env nextflow

process MULTIQC {

    label 'process_low'
    container 'quay.io/biocontainers/multiqc:1.19--pyhdfd78af_0'
    publishDir params.outdir, mode: "copy"

    input:
    path("*")
    
    output:
    path("multiqc_report.html")    

    script:
    """
    multiqc . -f
    """

    // stub:
    // """
    // touch multiqc_report.html
    // """
}
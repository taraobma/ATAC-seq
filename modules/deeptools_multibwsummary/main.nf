#!/usr/bin/env nextflow

process MULTIBWSUMMARY {
    
    label 'process_high'
    container 'quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    publishDir params.outdir, mode: "copy"

    input: 
    path(bw)

    output:
    path("bw_results.npz"), emit: npz

    script:
    """
    multiBigwigSummary bins -b ${bw.join(' ')} -o bw_results.npz
    """

    stub:
    """
    touch bw_all.npz
    """
}
#!/usr/bin/env nextflow

process MULTIBWSUMMARY {
    
    label 'process_high'
    container 'ghcr.io/bf528/deeptools:latest'
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
#!/usr/bin/env nextflow

process PLOTCORRELATION {

    label 'process_high'
    container 'quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    publishDir params.outdir, mode: "copy"

    input:
    path(npz)
    val(corrtype)

    output:
    path("correlation_plot.png"), emit: plot

    script:
    """
    plotCorrelation -in $npz -c $corrtype --skipZeros \\
    -p heatmap -o correlation_plot.png --removeOutliers \\
    --plotNumbers
    """

    // stub:
    // """
    // touch correlation_plot.png
    // """
}

// there is a difference of INPUT rep1 and INPUT rep2 from the IPs when removed outliers





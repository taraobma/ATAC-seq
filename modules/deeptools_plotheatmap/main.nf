#!/usr/bin/env nextflow

process PLOTHEATMAP {

    label 'process_medium'
    container 'quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(celltype), path(matrix)

    output:
    path("${celltype}_gain_loss_heatmap.png")

    script:
    """
    plotHeatmap \
        -m ${matrix} \
        -out ${celltype}_gain_loss_heatmap.png \
        --colorMap PuRd \
        --regionsLabel Gain Loss \
        --dpi 300
    """
}

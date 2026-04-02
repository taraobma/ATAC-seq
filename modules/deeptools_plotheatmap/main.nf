#!/usr/bin/env nextflow

process PLOTHEATMAP {

    label 'process_medium'
    container 'docker://quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(group), path(matrix)

    output:
    tuple val(group), path("${group}_heatmap.png"), emit: plot

    script:
    """ 
    plotHeatmap \
        -m ${matrix} \
        -o ${group}_heatmap.png \
        --plotTitle "${group} Signal at TSS" \
        --colorMap Blues \
        --whatToShow 'heatmap and colorbar'
    """
}

#!/usr/bin/env nextflow

process PLOTHEATMAP {

    label 'process_medium'
    container 'quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
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
        --plotTitle "${group}" \
        --colorMap RdBu \
        --whatToShow 'plot, heatmap and colorbar' \
        --legendLocation none \
        --xAxisLabel "" \
        --yAxisLabel "" \
        --sortRegions descend \
        --averageTypeSummaryPlot mean \
        --heatmapHeight 10 \
        --heatmapWidth 4 \
        --dpi 300
    """
}

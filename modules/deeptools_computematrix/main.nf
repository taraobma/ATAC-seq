#!/usr/bin/env nextflow

process COMPUTEMATRIX {
    label 'process_medium'
    container 'quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(celltype), path(bws), path(regions)
    path(genes)
    val(window)

    output:
    tuple val(celltype), path("${celltype}_matrix.gz")

    script:
    def bw_list = bws.join(' ')
    def region_list = regions.join(' ')
    """
    computeMatrix reference-point \
        --referencePoint TSS \
        -b ${window} -a ${window} \
        -S ${bw_list} \
        -R ${region_list} \
        --skipZeros \
        -o ${celltype}_matrix.gz
    """
}
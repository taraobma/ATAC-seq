#!/usr/bin/env nextflow

process COMPUTEMATRIX {
    label 'process_medium'
    container 'quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(group), path(bigwigs)
    path  genes
    val   window

    output:
    tuple val(group), path("${group}_matrix.gz"), emit: matrix

    script:
    def bw_list = (bigwigs instanceof List ? bigwigs : [bigwigs]).collect { it.toString() }.join(' ')
    """
    computeMatrix reference-point \\
        --referencePoint TSS \\
        -b ${window} -a ${window} \\
        -S ${bw_list} \\
        -R ${genes} \\
        --skipZeros \\
        -o ${group}_matrix.gz \\
        -p ${task.cpus}
    """
}
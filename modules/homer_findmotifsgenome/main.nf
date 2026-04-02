#!/usr/bin/env nextflow

process FIND_MOTIFS_GENOME {
    
    label 'process_high'
    container 'quay.io/biocontainers/homer:4.11--pl526h9a982cc_2'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(celltype), path(bed)
    path(genome)

    output:
    path("motifs_${celltype}"), emit: motifs

    script:
    """
    mkdir -p motifs_${celltype}
    findMotifsGenome.pl $bed $genome motifs_${celltype} -p $task.cpus
    """

    // stub:
    // """
    // mkdir motifs
    // """
}

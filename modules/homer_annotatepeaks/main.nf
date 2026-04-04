#!/usr/bin/env nextflow

process ANNOTATE {
    
    label 'process_high'
    container 'quay.io/biocontainers/homer:4.11--pl526h9a982cc_2'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(filtered_peaks)
    path(genome)
    path(gtf)

    output:
    tuple val(sample), path("annotated_peaks_${sample}.txt"), emit: annotated_peaks


    script:
    """
    annotatePeaks.pl ${filtered_peaks} $genome -gtf $gtf > annotated_peaks_${sample}.txt
    """

    // stub:
    // """
    // touch annotated_peaks_${sample}.txt
    // """
}

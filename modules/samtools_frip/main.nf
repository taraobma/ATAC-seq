#!/usr/bin/env nextflow

process FRIP {
    label 'process_medium'
    container 'quay.io/biocontainers/samtools:1.18--h50ea8bc_1'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(bam), path(bai), path(peaks)

    output:
    path "${sample}_frip.txt", emit: frip

    script:
    """
    total=\$(samtools view -c ${bam})
    in_peaks=\$(samtools view -c -L ${peaks} ${bam})

    # sample, in_peaks, total, FRiP
    awk -v s=${sample} -v i=\$in_peaks -v t=\$total 'BEGIN {
        printf "%s\\t%s\\t%s\\t%.4f\\n", s, i, t, i/t
    }' > ${sample}_frip.txt
    """
}


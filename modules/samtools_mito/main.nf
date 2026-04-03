#!/usr/bin/env nextflow

process SAMTOOLS_MITO {
    label 'process_single'
    container 'quay.io/biocontainers/samtools:1.18--h50ea8bc_1'
    publishDir "${params.outdir}/samtools_mito", mode: 'copy'
    
    input:
    tuple val(sample), path(bam), path(bai)

    output:
    tuple val(sample), path("${sample}_nomt_sorted.bam"), path("${sample}_nomt_sorted.bam.bai")

    script:
    """
    samtools view -@ 8 -b -F 4 ${bam} -e 'rname != "MT" && rname != "chrM"' > ${sample}_nomt.bam
    samtools sort -o ${sample}_nomt_sorted.bam ${sample}_nomt.bam
    samtools index ${sample}_nomt_sorted.bam
    """
}
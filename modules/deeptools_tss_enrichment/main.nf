#!/usr/bin/env nextflow

process TSS_ENRICHMENT {
    label 'process_medium'
    container 'quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(bam), path(bai)
    path  tss_bed

    output:
    tuple val(sample), path("${sample}_tss_enrichment.png"), emit: plot
    tuple val(sample), path("${sample}_tss_enrichment.txt"), emit: scores

    script:
    """
    computeMatrix reference-point \
        --referencePoint TSS \
        -b 2000 -a 2000 \
        -S ${bam} \
        -R ${tss_bed} \
        --skipZeros \
        -o ${sample}_matrix.gz \
        -p ${task.cpus}

    plotEnrichment \
        -b ${bam} \
        --BED ${tss_bed} \
        -o ${sample}_tss_enrichment.png \
        --outRawCounts ${sample}_tss_enrichment.txt \
        -p ${task.cpus}
    """
}

#!/usr/bin/env nextflow

process TSS_ENRICHMENT {
    label 'process_medium'
    container 'quay.io/biocontainers/deeptools:3.5.5--pyhdfd78af_0'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(bam), path(bai)
    path  tss_bed
    val window

    output:
    tuple val(sample), path("${sample}_tss_enrichment.png"), emit: plot
    tuple val(sample), path("${sample}_tss_enrichment.txt"), emit: scores

    script:
    """
    computeMatrix reference-point \
        --referencePoint TSS \
        -b ${window} -a ${window} \
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


// fraction of all fragments overlap any region in mm10_tss.bed (percentage of reads in TSS) - 1bp sites

// use a bed of TSS windows (+- 1 kb around TSS) 
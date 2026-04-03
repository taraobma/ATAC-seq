#!/usr/bin/env nextflow

process MITO_FRACTION {
    label 'process_medium'
    container 'quay.io/biocontainers/samtools:1.18--h50ea8bc_1'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(bam), path(bai)

    output:
    tuple val(sample), path("${sample}_mito_fraction.txt"), emit: mito

    script:
    """
    total=\$(samtools view -c ${bam})
    mito=\$(samtools view -c ${bam} chrM)

    if [ "\$total" -gt 0 ]; then
        frac=\$(awk -v m="\$mito" -v t="\$total" 'BEGIN { print m/t }')
    else
        frac=0
    fi

    echo -e "sample\\ttotal_reads\\tmito_reads\\tmito_fraction" > ${sample}_mito_fraction.txt
    echo -e "${sample}\\t\${total}\\t\${mito}\\t\${frac}" >> ${sample}_mito_fraction.txt
    """
}
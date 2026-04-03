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
    echo -e "${sample}\t\${in_peaks}\t\${total}" > ${sample}_frip.txt
    awk '{printf "%s\\tFRiP: %.4f\\n", \$1, \$2/\$3}' ${sample}_frip.txt
    """
}


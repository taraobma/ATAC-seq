#!/usr/bin/env nextflow

process BOWTIE2_ALIGN {

    label 'process_high'
    container 'ghcr.io/bf528/bowtie2:latest'
    publishDir params.outdir, mode: 'copy'
    
    input:
    tuple val(sample), path(reads)
    path bowtie2_index
    val name

    output:
    tuple val(sample), path("${sample}.bam"), emit: bam

    script:
    """
    bowtie2 \\
        -x $bowtie2_index/${name} \\
        -U $reads \\
        -p $task.cpus \\
        --very-sensitive | samtools view -bS -q 30 - > ${sample}.bam
    """

    stub:
    """
    touch ${sample}.bam
    """
}

// script for paired end reads
// bowtie2 -p 8 -x $bt2/$name -1 ${reads[0]} -2 ${reads[1]} | samtools view -bS - > ${sample}.bam


// script for single end reads
// bowtie2 =x $genome -U $reads -p $task.cpus | samtools view -bS - > ${sample}.bam
// -U for single end reads
// -p is for multiple threads
// -q is the mapping quality score (99.9% confidence that the read is correctly mapped)


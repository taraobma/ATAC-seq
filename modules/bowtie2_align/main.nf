#!/usr/bin/env nextflow

process BOWTIE2_ALIGN {
    label 'process_high'
    tag "$sample_id"
    container 'quay.io/biocontainers/bowtie2:2.5.4--he20e202_2'

    input:
    tuple val(sample_id), path(reads)
    path(index_dir)
    val(index_name)

    output:
    tuple val(sample_id), path("${sample_id}.sam"), emit: sam

    """
    bowtie2 \
        -x ${index_dir}/${index_name} \
        -U ${reads} \
        -p ${task.cpus} \
        --very-sensitive \
        -S ${sample_id}.sam
    """
}

// script for paired end reads
// bowtie2 -p 8 -x $bt2/$name -1 ${reads[0]} -2 ${reads[1]} | samtools view -bS - > ${sample}.bam


// script for single end reads
// bowtie2 =x $genome -U $reads -p $task.cpus | samtools view -bS - > ${sample}.bam
// -U for single end reads
// -p is for multiple threads
// -q is the mapping quality score (99.9% confidence that the read is correctly mapped)


#!/usr/bin/env nextflow

process TRIM {

    label 'process_low'
    container 'quay.io/biocontainers/trimmomatic:0.39--1'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path("${sample}_trimmed.fastq.gz"), emit: trimmed
    path("${sample}_trim.log"), emit: log
    
    script: 
    """
    trimmomatic SE \\
        -threads ${task.cpus} \\
        -phred33 \\
        ${reads} \\
        ${sample}_trimmed.fastq.gz \\
        ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 \\
        LEADING:3 \\
        TRAILING:3 \\
        SLIDINGWINDOW:4:15 \\
        MINLEN:36 \\
        > ${sample}_trim.log 2>&1
    """

    stub:
    """
    touch ${sample}_stub_trim.log
    touch ${sample}_trimmed.fastq.gz
    """
}

// use PE for paired end reads
// use SE for single end reads
// 2>&1 is for redirecting the standard error (2) to the same place as standard output (1)

process BOWTIE2_BUILD {
    
    label 'process_high'
    container 'quay.io/biocontainers/bowtie2:2.5.1--py39h3321a2d_0'
    publishDir params.outdir, mode: 'copy'

    input:
    path(genome)

    output:
    path('bowtie2_index'), emit: index
    val genome.baseName, emit: name

    script:
    """
    mkdir bowtie2_index
    bowtie2-build --threads $task.cpus $genome bowtie2_index/${genome.baseName}
    """


    stub:
    """
    mkdir bowtie2_index
    """
}
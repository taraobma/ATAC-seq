process SAMTOOLS_VIEW_SORT {
    tag "$sample_id"
    container 'quay.io/biocontainers/samtools:1.18--h50ea8bc_1'

    input:
    tuple val(sample_id), path(sam)

    output:
    tuple val(sample_id), path("${sample_id}.bam"), emit: bam

    """
    samtools view -bS -q 30 ${sam} | samtools sort -@ ${task.cpus} -o ${sample_id}.bam
    samtools index ${sample_id}.bam
    """
}
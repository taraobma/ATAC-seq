#!/usr/bin/env nextflow

process CALLPEAKS {
    label 'process_high'
    container 'joseespinosa/macs3:3.0.0b3'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(bam)
    val genome_size

    output:
    tuple val(sample), path('*narrowPeak'), emit: peaks

    script:
    """
    macs3 callpeak \\
    -f BAM \\
    -t ${bam} \\
    -g $genome_size \\
    -n ${sample} \\
    -q 0.01 \\
    --keep-dup auto \\
    --nomodel \\
    --extsize 147
    """

    stub:
    """
    touch ${sample}_peaks.narrowPeak
    """
}
// --nolambda //use global backgrounf instead of local background to call peaks
// macs3 callpeak -t ${ip_bam} -c ${input_bam} -f BAM -g ${params.genome_size} -n ${sample} --nomodel --extsize 147 --keep-dup auto

//macs3 callpeak -t $bam -f BAM -g 1.3e+8 -n ${samplename} --outdir results/macs3

//  macs3 callpeak -t ${bam} -f BAM -g $genome_size -n ${sample} -q 0.01

//extend reads to 200bp from the Tn5 insertion site
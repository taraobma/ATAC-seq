#!/usr/bin/env nextflow

process DIFFBIND {
    label 'process_high'
    publishDir params.outdir, mode: 'copy'

    input:
    path samplesheet
    val  pval_threshold

    output:
    path "*_diffbind_results.csv", emit: results
    path "*_significant_peaks.bed", emit: beds
    path "*_gain_peaks.bed", emit: gain
    path "*_loss_peaks.bed", emit: loss

    script:
    """
    export PATH=/share/pkg.8/r/4.5.2/install/bin:\$PATH
    export R_LIBS_USER=\$HOME/R/library

    Rscript ${projectDir}/run_diffbind.R \\
        --samplesheet ${samplesheet} \\
        --pval ${pval_threshold} \\
        --outdir .
    """

    stub:
    """
    touch cDC1_diffbind_results.csv
    touch cDC2_diffbind_results.csv
    touch cDC1_significant_peaks.bed
    touch cDC2_significant_peaks.bed
    touch cDC1_gain_peaks.bed
    touch cDC2_gain_peaks.bed
    touch cDC1_loss_peaks.bed
    touch cDC2_loss_peaks.bed
    """
}


// for pval_threshold
// input:
// path samplesheet
// val  pval_threshold  // rename to match

// output:
// path "diffbind_results.csv", emit: results
// path "*_significant_peaks.bed",emit: beds

// script:
// """
// Rscript ${projectDir}/scripts/run_diffbind.R \\
//     --samplesheet ${samplesheet} \\
//     --fdr ${pval_threshold}
// """
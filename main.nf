
include {DOWNLOAD} from './modules/download'
include {FASTQC} from './modules/fastqc'
include {TRIM} from './modules/trimmomatic'
include {BOWTIE2_BUILD} from './modules/bowtie2_build'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {SAMTOOLS_VIEW_SORT} from './modules/samtools_view'
include {SAMTOOLS_IDX} from './modules/samtools_idx'
include {SAMTOOLS_FLAGSTAT} from './modules/samtools_flagstat'
include {SAMTOOLS_MITO} from './modules/samtools_mito'
include {BAMCOVERAGE} from './modules/deeptools_bamcoverage'
include {MULTIQC} from './modules/multiqc'
include {MULTIBWSUMMARY} from './modules/deeptools_multibwsummary'
include {PLOTCORRELATION} from './modules/deeptools_plotcorrelation'
include {CALLPEAKS} from './modules/macs3_callpeaks'
include {BEDTOOLS_INTERSECT} from './modules/bedtools_intersect'
include {BEDTOOLS_REMOVE} from './modules/bedtools_remove'
include {DIFFBIND} from './modules/diffbind'
include {ANNOTATE} from './modules/homer_annotatepeaks'
include {FIND_MOTIFS_GENOME} from './modules/homer_findmotifsgenome'
include {COMPUTEMATRIX} from './modules/deeptools_computematrix'
include {PLOTHEATMAP} from './modules/deeptools_plotheatmap'
// include {FRAGMENT_SIZE} from './modules/deeptools_fragment_size'
include {TSS_ENRICHMENT} from './modules/deeptools_tss_enrichment'
include {FRIP} from './modules/samtools_frip'
include {MERGE_FRIP} from './modules/merge_frip'
include {MITO_FRACTION} from './modules/mito_fraction'
include {MERGE_MITO_FRACTION} from './modules/merge_mito'

workflow {

    //create a channel from the sample sheet and split it into name and path
    Channel.fromPath(params.samplesheet)
        | splitCsv( header: true )
        | map{ row -> tuple(row.name, row.path) }
        | set { read_ch }

    //download fastq files from the sample sheet
    DOWNLOAD(read_ch)

    //fastqc on the raw reads
    FASTQC(DOWNLOAD.out)

    //trimming the reads with trimmomatic
    TRIM(DOWNLOAD.out)

    //build the bowtie2 index for the reference genome
    BOWTIE2_BUILD(params.genome)

    //align the trimmed reads to the reference genome
    BOWTIE2_ALIGN(
                TRIM.out.trimmed, 
                BOWTIE2_BUILD.out.index,
                BOWTIE2_BUILD.out.name
                )

    // sort the aligned reads and convert to BAM format
    SAMTOOLS_VIEW_SORT(BOWTIE2_ALIGN.out)

    // index the sorted BAM files
    SAMTOOLS_IDX(SAMTOOLS_VIEW_SORT.out)

    // filter for mitochondrial reads
    SAMTOOLS_MITO(SAMTOOLS_IDX.out)

    // get flagstat metrics for the mitochondrial reads
    SAMTOOLS_FLAGSTAT(SAMTOOLS_MITO.out)

    multiqc_ch = FASTQC.out.zip
                .map { sample, zip -> zip }
                .mix(TRIM.out.log, SAMTOOLS_FLAGSTAT.out)
                .collect()
    
    // run MultiQC on the collected metrics
    MULTIQC(multiqc_ch)

    // get coverage files for the mitochondrial reads
    BAMCOVERAGE(SAMTOOLS_MITO.out)

    // bw_ch for plotting correlation
    bw_ch = BAMCOVERAGE.out.map {sample, bw -> bw }.collect()

    // get summary statistics for the BigWig files
    MULTIBWSUMMARY(bw_ch)

    //plotting the correlation plot with spearman correlation
    PLOTCORRELATION(MULTIBWSUMMARY.out, params.corrtype)
    
    // call peaks with MACS3 using the mitochondrial BAM files
    peaks_ch = CALLPEAKS(SAMTOOLS_MITO.out, params.genome_size)

    // create a channel for grouping/replicate logic downstream (diffbind onwards)
    Channel.fromPath(params.samplesheet)
        | splitCsv(header: true)
        | map { row ->
            def parts = row.name.tokenize('_')      // ['cDC1', 'WT', '1']
            tuple(row.name, parts[0..-2].join('_'), parts[-1])      // will look something like ('cDC1_WT_1', 'cDC1_WT', '1')
            }
        | set { meta_ch  }


    // attach metadata to peaks
    peaks_with_meta_ch = peaks_ch
        .join(meta_ch.map { name, group, rep -> tuple(name, group, rep) })
        .map { name, bed, group, rep -> tuple(group, rep, bed) }

    // group by group, sort by replicate, build pairs
    intersect_input_ch = peaks_with_meta_ch
        .groupTuple(by: 0)
        .map { group, reps, beds ->
            def sorted = [reps, beds].transpose().sort { a, b -> a[0] <=> b[0] }
            tuple(group, sorted[0][1], sorted[1][1])   // assumes exactly 2 reps
        }

    // intersect peaks between replicates for each group
    intersect_ch = BEDTOOLS_INTERSECT(intersect_input_ch)

    // remove blacklisted regions from the intersected peaks
    filtered_ch  = BEDTOOLS_REMOVE(intersect_ch, params.blacklist)

    // map each sample name to its group to join with filtered_ch
    sample_to_group_ch = meta_ch.map { name, group, rep -> tuple(group, name) }

    // give each sample its group's filtered consensus peak file
    sample_peaks_ch = sample_to_group_ch
        .join(filtered_ch)
        .map { group, name, bed -> tuple(name, bed) }
        
    // Per-sample peaks for DiffBind (no consensus intersect)
    bam_ch = SAMTOOLS_MITO.out
        .map { name, bam, bai -> tuple(name, bam) }

    // name, celltype, condition, replicate
    meta_celltype_ch = meta_ch.map { name, group, rep ->
        def parts = name.tokenize('_')
        tuple(name, parts[0], parts[1], rep)
    }

    // peaks_ch: (name, peak_bed) from MACS3
    per_sample_peaks_ch = peaks_ch
        .map { name, bed -> tuple(name, bed) }

    // Build DiffBind samplesheet with all samples that have BAM + peaks + metadata
    diffbind_sheet_ch = bam_ch
        .join(meta_celltype_ch)      // (name, bam, celltype, condition, rep)
        .join(per_sample_peaks_ch)   // (name, bam, celltype, condition, rep, peaks)
        .map { name, bam, celltype, condition, rep, peaks ->
            tuple(name, bam, celltype, condition, rep, peaks)
        }
        .collectFile(
            name: 'diffbind_samplesheet.csv',
            newLine: true,
            seed: "SampleID,CellType,Condition,Replicate,bamReads,Peaks,PeakCaller\n"
        ) { name, bam, celltype, condition, rep, peaks ->
            "${name},${celltype},${condition},${rep},${bam},${peaks},bed\n"
        }

    // Run DiffBind
    diffbind_out = DIFFBIND(diffbind_sheet_ch, params.pval_threshold)

    // Prepare motif input channel
    diffbind_out.beds
        .flatten()
        .map { bed -> tuple(bed.baseName.replace('_significant_peaks',''), bed) }
        .set { motif_ch }

    // Motif finding
    FIND_MOTIFS_GENOME(motif_ch, params.genome)

    // Annotation
    ANNOTATE(motif_ch, params.genome, params.gtf)

    // BigWig per cell type for heatmaps
    bw_with_type_ch = BAMCOVERAGE.out
        .map { sample, bw -> tuple(sample.tokenize('_')[0], bw) }

    // group BigWig files by cell type for computeMatrix
    group_bw_ch = bw_with_type_ch.groupTuple(by: 0)

    // compute matrix around TSS for each cell type using the UCSC genes as reference
    matrix_ch = COMPUTEMATRIX(group_bw_ch, params.ucsc_genes, params.window)
    
    // plot heatmap of signal around TSS
    PLOTHEATMAP(matrix_ch)

    // TSS enrichment - % of reads in ±1 kb windows around TSS
    TSS_ENRICHMENT(SAMTOOLS_MITO.out, params.tss_1kb, params.window)

    // fragment size distribution - PE reads only
    // FRAGMENT_SIZE(SAMTOOLS_MITO.out)

    // FRiP score input channel - need to join BAM files with their corresponding filtered peak files
    frip_input_ch = SAMTOOLS_MITO.out
        .join(meta_ch.map { name, group, rep -> tuple(name, group) })
        .map { name, bam, bai, group -> tuple(group, name, bam, bai) }
        .combine(filtered_ch, by: 0)
        .map { group, name, bam, bai, bed -> tuple(name, bam, bai, bed) }

    // calculate FRiP scores
    FRIP(frip_input_ch)

    // merge FRiP scores into a single table (tsv)
    MERGE_FRIP(FRIP.out.collect())

    // mitochondrial read fraction QC - % of reads mapping to chrM
    MITO_FRACTION(SAMTOOLS_VIEW_SORT.out.bam)

    // merge mitochondrial read fraction into a single table (tsv)
    MERGE_MITO_FRACTION( Channel.value(true) )

}



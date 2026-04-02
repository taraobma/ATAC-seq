.libPaths(c(file.path(Sys.getenv("HOME"), "R/library"), .libPaths()))

library(DiffBind)
library(optparse)
library(rtracklayer)
library(GenomicRanges)
library(edgeR)

option_list <- list(
    make_option("--samplesheet", type="character"),
    make_option("--pval",        type="double",  default=0.01),
    make_option("--outdir",      type="character", default=".")
)
opt <- parse_args(OptionParser(option_list=option_list))

samples <- read.csv(opt$samplesheet)

## Split samplesheet by celltype
cDC1_samples <- samples[samples$CellType == "cDC1", ]
cDC2_samples <- samples[samples$CellType == "cDC2", ]

write.csv(cDC1_samples, file.path(opt$outdir, "cDC1_diffbind.csv"), row.names=FALSE)
write.csv(cDC2_samples, file.path(opt$outdir, "cDC2_diffbind.csv"), row.names=FALSE)

run_edger_diffbind <- function(sheet_path, label, outdir, pval_thresh) {

    db <- dba(sampleSheet = sheet_path)
    
    # Check if we have enough samples
    if (nrow(db$samples) < 3) {
        cat(label, ": Skipping - insufficient samples for differential analysis (need >= 3, got", nrow(db$samples), ")\n")
        # Create empty output files
        write.csv(data.frame(), file.path(outdir, paste0(label, "_diffbind_results.csv")))
        write.csv(data.frame(), file.path(outdir, paste0(label, "_significant_peaks.bed")))
        write.csv(data.frame(), file.path(outdir, paste0(label, "_gain_peaks.bed")))
        write.csv(data.frame(), file.path(outdir, paste0(label, "_loss_peaks.bed")))
        return(NULL)
    }
    
    db <- dba.count(db, minOverlap = 2)

    counts_df    <- dba.peakset(db, bRetrieve = TRUE, DataType = DBA_DATA_FRAME)
    count_matrix <- as.matrix(counts_df[, 4:ncol(counts_df)])

    ## 1) Filter out low-count peaks to avoid no-residual-df issues
    keep <- rowSums(count_matrix) >= 10
    count_matrix <- count_matrix[keep, , drop = FALSE]
    counts_df    <- counts_df[keep, , drop = FALSE]

    ## edgeR TMM normalization + QLF test
    group  <- factor(db$samples$Condition)
    y      <- DGEList(counts = count_matrix, group = group)
    y      <- calcNormFactors(y, method = "TMM")
    design <- model.matrix(~ group)

    y <- estimateDisp(y, design)

    ## 2) Use legacy=TRUE to avoid NA-dispersion check that causes your error
    fit <- glmQLFit(y, design, legacy = TRUE)
    qlf <- glmQLFTest(fit, coef = 2)
    results <- topTags(qlf, n = Inf)$table

    ## Save full results
    write.csv(results,
            file.path(outdir, paste0(label, "_diffbind_results.csv")),
            row.names = TRUE)
    write.csv(counts_df,
            file.path(outdir, paste0(label, "_peaks.csv")),
            row.names = FALSE)

    cat(label, ":", nrow(results[results$PValue < pval_thresh, ]),
        "significant peaks\n")

    ## Significant peaks
    sig     <- results[results$PValue < pval_thresh, ]
    sig_idx <- match(rownames(sig), rownames(counts_df))

    ## All significant peaks BED
    sig_peaks <- GRanges(
        seqnames = counts_df$CHR[sig_idx],
        ranges   = IRanges(start = counts_df$START[sig_idx],
        end   = counts_df$END[sig_idx])
    )
    export.bed(sig_peaks, file.path(outdir, paste0(label, "_significant_peaks.bed")))

    ## Gain peaks (more open in KO: logFC > 0)
    gain_idx <- match(rownames(sig[sig$logFC > 0, ]), rownames(counts_df))
    gain_peaks <- GRanges(
        seqnames = counts_df$CHR[gain_idx],
        ranges   = IRanges(start = counts_df$START[gain_idx],
        end   = counts_df$END[gain_idx])
    )
    export.bed(gain_peaks, file.path(outdir, paste0(label, "_gain_peaks.bed")))

    ## Loss peaks (less open in KO: logFC < 0)
    loss_idx <- match(rownames(sig[sig$logFC < 0, ]), rownames(counts_df))
    loss_peaks <- GRanges(
        seqnames = counts_df$CHR[loss_idx],
        ranges   = IRanges(start = counts_df$START[loss_idx],
        end   = counts_df$END[loss_idx])
    )
    export.bed(loss_peaks, file.path(outdir, paste0(label, "_loss_peaks.bed")))
}

run_edger_diffbind(file.path(opt$outdir, "cDC1_diffbind.csv"), "cDC1", opt$outdir, opt$pval)
run_edger_diffbind(file.path(opt$outdir, "cDC2_diffbind.csv"), "cDC2", opt$outdir, opt$pval)


# # FDR (adjusted p-value)
# sig <- dba.report(dba_obj, th = opt$fdr, bUsePval = FALSE)

# #pval
# sig <- dba.report(dba_obj, th = opt$pval, bUsePval = TRUE)
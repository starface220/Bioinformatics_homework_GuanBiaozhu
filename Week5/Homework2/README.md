# Week 5 Homework 2

This folder contains a complete local EasyMultiProfiler RNA-seq analysis of the
bundled `RNAseq_output.csv` and `RNAseq_mapping.csv` datasets.

No results were uploaded to GitHub or any external EMP platform. The analysis
ran on the local EasyMultiProfiler Web v9.0.4 backend.

## Analysis

- Input: 24 samples x 19,150 genes
- Groups: DMSO, DMSO+LIPUS, T4400, T4400+LIPUS, T3976, T3976+LIPUS
- Primary comparison: T4400 versus DMSO
- Differential method: DESeq2
- Significance: `padj < 0.05` and `abs(log2FoldChange) >= 1`
- Organism: mouse (`mmu`)

## Folder contents

- `inputs/`: local copies of the two CSV files used for the analysis
- `EasyMultiProfiler_RNAseq_results/tables/`: PCA, DESeq2, DEG, correlation, and GO tables
- `EasyMultiProfiler_RNAseq_results/plots/`: PDF and PNG versions of all generated figures
- `EasyMultiProfiler_RNAseq_results/platform_exports/`: local assay matrix, metadata, and session RDS
- `EasyMultiProfiler_RNAseq_results/summary.txt`: EasyMultiProfiler run log
- `EasyMultiProfiler_RNAseq_bundle_complete_20260925-100834.zip`: original local download bundle
- `homework2_interpretation.md`: result interpretation
- `analysis_summary.csv`: compact result summary

## Main result

Of the 16,757 genes retained by the platform's differential-analysis step,
238 genes passed both the adjusted p-value and effect-size thresholds.
There were 172 genes higher in T4400 and 66 genes lower in T4400.

GO enrichment returned 40 terms. The strongest terms involved chemokine
signaling, leukocyte migration, acute-phase response, antimicrobial humoral
response, and regulation of vasculature development. KEGG enrichment was
initially interrupted by a temporary REST connection failure, then rerun
successfully. The successful KEGG analysis returned 26 pathways, led by
IL-17 signaling, cytokine-cytokine receptor interaction, TNF signaling, and
chemokine signaling.

The original one-click run log records the first transient KEGG failure. The
successful targeted retry is saved separately as
`tables/09_enrichment_kegg.csv` and `plots/09_enrichment_kegg.png`.

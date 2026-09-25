# Week 5 Homework

This directory contains the two Week 5 homework submissions.

## Homework 1

Folder: `Homework1/`

Homework 1 is a bulk RNA-seq differential-expression analysis completed in R
with DESeq2 and `apeglm`. The script reads the original count matrix and sample
metadata from `../for_student/` and writes all required submission files into
this folder.

Analysis summary:

- 12 samples in a balanced design with three batches and two conditions
- 1,000 input genes
- Model design: `~ batch + condition`
- Filter: at least 10 counts in at least 3 samples
- 989 genes retained for the DESeq2 model
- Differential-expression thresholds: `padj < 0.05` and
  `abs(shrunken log2FoldChange) >= 1`
- 60 significant genes: 36 higher and 24 lower in treated samples
- PCA: PC1 explains 24% of the variance and separates treated from control

Required files:

```text
week5_deseq2_analysis.R
week5_deseq2_results.csv
week5_pca.png
week5_de_plot.png
week5_interpretation.md
week5_AI_verification_log.md
week5_deseq2_object.rds
session_info.txt
```

To rerun Homework 1, open `week5_deseq2_analysis.R` in RStudio and click
`Source`.

## Homework 2

Folder: `Homework2/`

Homework 2 is a complete local EasyMultiProfiler Web analysis of the bundled
RNA-seq test data. The original input files are copied into `Homework2/inputs/`.
No results were sent to GitHub or an external EMP service.

Analysis summary:

- 24 samples and 19,150 genes
- Six groups with four samples per group
- Primary comparison: `T4400 vs DMSO`
- Method: DESeq2
- Thresholds: `padj < 0.05` and `abs(log2FoldChange) >= 1`
- 16,757 genes tested
- 238 significant genes: 172 higher and 66 lower in T4400
- PCA: PC1 explains 66.7% and PC2 explains 25.8%
- GO enrichment: 40 terms
- KEGG enrichment: 26 pathways after a successful targeted retry

Important local files:

```text
README.md
homework2_interpretation.md
analysis_summary.csv
KEGG_RETRY_NOTE.md
inputs/
EasyMultiProfiler_RNAseq_results/
EasyMultiProfiler_RNAseq_bundle_complete_20260925-100834.zip
```

The original EasyMultiProfiler session remains in the local application data
directory:

```text
C:\EasyMultiProfiler-Web-main\.local_run\data\sessions\Z6uHJSVEoZc7W4O5ZtxdcMNI
```

The first `summary.txt` inside the downloaded bundle records a temporary KEGG
connection failure. A targeted KEGG retry later succeeded; its CSV and PNG are
saved under `EasyMultiProfiler_RNAseq_results/`.

## Input files

The unchanged course input files remain in `for_student/`:

```text
Week5_Homework_Count_Matrix.csv
Week5_Homework_Sample_Metadata.csv
Week5_Homework_Starter.R
Week5_Homework_Gene_Annotation_Instructor_Key.csv
```

The instructor truth-value file was not used to fit models, select genes, or
write either interpretation.

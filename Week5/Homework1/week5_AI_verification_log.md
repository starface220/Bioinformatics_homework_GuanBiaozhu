# Week 5 AI Verification Log

## Prompt preserved

The user requested: "Complete Homework 1, create a new `submission` folder under the Homework folder, run the analysis, and generate the required files."

## AI-generated work

- Adapted the provided starter script into `week5_deseq2_analysis.R`.
- Added checks for sample identity, integer counts, duplicate sample IDs, balanced batches, and full-rank model matrices.
- Added DESeq2 fitting, `apeglm` shrinkage, result export, PCA, volcano plotting, RDS export, and `sessionInfo()` capture.
- Added a path-resolution fallback so the script works in both RStudio and command-line Rscript.
- Drafted the interpretation and this verification log from the locally generated results.

## Locally executed

The analysis was run locally with:

```text
Rscript week5_deseq2_analysis.R
```

No web data were used.

## Independent verification

- Count matrix dimensions: 1,000 genes by 12 samples.
- Metadata sample order was identical to the count-matrix column order.
- No duplicate sample IDs were present.
- Every batch contained two control and two treated samples.
- All count values were non-negative integers.
- The model matrix had rank 4 of 4.
- `resultsNames(dds)` contained `condition_treated_vs_control`.
- The filter retained 989 genes using at least 10 counts in at least 3 samples.
- The independently counted result table contained 989 rows and 60 significant genes: 36 up and 24 down in treated.
- Both PNG files were decoded and checked as valid 2100 by 1500 images.
- The instructor truth-value CSV was not used to fit the model, choose genes, or write the interpretation.

## Errors and revisions

- Missing R packages were installed and loaded successfully.
- The initial command-line path resolver failed on a non-ASCII Windows path; it was changed to prefer the current submission directory when the script is present there.
- The `vst()` shortcut rejected the filtered 989-row matrix because its default subsample size is 1,000; the script was changed to the direct `varianceStabilizingTransformation()`.
- The initial graphical device could not write the PNG files; both plots were regenerated with R's built-in `png()` device and verified on disk.

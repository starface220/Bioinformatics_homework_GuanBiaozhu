#!/usr/bin/env Rscript

# Week 5 Homework 1
# Bulk RNA-seq differential expression with DESeq2 and apeglm.

required_packages <- c(
  "DESeq2",
  "apeglm",
  "tidyverse",
  "ggrepel"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  stop(
    "Missing required packages: ",
    paste(missing_packages, collapse = ", ")
  )
}

suppressPackageStartupMessages({
  library(DESeq2)
  library(apeglm)
  library(tidyverse)
  library(ggrepel)
})

# Resolve paths whether the script is run from RStudio or Rscript.
get_script_directory <- function() {
  current_directory <- normalizePath(getwd())
  if (file.exists(file.path(current_directory, "week5_deseq2_analysis.R"))) {
    return(current_directory)
  }

  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    return(dirname(normalizePath(sub("^--file=", "", file_arg[1]))))
  }

  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    active_path <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(active_path)) {
      return(dirname(normalizePath(active_path)))
    }
  }

  normalizePath(getwd())
}

script_dir <- get_script_directory()
setwd(script_dir)

count_file <- file.path(
  "..",
  "for_student",
  "Week5_Homework_Count_Matrix.csv"
)
metadata_file <- file.path(
  "..",
  "for_student",
  "Week5_Homework_Sample_Metadata.csv"
)

counts <- read.csv(
  count_file,
  row.names = 1,
  check.names = FALSE
)

coldata <- read.csv(
  metadata_file,
  row.names = 1,
  check.names = FALSE
)

# Input validation required by the assignment.
stopifnot(ncol(counts) == nrow(coldata))
stopifnot(identical(colnames(counts), rownames(coldata)))
stopifnot(!anyDuplicated(rownames(coldata)))
stopifnot(all(as.matrix(counts) >= 0))
stopifnot(all(as.matrix(counts) == round(as.matrix(counts))))

coldata$condition <- relevel(factor(coldata$condition), ref = "control")
coldata$batch <- factor(coldata$batch)

condition_table <- table(coldata$batch, coldata$condition)
model_matrix <- model.matrix(~ batch + condition, data = coldata)
model_rank <- qr(model_matrix)$rank

stopifnot(model_rank == ncol(model_matrix))

cat("Sample count:", nrow(coldata), "\n")
cat("Gene count:", nrow(counts), "\n")
cat("Library size summary:\n")
print(summary(colSums(counts)))
cat("Condition-by-batch table:\n")
print(condition_table)
cat("Model matrix rank:", model_rank, "of", ncol(model_matrix), "\n")

# Batch is included because the experiment has three balanced technical
# batches. Modeling it prevents batch variation from being absorbed into the
# treatment comparison and improves the estimate of residual variation.
dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = coldata,
  design = ~ batch + condition
)

keep <- rowSums(counts(dds) >= 10) >= 3
cat("Genes before filtering:", nrow(dds), "\n")
dds <- dds[keep, ]
cat("Genes after filtering:", nrow(dds), "\n")

dds <- DESeq(dds)

coef_names <- resultsNames(dds)
cat("Result coefficients:\n")
print(coef_names)

target_coef <- "condition_treated_vs_control"
if (!target_coef %in% coef_names) {
  stop(
    "Expected coefficient was not found. Update target_coef after ",
    "inspecting resultsNames(dds)."
  )
}

res <- results(
  dds,
  contrast = c("condition", "treated", "control"),
  alpha = 0.05
)

res_shrunk <- lfcShrink(
  dds,
  coef = target_coef,
  type = "apeglm"
)

res_df <- as.data.frame(res_shrunk) |>
  rownames_to_column("gene_id") |>
  mutate(
    significant = !is.na(padj) &
      padj < 0.05 &
      abs(log2FoldChange) >= 1,
    direction = case_when(
      significant & log2FoldChange > 0 ~ "Up in treated",
      significant & log2FoldChange < 0 ~ "Down in treated",
      TRUE ~ "Not significant"
    )
  ) |>
  arrange(padj, gene_id)

write.csv(
  res_df,
  "week5_deseq2_results.csv",
  row.names = FALSE
)

cat("Significant gene count:", sum(res_df$significant), "\n")
cat("Significant direction table:\n")
print(table(res_df$direction))
cat("Top significant genes:\n")
print(
  head(
    res_df[
      res_df$significant,
      c("gene_id", "log2FoldChange", "lfcSE", "padj", "direction")
    ],
    10
  )
)

# PCA uses a variance-stabilizing transformation rather than raw counts.
# The direct transformation is used because the filtered matrix has fewer than
# the 1,000 rows required by the vst() subsampling shortcut.
vsd <- varianceStabilizingTransformation(dds, blind = FALSE)
pca_df <- plotPCA(
  vsd,
  intgroup = c("condition", "batch"),
  returnData = TRUE
)
percent_var <- round(100 * attr(pca_df, "percentVar"))

cat("PCA variance explained (%):", percent_var[1], percent_var[2], "\n")
cat("PCA coordinates:\n")
print(pca_df[, c("name", "condition", "batch", "PC1", "PC2")])

p_pca <- ggplot(
  pca_df,
  aes(
    x = PC1,
    y = PC2,
    color = condition,
    shape = batch,
    label = name
  )
) +
  geom_point(size = 4) +
  geom_text_repel(size = 3, max.overlaps = Inf) +
  labs(
    title = "Week 5 RNA-seq PCA",
    x = paste0("PC1: ", percent_var[1], "% variance"),
    y = paste0("PC2: ", percent_var[2], "% variance")
  ) +
  theme_bw(base_size = 12)

png(
  "week5_pca.png",
  width = 7,
  height = 5,
  units = "in",
  res = 300
)
print(p_pca)
dev.off()

plot_df <- res_df |>
  mutate(
    neg_log10_padj = -log10(pmax(padj, 1e-300))
  )

p_volcano <- ggplot(
  plot_df,
  aes(
    x = log2FoldChange,
    y = neg_log10_padj,
    color = direction
  )
) +
  geom_point(alpha = 0.7, size = 1.8) +
  geom_vline(
    xintercept = c(-1, 1),
    linetype = "dashed"
  ) +
  geom_hline(
    yintercept = -log10(0.05),
    linetype = "dashed"
  ) +
  scale_color_manual(
    values = c(
      "Up in treated" = "#C0392B",
      "Down in treated" = "#2F6DB3",
      "Not significant" = "grey70"
    )
  ) +
  labs(
    title = "Differential expression: treated versus control",
    x = "Shrunken log2 fold change",
    y = "-log10 adjusted p value",
    color = NULL
  ) +
  theme_bw(base_size = 12)

png(
  "week5_de_plot.png",
  width = 7,
  height = 5,
  units = "in",
  res = 300
)
print(p_volcano)
dev.off()

stopifnot(file.exists("week5_pca.png"))
stopifnot(file.exists("week5_de_plot.png"))

saveRDS(
  dds,
  "week5_deseq2_object.rds"
)

capture.output(
  sessionInfo(),
  file = "session_info.txt"
)

cat("Analysis complete.\n")

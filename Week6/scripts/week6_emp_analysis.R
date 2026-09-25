#!/usr/bin/env Rscript

# Supplementary statistics and figures for the Week 6 EMP 16S assignment.
# The main workflow is run in EasyMultiProfiler Web v9.0.4. This script uses
# the same level-7 taxonomy table and metadata to make the supplied results
# auditable outside the web application.

options(stringsAsFactors = FALSE)
set.seed(2026)

args <- commandArgs(trailingOnly = TRUE)
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[1]) else NA_character_
submission_dir <- if (length(args) >= 1L) {
  normalizePath(args[1], winslash = "/", mustWork = FALSE)
} else if (!is.na(script_path)) {
  normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = FALSE)
} else {
  normalizePath(file.path(getwd(), "submission"), winslash = "/", mustWork = FALSE)
}

data_dir <- file.path(submission_dir, "data")
results_dir <- file.path(submission_dir, "results")
figures_dir <- file.path(submission_dir, "figures")
logs_dir <- file.path(submission_dir, "logs")
for (d in c(data_dir, results_dir, figures_dir, logs_dir)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

counts_file <- file.path(data_dir, "16S_level-7.csv")
metadata_file <- file.path(data_dir, "16S_mapping.csv")
if (!file.exists(counts_file) || !file.exists(metadata_file)) {
  stop("Expected 16S_level-7.csv and 16S_mapping.csv under submission/data.")
}

suppressPackageStartupMessages({
  library(ggplot2)
  library(vegan)
})

counts_raw <- as.matrix(read.csv(
  counts_file, row.names = 1, check.names = FALSE, na.strings = c("", "NA")
))
storage.mode(counts_raw) <- "double"
counts_raw[!is.finite(counts_raw)] <- 0

metadata <- read.csv(metadata_file, check.names = FALSE)
if (!"SampleID" %in% names(metadata)) {
  stop("Metadata must contain a SampleID column.")
}
metadata <- merge(
  data.frame(SampleID = colnames(counts_raw), stringsAsFactors = FALSE),
  metadata,
  by = "SampleID",
  all.x = TRUE,
  sort = FALSE
)
rownames(metadata) <- metadata$SampleID
metadata <- metadata[colnames(counts_raw), , drop = FALSE]
stopifnot(identical(rownames(metadata), colnames(counts_raw)))

taxonomy_parts <- strsplit(rownames(counts_raw), ";", fixed = TRUE)
taxon_label <- vapply(
  taxonomy_parts,
  function(parts) {
    value <- if (length(parts) >= 7L) parts[7] else NA_character_
    if (is.na(value) || !nzchar(value)) "Unassigned" else value
  },
  character(1)
)

counts_collapsed <- rowsum(counts_raw, group = taxon_label, reorder = FALSE)
taxon_totals <- rowSums(counts_collapsed)
taxonomy_map <- tapply(
  rownames(counts_raw), taxon_label,
  function(x) paste(unique(x), collapse = " | ")
)
top_n <- min(40L, nrow(counts_collapsed))
top_idx <- order(taxon_totals, decreasing = TRUE)[seq_len(top_n)]
counts <- counts_collapsed[top_idx, , drop = FALSE]
storage.mode(counts) <- "integer"

metadata$Group <- as.character(metadata$Group)
metadata$Group_sub <- as.character(metadata$Group_sub)
metadata$Disease <- sub("_.*$", "", metadata$Group)
metadata$Phase <- sub("^.*_", "", metadata$Group)
metadata$Subject <- sub("_[0-9]+$", "", rownames(metadata))
metadata$Disease[is.na(metadata$Group)] <- NA_character_
metadata$Phase[is.na(metadata$Group)] <- NA_character_

relative <- sweep(counts, 2, pmax(colSums(counts), 1), "/")
rclr <- t(vegan::decostand(t(counts), method = "rclr", MARGIN = 1))

write.csv(counts, file.path(data_dir, "emp_genus_top40_counts.csv"))
write.csv(rclr, file.path(data_dir, "emp_genus_top40_rclr.csv"))
write.csv(metadata, file.path(data_dir, "emp_metadata.csv"), row.names = FALSE)

validation <- data.frame(
  item = c(
    "input_samples", "input_features", "metadata_rows",
    "collapsed_taxa", "retained_top_taxa",
    "samples_with_group", "samples_without_group",
    "paired_IBS_subjects", "paired_UC_subjects",
    "all_sample_ids_match"
  ),
  value = c(
    ncol(counts_raw), nrow(counts_raw), nrow(metadata),
    nrow(counts_collapsed), nrow(counts),
    sum(!is.na(metadata$Group)), sum(is.na(metadata$Group)),
    NA_integer_, NA_integer_, TRUE
  ),
  stringsAsFactors = FALSE
)

metric_names <- c(
  shannon = "shannon", simpson = "simpson", invsimpson = "invsimpson",
  observed = "observed", chao1 = "chao1", ACE = "ACE", pielou = "pielou"
)
x_samples <- t(counts)
alpha <- data.frame(
  primary = rownames(x_samples),
  Group = metadata$Group,
  Group_sub = metadata$Group_sub,
  Disease = metadata$Disease,
  Phase = metadata$Phase,
  Subject = metadata$Subject,
  sample_sum = rowSums(x_samples),
  shannon = vegan::diversity(x_samples, index = "shannon"),
  simpson = vegan::diversity(x_samples, index = "simpson"),
  invsimpson = vegan::diversity(x_samples, index = "invsimpson"),
  observed = rowSums(x_samples > 0),
  stringsAsFactors = FALSE
)
richness <- tryCatch(vegan::estimateR(x_samples), error = function(e) NULL)
alpha$chao1 <- if (!is.null(richness)) richness["S.chao1", ] else NA_real_
alpha$ACE <- if (!is.null(richness)) richness["S.ACE", ] else NA_real_
alpha$pielou <- alpha$shannon / log(pmax(2, alpha$observed))
alpha <- alpha[, c(
  "primary", "Group", "Group_sub", "Disease", "Phase", "Subject",
  "sample_sum", "observed", "shannon", "simpson", "invsimpson",
  "chao1", "ACE", "pielou"
)]
write.csv(alpha, file.path(results_dir, "alpha_metrics.csv"), row.names = FALSE)

alpha_complete <- alpha[!is.na(alpha$Group), , drop = FALSE]
alpha_summary <- do.call(rbind, lapply(
  c("shannon", "simpson", "invsimpson", "observed", "chao1", "ACE", "pielou"),
  function(metric) {
    rows <- lapply(split(alpha_complete, alpha_complete$Group), function(x) {
      data.frame(
        metric = metric,
        group = unique(x$Group),
        n = sum(is.finite(x[[metric]])),
        mean = mean(x[[metric]], na.rm = TRUE),
        sd = sd(x[[metric]], na.rm = TRUE),
        median = median(x[[metric]], na.rm = TRUE),
        q1 = quantile(x[[metric]], 0.25, na.rm = TRUE, names = FALSE),
        q3 = quantile(x[[metric]], 0.75, na.rm = TRUE, names = FALSE),
        stringsAsFactors = FALSE
      )
    })
    do.call(rbind, rows)
  }
))
write.csv(alpha_summary, file.path(results_dir, "alpha_group_summary.csv"), row.names = FALSE)

safe_test <- function(formula, data) {
  tryCatch(
    {
      fit <- stats::kruskal.test(formula, data = data)
      data.frame(
        statistic = unname(fit$statistic),
        df = unname(fit$parameter),
        p_value = fit$p.value,
        method = "Kruskal-Wallis",
        stringsAsFactors = FALSE
      )
    },
    error = function(e) {
      data.frame(
        statistic = NA_real_, df = NA_real_, p_value = NA_real_,
        method = "Kruskal-Wallis", stringsAsFactors = FALSE
      )
    }
  )
}

alpha_tests <- do.call(rbind, lapply(
  c("shannon", "simpson", "invsimpson", "observed", "chao1", "ACE", "pielou"),
  function(metric) {
    out <- safe_test(stats::as.formula(paste(metric, "~ Group")), alpha_complete)
    out$metric <- metric
    out$variable <- "Group"
    out
  }
))
alpha_tests <- do.call(rbind, list(
  alpha_tests,
  do.call(rbind, lapply(
    c("shannon", "simpson", "invsimpson", "observed", "chao1", "ACE", "pielou"),
    function(metric) {
      out <- safe_test(stats::as.formula(paste(metric, "~ Disease")), alpha_complete)
      out$metric <- metric
      out$variable <- "Disease"
      out
    }
  )),
  do.call(rbind, lapply(
    c("shannon", "simpson", "invsimpson", "observed", "chao1", "ACE", "pielou"),
    function(metric) {
      out <- safe_test(stats::as.formula(paste(metric, "~ Phase")), alpha_complete)
      out$metric <- metric
      out$variable <- "Phase"
      out
    }
  ))
))
write.csv(alpha_tests, file.path(results_dir, "alpha_group_tests.csv"), row.names = FALSE)

pairwise_alpha <- do.call(rbind, lapply(
  c("shannon", "observed", "chao1"),
  function(metric) {
    fit <- tryCatch(
      stats::pairwise.wilcox.test(
        alpha_complete[[metric]], alpha_complete$Group,
        p.adjust.method = "BH", exact = FALSE
      ),
      error = function(e) NULL
    )
    if (is.null(fit)) return(NULL)
    mat <- as.matrix(fit$p.value)
    out <- as.data.frame(as.table(mat), stringsAsFactors = FALSE)
    names(out) <- c("group_1", "group_2", "p_adjusted")
    out <- out[!is.na(out$p_adjusted), , drop = FALSE]
    out$metric <- metric
    out[, c("metric", "group_1", "group_2", "p_adjusted")]
  }
))
write.csv(pairwise_alpha, file.path(results_dir, "alpha_pairwise_wilcoxon.csv"), row.names = FALSE)

make_pairs <- function(disease) {
  sub <- metadata[
    !is.na(metadata$Group) & metadata$Disease == disease,
    , drop = FALSE
  ]
  before <- sub[sub$Phase == "before", , drop = FALSE]
  after <- sub[sub$Phase == "after", , drop = FALSE]
  ids <- intersect(unique(before$Subject), unique(after$Subject))
  before <- before[match(ids, before$Subject), , drop = FALSE]
  after <- after[match(ids, after$Subject), , drop = FALSE]
  keep <- !is.na(before$Subject) & !is.na(after$Subject)
  list(before = before[keep, , drop = FALSE], after = after[keep, , drop = FALSE])
}

pairs_ibs <- make_pairs("IBS")
pairs_uc <- make_pairs("UC")
validation$value[validation$item == "paired_IBS_subjects"] <- nrow(pairs_ibs$before)
validation$value[validation$item == "paired_UC_subjects"] <- nrow(pairs_uc$before)
write.csv(validation, file.path(results_dir, "data_validation.csv"), row.names = FALSE)

paired_alpha <- do.call(rbind, lapply(
  c("shannon", "simpson", "invsimpson", "observed", "chao1", "ACE", "pielou"),
  function(metric) {
    rows <- lapply(c("IBS", "UC"), function(disease) {
      pair <- if (disease == "IBS") pairs_ibs else pairs_uc
      before <- alpha[[metric]][match(rownames(pair$before), alpha$primary)]
      after <- alpha[[metric]][match(rownames(pair$after), alpha$primary)]
      test <- tryCatch(
        stats::wilcox.test(after, before, paired = TRUE, exact = FALSE),
        error = function(e) NULL
      )
      delta <- after - before
      data.frame(
        disease = disease,
        metric = metric,
        n_pairs = sum(is.finite(delta)),
        median_delta = median(delta, na.rm = TRUE),
        mean_delta = mean(delta, na.rm = TRUE),
        p_value = if (!is.null(test)) test$p.value else NA_real_,
        stringsAsFactors = FALSE
      )
    })
    do.call(rbind, rows)
  }
))
paired_alpha$p_adjusted <- ave(
  paired_alpha$p_value, paired_alpha$disease,
  FUN = function(x) p.adjust(x, method = "BH")
)
write.csv(paired_alpha, file.path(results_dir, "alpha_paired_before_after.csv"), row.names = FALSE)

pcoa_meta <- metadata[!is.na(metadata$Group), , drop = FALSE]
pcoa_counts <- counts[, rownames(pcoa_meta), drop = FALSE]
pcoa_dist <- vegan::vegdist(t(pcoa_counts), method = "bray")
pcoa_fit <- stats::cmdscale(pcoa_dist, k = 3, eig = TRUE)
pcoa_positive_eig <- pmax(pcoa_fit$eig, 0)
pcoa_pct <- 100 * pcoa_positive_eig / sum(pcoa_positive_eig)
pcoa_coords <- data.frame(
  sample = rownames(pcoa_fit$points),
  PCo1 = pcoa_fit$points[, 1],
  PCo2 = pcoa_fit$points[, 2],
  PCo3 = pcoa_fit$points[, 3],
  Group = pcoa_meta[rownames(pcoa_fit$points), "Group"],
  Disease = pcoa_meta[rownames(pcoa_fit$points), "Disease"],
  Phase = pcoa_meta[rownames(pcoa_fit$points), "Phase"],
  stringsAsFactors = FALSE
)
write.csv(pcoa_coords, file.path(results_dir, "beta_pcoa_coordinates.csv"), row.names = FALSE)

extract_adonis <- function(formula, data, permutations = 999, strata = NULL,
                           distance = NULL) {
  if (!is.null(distance)) {
    assign(".distance", distance, envir = .GlobalEnv)
    rhs_terms <- all.vars(formula)[-1]
    formula <- stats::as.formula(
      paste(".distance ~", paste(rhs_terms, collapse = " + "))
    )
    environment(formula) <- .GlobalEnv
  }
  tryCatch(
    {
      fit <- if (is.null(strata)) {
        vegan::adonis2(
          formula, data = data, permutations = permutations, by = "margin"
        )
      } else {
        vegan::adonis2(
          formula, data = data, permutations = permutations,
          by = "margin", strata = strata
        )
      }
      tab <- as.data.frame(fit)
      term <- rownames(tab)[1]
      data.frame(
        term = term,
        df = tab$Df[1],
        sum_sq = tab$SumOfSqs[1],
        r2 = tab$R2[1],
        f_statistic = tab$F[1],
        p_value = tab[["Pr(>F)"]][1],
        permutations = permutations,
        error_message = NA_character_,
        stringsAsFactors = FALSE
      )
    },
    error = function(e) {
      data.frame(
        term = NA_character_, df = NA_real_, sum_sq = NA_real_,
        r2 = NA_real_, f_statistic = NA_real_, p_value = NA_real_,
        permutations = permutations, error_message = conditionMessage(e),
        stringsAsFactors = FALSE
      )
    }
  )
}

extract_dispersion <- function(dist, groups, permutations = 999) {
  tryCatch(
    {
      fit <- vegan::betadisper(dist, groups)
      pt <- vegan::permutest(fit, permutations = permutations)
      data.frame(
        f_statistic = unname(pt$statistic),
        p_value = pt$tab[["Pr(>F)"]][1],
        permutations = permutations,
        stringsAsFactors = FALSE
      )
    },
    error = function(e) {
      data.frame(
        f_statistic = NA_real_, p_value = NA_real_,
        permutations = permutations, stringsAsFactors = FALSE
      )
    }
  )
}

permanova_group <- extract_adonis(.distance ~ Group, pcoa_meta, distance = pcoa_dist)
permanova_group$variable <- "Group"
permanova_group$levels <- paste(sort(unique(pcoa_meta$Group)), collapse = " | ")
permanova_group$disease <- NA_character_
permanova_disease <- extract_adonis(.distance ~ Disease, pcoa_meta, distance = pcoa_dist)
permanova_disease$variable <- "Disease"
permanova_disease$levels <- paste(sort(unique(pcoa_meta$Disease)), collapse = " | ")
permanova_disease$disease <- NA_character_
permanova_phase <- extract_adonis(.distance ~ Phase, pcoa_meta, distance = pcoa_dist)
permanova_phase$variable <- "Phase"
permanova_phase$levels <- paste(sort(unique(pcoa_meta$Phase)), collapse = " | ")
permanova_phase$disease <- NA_character_

paired_permanova <- do.call(rbind, lapply(c("IBS", "UC"), function(disease) {
  pair <- if (disease == "IBS") pairs_ibs else pairs_uc
  sample_ids <- c(rownames(pair$before), rownames(pair$after))
  meta_pair <- metadata[sample_ids, , drop = FALSE]
  dist_pair <- vegan::vegdist(t(counts[, sample_ids, drop = FALSE]), method = "bray")
  out <- extract_adonis(
    .distance ~ Phase, meta_pair,
    strata = meta_pair$Subject, distance = dist_pair
  )
  out$variable <- "Phase within disease"
  out$disease <- disease
  out$levels <- "before | after"
  out
}))
permanova <- rbind(
  permanova_group, permanova_disease, permanova_phase, paired_permanova
)
permanova$error_message <- NULL
write.csv(permanova, file.path(results_dir, "beta_permanova.csv"), row.names = FALSE)

dispersion <- rbind(
  transform(
    extract_dispersion(vegan::vegdist(t(pcoa_counts), method = "bray"), pcoa_meta$Group),
    variable = "Group", levels = paste(sort(unique(pcoa_meta$Group)), collapse = " | ")
  ),
  transform(
    extract_dispersion(vegan::vegdist(t(pcoa_counts), method = "bray"), pcoa_meta$Disease),
    variable = "Disease", levels = paste(sort(unique(pcoa_meta$Disease)), collapse = " | ")
  ),
  transform(
    extract_dispersion(vegan::vegdist(t(pcoa_counts), method = "bray"), pcoa_meta$Phase),
    variable = "Phase", levels = paste(sort(unique(pcoa_meta$Phase)), collapse = " | ")
  )
)
write.csv(dispersion, file.path(results_dir, "beta_dispersion.csv"), row.names = FALSE)

safe_numeric_p <- function(test) {
  if (is.null(test)) return(NA_real_)
  value <- suppressWarnings(as.numeric(test$p.value))
  if (length(value)) value[1] else NA_real_
}

taxa_rows <- lapply(seq_len(nrow(counts)), function(i) {
  group_values <- alpha_complete$Group
  group_rel <- relative[i, rownames(alpha_complete), drop = TRUE]
  group_test <- tryCatch(
    stats::kruskal.test(group_rel, factor(group_values)),
    error = function(e) NULL
  )

  disease_complete <- !is.na(metadata$Disease)
  disease_rel <- relative[i, disease_complete, drop = TRUE]
  disease_values <- factor(metadata$Disease[disease_complete])
  disease_test <- tryCatch(
    stats::wilcox.test(disease_rel ~ disease_values, exact = FALSE),
    error = function(e) NULL
  )
  ibs_rel <- disease_rel[disease_values == "IBS"]
  uc_rel <- disease_rel[disease_values == "UC"]

  paired_results <- lapply(list(IBS = pairs_ibs, UC = pairs_uc), function(pair) {
    ids_before <- rownames(pair$before)
    ids_after <- rownames(pair$after)
    before <- rclr[i, ids_before]
    after <- rclr[i, ids_after]
    test <- tryCatch(
      stats::wilcox.test(after, before, paired = TRUE, exact = FALSE),
      error = function(e) NULL
    )
    list(
      p = safe_numeric_p(test),
      median_delta = median(after - before, na.rm = TRUE),
      mean_before = mean(before, na.rm = TRUE),
      mean_after = mean(after, na.rm = TRUE)
    )
  })

  data.frame(
    feature = rownames(counts)[i],
    taxonomy = unname(taxonomy_map[rownames(counts)[i]]),
    overall_mean_relative = mean(relative[i, ], na.rm = TRUE),
    ibs_mean_relative = mean(ibs_rel, na.rm = TRUE),
    uc_mean_relative = mean(uc_rel, na.rm = TRUE),
    disease_log2fc_uc_vs_ibs = log2(
      (mean(uc_rel, na.rm = TRUE) + 1e-6) /
        (mean(ibs_rel, na.rm = TRUE) + 1e-6)
    ),
    group_kruskal_p = safe_numeric_p(group_test),
    disease_wilcox_p = safe_numeric_p(disease_test),
    ibs_paired_wilcox_p = paired_results$IBS$p,
    ibs_median_delta_rclr = paired_results$IBS$median_delta,
    uc_paired_wilcox_p = paired_results$UC$p,
    uc_median_delta_rclr = paired_results$UC$median_delta,
    stringsAsFactors = FALSE
  )
})
differential <- do.call(rbind, taxa_rows)
differential$group_kruskal_fdr <- p.adjust(differential$group_kruskal_p, method = "BH")
differential$disease_wilcox_fdr <- p.adjust(differential$disease_wilcox_p, method = "BH")
differential$ibs_paired_wilcox_fdr <- p.adjust(differential$ibs_paired_wilcox_p, method = "BH")
differential$uc_paired_wilcox_fdr <- p.adjust(differential$uc_paired_wilcox_p, method = "BH")
differential <- differential[order(
  differential$group_kruskal_fdr,
  differential$disease_wilcox_fdr,
  differential$ibs_paired_wilcox_fdr,
  differential$uc_paired_wilcox_fdr
), ]
write.csv(differential, file.path(results_dir, "differential_taxa.csv"), row.names = FALSE)

selected <- differential[order(
  pmin(
    differential$ibs_paired_wilcox_p,
    differential$uc_paired_wilcox_p,
    na.rm = TRUE
  )
), ]
selected <- head(selected, 15L)
write.csv(selected, file.path(results_dir, "differential_taxa_selected.csv"), row.names = FALSE)

plot_alpha <- ggplot(
  alpha_complete,
  aes(x = Group, y = shannon, fill = Group, colour = Group)
) +
  geom_boxplot(width = 0.6, alpha = 0.72, outlier.shape = NA) +
  geom_jitter(width = 0.14, size = 1.8, shape = 21, stroke = 0.25, colour = "grey20") +
  labs(x = NULL, y = "Shannon diversity", title = "Alpha diversity by group") +
  theme_bw(base_size = 11) +
  theme(legend.position = "none", axis.text.x = element_text(angle = 20, hjust = 1))

plot_pcoa <- ggplot(
  pcoa_coords,
  aes(x = PCo1, y = PCo2, colour = Group, fill = Group)
) +
  geom_hline(yintercept = 0, linetype = 2, colour = "grey80") +
  geom_vline(xintercept = 0, linetype = 2, colour = "grey80") +
  stat_ellipse(
    geom = "polygon", level = 0.68, alpha = 0.10, linewidth = 0.35,
    show.legend = FALSE
  ) +
  geom_point(size = 2.4, alpha = 0.9) +
  labs(
    x = sprintf("PCo1 (%.1f%%)", pcoa_pct[1]),
    y = sprintf("PCo2 (%.1f%%)", pcoa_pct[2]),
    title = "Bray-Curtis PCoA",
    subtitle = "68% normal ellipses"
  ) +
  theme_bw(base_size = 11)

top_features <- names(sort(rowMeans(relative), decreasing = TRUE))[1:min(10L, nrow(relative))]
composition <- do.call(rbind, lapply(levels(factor(pcoa_meta$Group)), function(group) {
  ids <- rownames(pcoa_meta)[pcoa_meta$Group == group]
  values <- rowMeans(relative[top_features, ids, drop = FALSE])
  data.frame(
    Group = group,
    Feature = top_features,
    Mean_relative_abundance = values,
    stringsAsFactors = FALSE
  )
}))
composition$Feature <- factor(
  composition$Feature,
  levels = rev(top_features)
)
plot_composition <- ggplot(
  composition,
  aes(x = Group, y = Mean_relative_abundance, fill = Feature)
) +
  geom_col(width = 0.72) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    x = NULL,
    y = "Mean relative abundance",
    title = "Top taxa composition",
    fill = "Level-7 taxon"
  ) +
  theme_bw(base_size = 10) +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

paired_long <- rbind(
  data.frame(
    feature = selected$feature,
    disease = "IBS",
    median_delta_rclr = selected$ibs_median_delta_rclr,
    p_value = selected$ibs_paired_wilcox_p,
    stringsAsFactors = FALSE
  ),
  data.frame(
    feature = selected$feature,
    disease = "UC",
    median_delta_rclr = selected$uc_median_delta_rclr,
    p_value = selected$uc_paired_wilcox_p,
    stringsAsFactors = FALSE
  )
)
paired_long$feature <- factor(
  paired_long$feature,
  levels = rev(unique(selected$feature))
)
plot_paired <- ggplot(
  paired_long,
  aes(x = feature, y = median_delta_rclr, fill = disease)
) +
  geom_col(position = position_dodge(width = 0.75), width = 0.68) +
  geom_hline(yintercept = 0, colour = "grey30", linewidth = 0.3) +
  coord_flip() +
  labs(
    x = NULL,
    y = "Median paired change in rCLR (after - before)",
    title = "Largest before/after taxon shifts",
    fill = "Disease"
  ) +
  theme_bw(base_size = 10)

save_plot <- function(plot, stem, width, height) {
  ggsave(
    file.path(figures_dir, paste0(stem, ".png")),
    plot, width = width, height = height, dpi = 300, units = "in"
  )
  ggsave(
    file.path(figures_dir, paste0(stem, ".pdf")),
    plot, width = width, height = height, units = "in"
  )
}

save_plot(plot_alpha, "alpha_shannon_group", 7.5, 5.5)
save_plot(plot_pcoa, "beta_pcoa_group", 8.5, 6.5)
save_plot(plot_composition, "top_taxa_composition", 9.0, 6.0)
save_plot(plot_paired, "paired_taxon_shift", 8.0, 6.0)

capture.output(
  sessionInfo(),
  file = file.path(logs_dir, "R_session_info.txt")
)
writeLines(
  c(
    paste0("EasyMultiProfiler Web version: 9.0.4"),
    paste0("Analysis timestamp: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
    paste0("Random seed: 2026"),
    paste0("Group comparisons: Group (4 levels), Disease (IBS vs UC), Phase (before vs after)"),
    paste0("Alpha models: Kruskal-Wallis; paired before/after: Wilcoxon signed-rank"),
    paste0("Beta model: Bray-Curtis; PERMANOVA 999 permutations; PERMDISP 999 permutations"),
    paste0("Taxa tests: Kruskal-Wallis, Mann-Whitney, and paired Wilcoxon; BH correction")
  ),
  file.path(logs_dir, "analysis_parameters.txt")
)

message("Week 6 analysis completed: ", submission_dir)

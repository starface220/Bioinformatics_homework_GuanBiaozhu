# Q4 variant prioritization
# Input: synthetic teaching data from the Week 4 student package.
# No clinical decision should be made from this script.

args <- commandArgs(trailingOnly = TRUE)

if (length(args) >= 1) {
  input_path <- args[1]
} else {
  input_path <- file.path("..", "for_student", "data", "variants_q4.tsv")
}

if (!file.exists(input_path)) {
  fallback_path <- file.path("answers", "variants_q4.tsv")
  if (file.exists(fallback_path)) {
    input_path <- fallback_path
  } else {
    stop("Could not find variants_q4.tsv. Pass the file path as the first argument.")
  }
}

variants <- read.delim(
  input_path,
  comment.char = "#",
  check.names = FALSE,
  stringsAsFactors = FALSE
)

required_columns <- c(
  "CHROM", "POS", "REF", "ALT", "FILTER", "DP", "GQ", "AF",
  "GENE", "CONSEQUENCE", "CLINVAR_SIG", "CLINVAR_ID", "NOTE"
)

missing_columns <- setdiff(required_columns, colnames(variants))
if (length(missing_columns) > 0) {
  stop(paste("Missing columns:", paste(missing_columns, collapse = ", ")))
}

# Thresholds chosen before ranking.
min_dp <- 20
min_gq <- 30
max_af <- 0.01
excluded_clinical_labels <- c("Benign", "Likely_benign")
impact_consequences <- c(
  "splice_acceptor_variant",
  "splice_donor_variant",
  "frameshift_variant",
  "stop_gained",
  "missense_variant"
)

variants$AF <- as.numeric(variants$AF)
variants$DP <- as.numeric(variants$DP)
variants$GQ <- as.numeric(variants$GQ)
variants$CLINVAR_SIG[is.na(variants$CLINVAR_SIG) | variants$CLINVAR_SIG == ""] <- "Not_provided"

filtered <- variants[
  variants$FILTER == "PASS" &
    variants$DP >= min_dp &
    variants$GQ >= min_gq &
    variants$AF <= max_af &
    variants$CONSEQUENCE %in% impact_consequences &
    !variants$CLINVAR_SIG %in% excluded_clinical_labels,
]

technical_score <- ifelse(filtered$DP >= 50, 2, 1) + ifelse(filtered$GQ >= 90, 2, 1)

frequency_score <- ifelse(
  filtered$AF <= 0.00001, 3,
  ifelse(filtered$AF <= 0.0001, 2,
         ifelse(filtered$AF <= 0.001, 1, 0))
)

consequence_score <- ifelse(
  filtered$CONSEQUENCE %in% c(
    "splice_acceptor_variant",
    "splice_donor_variant",
    "frameshift_variant",
    "stop_gained"
  ), 3,
  ifelse(filtered$CONSEQUENCE == "missense_variant", 2, 0)
)

clinical_score <- ifelse(
  filtered$CLINVAR_SIG == "Pathogenic", 3,
  ifelse(filtered$CLINVAR_SIG == "Likely_pathogenic", 2,
         ifelse(filtered$CLINVAR_SIG == "Uncertain_significance", 1, 0))
)

filtered$PRIORITY_SCORE <- technical_score + frequency_score + consequence_score + clinical_score
filtered$MANUAL_REVIEW <- paste(
  "Check reference build, MANE transcript, genotype quality in BAM,",
  "phenotype fit, inheritance, segregation, and orthogonal validation."
)

filtered <- filtered[order(-filtered$PRIORITY_SCORE, filtered$AF, filtered$CHROM, filtered$POS), ]

print(
  filtered[
    ,
    c(
      "CHROM", "POS", "REF", "ALT", "GENE", "CONSEQUENCE",
      "CLINVAR_SIG", "DP", "GQ", "AF", "PRIORITY_SCORE", "MANUAL_REVIEW"
    )
  ],
  row.names = FALSE
)

write.table(
  filtered,
  file = "Q4_shortlist.tsv",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

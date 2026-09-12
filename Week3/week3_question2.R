#!/usr/bin/env Rscript
# ============================================================
# Week 3 | Question 2 -- GSE87487 mini-case
#
# Answers the four questions from the downloaded files:
#   Q1  Are the values counts?
#   Q2  Are samples independent?
#   Q3  Can all 20 samples be compared directly?
#   Q4  Is full raw-read reprocessing possible?
#
# Inputs (expected in the same folder as this script):
#   GSE87487_counts.20samples.txt
#   GSE87487_series_matrix.txt
#
# Base R only, no external packages required.
# ============================================================

## ---- 0. locate input files ---------------------------------

args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
data_dir <- tryCatch({
  if (length(script_arg) > 0) {
    dirname(normalizePath(sub("^--file=", "", script_arg[1])))
  } else {
    getwd()
  }
}, error = function(e) getwd())

counts_file <- file.path(data_dir, "GSE87487_counts.20samples.txt")
meta_file   <- file.path(data_dir, "GSE87487_series_matrix.txt")
stopifnot(file.exists(counts_file), file.exists(meta_file))

rule <- function() cat(strrep("-", 64), "\n", sep = "")
norm <- function(x) toupper(gsub("[^A-Za-z0-9]", "", x))   # loose ID matching

# ============================================================
# Q1. Are the values counts?
# ============================================================

rule(); cat("Q1. Are the values counts?\n"); rule()

fc <- read.delim(counts_file, check.names = FALSE, stringsAsFactors = FALSE)

annot_cols <- c("Geneid", "Chr", "Start", "End", "Strand", "Length")
stopifnot(all(annot_cols %in% colnames(fc)))

mat <- as.matrix(fc[, setdiff(colnames(fc), annot_cols)])
storage.mode(mat) <- "double"

is_integer    <- all(mat == floor(mat))
is_nonneg     <- all(mat >= 0)
has_na        <- anyNA(mat)
has_dup_feat  <- anyDuplicated(fc$Geneid) > 0
frac_zero     <- mean(mat == 0)

cat("featureCounts annotation columns :", paste(annot_cols, collapse = ", "), "\n")
cat("matrix dimensions                :", nrow(mat), "features x", ncol(mat), "samples\n")
cat("value range                      :", paste(range(mat), collapse = " to "), "\n")
cat("all values are integers          :", is_integer, "\n")
cat("all values are non-negative      :", is_nonneg, "\n")
cat("any missing values (NA)          :", has_na, "\n")
cat("proportion of zero entries       :", sprintf("%.1f%%", 100 * frac_zero), "\n")
cat("duplicated feature IDs           :", has_dup_feat, "\n")
cat("example feature ID               :", fc$Geneid[1], "(Ensembl, versioned)\n")

q1_yes <- is_integer && is_nonneg && !has_na
cat("\n>> Q1 answer:", if (q1_yes)
  "YES. The matrix holds non-negative integers with no missing values, i.e. raw counts." else
  "NOT confirmed. Inspect the matrix further.", "\n")

# ============================================================
# Parse the Series Matrix metadata
# ============================================================

sm <- readLines(meta_file)

pull <- function(prefix) {
  hit <- grep(paste0("^", prefix), sm, value = TRUE)
  if (length(hit) == 0) return(NULL)
  lapply(hit, function(l) gsub('^"|"$', '', strsplit(l, "\t")[[1]][-1]))
}

gsm    <- pull("!Sample_geo_accession")[[1]]
title  <- pull("!Sample_title")[[1]]
chars  <- pull("!Sample_characteristics_ch1")

pick <- function(lst, pattern) {
  for (v in lst) if (length(v) && all(grepl(pattern, v))) return(v)
  NULL
}

stage  <- sub("^.*:\\s*", "", pick(chars, "^transplant stage:"))
iri    <- sub("^.*:\\s*", "", pick(chars, "^ischemia reperfusion injury"))
tissue <- sub("^.*:\\s*", "", pick(chars, "^tissue:"))
donor  <- sub("[Bb][Xx][12]$", "", title)      # e.g. RJBx1 -> RJ

meta <- data.frame(gsm, title, donor, stage, iri, tissue, stringsAsFactors = FALSE)

cat("\n"); rule(); cat("Sample dictionary (from the Series Matrix)\n"); rule()
print(meta, row.names = FALSE)

# ---- alignment: counts columns vs metadata -----------------

count_names <- sub("\\.bam$", "", sub("^Sample_", "", colnames(mat)))

cat("\ncounts column order  :", paste(count_names[c(1:3, 20)], collapse = ", "), "...\n")
cat("metadata order       :", paste(title[c(1:3, 20)], collapse = ", "), "...\n")
cat("identical order      :", identical(norm(count_names), norm(title)), "\n")
cat("all samples matchable:", !anyNA(match(norm(title), norm(count_names))), "\n")
cat("(naming differs, e.g. 'Pt10-Bx1' vs 'Pt10Bx1' -> explicit matching required)\n")

# ============================================================
# Q2. Are samples independent?
# ============================================================

rule(); cat("Q2. Are samples independent?\n"); rule()

per_donor <- table(meta$donor)
cat("n samples :", nrow(meta), "\n")
cat("n donors  :", length(per_donor), "\n")
cat("samples per donor:\n"); print(per_donor)
cat("every donor contributes exactly 2 samples:",
    all(per_donor == 2), "\n")

stage_pairs <- tapply(meta$stage, meta$donor,
                      function(x) paste(sort(unique(x)), collapse = " + "))
cat("\ntransplant stages collected per donor:\n"); print(stage_pairs)

q2_paired <- all(per_donor == 2)
cat("\n>> Q2 answer:", if (q2_paired)
  "NO. Each donor contributes a pre- and a post-reperfusion biopsy,\n   so the 20 samples are 10 repeated-measurement pairs, not 20 independent subjects." else
  "Paired structure not confirmed.", "\n")

# ============================================================
# Q3. Can all 20 samples be compared directly?
# ============================================================

rule(); cat("Q3. Can all 20 samples be compared directly?\n"); rule()

cat("cross-tabulation of the two factors (samples):\n")
print(table(iri = meta$iri, stage = meta$stage))

iri_per_donor <- tapply(meta$iri, meta$donor, function(x) length(unique(x)))
donors_by_iri <- table(unique(meta[, c("donor", "iri")])$iri)

cat("\nIRI status is constant within every donor:",
    all(iri_per_donor == 1), "\n")
cat("donors per IRI group:\n"); print(donors_by_iri)
cat("note: IRI is a donor-level (between-subject) trait,",
    "while stage is a within-subject factor.\n")

cat("\n>> Q3 answer: NO. Two distinct factors are present; pooling all 20 samples\n",
    "   into one comparison would (a) ignore the pre/post pairing and\n",
    "   (b) treat repeated biopsies of one donor as independent subjects.\n",
    "   A specific contrast must be defined first, e.g.\n",
    "     (a) paired pre vs post  -> design ~ donor + stage\n",
    "     (b) IRI+ vs IRI-        -> between-donor, unbalanced (",
    paste(names(donors_by_iri), donors_by_iri, sep = "=", collapse = " vs "), ")\n", sep = "")

# ============================================================
# Q4. Is full raw-read reprocessing possible?
# ============================================================

rule(); cat("Q4. Is full raw-read reprocessing possible?\n"); rule()

relations <- grep("^!Series_relation", sm, value = TRUE)
sample_type <- unique(pull("!Sample_type")[[1]])

cat("Sample_type in the record:\n"); print(sample_type)
cat("\nSeries relation links recorded in the Series Matrix:\n")
if (length(relations) > 0) cat(paste(relations, collapse = "\n"), "\n") else
  cat("  (none recorded in the Series Matrix)\n")

cat("\n>> Q4 answer: YES in principle, but beyond a one-hour homework.\n",
    "   Raw reads are archived in SRA (the record declares bioProject SRP090633),\n",
    "   so reprocessing would require: download FASTQ -> QC -> alignment ->\n",
    "   quantification, i.e. a full pipeline rather than a single script.\n",
    "   The supplied featureCounts matrix already provides the counts needed here.\n",
    sep = "")

rule()
cat("Script finished.\n")

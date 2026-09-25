# Week 6 16S homework

## Analysis

I ran the 16S analysis in EasyMultiProfiler Web v9.0.4 with the
`m16s_course` data set.

The input had 132 samples and 470 level-7 taxonomy features. A `Group` label
was available for 130 samples. The two samples without group information were
kept in the data check but left out of the group comparisons.

After the EMP taxonomy step, I kept the top 40 taxa by total abundance. I
calculated observed richness, Shannon, Simpson, inverse Simpson, Chao1, ACE,
and Pielou before normalization. I used the count table for Bray-Curtis PCoA,
PERMANOVA with 999 permutations, and PERMDISP with 999 permutations. For
differential taxa, I used Mann-Whitney tests for IBS versus UC and paired
Wilcoxon tests for before/after samples, with Benjamini-Hochberg correction.
The paired and differential comparisons used rCLR values.

## Results

Shannon diversity was similar across the four groups (Kruskal-Wallis
p = 0.290), between IBS and UC (p = 0.170), and between before and after
samples (p = 0.210).

The four-group community test gave weak evidence of a difference
(PERMANOVA R2 = 0.033, p = 0.095). IBS and UC showed a small compositional
difference (Bray-Curtis PERMANOVA R2 = 0.022, F = 2.83, p = 0.018, 999
permutations). PERMDISP did not point to a dispersion problem (p = 0.363).
The before/after contrast was not significant (p = 0.627).

The taxa with the clearest disease direction were:

| Taxon | IBS mean relative abundance | UC mean relative abundance | log2 FC (UC/IBS) | Wilcoxon p | BH FDR |
|---|---:|---:|---:|---:|---:|
| _Lactobacillus mucosae_ | 0.00046 | 0.00332 | +2.85 | 0.0048 | 0.080 |
| _Gemmiger formicilis_ | 0.0140 | 0.00670 | -1.06 | 0.0060 | 0.080 |
| _[Ruminococcus] torques_ | 0.00241 | 0.00063 | -1.93 | 0.0022 | 0.080 |
| _Ruminococcus bromii_ | 0.00834 | 0.00249 | -1.74 | 0.0103 | 0.082 |
| _Akkermansia muciniphila_ | 0.0247 | 0.00433 | -2.51 | 0.0143 | 0.086 |

No taxon reached BH FDR < 0.05, so I treated these as exploratory candidates
that need validation. Within UC, paired samples showed a decrease in Shannon
diversity (median change = -0.074, p = 0.021, BH q = 0.072) and Pielou
evenness (p = 0.018, BH q = 0.072). IBS did not show the same pattern.

## Hypothesis

My hypothesis is that UC affects a subset of gut taxa while overall Shannon
diversity stays similar. The data showed lower relative abundance of
_Akkermansia muciniphila_, _Ruminococcus bromii_,
_[Ruminococcus] torques_, and _Gemmiger formicilis_ in UC, along with higher
_Lactobacillus mucosae_.

One possible explanation is that UC-related mucosal inflammation changes
mucin turnover and the substrates available for fermentation. That could
reduce mucin- and butyrate-associated taxa and allow acid-tolerant
lactobacilli to increase. I would test this in an independent cohort using
absolute quantification, shotgun metagenomics, and inflammatory markers.
The hypothesis would be weakened if the directions reverse, if medication or
batch explains the pattern, or if the taxa do not track disease activity.

The parameters I used to support the hypothesis were:

- `Group` with IBS_before, IBS_after, UC_before, and UC_after.
- Shannon, observed richness, Simpson, inverse Simpson, Chao1, ACE, and
  Pielou, tested with Kruskal-Wallis and paired Wilcoxon tests.
- Bray-Curtis distance, PCoA, PERMANOVA with 999 permutations, and PERMDISP
  with 999 permutations.
- Relative abundance for IBS versus UC, and rCLR values for before/after
  comparisons, both with Benjamini-Hochberg correction.

The main support came from the disease PERMANOVA (R2 = 0.022, p = 0.018),
the PERMDISP result (p = 0.363), and five taxa with BH FDR between 0.080 and
0.086. The data are educational and compositional. The disease effect is
small, no taxon passes FDR < 0.05, and the paired results are trend-level
after correction. I cannot make a causal, diagnostic, or treatment claim from
this data set.

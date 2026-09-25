# Scientific hypothesis

## What I think is happening

My hypothesis is that UC changes a small number of gut taxa while overall
Shannon diversity remains similar. In UC samples, the relative abundance of
_Akkermansia muciniphila_, _Ruminococcus bromii_,
_[Ruminococcus] torques_, and _Gemmiger formicilis_ was lower.
_Lactobacillus mucosae_ was higher.

I would test whether UC-related mucosal inflammation changes mucin turnover
and the substrates available for fermentation. That could reduce
mucin- and butyrate-associated taxa and give acid-tolerant lactobacilli more
room to grow. This is a possible mechanism, not something the current data can
establish.

## Results behind the hypothesis

| Analysis | Parameter | Result |
|---|---|---|
| Data validation | 132 samples, 470 features | 130 samples had complete `Group` labels |
| Alpha diversity | Shannon, observed, Simpson, inverse Simpson, Chao1, ACE, Pielou | Shannon did not differ by disease (Kruskal-Wallis p = 0.170) |
| Alpha before/after | Paired Wilcoxon, BH correction | UC Shannon median change = -0.074, p = 0.021, q = 0.072 |
| Beta diversity | Bray-Curtis PCoA | PCo1 = 27.7%, PCo2 = 19.4% in EMP |
| Community test | PERMANOVA, 999 permutations | IBS vs UC: R2 = 0.022, F = 2.83, p = 0.018 |
| Dispersion check | PERMDISP, 999 permutations | Disease p = 0.363 |
| Differential taxa | Mann-Whitney, relative abundance, BH FDR | Five taxa had FDR between 0.080 and 0.086 |

The strongest directional taxa were:

| Taxon | Direction in UC | log2 FC (UC/IBS) | p | BH FDR |
|---|---|---:|---:|---:|
| _Lactobacillus mucosae_ | higher | +2.85 | 0.0048 | 0.080 |
| _Gemmiger formicilis_ | lower | -1.06 | 0.0060 | 0.080 |
| _[Ruminococcus] torques_ | lower | -1.93 | 0.0022 | 0.080 |
| _Ruminococcus bromii_ | lower | -1.74 | 0.0103 | 0.082 |
| _Akkermansia muciniphila_ | lower | -2.51 | 0.0143 | 0.086 |

No taxon reached BH FDR < 0.05, so this remains an exploratory hypothesis. It
should not be described as a confirmed biomarker or causal mechanism.

## How I would test it

An independent cohort should show the same directions with absolute
quantification and shotgun metagenomics. The taxa should still relate to
inflammatory markers after I account for antibiotics, medication, stool
transit, and batch. If the directions reverse, or if technical variables
explain the pattern, I would drop or revise the hypothesis.

## Limitation

The data are educational and compositional. Relative abundance alone cannot
show whether a taxon increased or decreased in absolute terms.

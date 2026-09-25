# Homework 2 Interpretation

The local EasyMultiProfiler analysis used the bundled RNA-seq matrix and sample
mapping file. The dataset contains 24 samples from six treatment groups, with
four samples in each group. The primary comparison was `T4400 versus DMSO`.
Counts were analyzed with DESeq2, and genes were called significant when
`padj < 0.05` and the absolute log2 fold change was at least 1.

PCA showed that PC1 explained 66.7% of the variance and PC2 explained 25.8%.
The T4400 samples were separated from the DMSO samples mainly along PC2.
Sample-level Spearman correlations remained high (minimum 0.979), so no sample
was removed on the basis of PCA alone.

After platform filtering, 16,757 genes were tested. A total of 238 genes passed
both thresholds: 172 were higher in T4400 and 66 were lower in T4400. The
strongest genes included `Cep290`, `Ptprv`, `Dcn`, `Il1a`, `Mest`, `Prdm1`,
`Aldh1l2`, `Ccl3`, `Nrn1`, and `Erv3`.

GO enrichment returned 40 terms. The strongest terms were related to
chemokine-mediated signaling, leukocyte migration, acute-phase response,
antimicrobial humoral response, cell chemotaxis, and regulation of
vasculature development. Several leading genes were chemokines or inflammatory
markers, including `Ccl3`, `Ccl2`, `Ccl5`, `Ccl7`, `Ccl8`, `Ccl11`, `Cxcl1`,
`Cxcl5`, and `Cxcl10`. These patterns suggest that T4400 treatment is
associated with a coordinated inflammatory and chemokine-related
transcriptional response in this dataset.

This interpretation is limited to the supplied mouse dataset. The analysis
does not establish which upstream regulator drives the response, and GO terms
describe enriched biological processes rather than proven causal mechanisms.
KEGG enrichment was initially interrupted by a temporary REST connection
failure from the local R process. A targeted retry succeeded and returned 26
pathways. The strongest included IL-17 signaling, cytokine-cytokine receptor
interaction, TNF signaling, chemokine signaling, and complement/coagulation
pathways. Together with the GO results, these findings support an inflammatory
and cytokine-related response in T4400, but they remain pathway-level
hypotheses rather than proof of a specific upstream mechanism.

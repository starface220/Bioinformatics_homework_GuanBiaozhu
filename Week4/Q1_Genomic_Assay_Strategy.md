# Q1 - Choose the Right Genomic Assay

**Name:**

**Student ID:**

**Date:**

---

## Core biological question

In this question, Gene X is expressed at a higher level in the disease group than in healthy controls. I need to find out which regulatory mechanism is most likely to explain this difference: a cis-regulatory DNA variant, a change in chromatin accessibility, a change in transcription-factor binding, a change in histone modification, a change in DNA methylation, or a change in enhancer-promoter contact.

I am treating the RNA-seq result as the starting point. The rest of the experiment should add evidence about the mechanism and, if possible, show that changing the candidate element changes Gene X expression.

I will assume that disease and control samples are matched for tissue, cell type, age, sex, and major technical variables. I will also assume that each assay has biological replicates and the appropriate input or IgG controls.

---

## 1. Reasoning before AI

### First assay: ATAC-seq

If I could start with one assay, I would choose ATAC-seq and compare the same disease-relevant cell type in cases and controls. ATAC-seq measures accessible DNA through Tn5 insertion. Differential peaks would give me a list of possible regulatory regions near Gene X, and motif enrichment could suggest transcription factors that might act there. Motif results would only be a hypothesis because ATAC-seq does not directly measure transcription-factor binding.

My main reason for starting with ATAC-seq is practical. Accessibility is one of the earlier regulatory features I can measure across the genome, and the result can help me decide which later assays are worth doing. RNA-seq tells me that Gene X is upregulated, but it does not tell me whether the cause is a DNA variant, a change in active chromatin, methylation, or a three-dimensional contact. ATAC-seq can narrow the search to specific regions for H3K27ac CUT&Tag or ChIP-seq, WGBS or EM-seq, Hi-C or Micro-C, and sequence analysis.

ATAC-seq also has clear limitations. An open region may be a promoter, enhancer, insulator, inactive element, or a region that regulates another gene. The assay cannot prove that a region is an enhancer, that it controls Gene X, or that accessibility causes the expression change. It also cannot tell me whether a DNA variant came first or whether the chromatin change happened later.

### Proposed multi-stage strategy and decision rules

I would not follow the order below rigidly. WGS or WES data could be generated early, but I would interpret variants in candidate regions after ATAC-seq has identified those regions.

#### Stage 0. Check the expression result

I would first use RNA-seq from matched disease and control samples to check that Gene X upregulation is reproducible across biological replicates. I would also check whether a batch effect, a shift in cell composition, or a global change in expression could explain the result.

If the difference is not reproducible in the relevant cell type, I would revise the phenotype or sample model before testing regulatory mechanisms. If it is reproducible, I would keep the same sample set and move on to the regulatory assays.

#### Stage 1. Find candidate regulatory regions with ATAC-seq

I would run ATAC-seq in disease and control samples with biological replicates. After peak calling and differential accessibility analysis, I would focus on regions near the Gene X promoter and any upstream or downstream regions that stand out.

If a reproducible peak differs between disease and control samples near Gene X, I would define that region as R and carry it into Stage 2. If several peaks are present, I would rank them by effect size, reproducibility, distance from Gene X, and overlap with known regulatory annotations.

If accessibility does not change near Gene X, I would not conclude that no regulatory mechanism exists. I would test other explanations, including trans-acting regulators, changes in chromatin regulators, a different cell type or activation state, and changes in promoter or transcript usage. WGS/WES and CAGE/RAMPAGE could help revise the hypothesis.

#### Stage 2. Check the state of region R

I would use H3K27ac ChIP-seq or CUT&Tag to check whether R has an active enhancer-associated chromatin state. WGBS or EM-seq would measure methylation at R, and Hi-C or Micro-C would test whether R contacts the Gene X promoter. CAGE or RAMPAGE could be added if promoter or transcription-start-site usage may explain part of the expression difference.

If R is accessible and gains H3K27ac in disease samples, it becomes a stronger active-enhancer candidate. If it is accessible but lacks H3K27ac, I would lower its priority, but I would first check whether the relevant chromatin state or time point is missing.

If R is hypomethylated in disease samples, that is compatible with regulatory activity. If it is hypermethylated, I would consider a simple active-enhancer model less likely, although methylation can depend on cell context. If R contacts the Gene X promoter, a cis-regulatory model becomes more plausible. If no contact is detected, I would consider another target gene, an indirect mechanism, a cell-type-specific contact, or the resolution limits of the contact assay.

After these results, I would classify R as supported, uncertain, or contradicted and write down which evidence is still missing.

#### Stage 3. Check sequence variation

I would use WGS for noncoding and regulatory variants and WES for coding or exome-focused hypotheses. WES alone is not enough to rule out a noncoding regulatory variant. I would test whether variants in or near R track with accessibility, H3K27ac, methylation, contact, or Gene X expression and would look for allele-specific signals where possible.

If a cis-regulatory variant is present and its genotype tracks with the regulatory or expression change, I would prioritize that allele for functional testing. If no such variant is found, I would keep epigenetic and trans-regulatory hypotheses on the table. A missing variant is not proof of an epigenetic cause.

If a coding variant is found, I would consider whether altered Gene X protein function, feedback, or a trans-acting pathway could cause the expression change. If the evidence layers point in different directions, I would design the next experiment to separate the competing mechanisms instead of forcing one model to fit all the data.

#### Stage 4. Test regulatory activity and function

I would use MPRA to compare the regulatory activity of disease-associated and control alleles or sequences from R in a reporter assay. I would then use CRISPRi, enhancer deletion, or loop-anchor perturbation to test the endogenous element.

If the disease allele increases reporter activity in MPRA, it may act through an allele-specific regulatory mechanism, but the result does not prove that the endogenous element regulates Gene X. If CRISPR perturbation reduces Gene X expression compared with non-targeting and inactive-region controls, the result gives stronger support that the element or its contact is involved.

If MPRA is positive but CRISPR perturbation is negative, the reporter effect may not transfer to the endogenous chromatin context. If CRISPR perturbation is positive but MPRA is negative, the endogenous sequence context, chromatin, or three-dimensional organization may be needed for activity. If perturbation has no effect, I would consider redundant enhancers, the wrong cell type or state, another target gene, or a mechanism outside the tested element. I would not treat a negative result as proof that Gene X is unregulated.

### Evidence hierarchy: observation, correlation, and causation

I will separate the results into three levels:

1. Direct observation: what the assay measures in the sampled cells.
2. Correlation or association: a measured feature changes with disease status or Gene X expression, but the direction and cause are unclear.
3. Causal evidence: a perturbation changes Gene X expression in the expected direction, with suitable controls and in the relevant biological context.

| Assay | Direct observation | Reasonable interpretation | Main limitation |
|---|---|---|---|
| RNA-seq | Transcript abundance and isoform usage | Gene X is differentially expressed or processed | It does not explain the cause |
| WGS / WES | DNA sequence and genotype | A variant may be related to the phenotype | A noncoding variant may not regulate Gene X |
| ATAC-seq | Accessible DNA and peak intensity | A region may be regulatory | It does not identify the enhancer, target gene, or cause |
| H3K27ac ChIP-seq / CUT&Tag | Enrichment of an active chromatin mark | A region may be actively regulated | It does not show which gene is controlled |
| WGBS / EM-seq | DNA methylation state | Methylation differs at the region | The difference may be a cause, a consequence, or a marker |
| Hi-C / Micro-C | Contact frequency | The region may contact the Gene X promoter | Contact does not prove function |
| CAGE / RAMPAGE | Promoter or transcription-start-site usage | Promoter or isoform usage differs | It does not explain why the change occurred |
| MPRA | Regulatory activity of a tested sequence | An allele or sequence changes reporter activity | The reporter may not represent the endogenous locus |
| CRISPR perturbation | Effect of editing an endogenous element | The element may be required for Gene X expression | Editing efficiency, controls, redundancy, and cell state affect the conclusion |

An open ATAC-seq peak is not automatically an enhancer. H3K27ac signal can mark active regulatory chromatin, but it does not show that the region controls Gene X. A methylation difference may appear after another regulatory change. A Hi-C or Micro-C contact shows proximity or contact frequency, but not that the contact has a regulatory function. A noncoding WGS or WES association still needs regulatory evidence. MPRA can test allele-dependent activity, but it does not reproduce all aspects of the endogenous chromatin or nuclear organization.

For CRISPRi, enhancer deletion, or loop-anchor perturbation, I would require a targeted perturbation, multiple guides or an independent perturbation when possible, non-targeting and inactive-region controls, the correct cell type and time point, and a readout that measures Gene X directly. Negative results also need careful interpretation because redundant enhancers, an inactive cell state, or incomplete editing can hide a real effect.

---

## 2. AI-assisted workflow

I used the following prompt after writing the plan in Section 1:

> Act as a skeptical genomics methods reviewer. Review my assay order, decision rules, and intended conclusions. Do not rewrite the plan for me. Identify missing controls, likely sources of confounding, conclusions that would be overinterpreted, necessary validation experiments, and any assay that should be moved earlier or later. For each issue, explain what result would change my decision.

The critique was useful because it challenged several assumptions that were easy to miss when the plan was written as a linear sequence. The main points are summarized below.

### Missing controls

The first issue was that replicate samples alone are not enough. I need specific quality and control checks for each assay:

- ATAC-seq needs fragment-size checks, TSS enrichment, FRiP, mitochondrial read fraction, blacklist filtering, and concordance between biological replicates. It does not need an input-DNA control in the same way as ChIP-seq, so I should not simply copy the ChIP control scheme into the ATAC analysis.
- H3K27ac ChIP-seq or CUT&Tag needs input or IgG controls, antibody validation, replicate concordance, and a check for global changes in H3K27ac signal. A spike-in or an equivalent normalization strategy may be needed if the mark changes globally.
- WGBS or EM-seq needs conversion controls, coverage checks, and a way to distinguish a true methylation difference from incomplete conversion or low coverage.
- Hi-C or Micro-C needs checks for restriction-enzyme digestion, ligation efficiency, sequencing depth, and replicate reproducibility. A standard contact map may not have enough resolution to support a specific enhancer-promoter claim, so promoter-focused analysis may be necessary.
- WGS or WES needs sample-contamination checks, coverage summaries, sex checks, and ancestry or population-structure checks if allele frequencies are compared.
- MPRA needs positive and negative regulatory controls, multiple barcodes or replicate measurements, allele-swapped sequences, and controls for transfection and batch effects.
- CRISPRi, enhancer deletion, or loop-anchor perturbation needs non-targeting guides, an inactive or safe-harbor control region, multiple guides when possible, editing or knockdown efficiency measurements, cell-viability checks, and a Gene X-specific readout. A rescue experiment would make the causal claim stronger.

### Confounding

The critique also pointed out that a difference between disease and control groups can come from something other than the proposed regulatory mechanism. Cell composition is a major concern. If the disease samples contain a different mixture of cell types, bulk RNA-seq, ATAC-seq, ChIP-seq, methylation, and Hi-C can all change without any cell-intrinsic regulatory change at Gene X. Cell sorting or single-cell measurements would help, but these are outside the methods listed for this question and would need to be treated as an additional design choice.

Other confounders include age, sex, medication, disease stage, tissue collection time, RNA quality, library batch, sequencing depth, and ancestry. I would match these variables at the design stage and include them in the analysis instead of assuming that matching is perfect.

The RNA-seq result could also have explanations that are not regulatory in the narrow sense. Copy-number changes, transcript stability, isoform usage, or a trans-acting pathway could increase Gene X RNA without changing the nearby chromatin in the expected direction. WGS, CAGE or RAMPAGE, and allele-specific expression analysis could help distinguish some of these possibilities. ATAC-seq and H3K27ac differences may also appear after transcription changes, so direction cannot be inferred from correlation alone.

### Overinterpretation

The AI critique marked several conclusions as too strong for the proposed evidence:

- An ATAC-seq peak can nominate a regulatory region, but it does not show that the region is an enhancer or that it controls Gene X.
- H3K27ac enrichment can support an active chromatin state, but it does not identify the target gene or show that the mark causes expression.
- A methylation difference can be a cause, a consequence, or a marker. Without perturbation, the direction is unknown.
- A Hi-C or Micro-C contact can show proximity or contact frequency, but it does not prove that the contact regulates Gene X.
- A noncoding WGS or WES variant near R can be a candidate, but its annotation or association is not proof of function.
- A positive MPRA result applies to the tested sequence in a reporter system. It does not prove that the same sequence controls Gene X at the endogenous locus.
- A CRISPR perturbation result is stronger, but it can still be affected by incomplete editing, off-target effects, indirect effects, or redundancy. Appropriate controls and a direct readout are necessary.

### Missing validation

The critique suggested several additions that were missing from the first version:

1. Check allele-specific expression in heterozygous samples when a candidate cis-regulatory variant is present.
2. Use CAGE or RAMPAGE if promoter choice or transcription-start-site usage could explain part of the expression difference.
3. Confirm that perturbation changes Gene X expression in the expected direction and that the effect is not caused by a general loss of cell fitness.
4. Use at least one independent perturbation method when possible. For example, if CRISPRi produces an effect, an enhancer deletion or loop-anchor perturbation would provide stronger support.
5. Add a rescue or allele-swap experiment when the goal is to connect a specific variant to Gene X expression.
6. Replicate the key finding in an independent biological sample set if the result is meant to support a general disease mechanism.

### Assay order

The critique did not reject ATAC-seq as the discovery assay, but it suggested several changes to the original order:

- WGS or WES should be generated early because sample collection and sequencing take time, even if variant interpretation waits until R has been defined.
- H3K27ac, methylation, and contact assays should remain in the second stage because their value depends on having a candidate region.
- MPRA should not be automatic for every candidate. It makes the most sense when R contains a sequence variant or when the disease and control sequences differ in a way that can be tested.
- CRISPR perturbation should come after the candidate region and the expected causal mechanism are defined. Running it before that point would make it difficult to interpret a negative result.
- CAGE or RAMPAGE should move earlier if the RNA-seq data show a change in promoter or transcript usage.

### Changes I will make after the critique

I would keep the general order of ATAC-seq discovery followed by mechanism-specific assays and functional testing, but I would add quality-control gates and make several decision points more explicit:

- Check cell composition and sample matching before interpreting any bulk regulatory assay.
- Treat ATAC-seq, H3K27ac, methylation, WGS/WES, and contact data as supporting evidence. A perturbation experiment is needed for a causal claim.
- Add allele-specific expression and, when possible, a second independent perturbation.
- Use negative results to revise the model instead of treating a single failed assay as proof that the mechanism is absent.
- Reserve the word "causal" for a perturbation experiment that changes Gene X expression with adequate controls.

These changes still need to be checked against assay documentation and primary sources. I will do that in Section 3 instead of accepting the AI critique as final.

---

## 3. Verification

I checked the AI critique against official consortium standards, platform documentation, and original method papers. The main conclusions are summarized below. The source numbers refer to the reference list at the end of this section.

| Assay | What it measures | Typical resolution | Input material | Main limitation | Best use in this question | Source |
|---|---|---|---|---|---|---|
| RNA-seq | RNA abundance and sequence | Gene-level quantification; isoform estimates are less reliable | Total RNA, usually with poly(A) selection or rRNA depletion | Expression is not a mechanism; library and analysis choices affect quantification | Confirm Gene X expression and detect promoter or isoform changes | [4] |
| WGS | DNA sequence across the genome | Base-pair variant resolution | Genomic DNA | Requires substantial sequencing and careful variant filtering; association is not function | Detect noncoding, structural, and copy-number changes | [6] |
| WES | DNA sequence in targeted coding regions | Base-pair variant resolution within captured regions | Genomic DNA plus exome capture | Misses most noncoding regulatory sequence | Test coding or exome-focused hypotheses | [7] |
| ATAC-seq | Accessible DNA | Read ends are base-pair level; peaks are usually hundreds of base pairs, with nucleosome information from fragment size | Nuclei or cells, with lower input than many ChIP assays | Open chromatin does not identify the enhancer, target gene, transcription factor, or cause | Find candidate regulatory regions near Gene X | [1] |
| H3K27ac ChIP-seq | Enrichment of the H3K27ac histone mark | Usually hundreds of base pairs to broader domains, depending on the mark and analysis | Chromatin, validated antibody, and input or IgG control | Mark enrichment does not prove target-gene regulation | Test for active enhancer-associated chromatin | [2] |
| CUT&Tag and CUT&RUN | Protein-DNA binding or histone-mark enrichment | Similar target resolution to ChIP-seq, with high signal-to-noise and low input | Cells or nuclei, antibody or fusion protein, and controls | Lower input does not remove antibody, epitope, or normalization concerns | Use when material is limited or a lower-background profile is needed | [2][9][10] |
| WGBS | DNA methylation at CpG sites | Single-base CpG resolution | Genomic DNA; bisulfite conversion degrades DNA | Low coverage, incomplete conversion, or cell mixtures can create false differences | Measure methylation at region R | [3] |
| EM-seq | DNA methylation at CpG sites | Single-base CpG resolution | Genomic DNA converted enzymatically instead of by bisulfite | Still coverage dependent, and the same causal limitations apply | Measure methylation when DNA input or degradation is a concern | [8] |
| CAGE and RAMPAGE | 5' ends of capped RNA and transcription start sites | Base-pair TSS resolution | RNA, usually poly(A)+ or rRNA-depleted material; ENCODE expects 20 million aligned reads per replicate and a matching RNA-seq control | Measures promoter or TSS usage; it does not measure enhancer activity or causality | Test promoter choice, alternative TSSs, or transcript usage | [5] |
| Hi-C | Contact frequency between genomic regions | Often kilobase to megabase scale, depending on depth and library | Intact nuclei or cells, crosslinking, restriction digestion, ligation, and deep sequencing | Contact is not function; resolution and cell composition can limit interpretation | Test whether region R contacts the Gene X promoter | [11][12] |
| Micro-C | Contact frequency with higher resolution than standard Hi-C | Higher-resolution contact maps, with nucleosome-scale information in suitable systems | Similar starting material and library workflow, often with deep sequencing | Higher resolution does not by itself prove regulatory causality | Resolve contacts that are unclear in standard Hi-C | [12] |
| MPRA | Regulatory activity of a tested DNA sequence | One measurement per tested element or allele | A synthesized reporter library, suitable cells, and internal controls | The reporter context does not reproduce all endogenous chromatin or nuclear organization | Compare disease and control alleles from region R | [13] |
| CRISPRi or CRISPR perturbation | Expression change after targeted perturbation | Guide-level targeting; effective region can range from a local regulatory element to a larger deletion | Cells that can be edited or repressed, delivery system, controls, and efficiency measurements | Off-target effects, incomplete perturbation, cell fitness, and enhancer redundancy can affect the result | Test whether region R or its contact is required for Gene X expression | [14][15] |

The ENCODE standards also changed two details in my original plan. ATAC-seq requires biological replicates and reports TSS enrichment, FRiP, read depth, fragment-length features, and replicate concordance; it does not use an input-DNA control in the way ChIP-seq does [1]. For histone ChIP-seq, ENCODE expects antibody characterization, an input or IgG control with matched run type and replication structure, and different sequencing depths for narrow and broad marks [2]. H3K27ac is treated as a broad histone mark in the ENCODE standard, so I should not use a narrow-peak depth assumption for it.

The methylation standards supported the AI's concern about conversion and coverage. ENCODE recommends 30X coverage per replicate for WGBS, a minimum read length of 100 bp, and a conversion rate of at least 98% [3]. EM-seq uses enzymatic conversion and can work from lower amounts of DNA, but coverage and cell-composition issues remain [8].

The RNA and promoter assays changed how I would interpret the final expression result. Bulk RNA-seq gives reasonably reliable gene-level quantification, while isoform estimates are more dependent on the analysis pipeline [4]. CAGE and RAMPAGE give base-pair information about transcription start sites, but they do not replace RNA-seq or prove that an enhancer is causal [5].

For contact assays, the 4D Nucleome portal describes Hi-C data as maps of 3D genome organization [11]. Micro-C improves contact-map resolution, but the original mammalian study also makes clear that the interpretation depends on the experimental system and resolution [12]. The AI's suggestion to use promoter-focused analysis is therefore reasonable when the question is about one enhancer-promoter pair. Standard Hi-C may not have enough resolution or depth to answer that question by itself.

The MPRA literature supports testing sequence-dependent regulatory activity, not endogenous target-gene regulation [13]. The same limitation applies to allele-swapped reporter libraries. CRISPRi and related perturbations give stronger causal evidence because they act on an endogenous locus, but the original CRISPRi studies still require efficient targeting and careful controls [14][15].

### AI suggestions I accepted

- I accepted the assay-specific quality-control requests for ATAC-seq, ChIP-seq or CUT&Tag, WGBS or EM-seq, Hi-C or Micro-C, MPRA, and CRISPR. The ENCODE standards and original method papers support the need for replication, assay quality metrics, controls, and reproducibility checks.
- I accepted that WGS or WES can be generated early, but their interpretation should wait until ATAC-seq or another discovery assay has identified candidate regions.
- I accepted that cell composition, sample matching, batch effects, and tissue quality are major confounders for every bulk assay.
- I accepted that H3K27ac, methylation, contact, and sequence evidence are supporting observations. A perturbation experiment is needed if I want to use the word "causal."
- I accepted the suggestion to run CAGE or RAMPAGE earlier when the RNA-seq data suggest a promoter or transcript-usage change.
- I accepted the suggestion to use MPRA only when there is a testable sequence or allele hypothesis. Running it by default would not answer the epigenetic part of the question.

### AI suggestions I accepted with qualifications

- Spike-in or equivalent normalization can be useful for H3K27ac when global changes are plausible, but it is not required in every ChIP-seq experiment. ENCODE requires input or IgG controls and antibody characterization; spike-in can be useful, but it is not the only valid normalization method.
- Promoter-focused Hi-C or Micro-C analysis can help with a specific enhancer-promoter question, but it does not prove function. A contact result still needs perturbation.
- WGS population-structure checks matter when allele frequencies or genotype-phenotype associations are compared. They are less relevant if the analysis is limited to a known candidate variant, although ancestry can still affect frequency interpretation.
- Rescue or allele-swap experiments make a causal claim stronger, but they are not always feasible in the available cell model. They are an additional level of evidence when feasible, not an absolute requirement.
- Independent sample replication is scientifically useful, but the assignment does not provide a second real cohort. It should be listed as a limitation or future validation step, not invented as part of the data.

### AI suggestions I rejected or corrected

- I rejected the idea that ATAC-seq needs the same input-DNA control scheme as ChIP-seq. ENCODE's ATAC-seq standard uses replicate and signal-quality metrics instead [1].
- I rejected the idea that every candidate region must go through MPRA. MPRA is most useful for sequence or allele comparisons, and it cannot replace an endogenous perturbation [13].
- I rejected the idea that one CRISPR guide is enough to establish causality. Multiple guides when possible, targeting efficiency, viability controls, and a direct Gene X readout are needed [14].
- I rejected the idea that a WGS or WES association, an active chromatin mark, a methylation difference, or a 3D contact can by itself prove that region R regulates Gene X.
- I corrected the original order so that WGS or WES data can be generated early, but variants are prioritized only after a candidate region exists.
- I rejected the interpretation that a negative perturbation result rules out the mechanism. Redundant enhancers, incomplete editing, the wrong cell state, or insufficient assay sensitivity can all produce a negative result.

### References

1. ENCODE. "ATAC-seq Data Standards and Processing Pipeline (ENCODE4)." https://www.encodeproject.org/data-standards/atac-seq/atac-encode4/ (accessed 2026-09-19).
2. ENCODE. "Histone ChIP-seq Data Standards and Processing Pipeline (ENCODE 4)." https://www.encodeproject.org/chip-seq/histone-encode4/ (accessed 2026-09-19).
3. ENCODE. "Whole-Genome Bisulfite Sequencing Data Standards and gemBS-based Processing Pipeline." https://www.encodeproject.org/data-standards/wgbs-encode4/ (accessed 2026-09-19).
4. ENCODE. "Bulk RNA-seq Data Standards and Processing Pipeline." https://www.encodeproject.org/data-standards/encode4-bulk-rna/ (accessed 2026-09-19).
5. ENCODE. "RAMPAGE and CAGE Data Standards and Processing Pipeline." https://www.encodeproject.org/data-standards/rampage/ (accessed 2026-09-19).
6. Illumina. "Whole-Genome Sequencing (WGS)." https://www.illumina.com/techniques/sequencing/dna-sequencing/whole-genome-sequencing.html (accessed 2026-09-19).
7. Illumina. "Whole Exome Sequencing." https://www.illumina.com/techniques/sequencing/dna-sequencing/targeted-resequencing/exome-sequencing.html (accessed 2026-09-19).
8. Vaisvila, R., et al. "Enzymatic methyl sequencing detects DNA methylation at single-base resolution from picograms of DNA." Genome Research 31, 1280-1289 (2021). https://doi.org/10.1101/gr.266551.120.
9. Kaya-Okur, H. S., et al. "CUT&Tag for efficient epigenomic profiling of small samples and single cells." Nature Communications 10, 1930 (2019). https://doi.org/10.1038/s41467-019-09982-5.
10. Skene, P. J., and Henikoff, S. "An efficient targeted nuclease strategy for high-resolution mapping of DNA binding sites." eLife 6, e21856 (2017). https://doi.org/10.7554/eLife.21856.
11. 4D Nucleome Program. "Understand 4D DNA Organization" and 4DN Data Portal. https://www.4dnucleome.org/ and https://data.4dnucleome.org/ (accessed 2026-09-19).
12. Krietenstein, N., et al. "Ultrastructural Details of Mammalian Chromosome Architecture." Molecular Cell 78, 554-565.e7 (2020). https://doi.org/10.1016/j.molcel.2020.03.003.
13. Kheradpour, P., et al. "Systematic dissection of regulatory motifs in 2000 predicted human enhancers using a massively parallel reporter assay." Genome Research 23, 800-811 (2013). https://doi.org/10.1101/gr.144899.112.
14. Qi, L. S., et al. "Repurposing CRISPR as an RNA-guided platform for sequence-specific control of gene expression." Cell 152, 1173-1183 (2013). https://doi.org/10.1016/j.cell.2013.02.022.
15. Gilbert, L. A., et al. "CRISPR-mediated modular RNA-guided regulation of transcription in eukaryotes." Cell 154, 442-451 (2013). https://doi.org/10.1016/j.cell.2013.06.044.

---

## 4. Final conclusion

![Q1 assay workflow](figures/Q1_workflow.png)

**Workflow figure:** `figures/Q1_workflow.png`  
**Vector source:** `figures/Q1_workflow.svg`

**Approximately 200-word explanation:**

I would confirm the RNA-seq result, then compare disease and control chromatin with ATAC-seq. RNA-seq shows that Gene X is upregulated but not why. ATAC-seq nominates candidate regions and helps order the next assays. WGS or WES tests nearby DNA variants; H3K27ac CUT&Tag tests active chromatin; WGBS or EM-seq tests methylation; Hi-C or Micro-C tests contact; CAGE or RAMPAGE tests promoter and TSS use.

None proves causality alone. An ATAC peak may be inactive. A variant near R can be present without causing the expression change. WGS and WES describe sequence, not function. H3K27ac, methylation, and contact can track expression, but they do not show which change came first. A contact can also exist without controlling Gene X. MPRA tests sequence activity only in a reporter, and CAGE or RAMPAGE do not test enhancer function.

These assays complement one another. ATAC-seq finds R; sequence and chromatin data test whether R fits the mechanism; contact and promoter data connect R to Gene X. MPRA tests allele activity, while CRISPRi, deletion, or loop perturbation tests whether R is required for Gene X expression. I would call the mechanism causal only when a controlled perturbation changes Gene X in the expected direction.

> The biological question chooses the assay because the hypothesis determines whether I need to discover a region, test a regulatory layer, or prove that an element changes Gene X expression.

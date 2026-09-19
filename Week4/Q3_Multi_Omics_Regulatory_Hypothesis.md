# Q3 - Integrate Multi-Omics Evidence into a Regulatory Hypothesis

**Name:**

**Student ID:**

**Date:**

---

## 1. Reasoning before AI

The candidate is an upstream region of Gene Y. The available layers are ATAC-seq, H3K27ac ChIP-seq or CUT&Tag, DNA methylation, Hi-C or Micro-C, and RNA-seq from the same biological condition. The assignment does not include a numerical track table, so I will not pretend that the exact peak height or contact frequency is known. I will use a consistent working pattern for the discussion: the candidate region has a reproducible ATAC signal, H3K27ac enrichment relative to input, low CpG methylation, a stronger than local-background contact with the Gene Y promoter, and Gene Y is expressed in the same cell type. The final conclusion will remain a hypothesis until a perturbation is done.

I am treating the cell type as already defined and assuming that all samples have biological replicates. If the original data come from a bulk tissue with several cell populations, the interpretation changes because ATAC, H3K27ac, methylation, and contact signals can all reflect a shift in cell composition.

### Layer-by-layer reading

| Layer | Direct observation | Biological interpretation | Missing evidence |
|---|---|---|---|
| ATAC-seq | The candidate region contains an accessible peak. The peak is reproducible and is not a blacklist region. | The DNA is accessible in this condition. It may be a promoter, enhancer, insulator, or another regulatory element. | Accessibility does not identify the target gene, the transcription factors, or causality. Controls may also expose a cell-composition effect. |
| H3K27ac ChIP-seq or CUT&Tag | The candidate region is enriched for H3K27ac relative to input and a matched inactive region. | The region has an active chromatin state, which is compatible with an active enhancer. | H3K27ac does not show which gene is controlled, and it cannot separate a causal enhancer from a region that changed after transcription. |
| DNA methylation | CpG methylation across the candidate region is low, or lower than at a matched control region. | Hypomethylation is compatible with regulatory activity. | The observation is associative. Methylation may change after another regulator acts, and bulk data can hide allele or cell-type-specific patterns. |
| Hi-C or Micro-C | The candidate region contacts the Gene Y promoter more often than expected from local background. | The region and promoter occupy the same contact domain and may have a regulatory connection. | Contact frequency is not enhancer function. Resolution, read depth, cell mixture, and transcription can all affect the signal. |
| RNA-seq | Gene Y is expressed, and its transcript level is higher in the condition under study. | Gene Y is active and may be affected by the candidate region. | Expression alone does not show direction, target specificity, or whether another enhancer or a trans-acting factor is responsible. |

### Preliminary integrated model

The layers fit a plausible enhancer model if the ATAC peak, H3K27ac signal, low methylation, and Gene Y promoter contact occur in the same cell type and at the same time as the increase in Gene Y RNA. In that model, the candidate element would be accessible, carry an active chromatin mark, have little methylation, and sit in contact with the promoter. The model is still correlative. A regulatory region can be active and still control a different gene, and a promoter contact can be present without detectable regulatory activity.

The evidence would become less convincing if the contact disappears after promoter-focused analysis, if the H3K27ac signal is explained by a nearby promoter, if methylation is high across most CpGs, or if the ATAC peak is present in both conditions while Gene Y expression differs. A conflict between layers is useful. It usually means that the simple enhancer model is incomplete or that a technical factor is affecting one assay.

### Open questions and conflicts

1. Does the contact persist when the analysis focuses on the promoter and the candidate element instead of a broad contact map?
2. Is the H3K27ac signal enhancer-like in the same cell type, or is it coming from a promoter or another annotated element?
3. Are the ATAC and H3K27ac differences present in the same cells, or do they reflect a change in cell composition?
4. Is there a DNA variant, allele-specific accessibility, or allele-specific expression that links the candidate sequence to Gene Y?
5. Could the candidate region regulate a nearby gene while Gene Y changes through another enhancer, a trans-acting factor, or a post-transcriptional mechanism?
6. Would a perturbation of the candidate region change Gene Y expression, or is the region redundant?

---

## 2. AI-assisted workflow

I used this prompt after writing the layer table:

> Act as a skeptical regulatory genomics reviewer. Separate the evidence for this candidate region into direct observations, biological interpretations, and missing evidence. Check whether I have mixed an assay result with a conclusion about Gene Y. Identify the strongest alternative explanation and the controls needed to distinguish correlation from causality. Do not tell me that the region is an enhancer unless the evidence actually supports that claim.

The useful part of the response was the classification check. It made me move several statements out of the observation column. For example, "the region is an enhancer" is an interpretation, while "the region has an ATAC peak and H3K27ac enrichment" is an observation. The same distinction applies to methylation and contact. A low methylation value is an observation. "Methylation activates Gene Y" is not supported by the data.

The AI also pointed out that the current evidence does not show that Gene Y is the target. A region can be active, contact a promoter, and still have little measurable effect on transcription. My first model treated the contact as stronger evidence than it deserves. Contact maps show physical proximity and frequency, not the regulatory consequence of that contact.

Several proposed controls were accepted:

- Use replicate concordance, fragment-size checks, TSS enrichment, FRiP, and blacklist filtering for ATAC-seq.
- Use input or IgG controls, antibody validation, and a spike-in or another justified normalization strategy for H3K27ac.
- Use conversion controls and report CpG coverage for methylation data.
- Check contact-map resolution, ligation or digestion quality, and replicate agreement before interpreting a promoter contact.
- Measure Gene Y directly at RNA and nascent-transcript levels after perturbation.
- Use more than one independent perturbation when possible.

The AI also made a few suggestions that I would not accept as written:

- It treated hypomethylation as evidence that the element is active. Methylation and activity often correlate, but the direction of the relationship is not settled by this dataset.
- It implied that a Hi-C or Micro-C contact proves a functional enhancer-promoter link. Contact alone is weaker than that.
- It suggested that a positive MPRA would confirm the endogenous enhancer. MPRA measures a sequence in a reporter context and cannot establish the endogenous target gene by itself.
- It treated a negative CRISPR result as evidence that the element has no function. Redundant enhancers, poor editing, the wrong cell state, or an insensitive readout can all produce a negative result.

I would keep the model, add the missing controls, and reserve the word causal for a perturbation that changes Gene Y with the expected controls. The alternative explanation below must remain visible throughout the analysis.

---

## 3. Verification

I checked the main claims against consortium standards, method papers, and primary studies. The references are listed at the end of this section.

| Claim to check | What the source supports | My decision |
|---|---|---|
| ATAC-seq measures accessible DNA, not enhancer identity | ENCODE describes ATAC-seq as a measure of open chromatin and expects signal-quality metrics, replicates, and fragment information. An open peak can overlap different regulatory classes. | Accept. Keep ATAC as evidence for accessibility only. |
| H3K27ac marks active chromatin and is commonly enriched at active enhancers | ENCODE histone ChIP-seq standards and Roadmap analyses support H3K27ac as an active chromatin mark. They do not identify the target gene. | Accept, but do not treat the mark as a target-gene assay. |
| DNA methylation is associated with regulatory state, but the direction is context dependent | ENCODE WGBS standards and the EM-seq paper support single-base methylation measurement. They do not show that a methylation change causes the expression change. | Accept the measurement, reject the causal wording. |
| Hi-C and Micro-C report contact frequency and 3D organization | The 4D Nucleome resources and the Micro-C study describe contact maps at different resolutions. A contact is not a functional test. | Accept for physical-contact evidence. Use promoter-focused analysis if resolution allows. |
| Gene Y expression is required for the hypothesis but is not causal evidence | RNA-seq quantifies RNA abundance. It cannot separate direct regulation from downstream or post-transcriptional effects. | Accept as a phenotype and readout, not as proof of regulation. |
| MPRA can test sequence-dependent regulatory activity | The ENCODE MPRA resources and the Kheradpour study show that reporter libraries can compare regulatory sequences or alleles. The assay does not reproduce the full endogenous locus. | Use as an allele or sequence test. Do not call it a definitive target-gene test. |
| CRISPRi and enhancer deletion can test an endogenous element | CRISPRi studies and enhancer-perturbation work show that targeted perturbation can connect a regulatory element to a gene, but controls and effective targeting are required. | Use as the main causal experiment, with non-targeting and inactive-region controls. |

The AI was right that the evidence should be separated into observation, interpretation, and missing evidence. It was wrong to make a causal claim from a methylation pattern or a contact map. A useful test of the model is whether several independent lines of evidence point in the same direction and whether perturbation changes Gene Y. Agreement among assays strengthens the hypothesis, but it does not replace the perturbation.

### References

1. ENCODE. "ATAC-seq Data Standards and Processing Pipeline (ENCODE4)." https://www.encodeproject.org/data-standards/atac-seq/atac-encode4/ (accessed 2026-09-19).
2. ENCODE. "Histone ChIP-seq Data Standards and Processing Pipeline (ENCODE 4)." https://www.encodeproject.org/chip-seq/histone-encode4/ (accessed 2026-09-19).
3. Roadmap Epigenomics Consortium. "Integrative analysis of 111 reference human epigenomes." Nature 518, 317-330 (2015). https://doi.org/10.1038/nature14248.
4. ENCODE. "Whole-Genome Bisulfite Sequencing Data Standards and gemBS-based Processing Pipeline." https://www.encodeproject.org/data-standards/wgbs-encode4/ (accessed 2026-09-19).
5. Vaisvila, R., et al. "Enzymatic methyl sequencing detects DNA methylation at single-base resolution from picograms of DNA." Genome Research 31, 1280-1289 (2021). https://doi.org/10.1101/gr.266551.120.
6. 4D Nucleome Program. Data Portal and Hi-C resources. https://data.4dnucleome.org/ (accessed 2026-09-19).
7. Krietenstein, N., et al. "Ultrastructural Details of Mammalian Chromosome Architecture." Molecular Cell 78, 554-565.e7 (2020). https://doi.org/10.1016/j.molcel.2020.03.003.
8. Kheradpour, P., et al. "Systematic dissection of regulatory motifs in 2000 predicted human enhancers using a massively parallel reporter assay." Genome Research 23, 800-811 (2013). https://doi.org/10.1101/gr.144899.112.
9. Fulco, C. P., et al. "Activity-by-contact model of enhancer-promoter regulation from thousands of CRISPR perturbations." Nature Genetics 51, 1664-1669 (2019). https://doi.org/10.1038/s41588-019-0538-0.
10. Gasperini, M., et al. "A Genome-wide Framework for Mapping Gene Regulation via Cellular Genetic Screens." Cell 176, 377-390.e19 (2019). https://doi.org/10.1016/j.cell.2018.11.029.

---

## 4. Final conclusion

![Q3 integrated locus chain](figures/Q3_locus_chain.png)

**Vector source:** `figures/Q3_locus_chain.svg`

### Alternative explanation

The strongest alternative is that the candidate region is an active regulatory element, but its main target is another nearby gene. The contact with the Gene Y promoter could reflect a shared topologically associating domain, while Gene Y expression changes because of a different enhancer or a trans-acting factor. The layers would still look compatible because an accessible, H3K27ac-marked, hypomethylated region can contact several promoters. The model would fail if perturbing the candidate region did not change Gene Y while another gene did change.

### Functional experiment

I would use CRISPRi against the candidate region as the main perturbation, with several guides where possible. I would also include an enhancer deletion if the cell system allows it. Non-targeting guides, an inactive nearby region, and a promoter control would be necessary. I would measure Gene Y RNA by RT-qPCR and RNA-seq, check nascent transcription if possible, and repeat ATAC and H3K27ac measurements after perturbation.

If the candidate region is causal, CRISPRi or deletion should reduce Gene Y expression and reduce the promoter contact in the treated cells. If the alternative is true, Gene Y should remain unchanged or the nearby alternative target should change instead. A negative result would need a check of editing or knockdown efficiency before it could be interpreted.

### Integrated interpretation, about 200 words

The candidate region is a plausible enhancer because it has several features expected at an active regulatory element. It is accessible in ATAC-seq, carries H3K27ac, has low CpG methylation, and contacts the Gene Y promoter while Gene Y is expressed. Each layer adds one part of the model. ATAC shows that the DNA can be reached by regulatory proteins. H3K27ac shows an active chromatin state. Methylation gives a second view of regulatory potential. Hi-C or Micro-C links the region to the promoter, and RNA-seq confirms that Gene Y is active.

The same evidence does not show that the region controls Gene Y. An accessible peak can be inactive, H3K27ac can mark a regulatory element for another gene, methylation can change after transcription, and contact can occur without a measurable regulatory effect. The strongest alternative is that the region regulates a nearby gene while Gene Y changes through another mechanism. A controlled CRISPRi or deletion experiment would separate these models. The causal claim would require reduced Gene Y expression and a changed promoter contact after perturbation, with the same cell type and appropriate controls. The perturbation must also be checked for efficient targeting and a specific effect on the candidate element.

> The candidate element regulates Gene Y by acting as an accessible, H3K27ac-marked, hypomethylated enhancer that contacts the Gene Y promoter and supports transcription; this can be tested by CRISPRi and enhancer deletion with Gene Y expression and promoter-contact readouts.

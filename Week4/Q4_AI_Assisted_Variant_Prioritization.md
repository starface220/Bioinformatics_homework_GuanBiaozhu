# Q4 - AI-Assisted Variant Prioritization

**Name:**

**Student ID:**

**Date:**

---

## Data note

I used `variants_q4.tsv` as supplied. The README says that the coordinates, gene annotations, ClinVar-style labels, and VCV identifiers are synthetic teaching values. I will therefore use those fields as the input evidence for the exercise, but I will not treat the VCV identifiers as real database records or submit them anywhere as clinical data.

The table does not include a disease phenotype, inheritance pattern, sample ancestry, sex, tumor content, transcript identifier, or variant validation status. Those missing fields affect the final interpretation. My ranking below is a prioritization for further investigation, not a diagnosis.

---

## 1. Reasoning before AI

### Filtering logic before AI

| Criterion | My rule | Reason |
|---|---|---|
| `FILTER` | Hard requirement: keep `PASS` only | A failed or low-quality call should not reach the top of a candidate list without orthogonal evidence |
| Depth, `DP` | `DP >= 20` | A genotype needs enough reads to support the allele call. I would use a higher threshold for clinical reporting, but 20 gives a reasonable first-pass floor for this exercise |
| Genotype quality, `GQ` | `GQ >= 30` | This removes genotypes with very weak support. It is a screening rule, not proof that the call is correct |
| Population frequency, `AF` | `AF <= 0.01` for a rare-disease hypothesis | Common variants are less likely to explain a rare, highly penetrant phenotype. The threshold would change for a common-disease or pharmacogenomic question |
| Consequence | Rank high-impact annotations above moderate ones | Splice acceptor, splice donor, stop-gained, and frameshift annotations can have direct effects on a transcript. Missense and synonymous labels need more context |
| Clinical annotation | Use as supporting evidence after technical filtering | A `Pathogenic` label cannot rescue a low-quality call, and a VUS should not be discarded only because the word "uncertain" appears |
| Gene and phenotype | Rank genes that fit the disease mechanism | This table has no phenotype, so this criterion can only be recorded as missing information |
| Transcript context | Keep transcript identity as a verification requirement | A splice annotation depends on the transcript model and genomic context |

Hard excludes:

- `FILTER` values other than `PASS`.
- `DP < 20` or `GQ < 30`.
- `AF > 0.01` for the rare-variant part of this exercise.
- Strongly benign or likely benign annotations when the question is to find a disease-relevant candidate.
- Variants with no plausible target gene, unless there is a separate noncoding hypothesis.

Soft ranks:

- Rare high-impact variants rank above rare missense or synonymous variants.
- Pathogenic or likely pathogenic evidence ranks above conflicting evidence and VUS.
- A technically clean VUS can remain as a second candidate, but it should not be ranked with the same confidence as a high-quality Pathogenic splice variant.
- Gene-disease relationship and phenotype match would outrank a generic database label if those data were available.

### First-pass result

| Variant | Technical result | Consequence and evidence | My initial rank |
|---|---|---|---|
| `chr17:7673803 G>A`, TP53 | PASS, DP 80, GQ 99, AF 0.00001 | splice acceptor, Pathogenic | Primary candidate |
| `chr13:32316461 C>T`, BRCA2 | PASS, DP 60, GQ 90, AF 0.0001 | missense, VUS | Provisional second candidate |
| `chr12:25398284 C>A`, KRAS | PASS, DP 58, GQ 91, AF 0.00015 | missense, conflicting interpretations | Conditional backup |
| `chr7:117199644 C>T`, CFTR | PASS, DP 70, GQ 99, AF 0.00005 | synonymous, Benign | Not prioritized |
| `chr19:11200200 C>T`, LDLR | PASS, DP 40, GQ 88, AF 0.0002 | missense, Likely benign | Not prioritized |
| `chr2:47641560 A>G`, MSH2 | LowQual, DP 8, GQ 12 | stop gained, Pathogenic | Fails technical filter |
| `chrX:153870000 G>A`, MECP2 | PASS, DP 5, GQ 20 | frameshift, Pathogenic | Fails technical filter |

The other variants fail at least one hard rule. F5 and ATM have common population-style frequencies. HLA-A has `FILTER=FAIL` and lies in the MHC region. The intergenic and intronic rows lack a clear target-gene hypothesis, and the intronic row also has a high frequency.

My first choice before AI is TP53. My provisional second choice is BRCA2 because it passes the technical and frequency filters, although the missense consequence and VUS label make it weaker. I would keep KRAS as a conditional alternative because conflicting interpretations are a reason to investigate, not a reason to accept the variant.

---

## 2. AI-assisted workflow

I used a plan-first prompt so the ranking logic would be visible before any code was written:

> Plan a reproducible prioritization workflow for a synthetic germline variant table. Start with technical filtering, then population frequency, consequence, clinical evidence, and gene or phenotype relevance. Explain why each filter is used and what it cannot prove. Keep high-impact variants with poor technical support separate from variants that pass technical filters. Do not treat the ClinVar-style labels as final truth.

After the plan was reviewed, I asked for a second pass:

> Now act as a skeptical reviewer. Give the strongest reasons the top variant could be a false lead. Focus on transcript annotation, synthetic database fields, missing phenotype, inheritance, sample context, and the difference between a technical call and a disease-causing variant.

### AI recommendations and my response

| AI recommendation | My response |
|---|---|
| Apply `FILTER == PASS`, `DP >= 20`, `GQ >= 30`, and `AF <= 0.01` before ranking | Accepted for this exercise. I would adjust the depth and frequency thresholds after the phenotype and sequencing context are known |
| Rank high-impact consequences above missense and synonymous variants | Accepted. This is a ranking rule, not a claim that every high-impact annotation causes disease |
| Use the ClinVar-style field to support the ranking | Accepted with a limit. The labels are synthetic, and a real classification would need the current record, review status, transcript, condition, and inheritance data |
| Drop every VUS | Modified. A technically strong rare VUS can remain as a second candidate because further evidence may change its interpretation |
| Drop variants with conflicting classifications | Rejected. Conflicting evidence is a reason to inspect the variant and the source records |
| Treat a Pathogenic label as enough to prioritize the variant | Rejected. MSH2 and MECP2 have severe labels but fail depth and genotype-quality filters |
| Use one fixed threshold for all consequences | Modified. Splice, coding, and noncoding variants need different review logic |
| Ignore gene and phenotype relevance | Rejected in principle, but the table does not provide a phenotype, so I recorded this as a missing variable |

### False-lead critique

The AI's strongest warning was that the TP53 variant could be a false lead because the table gives no independent confirmation of the call, no transcript identifier, no phenotype, and no inheritance data. The VCV identifier is a teaching placeholder, so the Pathogenic label cannot be independently verified from this table alone.

The critique also pointed out that a splice-acceptor annotation could be transcript-specific or based on a noncanonical junction. Without the reference transcript and read-level inspection, I cannot know which exon is affected or whether the transcript is expressed in the relevant tissue. If the sample came from a tumor, the population-style AF field would also not replace tumor variant allele fraction, purity, or ploidy.

The most important technical risks are different for the lower-ranked variants. MSH2 and MECP2 may be real pathogenic calls with poor support in this synthetic table. They should be reviewed at the read level or tested with another method before being dismissed. BRCA2 and KRAS need transcript-level and clinical-context review because their labels do not provide a direct functional conclusion.

---

## 3. Verification

I checked the filtering logic against resources that define variant classification, population frequency, transcript consequence, and gene-disease evidence. The source numbers refer to the reference list below.

| Claim or recommendation | Verification | Final decision |
|---|---|---|
| `PASS` means the variant is real or clinically important | ClinVar distinguishes a submitted classification from diagnostic truth, and a variant can require clinical context and review [1][2] | Rejected. Treat `PASS` as a technical filter result only |
| A Pathogenic label should outrank the technical measurements | The ACMG/AMP framework combines multiple evidence types and includes phenotype and inheritance context [5] | Modified. A high-quality call and the consequence rank first, then clinical evidence is reviewed |
| Very low AF proves pathogenicity | Population databases help estimate how rare a variant is, but frequency alone does not assign a disease mechanism [3] | Rejected. Use AF as a filter, not as proof |
| A common variant cannot be involved in any disease | Common variants can contribute to complex traits or pharmacogenomic phenotypes [3] | Qualified. `AF > 0.01` is a rare-disease filter for this assignment, not a universal rule |
| A `splice_acceptor_variant` annotation is sufficient to conclude that splicing is disrupted | VEP consequence labels depend on the transcript and predicted event [4] | Modified. Require the correct transcript, junction context, and RNA or minigene evidence |
| A stop-gained or frameshift call should always be prioritized | The consequence can be severe, but low depth and low `GQ` still raise the chance of a technical false call | Accepted with technical gating. MSH2 and MECP2 do not pass the first pass |
| ClinGen can classify the variant | ClinGen describes gene-disease validity and expert evidence resources, but a gene-disease relationship does not assign every variant in that gene [6] | Modified. Use it as gene-level context, not variant-level proof |
| A VUS should be ignored | A VUS means the available evidence is insufficient for a classification, not that the variant is benign [1][2] | Accepted. Keep BRCA2 as a lower-confidence second candidate |
| The TP53 VCV identifier can be checked directly | The README states that the identifiers are synthetic | Rejected. Do not query or submit the placeholder as a patient record |

### Ranking after verification

I will carry one primary variant and one lower-confidence second candidate into further review:

1. **Primary:** `chr17:7673803 G>A` in TP53. It passes every technical and frequency filter and has the strongest consequence label in the table. The interpretation still depends on the correct transcript and a real clinical record.
2. **Secondary:** `chr13:32316461 C>T` in BRCA2. It passes the technical filters and is rare, but it is a missense VUS. It is worth review only if the phenotype and inheritance pattern fit BRCA2.

I would keep `chr12:25398284 C>A` in KRAS as a conditional alternative because the classification is conflicting. I would not carry the low-depth MSH2 or MECP2 rows into the primary list without read-level review or an orthogonal assay.

### Sources checked on 19 September 2026

1. NCBI. [ClinVar](https://www.ncbi.nlm.nih.gov/clinvar/).
2. NCBI. [ClinVar data and classification documentation](https://www.ncbi.nlm.nih.gov/clinvar/docs/).
3. Broad Institute. [gnomAD population frequency database](https://gnomad.broadinstitute.org/).
4. Ensembl. [Variant Effect Predictor consequences](https://www.ensembl.org/info/genome/variation/prediction/predicted_data.html).
5. Richards, S., et al. Standards and guidelines for the interpretation of sequence variants. *Genetics in Medicine* 17, 405-424 (2015). https://doi.org/10.1038/gim.2015.30.
6. ClinGen. [Clinical Genome Resource](https://clinicalgenome.org/).
7. NCBI. [RefSeq transcript and genome annotation resources](https://www.ncbi.nlm.nih.gov/refseq/).

---

## 4. Final conclusion

![Q4 variant prioritization workflow](figures/Q4_prioritization_workflow.png)

**Prioritization figure:** `figures/Q4_prioritization_workflow.png`

**Vector source:** `figures/Q4_prioritization_workflow.svg`

**Supporting files:** `Q4_variant_filter.R` contains the same first-pass thresholds and ranking logic. `Q4_shortlist.tsv` records the three variants that pass the first pass before the final manual ranking.

The script was run with R 4.4.3. Its output order was TP53 with a priority score of 13, BRCA2 with 9, and KRAS with 7. The TSV format changed `0.00001` and `0.0001` to `1e-05` and `1e-04`, but these are the same values used in the tables above.

**Approximately 200-word final interpretation:**

Known evidence: the TP53 row is PASS, DP 80, GQ 99, AF 0.00001, a splice-acceptor annotation, and a Pathogenic-style label. BRCA2 is PASS, DP 60, GQ 90, AF 0.0001, missense, and VUS. These labels are synthetic, and the placeholder VCV identifiers cannot be treated as verified records. Computational inference: TP53 passes all technical and frequency gates and has the strongest consequence. BRCA2 passes the same technical gates but has weaker consequence and clinical evidence. MSH2 and MECP2 fail depth or genotype quality despite severe annotations, so they need technical review before biological interpretation.

The scientific hypothesis is that the TP53 change alters normal exon joining, perhaps by causing exon skipping or intron retention, and changes TP53 function. The BRCA2 missense variant could alter protein function, but that is less specific. The required experiment is orthogonal DNA confirmation followed by RT-PCR across the affected junction and Sanger or long-read sequencing of the transcript. If RNA is unavailable, a minigene assay can test the splice effect. Phenotype match, inheritance, and a functional assay are still needed before calling either variant clinically relevant. Controls should show that the assay reads the intended transcript, not a different isoform, and should confirm the DNA change independently.

> Variant chr17:7673803 G>A may influence TP53 transcript processing by affecting a canonical splice acceptor; this can be tested by RT-PCR across the affected junction, Sanger or long-read sequencing, and a minigene splice assay when needed.

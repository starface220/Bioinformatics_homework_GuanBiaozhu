# Q2 - From FASTQ to a Trustworthy Analysis Workflow

**Name:**

**Student ID:**

**Date:**

---

## Context and working assumption

The manifest contains WGS, RNA-seq, ATAC-seq, and H3K27ac ChIP-seq samples, but only the S01 WGS sample has a small paired-end FASTQ demo. I will use WGS as the main workflow so the general steps can be connected to the only data set that can be inspected directly. The early steps can be shared with the other assays, while the downstream branch changes after mapped-read processing.

I will assume that the reads are paired-end Illumina reads from a human sample. The workflow below is a plan, not a result. No production genome alignment is needed for this assignment.

---

## 1. Reasoning before AI

### Initial workflow sketch

My first workflow is:

```text
Raw paired-end FASTQ
  -> FASTQ quality control
  -> adapter and quality trimming, followed by a second QC check
  -> reference genome and annotation selection
  -> alignment
  -> mapped-read processing
  -> WGS variant calling and filtering
  -> variant annotation
  -> visualization and manual inspection
  -> biological interpretation and validation planning
```

The exact reference release, aligner version, and filtering thresholds still need to be checked. At this stage, I am only defining the logical order of the analysis and the decisions that depend on earlier results.

### Purpose of each step

| Step | What I would do | Main output | Why the step matters |
|---|---|---|---|
| 1. FASTQ QC | Run FastQC and combine reports with MultiQC | QC report before trimming | Detects low-quality bases, adapters, contamination signals, and duplicate patterns before they affect alignment |
| 2. Reference selection | Choose a named human genome build and matching annotation | Reference FASTA, index, and annotation files | All coordinates and downstream annotations must refer to the same genome version |
| 3. Alignment | Map paired-end reads to the selected reference | Sorted BAM or CRAM | Converts reads into genomic positions that can be processed and counted |
| 4. Mapped-read processing | Sort, index, mark duplicates, and record read-group or sample information | Analysis-ready BAM or CRAM | Reduces avoidable technical effects and prepares the file for variant calling |
| 5. WGS downstream analysis | Call variants and apply quality-aware filtering | VCF before annotation | Turns aligned reads into candidate variants, but does not yet explain their biology |
| 6. Annotation | Add gene, transcript, consequence, frequency, and database evidence | Annotated VCF or variant table | Places variants in a biological context and helps separate technical calls from plausible candidates |
| 7. Visualization | Inspect coverage and candidate variants in a genome browser, and summarize QC in plots | IGV views and summary figures | Makes unusual coverage, mapping, or variant patterns easier to notice |
| 8. Interpretation | Combine QC, variant quality, annotation, frequency, and biological context | Candidate list and next experimental step | Keeps the conclusion at the level supported by the data |

Steps 1 to 4 can be shared across WGS, RNA-seq, ATAC-seq, and ChIP-seq, although the exact QC thresholds and trimming choices may differ. After processing, the workflow branches. For WGS, I would continue to variant calling. For RNA-seq, I would quantify expression. For ATAC-seq, I would call accessible regions. For H3K27ac ChIP-seq, I would call enrichment regions and inspect the active chromatin signal.

### Decision rules before AI

- If the first QC run shows adapter contamination, I would trim adapters and run QC again. I would not ignore the adapter result just because the reads can still be aligned.
- If per-base quality drops near the 3' end, I would use moderate quality trimming and check how many bases are removed. Aggressive trimming could shorten reads enough to reduce mapping quality.
- If the GC distribution has a high-GC shoulder or a second peak, I would investigate contamination, library bias, or a mixed sample. I would not delete all high-GC reads without understanding the pattern.
- If duplication is high, I would keep the reads in the file and mark the duplicates. Some duplicated reads can still carry valid information for coverage and variant calling.
- If the mapping rate is lower than expected, I would check the reference build, adapter leftovers, contamination, read length, and trimming choices before changing the aligner.
- If coverage is uneven or a variant has low depth, I would not trust the call simply because it appears in a VCF. I would inspect the read evidence and apply filtering that reflects the sample and assay.
- If a variant is rare and has a plausible functional consequence, I would still treat it as a candidate until database evidence and biological context support it.

### FastQC metrics I would inspect

The synthetic snapshot contains several planted problems. I would interpret at least these five metrics before asking AI for help.

| Metric | Observation in the demo | My interpretation | Preliminary decision |
|---|---|---|---|
| Per base sequence quality | R1 falls to a Phred score around 12 after cycle 50 for roughly 15% of reads | This is a clear 3' quality problem and could create mismatches or reduce mapping quality | Apply moderate 3' trimming and run QC again |
| Per sequence GC content | Main mode is about 41% GC, with a high-GC shoulder near 78% | The shoulder suggests contamination, a GC-biased fraction, or a mixed library; the cause is not clear from FastQC alone | Investigate read composition and contamination before removing reads |
| Adapter content | The Illumina-like sequence `AGATCGGAAGAGC` rises at the 3' end in about 15% of pairs | Adapter read-through has occurred and should not be carried into alignment | Perform adapter trimming and repeat QC |
| Sequence duplication levels | One template appears in roughly 15% of R1 reads | The library may have low complexity or PCR duplicates | Mark duplicates and examine library complexity; do not simply delete all duplicated reads |
| Overrepresented sequences | A fragment matching the adapter appears among the top sequences | This agrees with the adapter-content result and does not add a separate biological signal | Use the adapter result to guide trimming and then re-check the metric |

The per-base N content and sequence length modules look normal in the snapshot, so they do not require a major intervention in this demo.

### Initial choices that still need verification

I would begin with human GRCh38, but I would not write "GRCh38" without a specific release and annotation source. The reference choice needs to match the aligner, variant caller, annotation database, and any later comparison with public data.

For the initial plan, I would consider a short-read aligner such as BWA-MEM2, duplicate marking with Picard or GATK, variant calling with GATK HaplotypeCaller or DeepVariant, and annotation with VEP, ANNOVAR, or SnpEff. These are placeholders. Their versions, output formats, required indexes, and key parameters need to be checked against official documentation before they are presented as final decisions.

I would also record the sample name, library, platform, lane, and read group during alignment. Without this metadata, later files may be difficult to reproduce or combine correctly.

At the end of this section, I still have several questions for the AI-assisted workflow: which reference release is most appropriate, whether base quality recalibration is needed with the selected caller, how filtering should change with coverage, and which QC results should stop the analysis or lead to a rerun.

---

## 2. AI-assisted workflow

I used a plan-first prompt because a long list of commands would make it harder to see whether the logic of the workflow was sound. The first prompt asked for a review and an ordered plan. It did not ask for version-specific parameters.

> Act as a senior genomics workflow reviewer. I assume paired-end human WGS reads. Review my eight-step workflow and preliminary tool choices. For each step, give the purpose, input, output, likely failure modes, and a rule for moving forward, rerunning, or stopping. Point out missing quality checks, incorrect ordering, and assumptions that need verification. Return a plan only. Do not write shell commands until I approve the plan.

After reviewing the plan, I used a second prompt for the implementation details:

> Expand the approved plan into the tool families and command names that would be used at each step. Mark every parameter or threshold that depends on the software version, reference release, coverage, or sample design. Do not present a placeholder value as a final recommendation.

### AI review of the workflow

The AI kept the overall order from my first plan, but it made the decision points more explicit. The revised order is:

```text
Raw paired-end FASTQ
  -> FASTQ QC and read-pair checks
  -> decide whether trimming is needed
  -> choose the reference and annotation, and build matching indexes
  -> align reads with read-group metadata
  -> sort, index, and mark duplicates
  -> inspect mapping and duplication metrics
  -> call variants
  -> filter calls using quality and context
  -> annotate variants
  -> visualize and manually inspect selected sites
  -> interpret with a clear distinction between evidence and hypothesis
```

The AI treated reference selection as something that can happen while QC is running. I agree with that arrangement because the reference choice does not depend on the QC result. Alignment must wait until the reference files and indexes exist.

| Step | AI recommendation | My provisional response |
|---|---|---|
| FASTQ QC | Run FastQC before and after trimming. Check that R1 and R2 are valid pairs and that read groups match the sample sheet. | Accept. Add a failed-pair check and sample identity check to the plan. |
| Trimming | Trim adapters when adapter content is high. Use quality trimming only where the quality profile supports it. | Accept with a caution. I would compare trimmed and untrimmed QC instead of assuming that trimming always improves mapping. |
| Reference | Use a named human GRCh38 release and a matching annotation source. Record the contig set and index version. | Accept in principle. I cannot decide the exact release until I check the reference documentation. |
| Alignment | Use a short-read aligner such as BWA-MEM2 and include sample, library, platform, lane, and read-group metadata. | Keep as a candidate. The aligner and exact command need version checks. |
| Mapped-read processing | Sort and index the alignment, then mark duplicates. Keep duplicate metrics for review. | Accept. I would not delete duplicated reads at this point. |
| BQSR | Run BQSR before variant calling when the selected caller expects recalibrated base qualities. | Modify. BQSR should be conditional on the caller and reference resources, not a default step for every pipeline. |
| Variant calling | Use a WGS-appropriate caller such as GATK HaplotypeCaller or DeepVariant. Use joint calling only when the study design and sample set support it. | Hold for verification. I would not choose the caller until I check the caller documentation and data requirements. |
| Variant filtering | Filter on depth, genotype quality, allele balance, strand bias, mapping quality, repetitive regions, and other caller-specific metrics. | Accept the logic, reject fixed thresholds at this stage. Thresholds need to match coverage, caller, and the intended analysis. |
| Annotation | Annotate with VEP, ANNOVAR, or SnpEff using a recorded transcript set and database version. | Accept. The database and transcript versions must be written in the report. |
| Visualization | Use MultiQC for run-level summaries and IGV or a comparable browser for site-level inspection. | Accept. Visualization supports both QC and site review, so it belongs before the final report. |
| Interpretation | Separate technical observations, computational inference, biological hypotheses, and required validation. | Accept. I would not call a variant causal from annotation or frequency alone. |

### Main changes suggested by the AI

The review made failure paths more explicit. A failed QC result should lead to one of three actions: trim and rerun, investigate the sample or library, or stop the analysis. It should not automatically lead to more trimming.

Reference preparation was moved ahead of alignment. The reference release, annotation source, and index must be compatible. If one of these files changes after alignment, the alignment and downstream files should be regenerated.

Duplicate handling also changed. For WGS, the plan will mark duplicates and keep the Picard or GATK duplicate metrics for review. Deleting all duplicate reads would remove information that may still be useful for coverage checks.

The review also discouraged one universal filtering rule. A variant that passes depth and genotype-quality filters can still be a poor candidate because of strand bias, low mapping quality, repeat context, or a database mismatch. The final filter needs to be justified after the caller and coverage are known.

The last major change was to make the assay-specific branch more visible. The common pipeline can start with FASTQ QC and mapped-read processing, but WGS, RNA-seq, ATAC-seq, and H3K27ac ChIP-seq cannot share the same downstream analysis. WGS continues to variant calling. RNA-seq continues to transcript quantification. ATAC-seq and ChIP-seq continue to peak calling and regulatory interpretation.

### AI suggestions I did not accept as written

- A fixed minimum depth or genotype-quality cutoff stays out of the plan until the caller and expected coverage are known.
- BQSR remains conditional. Some callers use different preprocessing recommendations, so this choice belongs to the software-specific verification stage.
- Duplicate reads will be marked and inspected. The plan will not delete them all.
- The filter will not use one recipe for every WGS sample. Coverage and library quality can differ between samples.
- Exact command parameters remain undecided until the reference release, tool version, and file format are checked.

### Questions to carry into verification

The AI-assisted plan leaves several points open:

1. Which GRCh38 release and contig set should be used, and which annotation release matches it?
2. Which aligner version and read-group fields are required by the chosen downstream pipeline?
3. Does the selected variant caller require BQSR, or does it use a different preprocessing model?
4. Which filtering metrics should be kept separate from hard filters so that they can be inspected later?
5. Which annotation database and transcript version should be recorded?
6. Which of the proposed commands are still current, and which have been replaced or renamed?

These questions belong to Section 3. I will not treat the AI plan as final until the reference, file formats, software versions, and major parameters have been checked against official documentation.

---

## 3. Verification

I checked the plan against primary documentation instead of tutorials. I used NCBI for the assembly, the SAM/BAM and VCF specifications for file structure, and the official documentation or source repositories for BWA-MEM2, Picard, DeepVariant, VEP, fastp, FastQC, samtools, and GATK. The FASTQ demo is synthetic and much smaller than a real WGS library, so I did not invent mapping rates, coverage, or variant results.

### Reference and annotation

I will use human GRCh38.p14. NCBI identifies this assembly as RefSeq accession `GCF_000001405.40` and GenBank accession `GCA_000001405.29` [1]. "GRCh38" by itself is not specific enough because the patch version and file source affect the contig set and sequence names. For this teaching workflow, I will use the primary assembly, exclude ALT and decoy contigs, and keep one FASTA as the only reference used for indexing, alignment, and variant calling.

For annotation, I will use Ensembl release 116 and the matching VEP release 116 cache. VEP uses GRCh38 by default when `--grch37` is not selected [9], but the cache is release-specific. The cache release, transcript source, and contig naming have to match the VCF. I would not mix `1`, `chr1`, and `NC_000001.11` names in one run. The AI originally wrote only "use GRCh38", so I changed this to one named patch, one accession, one contig set, and one annotation release.

### FASTQ QC and trimming

The FastQC snapshot is synthetic, so the warnings describe planted problems. They do not indicate a failed sequencing run. The official FastQC adapter module supports the decision to trim adapters when adapter sequence accumulates at the 3' end [10]. The GC module says a broad peak or shoulder may reflect contamination or another biased subset, and it should be interpreted together with overrepresented sequences [11]. I therefore kept the plan to investigate the high-GC shoulder and did not delete all high-GC reads.

The AI's first trimming suggestion was effectively "trim adapters, then rerun QC". That was incomplete for paired-end fastp data. The official fastp documentation states that adapter auto-detection is disabled for paired-end input by default. It has to be enabled with `--detect_adapter_for_pe`, or the adapter sequences have to be supplied explicitly [12]. The demo contains an `AGATCGGAAGAGC` fragment, which is consistent with the TruSeq adapter family. My final QC branch is:

```text
FastQC/MultiQC before trimming
  -> trim with fastp using paired-end adapter detection or explicit adapter sequences
  -> use moderate 3' quality trimming only where the quality profile supports it
  -> run FastQC/MultiQC again
  -> compare read count, length, GC, duplication, and adapter metrics before moving on
```

I would not use a fixed "trim the last N bases" rule. The quality profile, read length after trimming, and mapping metrics determine whether the trimming helped.

### Alignment and mapped-read processing

I will use BWA-MEM2 version 2.2.1. Its official documentation shows that the FASTA must first be indexed with `bwa-mem2 index`, and that `bwa-mem2 mem` maps paired reads and writes SAM output [4]. The index has to be built from the same FASTA that is later supplied to the caller.

The alignment command needs read-group metadata. The SAM specification says each `@RG` line must have a unique `ID`, and every alignment record carrying an `RG` tag must have a matching header line [2]. I will include at least:

```text
ID = unique read-group ID
SM = sample name
LB = library
PL = ILLUMINA
PU = platform unit, such as flowcell-barcode.lane
```

Without those fields, later sample or lane information can be lost. This was an addition to the AI plan, not a rejection of it.

After alignment, I will sort the file by coordinate and create an index. The SAM header records coordinate sorting with `SO:coordinate`, and the VCF specification likewise expects a defined and stable reference context for downstream files [2][3]. For the teaching workflow I will keep BAM because it is the format used in the DeepVariant quick start [6]. CRAM would be reasonable for long-term storage, but introducing it would add reference-encoding details that are not needed for this assignment.

Duplicate handling will use Picard 3.5.0 MarkDuplicates. The official tool description says that it finds reads from a single DNA fragment, marks them with SAM flag `0x400`, and writes a metrics file [5]. I will keep the records and retain the metrics. This is different from deleting every duplicated read. Marking preserves coverage information and makes the duplicate rate visible.

### Variant calling and BQSR

I changed the main caller from a general GATK HaplotypeCaller plan to DeepVariant 1.10.0 for this workflow. The official DeepVariant documentation states that the reference FASTA and BAM must both be indexed, the BAM must be coordinate sorted, and the BAM and FASTA have to contain compatible contigs [7]. The quick start gives a WGS model and produces both `VCF.gz` and `gVCF.gz` outputs with tabix indexes [6].

DeepVariant's own documentation recommends against BQSR and reports a small decrease in accuracy when BQSR is performed [7]. This is direct evidence against the AI recommendation to run BQSR before calling. I therefore removed BQSR from the final WGS branch. BQSR is not wrong in every pipeline. It depends on the caller and available known sites. It is simply not appropriate for the caller selected here.

Duplicate marking is also not treated as mandatory. DeepVariant says that duplicate marking may be performed and that the accuracy difference is small, with the effect mainly appearing below 20x coverage [7]. Its `make_examples` code excludes duplicate reads by default through `keep_duplicates=False` [8]. I will still mark duplicates because this gives a library-complexity metric and makes the decision explicit. The duplicates stay in the BAM for auditability.

For the demo itself, no biological variant interpretation will be attempted. The file contains only 120 synthetic pairs, which is nowhere near enough coverage for a genome-wide call set. If a small test call is run, it is a software check only.

### Variant filtering

There is no universal depth or genotype-quality cutoff that can be copied into every WGS project. GATK's hard-filtering guidance presents example thresholds for selected variant metrics and warns that they have to be adapted to the dataset [14]. I will use the following properties to review the evidence. They are not fixed biological cutoffs:

| Field or pattern | What it helps check | How I will use it |
|---|---|---|
| `QUAL` | Caller confidence in the variant | Compare with coverage and genotype evidence; do not use one cutoff for all regions |
| `DP` and `AD` | Total and allele-specific depth | Check whether the genotype has enough support and whether one allele is barely covered |
| `GQ` | Confidence in the assigned genotype | Use as one piece of evidence, not as proof that the variant is real |
| Allele balance | Whether a heterozygous call has balanced read support | Inspect outliers, but allow for mapping and sequencing bias |
| `MQ` | Mapping confidence around the call | Inspect low values and repeat or paralogous regions |
| `QD`, `FS`, `SOR`, `ReadPosRankSum`, `MQRankSum` | Possible strand, position, or mapping artifacts | Use the caller-appropriate thresholds as review filters and compare with IGV |
| Repeat and segmental-duplication annotations | Ambiguous or duplicated reference sequence | Flag separately from high-confidence regions |

SNPs and indels will not share one threshold table. Indel calls often have lower depth or quality than nearby SNPs without being false. I will also keep the original callset before filtering, write down every filter, and inspect candidate sites in IGV. A `PASS` label means that a record passed the caller's or filterer's checks. It does not mean that the variant is biologically causal or clinically actionable.

### Annotation

I will annotate with Ensembl VEP release 116 in cache and offline mode, using the GRCh38 cache and VCF input [9]. The command will record the VEP version, cache release, transcript source, and any `--pick` or transcript-selection option. I will keep multiple transcript consequences during the first annotation pass and only shorten the output after checking which transcripts are relevant. AI suggested using `--pick` immediately to make the table simpler. I rejected that as the default because it can hide alternative transcripts, including a more relevant consequence.

VEP consequences are predictions based on a transcript model. A `missense_variant` or `splice_region_variant` label does not by itself establish disease relevance. Frequency databases, clinical evidence, transcript expression, and experimental validation remain separate evidence layers.

### Visualization and reproducibility

MultiQC will combine FastQC reports and can also summarize alignment and duplicate metrics. IGV will be used for read-level inspection of selected sites, coverage gaps, allele balance, and suspicious mapping. `samtools 1.24` will provide sorting, indexing, and basic alignment statistics [13].

The final run record should contain:

```text
software_versions.txt
commands.sh or workflow configuration
reference FASTA name, accession, and checksum
annotation cache release and checksum
sample sheet and read-group table
FastQC/MultiQC reports before and after trimming
mapping and duplicate metrics
unfiltered and filtered VCF files
annotated variant table
IGV screenshots for manually reviewed candidates
```

These files make it possible to see where a result came from. A workflow in a report is not reproducible if the reference release, annotation cache, software version, or filter logic is missing.

### AI-audit table

| AI recommendation | My verification | Final decision |
|---|---|---|
| Treat "GRCh38" as a complete reference description | NCBI distinguishes GRCh38.p14 as `GCF_000001405.40` and `GCA_000001405.29` [1] | Changed. Use one named patch, accession, contig set, and source file |
| Use any current annotation database | VEP caches and transcript annotations are release-specific, and VEP uses GRCh38 unless `--grch37` is selected [9] | Changed. Pair the reference with Ensembl/VEP release 116 and record the cache version |
| Run default paired-end adapter trimming | fastp disables paired-end adapter auto-detection by default [12] | Modified. Use `--detect_adapter_for_pe` or explicit R1/R2 adapter sequences |
| Trim the last N bases from every read | The FastQC profile, post-trim length, and mapping metrics decide whether trimming helps | Rejected as a fixed rule. Use moderate quality trimming and compare pre/post QC |
| Remove all duplicate reads before calling | Picard marks duplicates and reports metrics [5]; DeepVariant ignores duplicates by default but can accept an unmarked BAM [7][8] | Modified. Mark duplicates, keep the records, and retain the metrics |
| Run BQSR before variant calling | DeepVariant 1.10.0 recommends against BQSR and reports a small accuracy decrease [7] | Rejected for this pipeline. Remove BQSR from the WGS branch |
| Use GATK HaplotypeCaller as the main caller | DeepVariant documents a supported WGS model and the required sorted/indexed BAM plus indexed FASTA [6][7] | Changed. Use DeepVariant 1.10.0 for this workflow; GATK remains an alternative, not a second mandatory pass |
| Apply one fixed `DP` or `GQ` cutoff to every sample | No single threshold covers all coverage, ploidy, and repeat contexts; GATK's example filters require adaptation [14] | Rejected. Use depth, genotype quality, allele balance, and artifact metrics as review evidence |
| Use `PASS` as proof that a variant is real | `PASS` records technical filtering, not biological or clinical truth | Rejected. Keep PASS and flagged calls separate and inspect candidates |
| Use `--pick` in the first VEP run | The README documents transcript-selection options, but a picked consequence is only one selected transcript [9] | Modified. Keep multiple consequences first; simplify only after checking relevant transcripts |
| Combine every sample through immediate joint calling | DeepVariant supports per-sample VCF and gVCF output, but joint analysis depends on study design and infrastructure [6] | Modified. Keep per-sample VCF/gVCF for the teaching workflow; joint calling is a later cohort step |
| Mix `1`, `chr1`, and RefSeq contig names freely | SAM headers use reference names from `@SQ`, and DeepVariant only processes contigs shared by BAM and FASTA [2][7] | Rejected. Normalize contig names and record the conversion before alignment |
| Trust an AI-generated command without checking indexes and formats | DeepVariant requires indexed FASTA and sorted/indexed BAM [6][7] | Modified. Every command now has an input-format and index check |

### Limits of this verification

The S01 file is a 120-pair synthetic demo, not a real WGS library. The FastQC snapshot is precomputed, so it does not prove that a specific FastQC version produced those plots. No mapping rate, duplication rate, coverage distribution, or variant truth set can be estimated from this demo. The workflow is therefore verified at the level of reference identity, file contracts, tool behavior, and parameter logic. Performance of the pipeline on real data would have to be tested with a proper benchmark sample and a known truth set.

### Sources checked on 19 September 2026

1. [NCBI genome assembly GRCh38.p14, `GCF_000001405.40`](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001405.40/)
2. [SAM/BAM format specification, SAMv1](https://samtools.github.io/hts-specs/SAMv1.pdf)
3. [VCF format specification, VCFv4.3](https://samtools.github.io/hts-specs/VCFv4.3.pdf)
4. [BWA-MEM2 official repository and command documentation](https://github.com/bwa-mem2/bwa-mem2)
5. [Picard 3.5.0 release and MarkDuplicates tool documentation](https://github.com/broadinstitute/picard/releases/tag/3.5.0)
6. [DeepVariant 1.10.0 quick start](https://github.com/google/deepvariant/blob/v1.10.0/docs/deepvariant-quick-start.md)
7. [DeepVariant 1.10.0 input and preprocessing details](https://github.com/google/deepvariant/blob/v1.10.0/docs/deepvariant-details.md)
8. [DeepVariant 1.10.0 `make_examples` duplicate option](https://github.com/google/deepvariant/blob/v1.10.0/deepvariant/make_examples_options.py)
9. [Ensembl Variant Effect Predictor, release 116](https://github.com/Ensembl/ensembl-vep/tree/release/116)
10. [FastQC adapter content module](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/3%20Analysis%20Modules/10%20Adapter%20Content.html)
11. [FastQC per-sequence GC content module](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/3%20Analysis%20Modules/5%20Per%20Sequence%20GC%20Content.html)
12. [fastp official repository and adapter documentation](https://github.com/OpenGene/fastp)
13. [samtools 1.24 release](https://github.com/samtools/samtools/releases/tag/1.24)
14. [GATK hard-filtering guidance for germline short variants](https://gatk.broadinstitute.org/hc/en-us/articles/360035890471-Hard-filtering-germline-short-variants)

---

## 4. Final conclusion

![Q2 WGS workflow](figures/Q2_workflow.png)

**Workflow figure:** `figures/Q2_workflow.png`  
**Vector source:** `figures/Q2_workflow.svg`

**Approximately 200-word explanation:**

First, I would check read quality with FastQC and MultiQC. If adapter content or the 3' quality drop remains a problem, I would trim with fastp, enable paired-end adapter detection or supply adapter sequences explicitly, and repeat QC. I would choose GRCh38.p14, record its accession and primary contig set, and pair it with Ensembl/VEP release 116. BWA-MEM2 2.2.1 would map the reads, after which samtools 1.24 would sort and index the BAM with read-group metadata. Picard 3.5.0 would mark duplicates, but I would keep the records and review the metrics.

After processing, the assays branch. WGS would continue to DeepVariant 1.10.0. RNA-seq would move to expression quantification, ATAC-seq to peak calling, and ChIP-seq to enrichment analysis. For WGS, I would keep the unfiltered VCF, review variants with several quality measures, annotate with VEP 116 without hiding transcripts on the first pass, and inspect selected sites in IGV. PASS would not mean the variant is biologically real.

The final record would include software versions, commands, reference checksum, annotation cache, QC reports, mapping metrics, and VCFs. It should be detailed enough for another analyst to rerun the main steps, inspect the same sites, and see why each filtering decision was made.

> The analyst, not the AI, is responsible for checking the reference and tool versions, justifying each parameter, reviewing outputs, and deciding how much biological confidence the evidence supports.

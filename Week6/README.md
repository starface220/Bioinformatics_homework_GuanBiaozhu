# Week 6

This folder contains the Week 6 16S homework in two forms.

## Local submission

The files directly under `Week6/` are a copy of the local `submission` folder.
They include:

- `SUBMISSION_ANSWER.md`: written answer to the homework.
- `SCIENTIFIC_HYPOTHESIS.md` and `科学假设.md`: English and Chinese versions
  of the scientific hypothesis.
- `EMP_Teaching_Report.md`: report generated from the EMP teaching journal.
- `data/`, `results/`, `figures/`, and `logs/`: input data, analysis tables,
  figures, and run information.
- `scripts/week6_emp_analysis.R`: supplementary R checks.
- `emp_bundle/`: EMP Run All output from session
  `24bI6P4jLOScr48iq7QI0Wen`.

This part is a human-readable submission package. It was not created by the
EMP GitHub Sync process.

## EMP submission

`Week6/EMP2026/` contains the Week 6 EMP course submission.

The original EMP layout uses `EMP2026/` at the repository root. In this local
working copy I moved the whole folder under `Week6/` so that all Week 6 files
are in one place.

Only the final Week 6 run is kept here:

```text
Week6/EMP2026/Week_06/microbiome_16s/weekly/runs/
└── 2026-09-25T11-21-18-594Z-lep8n6/
```

`LATEST` points to:

```text
2026-09-25T11-21-18-594Z-lep8n6
```

The earlier run `2026-09-25T10-58-41-216Z-ztpuk5` and its `_ledger` record
were removed from this local working copy to avoid two near-identical Week 6
submissions. They still exist in the current GitHub branch until the local
deletions are committed and pushed.

The remaining run contains:

```text
manifest.json
data/
results/
plots/
teaching/
```

The `teaching/report.md` file contains the current hypothesis,
interpretation, limitations, and AI-use declaration.

## Analysis summary

- EMP version: `9.0.4`
- Session: `MYLQuB4Wvb429RvLHXEIuOvq`
- Experiment: `microbiome_16s_week6`
- Input: 132 samples and 470 level-7 taxonomy features
- Group labels: 130 samples; two samples were excluded from group comparisons
- Retained taxa: top 40 by total abundance
- Alpha diversity: no significant group difference
- Bray-Curtis PERMANOVA: IBS versus UC
  `R2 = 0.022`, `F = 2.83`, `p = 0.018`
- PERMDISP for disease: `p = 0.363`
- Before/after community test: `p = 0.627`
- Differential taxa: five exploratory taxa with BH FDR from 0.080 to 0.086;
  none passed FDR < 0.05

The main hypothesis is that UC affects a small number of gut taxa while
overall Shannon diversity remains similar. The taxa and proposed mechanism
are described in `SCIENTIFIC_HYPOTHESIS.md`, `科学假设.md`, and the EMP
teaching report.

## Important note about re-syncing

EMP expects its course directory at the repository root:

```text
EMP2026/
```

If Week 6 is synced again, the app will create a new top-level `EMP2026/`
folder and a new timestamped run. It will not automatically move that folder
under `Week6/`. After a later sync, the new Week 6 run must be merged into
`Week6/EMP2026/` if the Week 6 folder is to remain the single entry point.

The local submission files are not included in EMP Sync. EMP only packages
the current session data, results, plots, and teaching files.


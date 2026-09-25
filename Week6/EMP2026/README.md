# EMP2026 Course Submissions

- Student ID: `24000204`
- Display name: **关标著**
- EMP version: `9.0.4`
- GitHub: `starface220` / `starface220/Bioinformatics_homework_GuanBiaozhu`

## Local layout

In this repository, the EMP course folder was moved under `Week6/` so that it
sits with the rest of the Week 6 homework:

```text
Week6/
  EMP2026/
    Week_06/microbiome_16s/weekly/runs/...
    profile.json
    _ledger/<run_id>.json
    README.md
  ...
```

Only the final Week 6 run is kept in this local copy:

```text
Week6/EMP2026/Week_06/microbiome_16s/weekly/runs/2026-09-25T11-21-18-594Z-lep8n6
```

The earlier run `2026-09-25T10-58-41-216Z-ztpuk5` and its ledger entry were
removed locally. They remain on the current GitHub branch until these changes
are committed and pushed.

## Sync behavior

EMP normally creates a new run for each sync and keeps earlier runs. If the
course tool is used again, it will expect `EMP2026/` at the repository root
and create a new run there. That new run must be merged into
`Week6/EMP2026/` if this local organization is kept.

Latest retained run:

```text
Week6/EMP2026/Week_06/microbiome_16s/weekly/runs/2026-09-25T11-21-18-594Z-lep8n6
```


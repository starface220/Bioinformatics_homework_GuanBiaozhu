# KEGG retry note

The first one-click EasyMultiProfiler run recorded a temporary failure when
the local R process tried to reach the KEGG REST service.

Direct connection checks later succeeded for both:

- `https://rest.kegg.jp/info/mmu`
- `https://rest.kegg.jp/link/mmu/pathway`

The same session was then rerun with KEGG enrichment. The retry succeeded and
returned 26 pathways. The successful output is saved in:

- `tables/09_enrichment_kegg.csv`
- `plots/09_enrichment_kegg.png`

The unsuccessful first attempt remains visible in the original
`summary.txt`, because that file is part of the unmodified EasyMultiProfiler
bundle.

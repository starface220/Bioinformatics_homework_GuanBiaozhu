# Week 5 Homework 2

本目录包含使用本地 EasyMultiProfiler 对 `RNAseq_output.csv` 和
`RNAseq_mapping.csv` 完成的 RNA-seq 分析。

分析在本地 EasyMultiProfiler Web v9.0.4 后端运行，结果未上传到外部 EMP
平台。

## 分析设置

- 输入：24 个样本 × 19,150 个基因
- 分组：DMSO、DMSO+LIPUS、T4400、T4400+LIPUS、T3976、T3976+LIPUS
- 主要比较：T4400 versus DMSO
- 差异分析方法：DESeq2
- 显著性阈值：`padj < 0.05` 且 `abs(log2FoldChange) >= 1`
- 物种：小鼠（`mmu`）

## 目录内容

- `inputs/`：本次分析使用的两个原始 CSV 副本
- `EasyMultiProfiler_RNAseq_results/tables/`：PCA、DESeq2、DEG、相关性和富集表格
- `EasyMultiProfiler_RNAseq_results/plots/`：全部分析图形的 PDF 和 PNG
- `EasyMultiProfiler_RNAseq_results/platform_exports/`：本地 assay 矩阵、metadata 和会话 RDS
- `EasyMultiProfiler_RNAseq_results/summary.txt`：EasyMultiProfiler 运行日志
- `EasyMultiProfiler_RNAseq_bundle_complete_20260925-100834.zip`：本地下载的完整 bundle
- `homework2_interpretation.md`：结果解释
- `analysis_summary.csv`：关键结果摘要

## 主要结果

平台差异分析保留了 16,757 个基因，其中 238 个基因同时满足校正后 p 值和
效应量阈值。T4400 中有 172 个基因升高、66 个基因降低。

GO 富集得到 40 条结果，主要涉及趋化因子信号、白细胞迁移、急性期反应、
抗菌体液反应和血管发育。KEGG 富集最初因临时 REST 连接失败而中断，之后
重试成功并得到 26 条通路，主要包括 IL-17 信号、细胞因子与受体互作、
TNF 信号和趋化因子信号。

原始一键运行日志保留了第一次 KEGG 失败记录。成功重试的结果单独保存在：

- `tables/09_enrichment_kegg.csv`
- `plots/09_enrichment_kegg.png`

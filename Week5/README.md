# Week 5 作业

本目录包含 Week 5 的两份作业提交。

## Homework 1

目录：`Homework1/`

Homework 1 是使用 R、DESeq2 和 `apeglm` 完成的 bulk RNA-seq 差异表达分析。
脚本从 `../for_student/` 读取原始计数矩阵和样本元数据，并将所有要求文件写入
当前目录。

分析摘要：

- 12 个样本，两个条件、三个批次，设计均衡
- 输入 1,000 个基因
- 模型设计：`~ batch + condition`
- 过滤条件：至少 3 个样本中的计数不少于 10
- DESeq2 模型保留 989 个基因
- 差异表达阈值：`padj < 0.05` 且 `abs(shrunken log2FoldChange) >= 1`
- 60 个显著基因：treated 中 36 个升高、24 个降低
- PCA：PC1 解释 24% 的方差，并将 treated 与 control 分开

要求的文件：

```text
week5_deseq2_analysis.R
week5_deseq2_results.csv
week5_pca.png
week5_de_plot.png
week5_interpretation.md
week5_AI_verification_log.md
week5_deseq2_object.rds
session_info.txt
```

如需重新运行 Homework 1，请在 RStudio 中打开
`week5_deseq2_analysis.R`，然后点击 `Source`。

## Homework 2

目录：`Homework2/`

Homework 2 使用本地 EasyMultiProfiler Web 完成了内置 RNA-seq 测试数据的
完整分析。原始输入文件已复制到 `Homework2/inputs/`。分析结果未上传至外部
EMP 服务。

分析摘要：

- 24 个样本、19,150 个基因
- 6 个分组，每组 4 个样本
- 主要比较：`T4400 vs DMSO`
- 方法：DESeq2
- 阈值：`padj < 0.05` 且 `abs(log2FoldChange) >= 1`
- 参与差异分析：16,757 个基因
- 238 个显著基因：T4400 中 172 个升高、66 个降低
- PCA：PC1 解释 66.7% 的方差，PC2 解释 25.8%
- GO 富集：40 条结果
- KEGG 富集：定向重试成功后得到 26 条通路

主要本地文件：

```text
README.md
homework2_interpretation.md
analysis_summary.csv
KEGG_RETRY_NOTE.md
inputs/
EasyMultiProfiler_RNAseq_results/
EasyMultiProfiler_RNAseq_bundle_complete_20260925-100834.zip
```

原始 EasyMultiProfiler 会话仍保存在本地应用数据目录：

```text
C:\EasyMultiProfiler-Web-main\.local_run\data\sessions\Z6uHJSVEoZc7W4O5ZtxdcMNI
```

下载 bundle 中的第一份 `summary.txt` 记录了一次临时 KEGG 连接失败。之后定向
重试成功，其 CSV 和 PNG 保存在 `EasyMultiProfiler_RNAseq_results/` 下。

## 输入文件

未修改的课程输入文件仍保存在 `for_student/`：

```text
Week5_Homework_Count_Matrix.csv
Week5_Homework_Sample_Metadata.csv
Week5_Homework_Starter.R
Week5_Homework_Gene_Annotation_Instructor_Key.csv
```

教师 true-value 文件未用于模型拟合、基因筛选或撰写任何解释。

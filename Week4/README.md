# Week 4 作业提交说明

**课程：** Bioinformatics: From Multi-Omics Data to Discovery  
**日期：** 2026-09-19  
**学生信息：** 可通过本仓库对应的 GitHub 账号确认

## 主报告

完整提交报告为：

[submission_template.md](submission_template.md)

报告包含 Q1 到 Q4 的全部四部分内容：

1. 使用 AI 前的推理
2. AI 辅助工作流程
3. 权威资料验证
4. 最终结论

报告中包含所需的 workflow figures、解释、AI 审核记录、权威来源和规定结尾句。

## 各题摘要

**Question 1.** 设计实验策略，判断 Gene X 在疾病组中上调的可能机制。流程首先使用 ATAC-seq，再结合 DNA 序列、chromatin state、methylation、3D contact 和 perturbation evidence 区分不同调控机制。

**Question 2.** 设计从 paired-end FASTQ 到可解释 WGS variant results 的分析流程，覆盖 QC、trimming、reference selection、alignment、mapped-read processing、variant calling、filtering、annotation、visualization 和 interpretation。

**Question 3.** 整合 ATAC-seq、H3K27ac、methylation、Hi-C 或 Micro-C 和 RNA-seq 证据，评估 Gene Y 上游候选区域是否可能是 enhancer。在完成 endogenous perturbation test 之前，该模型仍属于 hypothesis。

**Question 4.** 对合成教学变异表进行优先级排序。TP53 `chr17:7673803 G>A` 是首选候选，BRCA2 `chr13:32316461 C>T` 是置信度较低的第二候选，KRAS 保留为条件性备选。

## 图表文件

报告使用的所有图片位于：

[figures](figures/)

Markdown 报告通过相对路径引用 PNG 文件。可编辑的 SVG 源文件也保存在同一目录。

## Q4 可复现性

Variant filtering 和 ranking workflow 位于：

- [Q4_variant_filter.R](Q4_variant_filter.R)

筛选结果位于：

- [Q4_shortlist.tsv](Q4_shortlist.tsv)

脚本使用 R 4.4.3 运行，得到的优先级分数为：

| 排名 | Gene | Priority score |
|---:|---|---:|
| 1 | TP53 | 13 |
| 2 | BRCA2 | 9 |
| 3 | KRAS | 7 |

使用的合成数据表位于：

```text
../for_student/data/variants_q4.tsv
```

## 数据说明

本作业使用的 FASTQ 和 variant tables 都是合成教学数据，不包含真实患者信息，也未作为临床结果提交到任何临床数据库。

## AI 使用声明

AI 按作业要求用于设计批评、workflow 改进和代码辅助。每题的主要 prompt 都记录在第 2 部分。推理过程、验证判断、alternative explanations 和最终结论仍由作者负责。

## 附加文件

Q1 到 Q4 的独立 Markdown 文件作为完整工作记录一并保留：

- [Q1_Genomic_Assay_Strategy.md](Q1_Genomic_Assay_Strategy.md)
- [Q2_FASTQ_Trustworthy_Workflow.md](Q2_FASTQ_Trustworthy_Workflow.md)
- [Q3_Multi_Omics_Regulatory_Hypothesis.md](Q3_Multi_Omics_Regulatory_Hypothesis.md)
- [Q4_AI_Assisted_Variant_Prioritization.md](Q4_AI_Assisted_Variant_Prioritization.md)

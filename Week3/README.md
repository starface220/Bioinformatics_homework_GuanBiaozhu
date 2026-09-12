# Week 3 Homework — GSE87487 数据获取与验证

本文件夹是 Week 3 作业的工作目录，包含作业文档、原始下载数据（未修改）以及用于验证数据属性的 R 脚本。

---

## 文件清单

| 文件 | 大小 | 说明 |
|---|---|---|
| `Homework for week 3.docx` | 23 KB | 作业正文。第一题（GSE111889 研究身份与设计）和第二题（GSE87487 四个判断题）的答案已写入表格，文末附有 R 脚本与运行输出 |
| `GSE87487_counts.20samples.txt` | 12.1 MB | GEO 补充文件，featureCounts 计数矩阵。**原始下载内容，未做任何修改** |
| `GSE87487_series_matrix.txt` | 37.9 KB | GEO Series Matrix，样本元数据（SOFT 格式） |
| `week3_question2.R` | 7.7 KB | 验证第二题四个问题的 R 脚本，仅使用 base R |
| `README.md` | 本文件 | 文件夹说明 |

---

## 数据来源

两个数据文件均来自 NCBI GEO 的 **GSE87487**（Homo sapiens，肝脏移植活检 bulk RNA-seq）：

```
https://ftp.ncbi.nlm.nih.gov/geo/series/GSE87nnn/GSE87487/suppl/GSE87487_counts.20samples.txt.gz
https://ftp.ncbi.nlm.nih.gov/geo/series/GSE87nnn/GSE87487/matrix/GSE87487_series_matrix.txt.gz
```

下载后解压，压缩包已删除。**解压产物保持原样，脚本只读取、从不写入这两个文件。**

### `GSE87487_counts.20samples.txt` 的结构

featureCounts 标准输出，制表符分隔：

| 列 | 内容 |
|---|---|
| 1–6 | `Geneid`、`Chr`、`Start`、`End`、`Strand`、`Length`（注释列） |
| 7–26 | 20 个样本列，列名形如 `Sample_HBBx1.bam` |

- 共 **60,498 个特征 × 20 个样本**（含表头 60,499 行）
- 基因 ID 为带版本号的 Ensembl 编号，例如 `ENSG00000223972.5`

### `GSE87487_series_matrix.txt` 的结构

GEO SOFT 格式，元数据行以 `!` 开头，字段用制表符分隔、值带引号。本作业用到的标签：

- `!Sample_geo_accession` — GSM2332515 至 GSM2332534
- `!Sample_title` — 样本名，如 `RJBx1`
- `!Sample_characteristics_ch1` — 三行，分别是 transplant stage、IRI 状态、组织
- `!Series_relation` — 外部链接（BioProject、SRA）

---

## R 脚本说明

### 用途

`week3_question2.R` 把第二题的四道判断题各自转化为**一项可执行的检验**，输出结论及其证据。目的是避免"从文件名猜内容"——例如不能因为文件名叫 `_counts` 就断定它是整数计数，必须实际验证。

### 运行方式

脚本不依赖任何第三方包，**只需要 base R**（实测环境 R 4.4.3）。

```powershell
# 方式一：命令行（在 Homework 目录下）
& "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" "week3_question2.R"
```

```r
# 方式二：RStudio —— 打开脚本，全选后 Ctrl+Enter，或在 Console 中
source("week3_question2.R")
```

脚本启动时会自动定位自身所在目录来读取两个数据文件，因此可以直接运行，无需改路径。若定位失败会自动回退到当前工作目录。

### 输入与输出

- **输入**：同目录下的 `GSE87487_counts.20samples.txt`、`GSE87487_series_matrix.txt`
- **输出**：全部打印到 console，不写任何文件
- **运行时间**：约 1 秒

### 各段功能

| 段落 | 功能 | 对应问题 |
|---|---|---|
| 第 0 段 | 定位脚本目录、拼出输入路径、断言文件存在 | — |
| 第 1 段 | 读入计数矩阵，分离注释列与样本列；检验整数性、非负性、缺失值、取值范围、重复 ID | **Q1** |
| 第 2 段 | 解析 Series Matrix 的 SOFT 标签，构建样本字典（GSM / 样本名 / 供体 / 时期 / IRI / 组织） | 供 Q2、Q3 |
| 第 3 段 | 对齐检查：比较计数文件列名与元数据顺序（结果：**顺序不同**，命名也不同） | 方法学提示 |
| 第 4 段 | 统计每位供体的样本数、每人采集的时期；判断是否配对 | **Q2** |
| 第 5 段 | IRI × 时期的交叉表；检验 IRI 是否在每个供体内恒定 | **Q3** |
| 第 6 段 | 从 `!Series_relation` 提取 BioProject / SRA 链接，检查 `Sample_type` | **Q4** |

### 关键代码片段

**整数性检验**（Q1 的核心）：

```r
all(mat == floor(mat))   # 整数 n 满足 n == floor(n)，小数不满足
```

**供体还原**（从样本名去掉尾部的 `Bx1`/`Bx2`）：

```r
donor <- sub("[Bb][Xx][12]$", "", title)   # RJBx1 -> RJ
```

**配对结构检验**（Q2 的核心）：

```r
table(meta$donor)          # 每位供体出现几次
all(table(meta$donor) == 2)
```

**因子性质检验**（Q3 的核心）：

```r
table(iri, stage)                                   # 两因子交叉表
tapply(meta$iri, meta$donor, function(x) length(unique(x)))  # IRI 是否随供体变化
```

**外部链接提取**（Q4）：

```r
grep("^!Series_relation", sm, value = TRUE)
```

---

## R 脚本得出的结论

### Q1. Are the values counts? — 是

矩阵 60,498 × 20，全部为非负整数（范围 0 – 1,003,757），无缺失值，无重复特征 ID，零值占比 68.7%。与 featureCounts 输出格式一致，属于原始计数，不是标准化值。

### Q2. Are samples independent? — 否

20 个样本来自 **10 位供体**，每位供体恰好贡献 2 个样本：再灌注前（pre-reperfusion）与再灌注后（post-reperfusion）各一次。属于配对重复测量，必须在元数据和实验设计中保留供体身份。

### Q3. Can all 20 samples be compared directly? — 否

存在两个性质不同的因子：

- **IRI 状态**：供体水平（组间）属性，阴性 6 位供体 vs 阳性 4 位供体，且在每个供体内恒定
- **移植时期**：样本水平（组内）属性，pre vs post

把 20 个样本直接合并比较会同时忽略配对结构、并把同一供体的重复测量当作独立样本。必须先声明具体对比，例如配对比较 pre vs post，设计公式 `~ donor + stage`。

### Q4. Is full raw-read reprocessing possible? — 可行，但超出一次一小时作业的范畴

Series Matrix 中声明 `Sample_type = SRA`，并链接了 BioProject **PRJNA344898** 与 SRA study **SRP090633**，说明原始读段已归档。完整再处理需要「下载 FASTQ → 质控 → 比对 → 重新定量」，是一条完整流水线而非单个脚本。本次使用 featureCounts 矩阵已足够。

---

## 需要注意的细节

1. **样本顺序陷阱**
   计数文件的样本顺序与 Series Matrix 的元数据顺序**不一致**，且命名方式有差异（`Pt10-Bx1` vs `Pt10Bx1`、`HBBX1` 中的大写 X）。脚本通过标准化名称后显式匹配，20/20 全部对应成功。若按位置直接对应，会把标签错配到错误的样本上。

2. **Windows 区域设置警告**
   启动 R 时可能看到若干 `Setting LC_* failed` 警告。这是 Windows 中文区域设置下 R 的常规提示，**不影响任何计算结果**。脚本输出的转录已将这些警告滤除。

3. **中文路径**
   若从命令行传入完整中文路径，R 的 `normalizePath()` 可能报 UTF-8 转换错误。因此脚本对路径定位做了容错：失败时回退到当前工作目录。推荐在 Homework 目录内运行。

---

## 复现步骤

```powershell
# 1. 进入本目录
cd "Week 3\Homework"

# 2. 运行脚本
& "C:\Program Files\R\R-4.4.3\bin\Rscript.exe" "week3_question2.R"

# 3. console 会依次打印 Q1–Q4 的结论及支撑证据
```

脚本不写入任何文件，可反复运行，结果一致。

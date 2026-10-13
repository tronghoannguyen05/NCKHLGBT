# Replication package

**Pathology or Prejudice? A Within-Group Test of Workplace Stigma and Anxiety and Depressive Symptoms among LGBT Workers in Vietnam**

This repository contains the code that produces every table and figure of the article. Hướng dẫn chạy bằng tiếng Việt: `docs/huong_dan_chay_stata.md`.

## Data availability

The analysis uses a cross-sectional survey of workers in Vietnam (850 responses). The data include sexual orientation, gender identity, and mental health, which are sensitive personal data under Vietnam's Law on Personal Data Protection (Law No. 91/2025/QH15) and Decree No. 356/2025/ND-CP. Individual-level data are therefore not publicly available and are not included in this repository. Aggregate results, with cells of fewer than 10 respondents suppressed, are in `output/tables/stata/`.

## Computational requirements

- Stata 17 or later (the results in the article were produced with Stata/MP 17.0).
- User-written packages from SSC: `sensemakr` and `boottest`. The code installs them on the first run if they are missing, and the log records the installed versions.
- Random-number seeds are fixed (`global SEED` in Section 0), so the bootstrap, wild bootstrap, and multiple imputation results are reproducible.

## Instructions

1. Open `phan_tich.do` and set two paths in Section 0: `DATA` (the survey export, .xlsx, as downloaded and unedited) and `OUT` (an output folder).
2. Run the whole file. A full run takes a few minutes; most of the time is spent on the bootstrap, the wild bootstrap and the multiple imputation.

After import the file keeps only the variables used in the analysis. It checks the sample flow against the counts reported in Table 1 and stops if they differ.

## Output

All output is written to `OUT`.

| File or sheet | Article |
|---|---|
| `results.xlsx`, sheet `Table1` | Table 1, sample flow |
| `Table2` | Table 2, sample characteristics |
| `Table3_Descriptives`, `Table3_Correlations` | Table 3 |
| `Table4` | Table 4, H1, including the estimate per standard deviation of the stigma index and the equivalence test |
| `Table5` | Table 5, RQ1, three groups of stigma situations |
| `Table6` | Table 6, H2, concealment pathway, including the bootstrap of *a* × *b* |
| `Table7` | Table 7, H3, perceived DEI enforcement as moderator |
| `Table8` | Table 8, robustness checks |
| `TableS1` | Table S1, PHQ-4 by the covariates |
| `TableS2` | Table S2, diagnostics |
| `analysis.log`, section "Table S3" | Table S3, sensitivity analysis (sensemakr) |
| `TableS4` | Table S4, individual situations and levels of exposure |
| `TableS5` | Table S5, all specifications of the specification curve |
| `TableS6` | Table S6, post hoc sensitivity analyses |
| `figure2.png` | Figure 2, specification curve |
| `Symptoms`, `Reliability`, `Prevalence`, `MissingData`, `MergedCategories` | Values reported in the Methods and Results text |
| `AllResults` | Every estimate, with Holm and Benjamini-Hochberg adjusted *p* values |

## Structure of `phan_tich.do`

| Section | Content |
|---|---|
| 0 | Paths and parameters |
| 1 | Import and coding of the survey export |
| 2 | Indices, sample indicators, response-quality flags |
| 3 | Sample flow |
| 4 | Descriptive statistics, reliability, disclosure control |
| 5 | Merging of sparse covariate categories; Table S1 |
| 6 | H1 and the equivalence test |
| 7 | RQ1 |
| 8 | H2 and the bootstrap of *a* × *b* |
| 9 | H3 |
| 10 | Supplementary exploratory analyses |
| 11 | Diagnostics |
| 12 | Robustness checks and sensitivity analysis |
| 13 | Post hoc sensitivity analyses |
| 14 | Specification curve |
| 15 | Multiple-testing adjustment and export |

## Other material

- `docs/codebook.md`: variables and coding rules.
- `tests/python_replication/`: an independent Python replication used to check the Stata results. It reproduces every estimate that does not depend on random draws. Run `prep.py`, `desc.py` and `models.py` with the environment variable `LGBT_DATA` set to the survey export, then `compare.py` with `STATA_RESULTS` set to `results.xlsx`.
- `tests/check_no_data.sh`: refuses commits that contain individual-level data.

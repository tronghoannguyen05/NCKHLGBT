# Replication package

**Pathology or Prejudice? Workplace Stigma and Mental Health among LGBT Workers in Vietnam**

This repository contains the code that produces every table and figure of the article. Hướng dẫn chạy bằng tiếng Việt: `docs/huong_dan_chay_stata.md`.

## Data availability

The analysis uses a cross-sectional survey of 850 workers in Vietnam. The data include sexual orientation, gender identity, and mental health, which are sensitive personal data under Vietnam's Law on Personal Data Protection (Law No. 91/2025/QH15) and Decree No. 356/2025/ND-CP. Individual-level data are therefore not publicly available and are not included in this repository. Aggregate results, with cells of fewer than 10 respondents suppressed, are in `output/tables/stata/`.

## Computational requirements

- Stata 17 or later (the results in the article were produced with Stata/MP 17.0).
- User-written packages from SSC: `sensemakr` and `boottest`. The code installs them on the first run if they are missing, and the log records the installed versions.
- Random-number seeds are fixed (`global SEED` in Section 0), so the bootstrap, wild bootstrap, and multiple imputation results are reproducible.

## Instructions

1. Open `phan_tich.do` and set two paths in Section 0: `DATA` (the survey export, .xlsx) and `OUT` (an output folder).
2. Run the whole file.

The file checks the sample flow against the counts reported in Table 1 and stops if they differ.

## Output

All output is written to `OUT`.

| File or sheet | Article |
|---|---|
| `results.xlsx`, sheet `Table1` | Table 1, sample flow |
| `Table2` | Table 2, sample characteristics |
| `Table3_Descriptives`, `Table3_Correlations` | Table 3 |
| `Table4` | Table 4, H1, H2a, H2b |
| `Table5` | Table 5, H3 |
| `Table6` | Table 6, exploratory analyses E1, E2, E4, E5 |
| `Table7` | Table 7, robustness checks |
| `TableS1` | Table S1, PHQ-4 by pre-exposure characteristics |
| `TableS2` | Table S2, diagnostics |
| `analysis.log`, section "Table S3" | Table S3, sensitivity analysis (sensemakr) |
| `TableS4` | Table S4, E3 |
| `TableS5` | Table S5, indirect product *a* × *b* |
| `TableS6` | Table S6, all specifications of the specification curve |
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
| 6 | H1, H2a, H2b, equivalence test |
| 7 | H3 and the bootstrap of *a* × *b* |
| 8 | Exploratory analyses |
| 9 | Diagnostics |
| 10 | Robustness checks and sensitivity analysis |
| 11 | Specification curve |
| 12 | Multiple-testing adjustment and export |

## Other material

- `docs/analysis_plan.md`: the analysis plan, finalized on 5 October 2026 before estimation.
- `docs/deviations.md`: departures from the plan.
- `docs/codebook.md`: variables and coding rules.
- `tests/doi_chieu_python/`: an independent Python replication used to check the Stata results; it reproduces every estimate that does not depend on random draws.
- `code/`: an earlier modular version of the pipeline, kept for reference. It is not used for the article.
- `tests/check_no_data.sh`: refuses commits that contain individual-level data.

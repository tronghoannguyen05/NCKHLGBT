# Descriptive statistics of the article (section 4 of phan_tich.do). Aggregate
# figures only; cells with fewer than 10 respondents are suppressed.
# Run: LGBT_DATA=/path/to/export.xlsx python3 tests/python_replication/desc.py
import os
import warnings
warnings.filterwarnings('ignore')
import numpy as np
import pandas as pd
from prep import load

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'output', 'tables', 'python_replication')
os.makedirs(OUT, exist_ok=True)
MIN_CELL = 10

LABELS = {
    'agegrp_orig': {1: '18-24', 2: '25-34', 3: '35-44', 4: '45+'},
    'sex_birth_orig': {1: 'Male', 2: 'Female'},
    'educ_orig': {1: 'Upper secondary or below', 2: 'College', 3: 'University', 4: 'Postgraduate'},
    'relstat_orig': {1: 'No partner', 2: 'Partner', 3: 'Separated, divorced, or widowed', 9: 'Prefer not to answer'},
    'region_orig': {1: 'Hanoi', 2: 'Ho Chi Minh City', 3: 'Da Nang', 4: 'Elsewhere'},
    'orient_g': {2: 'Gay', 3: 'Lesbian', 4: 'Bisexual', 5: 'Pansexual', 0: 'Other, questioning, or not reported'},
}


def cell(n, tot):
    if 0 < n < MIN_CELL:
        return '<10', ''
    return str(n), f'{100 * n / tot:.1f}'


d = load()
e3 = d[d.in_e3].copy()
e3['orient_g'] = e3.orient.where(e3.orient.isin([2, 3, 4, 5]), 0)
rows = []
for v, lab in LABELS.items():
    for g, gname in [(1, 'LGBT'), (0, 'Non-LGBT')]:
        sub = e3[e3.lgbt == g]
        if v == 'orient_g' and g == 0:
            continue
        for code, name in lab.items():
            n, p = cell(int((sub[v] == code).sum()), len(sub))
            rows.append(dict(variable=v, level=name, group=gname, n=n, pct=p, total=len(sub)))
pd.DataFrame(rows).to_csv(f'{OUT}/table2.csv', index=False)

x = d[d.in_xd_main]
out = []
for v in ['phq4', 'gad2', 'phq2', 'S', 'C', 'Q']:
    s = x[v].dropna()
    out.append(dict(variable=v, n=len(s), mean=s.mean(), sd=s.std(), median=s.median(), min=s.min(), max=s.max()))
out.append(dict(variable='pct S > 0', n=int((x.S > 0).sum()), mean=100 * (x.S > 0).mean()))
out.append(dict(variable='pct PHQ-4 >= 6', n=int((x.phq4 >= 6).sum()), mean=100 * (x.phq4 >= 6).mean()))
pd.DataFrame(out).to_csv(f'{OUT}/table3_descriptives.csv', index=False)
x[['phq4', 'gad2', 'phq2', 'S', 'C', 'Q']].corr().to_csv(f'{OUT}/table3_correlations.csv')

m = d[d.in_main]
prev = []
for j in range(1, 9):
    v = m[f'stig{j}_any']
    n, p = cell(int((v == 1).sum()), int(v.notna().sum()))
    prev.append(dict(situation=f'stig{j}', n_valid=int(v.notna().sum()), n_exposed=n, pct=p))
n, p = cell(int((m.S > 0).sum()), len(m))
prev.append(dict(situation='any of 1-7', n_valid=len(m), n_exposed=n, pct=p))
pd.DataFrame(prev).to_csv(f'{OUT}/prevalence.csv', index=False)

la = d[d.in_analytic & (d.lgbt == 1)]
mis = []
for has, sub in la.groupby(la.phq4.notna()):
    mis.append(dict(comparison='LGBT analytic sample: with PHQ-4' if has else 'LGBT analytic sample: without PHQ-4',
                    n=len(sub), n_S=int(sub.S.notna().sum()), mean_S=sub.S.mean(), mean_phq4=sub.phq4.mean()))
for has, sub in m.groupby(m.in_xd_main):
    mis.append(dict(comparison='Main sample: complete XD' if has else 'Main sample: incomplete XD', n=len(sub),
                    n_S=int(sub.S.notna().sum()), mean_S=sub.S.mean(), sd_S=sub.S.std(),
                    mean_phq4=sub.phq4.mean(), sd_phq4=sub.phq4.std()))
pd.DataFrame(mis).to_csv(f'{OUT}/missing_data.csv', index=False)
print('Written to', os.path.abspath(OUT))

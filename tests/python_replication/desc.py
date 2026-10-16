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
    'orient_g': {2: 'Gay', 3: 'Lesbian', 4: 'Bisexual', 5: 'Pansexual', 0: 'Other, questioning, or not stated'},
    'ind_g': {1: 'Finance and banking', 2: 'Information technology', 3: 'Education', 5: 'Trade and services',
              6: 'Manufacturing', 7: 'Media and marketing', 11: 'Health care, tourism, or other'},
}


def cell(n, tot):
    if 0 < n < MIN_CELL:
        return '<10', ''
    return str(n), f'{100 * n / tot:.1f}'


d = load()
m = d[d.in_xd_main].copy()
m['orient_g'] = m.orient.where(m.orient.isin([2, 3, 4, 5]), 0)
m['ind_g'] = m.industry_orig.where(~m.industry_orig.isin([4, 10]), 11)
rows = []
for v, lab in LABELS.items():
    for code, name in lab.items():
        n, p = cell(int((m[v] == code).sum()), len(m))
        rows.append(dict(variable=v, level=name, n=n, pct=p, total=len(m)))
pd.DataFrame(rows).to_csv(f'{OUT}/table2.csv', index=False)

x = d[d.in_xd_main]
VARS = ['phq4', 'S', 'S_int', 'S_car', 'S_gen']
out = []
for v in VARS:
    s = x[v].dropna()
    out.append(dict(variable=v, n=len(s), mean=s.mean(), sd=s.std(), median=s.median(), min=s.min(), max=s.max()))
out.append(dict(variable='pct S > 0', n=int((x.S > 0).sum()), mean=100 * (x.S > 0).mean()))
out.append(dict(variable='pct PHQ-4 >= 6', n=int((x.phq4 >= 6).sum()), mean=100 * (x.phq4 >= 6).mean()))
pd.DataFrame(out).to_csv(f'{OUT}/table3_descriptives.csv', index=False)
x[VARS].corr().to_csv(f'{OUT}/table3_correlations.csv')


def cell_fmt(k, tot, other):
    # the cell is not reported if its count, or a count derivable from it, is 1-9
    if 0 < k < MIN_CELL:
        return f'<{MIN_CELL}', ''
    if 0 < other < MIN_CELL:
        return 'not reported', ''
    return str(k), f'{100 * k / tot:.1f}'


def freq_rows(v, codes, labels, name):
    tot = int(x[v].notna().sum())
    rows, nsupp = [], 0
    for c, lab in zip(codes, labels):
        n, p = cell_fmt(int((x[v] == c).sum()), tot, 0)
        nsupp += p == '' and n != '0'
        rows.append({name: lab, 'n': n, 'pct': p})
    if nsupp == 1:
        raise SystemExit(f'{v}: a suppressed cell can be recovered from the total')
    return pd.DataFrame(rows)


freq_rows('phq4_cat', [1, 2, 3, 4], ['0-2 (none)', '3-5 (mild)', '6-8 (moderate)', '9-12 (severe)'],
          'category').to_csv(f'{OUT}/table3_severity.csv', index=False)

LAB = {'all': 'Any of situations 1-8', 'int': 'Interpersonal: any of situations 1-3',
       'car': 'Career-related: any of situations 4-6', 'gen': 'Gender expression: any of situations 7-8',
       1: '1 Offensive jokes or comments', 2: '2 Unwanted personal questions',
       3: '3 Disclosure or threatened disclosure without consent', 4: '4 Exclusion from training or career development',
       5: '5 Unfair evaluation, pay, or promotion', 6: '6 Unfavourable work assignments',
       7: '7 Pressure to conform to gender stereotypes', 8: '8 Difficulty with name, pronouns, dress, or restrooms'}
# (label, score, any, often) in the order of Tables 4 and 5
FORMS = [(LAB['all'], 'S', 'ever_exposed', 'ever_often')]
for g, sits in [('int', [1, 2, 3]), ('car', [4, 5, 6]), ('gen', [7, 8])]:
    FORMS.append((LAB[g], 'S_' + g, g + '_any', g + '_often'))
    FORMS += [(LAB[j], f'stig{j}', f'stig{j}_any', f'stig{j}_often') for j in sits]

t4 = []
for lab, score, anyv, often in FORMS:
    valid = x[anyv].notna()
    nv, na, no = int(valid.sum()), int((x[anyv] == 1).sum()), int((x[often] == 1).sum())
    n1, p1 = cell_fmt(na, nv, nv - na)
    n2, p2 = cell_fmt(no, nv, na - no)
    sc = x.loc[valid, score]
    t4.append(dict(form=lab, n_valid=nv, n_once=n1, pct_once=p1, n_often=n2, pct_often=p2,
                   mean_score=sc.mean(), sd_score=sc.std()))
pd.DataFrame(t4).to_csv(f'{OUT}/table4.csv', index=False)

x = x.assign(S_count8_c=x.S_count8.clip(upper=3))
freq_rows('S_count8_c', [0, 1, 2, 3], ['0', '1', '2', '3 or more'], 'situations').to_csv(
    f'{OUT}/table4_number.csv', index=False)

t5 = []
for lab, score, anyv, often in FORMS:
    e, u = x[x[anyv] == 1].phq4, x[x[anyv] == 0].phq4
    ne, nu = len(e), len(u)
    if ne < MIN_CELL or nu < MIN_CELL:
        t5.append(dict(form=lab, n_exposed='<10' if ne < MIN_CELL else 'not reported',
                       n_unexposed='<10' if nu < MIN_CELL else 'not reported'))
        continue
    ke, ku = int((e >= 6).sum()), int((u >= 6).sum())
    t5.append(dict(form=lab, n_exposed=str(ne), n_unexposed=str(nu), mean_exposed=e.mean(), sd_exposed=e.std(),
                   mean_unexposed=u.mean(), sd_unexposed=u.std(), difference=e.mean() - u.mean(),
                   pct6_exposed=cell_fmt(ke, ne, ne - ke)[1], pct6_unexposed=cell_fmt(ku, nu, nu - ku)[1]))
cols = ['form', 'n_exposed', 'n_unexposed', 'mean_exposed', 'sd_exposed', 'mean_unexposed', 'sd_unexposed',
        'difference', 'pct6_exposed', 'pct6_unexposed']
pd.DataFrame(t5, columns=cols).to_csv(f'{OUT}/table5.csv', index=False)

la = d[d.in_lgbt]
mis = []
for has, sub in la.groupby(la.phq4.notna()):
    mis.append(dict(comparison='LGBT respondents: with PHQ-4' if has else 'LGBT respondents: without PHQ-4',
                    n=len(sub), n_S=int(sub.S.notna().sum()), mean_S=sub.S.mean(), mean_phq4=sub.phq4.mean()))
mm = d[d.in_main]
for has, sub in mm.groupby(mm.in_xd_main):
    mis.append(dict(comparison='Main sample: complete XD' if has else 'Main sample: incomplete XD', n=len(sub),
                    n_S=int(sub.S.notna().sum()), mean_S=sub.S.mean(), sd_S=sub.S.std(),
                    mean_phq4=sub.phq4.mean(), sd_phq4=sub.phq4.std()))
pd.DataFrame(mis).to_csv(f'{OUT}/missing_data.csv', index=False)
print('Written to', os.path.abspath(OUT))

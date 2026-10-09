# Compares the Python replication (output/tables/python_replication/results.csv)
# with the AllResults sheet of the Stata output.
# Run: STATA_RESULTS=/path/to/results.xlsx python3 tests/python_replication/compare.py
import os
import numpy as np
import pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
PY = os.path.join(HERE, '..', '..', 'output', 'tables', 'python_replication', 'results.csv')
ST = os.environ.get('STATA_RESULTS', '')
# Estimates that depend on random draws or on a different variance formula
APPROX = {('H3_ab', 'percentile bootstrap'), ('Robust', 'restricted wild bootstrap, Webb'),
          ('Robust', 'multiple imputation, m = 20'), ('AnxDep', 'suest')}
# The spline knots reach mkspline through macros, which round them slightly
TOL = 1e-5

if not os.path.isfile(ST):
    raise SystemExit('Set the environment variable STATA_RESULTS to results.xlsx')
py = pd.read_csv(PY)
st = pd.read_excel(ST, sheet_name='AllResults')
key = ['part', 'outcome', 'spec', 'term']
for d in (py, st):
    for c in ('outcome', 'spec', 'term'):
        d[c] = d[c].astype(str).str.strip()
m = st.merge(py, on=key, how='outer', suffixes=('_stata', '_py'), indicator=True)
print('rows only in Stata:', m.loc[m._merge == 'left_only', key].values.tolist())
print('rows only in Python:', m.loc[m._merge == 'right_only', key].values.tolist())
both = m[m._merge == 'both']
worst = []
for _, r in both.iterrows():
    diffs = [abs(r[c + '_stata'] - r[c + '_py']) for c in ('b', 'se', 'lb', 'ub', 'p', 'p_holm', 'p_bh', 'N')
             if not (pd.isna(r[c + '_stata']) and pd.isna(r[c + '_py']))]
    dmax = np.nanmax(diffs) if diffs else 0.0
    worst.append((r.part, r.outcome, r.spec, r.term, dmax, (r.part, r.spec) in APPROX))
w = pd.DataFrame(worst, columns=['part', 'outcome', 'spec', 'term', 'max_abs_diff', 'approximate'])
exact = w[~w.approximate]
print(f'deterministic rows: {len(exact)}, largest difference {exact.max_abs_diff.max():.2e}')
bad = exact[exact.max_abs_diff > TOL]
print('deterministic rows above tolerance:' if len(bad) else 'all deterministic rows agree')
if len(bad):
    print(bad.to_string(index=False))
print(w[w.approximate].to_string(index=False))

# Compares the Python replication (output/tables/python_replication_vi/ket_qua.csv)
# with the KetQua sheet of the Stata output of phan_tich_bai_tieng_viet.do.
# Run: STATA_RESULTS=/path/to/ket_qua.xlsx python3 tests/python_replication_vi/compare_vi.py
import os

import numpy as np
import pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
PY = os.path.join(HERE, '..', '..', 'output', 'tables', 'python_replication_vi', 'ket_qua.csv')
ST = os.environ.get('STATA_RESULTS', '')
TOL = 1e-5

if not os.path.isfile(ST):
    raise SystemExit('Set the environment variable STATA_RESULTS to ket_qua.xlsx')
py = pd.read_csv(PY, keep_default_na=False, na_values=[''])
st = pd.read_excel(ST, sheet_name='KetQua')
key = ['part', 'outcome', 'spec', 'term']
for d in (py, st):
    for c in key:
        d[c] = d[c].astype(str).str.strip()
m = st.merge(py, on=key, how='outer', suffixes=('_stata', '_py'), indicator=True)
print('rows only in Stata:', m.loc[m._merge == 'left_only', key].values.tolist())
print('rows only in Python:', m.loc[m._merge == 'right_only', key].values.tolist())
both = m[m._merge == 'both']
worst = []
for _, r in both.iterrows():
    diffs = [abs(r[c + '_stata'] - r[c + '_py']) for c in ('b', 'se', 'lb', 'ub', 'p', 'p_bh', 'N')
             if not (pd.isna(r[c + '_stata']) and pd.isna(r[c + '_py']))]
    worst.append((r.part, r.spec, r.term, np.nanmax(diffs) if diffs else 0.0))
w = pd.DataFrame(worst, columns=['part', 'spec', 'term', 'max_abs_diff'])
print(f'rows compared: {len(w)}, largest difference {w.max_abs_diff.max():.2e}')
bad = w[w.max_abs_diff > TOL]
print('rows above tolerance:' if len(bad) else 'all rows agree')
if len(bad):
    print(bad.to_string(index=False))

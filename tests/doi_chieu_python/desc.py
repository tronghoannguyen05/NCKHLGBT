# Thống kê mô tả cho bài báo. Chỉ xuất số tổng hợp; ô dưới 10 người được ẩn.
# Chạy: LGBT_DATA=/đường/dẫn/tệp.xlsx python3 tests/doi_chieu_python/desc.py
import os
import warnings
warnings.filterwarnings('ignore')
import numpy as np
import pandas as pd
from prep import load

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'output', 'tables', 'doi_chieu_python')
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
pd.DataFrame(rows).to_csv(f'{OUT}/DacDiemMau.csv', index=False)

x = d[d.in_xd_main]
out = []
for v in ['phq4', 'gad2', 'phq2', 'S', 'C', 'Q']:
    s = x[v].dropna()
    out.append(dict(bien=v, n=len(s), tb=s.mean(), sd=s.std(), trung_vi=s.median(), nho_nhat=s.min(), lon_nhat=s.max()))
out.append(dict(bien='ty_le_S>0', n=int((x.S > 0).sum()), tb=100 * (x.S > 0).mean()))
out.append(dict(bien='ty_le_PHQ>=6', n=int((x.phq4 >= 6).sum()), tb=100 * (x.phq4 >= 6).mean()))
pd.DataFrame(out).to_csv(f'{OUT}/MoTaBien.csv', index=False)
x[['phq4', 'gad2', 'phq2', 'S', 'C', 'Q']].corr().to_csv(f'{OUT}/TuongQuan.csv')

m = d[d.in_main]
prev = []
for j in range(1, 9):
    v = m[f'stig{j}_any']
    n, p = cell(int((v == 1).sum()), int(v.notna().sum()))
    prev.append(dict(tinh_huong=f'stig{j}', n_hop_le=int(v.notna().sum()), n_gap=n, ty_le=p))
n, p = cell(int((m.S > 0).sum()), len(m))
prev.append(dict(tinh_huong='S>0 (7 câu)', n_hop_le=len(m), n_gap=n, ty_le=p))
pd.DataFrame(prev).to_csv(f'{OUT}/TyLeKyThi.csv', index=False)

la = d[d.in_analytic & (d.lgbt == 1)]
mis = []
for has, sub in la.groupby(la.phq4.notna()):
    mis.append(dict(so_sanh='LGBT phân tích: có PHQ-4' if has else 'LGBT phân tích: không có PHQ-4',
                    n=len(sub), n_S=int(sub.S.notna().sum()), tb_S=sub.S.mean(), tb_phq4=sub.phq4.mean()))
for has, sub in m.groupby(m.in_xd_main):
    mis.append(dict(so_sanh='Mẫu chính: đủ XD' if has else 'Mẫu chính: thiếu XD', n=len(sub),
                    n_S=int(sub.S.notna().sum()), tb_S=sub.S.mean(), sd_S=sub.S.std(),
                    tb_phq4=sub.phq4.mean(), sd_phq4=sub.phq4.std()))
pd.DataFrame(mis).to_csv(f'{OUT}/SoSanhKhuyet.csv', index=False)
print('Đã ghi vào', os.path.abspath(OUT))

# Replicates sections 1, 2 and 5 of phan_tich_bai_tieng_viet.do (import, coding,
# samples, merging of sparse categories). Uses the helpers of the replication of
# phan_tich.do. Prints aggregate figures only.
# The survey export is found as in the do-file (data/raw/, data/ or the
# repository root); the environment variable LGBT_DATA, if set, takes precedence.
import os
import sys

import warnings
import numpy as np
import pandas as pd
warnings.simplefilter("ignore", pd.errors.PerformanceWarning)

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'python_replication'))
from prep import (RAW, SUBST, XD, PHQI, STIG8, STIG_I, STIG_C, STIG_G, MIN_LEVEL,  # noqa: E402
                  map_codes, num, collapse_sparse)

ORG = ['orgtype', 'orgsize']
ORDERED = ['agegrp', 'educ', 'orgsize']
DEI = ['dei1', 'dei2', 'dei3', 'dei4']
POL = [f'pol{j}' for j in range(1, 6)]
XDO_D = [v + '_d' for v in XD + ORG]
XDO_A = [v + '_a' for v in XD + ORG]


def load():
    if not os.path.isfile(RAW):
        raise SystemExit('Survey export not found: put it in data/raw/ or set LGBT_DATA to its path')
    r = pd.read_excel(RAW, dtype=str, keep_default_na=False)
    r = r.apply(lambda c: c.str.strip())
    d = pd.DataFrame(index=r.index)
    d['n_answered'] = (r[SUBST] != '').sum(axis=1)
    d['age18'] = map_codes(r.s1_age18, 'co khong', [1, 0])
    d['has_job'] = map_codes(r.s2_has_job, 'co khong', [1, 0])
    d['lgbt_self'] = map_codes(r.c17_lgbt_self_id, 'co khong khong_chac kmtl', [1, 0, 8, 9])
    d['orient'] = map_codes(r.c16_sexual_orientation,
                            'di_tinh gay lesbian bisexual pansexual khac dang_tu_xd kmtl', [1, 2, 3, 4, 5, 6, 7, 9])
    d['gender_id'] = map_codes(r.c15_gender_identity, 'nam nu nam_ctg nu_ctg phi_nhi_nguyen khac kmtl',
                               [1, 2, 3, 4, 5, 6, 9])
    d['sex_birth'] = map_codes(r.c14_sex_assigned, 'nam nu kmtl', [1, 2, 9])
    d['agegrp'] = map_codes(r.c1_age_group, '1824 2534 3544 4554 tu55 kmtl', [1, 2, 3, 4, 4, 9])
    d['educ'] = map_codes(r.c2_education, 'thpt cd dh sdh kmtl', [1, 2, 3, 4, 9])
    d['relstat'] = map_codes(r.c11_relationship, 'doc_than co_bandoi ly_than kmtl', [1, 2, 3, 9])
    d['region'] = map_codes(r.c10_province, 'hn hcm dn khac kmtl', [1, 2, 3, 4, 9])
    d['industry'] = map_codes(r.c4_industry, 'tcnh cntt gd yt tmdv sxcn ttmkt dlnhks khac kmtl',
                              [1, 2, 3, 4, 5, 6, 7, 10, 11, 9])
    d['emptype'] = map_codes(r.c6_employment, 'tt_luong bt_luong thoivu ctv freelancer khac kmtl',
                             [1, 2, 3, 4, 5, 7, 9])
    d['orgtype'] = map_codes(r.c8_employer_type, 'nn tn_trongnuoc fdi ngo tudoanh khac kmtl', [1, 2, 3, 4, 5, 6, 9])
    d['orgsize'] = map_codes(r.c9_employer_size, 'duoi50 50199 200499 tu500 kad_kr kmtl', [1, 2, 3, 4, 97, 9])
    d['src20'] = map_codes(r.c20_source, 'ql_truc_tiep dong_nghiep khach_hang nhan_su khac kmtl', [1, 2, 3, 4, 5, 9])
    for j in range(1, 6):
        d[f'pol{j}'] = map_codes(r[f'c23_{j}'], 'co khong khong_biet', [1, 0, 8])
    d['c25_any'] = r.c25_suggestion != ''
    d['phqi1'] = num(r.c21_1)
    d['phqi2'] = num(r.c21_2)
    d['phqi3'] = num(r.c21_4)
    d['phqi4'] = num(r.c21_3)
    for j in range(1, 9):
        d[f'stig{j}'] = num(r[f'c19_{j}'])
    for j in range(1, 5):
        d[f'dei{j}'] = num(r[f'c24_{j}'])
    assert d[PHQI].stack().dropna().between(0, 3).all()
    assert d[STIG8].stack().dropna().isin([0, 1, 2, 3, 4, 9]).all()
    assert d[DEI].stack().dropna().isin([1, 2, 3, 4, 5, 9]).all()

    # section 2: derived variables and sample indicators
    d['in_base'] = (d.has_job == 1) & (d.n_answered > 0)
    d['lgbt'] = (d.lgbt_self == 1).astype(int)
    d['in_lgbt'] = d.in_base & (d.lgbt == 1)
    assert (d.loc[d.in_base, 'age18'] == 1).all()
    d['gmin'] = np.select([d.gender_id.isin([1, 2]), d.gender_id.isin([3, 4, 5, 6]), d.gender_id == 9],
                          [0, 1, 9], np.nan)
    d['orientg'] = np.select([d.orient == 2, d.orient == 3, d.orient.isin([4, 5]), d.orient.isin([1, 6, 7]),
                              d.orient == 9], [1, 2, 3, 98, 9], np.nan)
    for v in STIG8 + DEI:
        d.loc[d[v] == 9, v] = np.nan
    d['phq_n'] = d[PHQI].notna().sum(axis=1)
    d['phq4'] = d[PHQI].sum(axis=1, min_count=4).where(d.phq_n == 4)

    L = d.lgbt == 1
    d['S_n'] = d[STIG8].notna().sum(axis=1)
    d['S'] = d[STIG8].mean(axis=1).where((d.S_n >= 6) & L)
    d['S_count8'] = d[STIG8].isin([1, 2, 3, 4]).sum(axis=1).astype(float).where(d.S.notna())
    d['S_int'] = d[STIG_I].mean(axis=1).where((d[STIG_I].notna().sum(axis=1) >= 2) & L)
    d['S_car'] = d[STIG_C].mean(axis=1).where((d[STIG_C].notna().sum(axis=1) >= 2) & L)
    d['S_gen'] = d[STIG_G].mean(axis=1).where(L)
    for j in range(1, 9):
        v = d[f'stig{j}']
        d[f'stig{j}_any'] = (v >= 1).astype(float).where(v.notna())
        d[f'stig{j}_often'] = (v >= 3).astype(float).where(v.notna())
    d['ever_exposed'] = (d.S > 0).astype(float).where(d.S.notna())
    d['ever_often'] = (d[STIG8].max(axis=1) >= 3).astype(float).where(d.S.notna())
    for g, items in [('int', STIG_I), ('car', STIG_C), ('gen', STIG_G)]:
        sg = d['S_' + g]
        d[g + '_any'] = (sg > 0).astype(float).where(sg.notna())
        d[g + '_often'] = (d[items].max(axis=1) >= 3).astype(float).where(sg.notna())

    d['Q_n'] = d[DEI].notna().sum(axis=1)
    d['Q'] = d[DEI].mean(axis=1).where(d.Q_n >= 3)
    d['pol_n'] = d[POL].notna().sum(axis=1)
    d['npol_co'] = (d[POL] == 1).sum(axis=1).astype(float).where(d.pol_n == 5)
    d['npol_kb'] = (d[POL] == 8).sum(axis=1).astype(float).where(d.pol_n == 5)
    d['npol_lo'] = d.npol_co
    d['npol_hi'] = d.npol_co + d.npol_kb
    d['src20c'] = d.src20.fillna(0)

    d['in_main'] = d.in_lgbt & d.phq4.notna() & d.S.notna()
    d['in_xd_main'] = d.in_main & d[XD].notna().all(axis=1)
    d['in_h3'] = d.in_xd_main & d.Q.notna()
    d['in_org'] = d.orgtype.notna() & d.emptype.notna() & (d.orgtype != 5) & (d.emptype != 5)
    d['in_dei_all'] = d.in_xd_main & (d.pol_n == 5) & d.Q.notna() & d.orgtype.notna() & d.orgsize.notna()
    d['in_dei'] = d.in_dei_all & d.in_org

    # section 5: merging sparse categories; copies for the DEI samples come from the original codes
    for v in XD + ORG:
        d[v + '_d'] = d[v].copy()
        d[v + '_a'] = d[v].copy()
    log = []
    for v in XD:
        collapse_sparse(d, v, d.in_xd_main, 'ordered' if v in ORDERED else 'nominal', log)
    for s, touse in (('d', d.in_dei), ('a', d.in_dei_all)):
        for v in XD + ORG:
            collapse_sparse(d, v + '_' + s, touse, 'ordered' if v in ORDERED else 'nominal', log)
    d.attrs['collapse_log'] = log
    return d


if __name__ == '__main__':
    d = load()
    print('flow', len(d), int((d.has_job == 1).sum()), int(d.in_base.sum()), int(d.in_lgbt.sum()),
          [(s, int(d[s].sum())) for s in ['in_main', 'in_xd_main', 'in_h3', 'in_dei', 'in_dei_all']])
    print('collapse', d.attrs['collapse_log'])

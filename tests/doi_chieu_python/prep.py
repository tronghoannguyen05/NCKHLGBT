# Tái lập mục 1-5 của phan_tich.do. Chỉ in số tổng hợp.
# Đường dẫn tệp dữ liệu: biến môi trường LGBT_DATA.
import os
import numpy as np
import pandas as pd

RAW = os.environ.get('LGBT_DATA', '')

XD = ['agegrp', 'sex_birth', 'educ', 'relstat', 'region']
XJ = ['exper', 'industry', 'position', 'emptype', 'orgtype', 'orgsize', 'socins', 'hours']
ORDERED = ['agegrp', 'educ', 'exper', 'orgsize', 'hours']
PHQI = ['phqi1', 'phqi2', 'phqi3', 'phqi4']
STIG7 = [f'stig{j}' for j in range(1, 8)]
STIG8 = [f'stig{j}' for j in range(1, 9)]
CONC = ['conc1', 'conc2', 'conc3', 'conc4']
CONC3 = ['conc1', 'conc2', 'conc3']
DEI = ['dei1', 'dei2', 'dei3', 'dei4']
MIN_LEVEL = 5


def map_codes(s, frm, to):
    m = dict(zip(frm.split(), to))
    out = s.map(m).astype(float)
    bad = (s != '') & out.isna()
    if bad.any():
        raise ValueError(f'unmapped values in {s.name}: {sorted(s[bad].unique())}')
    return out


def num(s):
    return pd.to_numeric(s.replace('', np.nan))


def stata_median(x):
    x = np.sort(np.asarray(x, float))
    return np.median(x)


def stata_pctile(x, p):
    x = np.sort(np.asarray(x, float))
    n = len(x)
    P = n * p / 100
    if abs(P - round(P)) < 1e-12:
        i = int(round(P))
        return (x[i - 1] + x[i]) / 2
    return x[int(np.floor(P))]


def modal_level(d, v, touse, exclude):
    levs = sorted(d.loc[touse, v].dropna().unique())
    best, bestn = None, -1
    for l in levs:
        if l in exclude:
            continue
        n = int(((d[v] == l) & touse).sum())
        if n > bestn:
            best, bestn = l, n
    return best


def collapse_sparse(d, v, touse, kind, log, special=(9, 97), pooled=98, mn=MIN_LEVEL):
    for _ in range(50):
        levs = sorted(d.loc[touse, v].dropna().unique())
        if len(levs) <= 1:
            return
        l = None
        for x in levs:
            if ((d[v] == x) & touse).sum() < mn:
                l = x
                break
        if l is None:
            return
        target = None
        if l in special:
            target = pooled if pooled in levs else modal_level(d, v, touse, list(special))
        elif kind == 'ordered':
            excl = list(special) + [pooled]
            med = stata_median(d.loc[touse & ~d[v].isin(excl) & d[v].notna(), v])
            up = down = None
            for x in levs:
                if x in excl:
                    continue
                if x > l and up is None:
                    up = x
                if x < l:
                    down = x
            if l < med:
                target = up if up is not None else down
            else:
                target = down if down is not None else up
        else:
            target = modal_level(d, v, touse, [pooled] + list(special)) if l == pooled else pooled
        if target is None or target == l:
            return
        d.loc[d[v] == l, v] = target
        log.append((v, l, target))
    raise RuntimeError('too many loops')


def load():
    if not os.path.isfile(RAW):
        raise SystemExit('Đặt biến môi trường LGBT_DATA trỏ tới tệp .xlsx')
    r = pd.read_excel(RAW, dtype=str, keep_default_na=False)
    r = r.apply(lambda c: c.str.strip())
    d = pd.DataFrame(index=r.index)
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
    d['exper'] = map_codes(r.c3_experience, 'duoi1 13 35 510 tu10 kmtl', [1, 2, 3, 4, 5, 9])
    d['industry'] = map_codes(r.c4_industry, 'tcnh cntt gd yt tmdv sxcn ttmkt dlnhks khac kmtl',
                              [1, 2, 3, 4, 5, 6, 7, 10, 11, 9])
    d['position'] = map_codes(r.c5_position, 'nv tn_gs qlct qlcc kad_khac kmtl', [1, 2, 3, 4, 6, 9])
    d['emptype'] = map_codes(r.c6_employment, 'tt_luong bt_luong thoivu ctv freelancer khac kmtl',
                             [1, 2, 3, 4, 5, 7, 9])
    d['orgtype'] = map_codes(r.c8_employer_type, 'nn tn_trongnuoc fdi ngo tudoanh khac kmtl', [1, 2, 3, 4, 5, 6, 9])
    d['orgsize'] = map_codes(r.c9_employer_size, 'duoi50 50199 200499 tu500 kad_kr kmtl', [1, 2, 3, 4, 97, 9])
    d['socins'] = map_codes(r.c7_social_insurance, 'co khong kad kr kmtl', [1, 2, 3, 4, 9])
    d['hours'] = map_codes(r.c13_hours, 'duoi20 2035 3545 4555 tu55 kxd_kmtl', [1, 2, 3, 4, 5, 9])
    d['phqi1'] = num(r.c21_1)
    d['phqi2'] = num(r.c21_2)
    d['phqi3'] = num(r.c21_4)
    d['phqi4'] = num(r.c21_3)
    for j in range(1, 9):
        d[f'stig{j}'] = num(r[f'c19_{j}'])
    for j in range(1, 5):
        d[f'conc{j}'] = num(r[f'c22_{j}'])
        d[f'dei{j}'] = num(r[f'c24_{j}'])

    assert d[PHQI].stack().dropna().between(0, 3).all()
    assert d[STIG8].stack().dropna().isin([0, 1, 2, 3, 4, 9]).all()
    assert d[CONC].stack().dropna().between(1, 5).all()
    assert d[DEI].stack().dropna().isin([1, 2, 3, 4, 5, 9]).all()

    # mục 2
    d['eligible'] = ((d.age18 == 1) & (d.has_job == 1)).astype(int)
    d['lgbt'] = np.where(d.lgbt_self == 1, 1, np.where(d.lgbt_self == 0, 0, np.nan))
    d['in_analytic'] = (d.eligible == 1) & d.lgbt.notna()
    gm = d.gender_id.isin([3, 4, 5, 6]).astype(float)
    gm[d.gender_id.isna() | (d.gender_id == 9)] = np.nan
    d['gender_minority'] = gm
    d['orient3'] = np.select([d.orient.isin([4, 5]), d.orient == 3, d.orient == 2], [1, 2, 3], np.nan)
    for v in STIG8 + DEI:
        d.loc[d[v] == 9, v] = np.nan
    for v in XD:
        d[v + '_alt'] = d[v].where(d[v] != 9)

    d['phq_n'] = d[PHQI].notna().sum(1)
    d['phq4'] = d[PHQI].sum(1, min_count=4).where(d.phq_n == 4)
    d['gad2'] = d.phqi1 + d.phqi2
    d['phq2'] = d.phqi3 + d.phqi4
    d['phq4_frac'] = d.phq4 / 12
    d['phq_ge6'] = (d.phq4 >= 6).astype(float).where(d.phq4.notna())
    d['phq4_zero'] = (d.phq4 == 0).astype(float).where(d.phq4.notna())

    L = d.lgbt == 1
    d['S_n'] = d[STIG7].notna().sum(1)
    d['S'] = d[STIG7].mean(1).where((d.S_n >= 4) & L)
    d['S8_n'] = d[STIG8].notna().sum(1)
    d['S8'] = d[STIG8].mean(1).where((d.S8_n >= 4) & L)
    d['S_count7'] = d[STIG7].isin([1, 2, 3, 4]).sum(1).astype(float).where((d.S_n >= 4) & L)
    d['S_complete7'] = d.S.where(d.S_n == 7)
    for j in range(1, 9):
        d[f'stig{j}_any'] = (d[f'stig{j}'] >= 1).astype(float).where(d[f'stig{j}'].notna())
    d['ever_exposed'] = (d.S > 0).astype(float).where(d.S.notna())
    d['S_exposed'] = np.where(d.ever_exposed == 1, d.S, 0.0)
    d.loc[d.S.isna(), 'S_exposed'] = np.nan

    d['C'] = d[CONC].mean(1).where((d[CONC].notna().sum(1) == 4) & L)
    d['C3'] = d[CONC3].mean(1).where((d[CONC3].notna().sum(1) == 3) & L)
    d['Q'] = d[DEI].mean(1).where(d[DEI].notna().sum(1) >= 3)

    def flat(cols):
        full = d[cols].notna().sum(1) == len(cols)
        return full & (d[cols].std(1, ddof=1) == 0)
    d['flag_straight'] = flat(PHQI) & flat(CONC) & flat(DEI)
    d['flag_contra'] = (d.agegrp == 1) & (d.position == 4)
    d['flag_quality'] = (d.flag_straight | d.flag_contra).astype(int)

    d['in_e3'] = d.in_analytic & (d.phq_n == 4)
    d['in_main'] = d.in_analytic & L & d.phq4.notna() & d.S.notna()
    d['in_xd_main'] = d.in_main & d[XD].notna().all(1)
    d['in_xd_alt'] = d.in_main & d[[v + '_alt' for v in XD]].notna().all(1)
    d['in_xj'] = d.in_xd_main & d[XJ].notna().all(1)
    d['in_e5'] = d.in_xd_main & d.Q.notna()
    d['Qc'] = d.Q - d.loc[d.in_e5, 'Q'].mean()

    med = stata_median(d.loc[d.in_main & (d.S > 0), 'S'])
    d['S3'] = np.select([d.S == 0, (d.S > 0) & (d.S <= med), d.S > med], [0, 1, 2], np.nan)
    d.loc[d.S.isna(), 'S3'] = np.nan
    d['lgbt_consistent'] = L & (d.orient.between(2, 6) | (d.gender_minority == 1))

    # mục 5: gộp mức thưa
    for v in XD:
        d[v + '_orig'] = d[v].copy()
    log = []
    for v in XD:
        collapse_sparse(d, v, d.in_xd_main, 'ordered' if v in ORDERED else 'nominal', log)
    for v in XD:
        collapse_sparse(d, v + '_alt', d.in_xd_alt, 'ordered' if v in ORDERED else 'nominal', log)
    for v in XJ:
        collapse_sparse(d, v, d.in_xj, 'ordered' if v in ORDERED else 'nominal', log)
    d.attrs['collapse_log'] = log
    d.attrs['S_med_exposed'] = med
    return d


if __name__ == '__main__':
    d = load()
    print('flow', len(d), int(d.eligible.sum()),
          [(s, int(d[s].sum()), int((d[s] & (d.lgbt == 0)).sum()), int((d[s] & (d.lgbt == 1)).sum()))
           for s in ['in_analytic', 'in_e3', 'in_main', 'in_xd_main', 'in_xd_alt', 'in_e5']])
    print('collapse', d.attrs['collapse_log'])
    e3 = d[d.in_e3]
    print(e3.groupby('lgbt')[['phq4', 'gad2', 'phq2']].agg(['mean', 'std']).round(6).to_string())
    print(e3.groupby('lgbt').phq4_zero.mean())

    def alpha(X):
        X = X.dropna()
        k = X.shape[1]
        return k / (k - 1) * (1 - X.var(ddof=1).sum() / X.sum(1).var(ddof=1)), len(X)
    print('alpha phq4', alpha(e3[PHQI]))
    print('r gad2', e3[['phqi1', 'phqi2']].corr().iloc[0, 1], 'r phq2', e3[['phqi3', 'phqi4']].corr().iloc[0, 1])
    la = d[d.in_analytic & (d.lgbt == 1)]
    print('alpha conc', alpha(la[CONC]), 'alpha dei', alpha(d.loc[d.in_analytic, DEI]),
          'alpha s7', alpha(la[STIG7]), 'alpha s8', alpha(la[STIG8]))
    m = d[d.in_main]
    for j in range(1, 9):
        v = m[f'stig{j}_any']
        print(f'stig{j}', int(v.notna().sum()), int((v == 1).sum()))
    print('S_med_exposed', d.attrs['S_med_exposed'])

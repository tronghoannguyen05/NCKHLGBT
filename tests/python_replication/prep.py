# Replicates sections 1-5 of phan_tich.do (import, coding, samples, merging of
# sparse categories). Prints aggregate figures only.
# The survey export is found as in phan_tich.do: data/raw/, data/ or the
# repository root, first workbook that contains the variables of the export.
# The environment variable LGBT_DATA, if set, takes precedence.
import os
import numpy as np
import pandas as pd

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REQUIRED = ['s1_age18', 's2_has_job', 'c17_lgbt_self_id', 'c19_1', 'c21_1']


def find_data(root=ROOT):
    if os.environ.get('LGBT_DATA'):
        return os.environ['LGBT_DATA']
    for sub in ('data/raw', 'data', '.'):
        folder = os.path.join(root, sub)
        if not os.path.isdir(folder):
            continue
        for name in sorted(os.listdir(folder)):
            if not name.lower().endswith('.xlsx') or name.startswith('~'):
                continue
            path = os.path.join(folder, name)
            try:
                cols = pd.read_excel(path, nrows=0).columns
            except Exception:
                continue
            if all(c in cols for c in REQUIRED):
                return path
    return ''


RAW = find_data()

XD = ['agegrp', 'educ', 'sex_birth', 'gmin', 'orientg', 'relstat', 'region', 'industry']
XJ = ['exper', 'position', 'emptype', 'orgtype', 'orgsize', 'socins', 'hours']
ORDERED = ['agegrp', 'educ', 'exper', 'orgsize', 'hours']
PHQI = ['phqi1', 'phqi2', 'phqi3', 'phqi4']
STIG7 = [f'stig{j}' for j in range(1, 8)]
STIG8 = [f'stig{j}' for j in range(1, 9)]
STIG_I = ['stig1', 'stig2', 'stig3']
STIG_C = ['stig4', 'stig5', 'stig6']
STIG_G = ['stig7', 'stig8']
RQ1 = ['S_int', 'S_car', 'S_gen']
# The two other Likert scales of the questionnaire, used only for the response-quality flag
CONC = ['conc1', 'conc2', 'conc3', 'conc4']
DEI = ['dei1', 'dei2', 'dei3', 'dei4']
MIN_LEVEL = 5
# Questions after the screening block; any answer counts as substantive data
SUBST = (['c1_age_group', 'c2_education', 'c3_experience', 'c4_industry', 'c5_position', 'c6_employment',
          'c7_social_insurance', 'c8_employer_type', 'c9_employer_size', 'c10_province', 'c11_relationship',
          'c13_hours', 'c14_sex_assigned', 'c15_gender_identity', 'c16_sexual_orientation', 'c17_lgbt_self_id']
         + [f'c19_{j}' for j in range(1, 9)] + [f'c21_{j}' for j in range(1, 5)]
         + [f'c22_{j}' for j in range(1, 5)] + [f'c24_{j}' for j in range(1, 5)])


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
    d['disclose'] = map_codes(r.c18_disclosure, 'chua_ck vai_dn dn_va_ql rong_rai kad_kmtl', [1, 2, 4, 5, 9])
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

    # section 2: derived variables and sample indicators
    d['in_base'] = (d.has_job == 1) & (d.n_answered > 0)
    d['lgbt'] = (d.lgbt_self == 1).astype(int)
    d['in_lgbt'] = d.in_base & (d.lgbt == 1)
    assert (d.loc[d.in_base, 'age18'] == 1).all()
    d['gmin'] = np.select([d.gender_id.isin([1, 2]), d.gender_id.isin([3, 4, 5, 6]), d.gender_id == 9], [0, 1, 9], np.nan)
    d['orientg'] = np.select([d.orient == 2, d.orient == 3, d.orient.isin([4, 5]), d.orient.isin([1, 6, 7]), d.orient == 9],
                             [1, 2, 3, 98, 9], np.nan)
    for v in STIG8 + DEI:
        d.loc[d[v] == 9, v] = np.nan
    for v in XD:
        d[v + '_alt'] = d[v].where(d[v] != 9)

    d['phq_n'] = d[PHQI].notna().sum(axis=1)
    d['phq4'] = d[PHQI].sum(axis=1, min_count=4).where(d.phq_n == 4)
    d['phq4_frac'] = d.phq4 / 12
    d['phq4_zero'] = (d.phq4 == 0).astype(float).where(d.phq4.notna())

    L = d.lgbt == 1
    d['S_n'] = d[STIG8].notna().sum(axis=1)
    d['S'] = d[STIG8].mean(axis=1).where((d.S_n >= 6) & L)
    d['S7'] = d[STIG7].mean(axis=1).where((d[STIG7].notna().sum(axis=1) >= 4) & L)
    d['S_count8'] = d[STIG8].isin([1, 2, 3, 4]).sum(axis=1).astype(float).where(d.S.notna())
    d['S_complete8'] = d.S.where(d.S_n == 8)
    d['S_int'] = d[STIG_I].mean(axis=1).where((d[STIG_I].notna().sum(axis=1) >= 2) & L)
    d['S_car'] = d[STIG_C].mean(axis=1).where((d[STIG_C].notna().sum(axis=1) >= 2) & L)
    d['S_gen'] = d[STIG_G].mean(axis=1).where(L)
    # experienced at least once (any) and often or very often (often)
    for j in range(1, 9):
        v = d[f'stig{j}']
        d[f'stig{j}_any'] = (v >= 1).astype(float).where(v.notna())
        d[f'stig{j}_often'] = (v >= 3).astype(float).where(v.notna())
    d['ever_exposed'] = (d.S > 0).astype(float).where(d.S.notna())
    d['S_exposed'] = np.where(d.ever_exposed == 1, d.S, 0.0)
    d.loc[d.S.isna(), 'S_exposed'] = np.nan
    d['ever_often'] = (d[STIG8].max(axis=1) >= 3).astype(float).where(d.S.notna())
    for g, items in [('int', STIG_I), ('car', STIG_C), ('gen', STIG_G)]:
        sg = d['S_' + g]
        d[g + '_any'] = (sg > 0).astype(float).where(sg.notna())
        d[g + '_often'] = (d[items].max(axis=1) >= 3).astype(float).where(sg.notna())
    # PHQ-4 severity categories (Kroenke et al., 2009)
    d['phq4_cat'] = pd.cut(d.phq4, [-1, 2, 5, 8, 12], labels=[1, 2, 3, 4]).astype(float)

    def flat(cols):
        full = d[cols].notna().sum(axis=1) == len(cols)
        return full & (d[cols].std(axis=1, ddof=1) == 0)
    d['flag_straight'] = flat(PHQI) & flat(CONC) & flat(DEI)
    d['flag_contra'] = (d.agegrp == 1) & (d.position == 4)
    d['flag_quality'] = (d.flag_straight | d.flag_contra).astype(int)

    d['in_main'] = d.in_lgbt & d.phq4.notna() & d.S.notna()
    d['in_xd_main'] = d.in_main & d[XD].notna().all(axis=1)
    d['in_xd_alt'] = d.in_main & d[[v + '_alt' for v in XD]].notna().all(axis=1)
    d['in_xj'] = d.in_xd_main & d[XJ].notna().all(axis=1)
    d['in_rq1'] = d.in_xd_main & d[RQ1].notna().all(axis=1)

    med = stata_median(d.loc[d.in_xd_main & (d.S > 0), 'S'])
    d['S3'] = np.select([d.S == 0, (d.S > 0) & (d.S <= med), d.S > med], [0, 1, 2], np.nan)
    d.loc[d.S.isna(), 'S3'] = np.nan
    d['lgbt_consistent'] = L & (d.orient.between(2, 6) | (d.gmin == 1))

    # section 5: merging sparse covariate categories
    for v in XD:
        d[v + '_orig'] = d[v].copy()
    d['exper_ph'] = d.exper.copy()
    d['disclose_ph'] = d.disclose.copy()
    log = []
    for v in XD:
        collapse_sparse(d, v, d.in_xd_main, 'ordered' if v in ORDERED else 'nominal', log)
    for v in XD:
        collapse_sparse(d, v + '_alt', d.in_xd_alt, 'ordered' if v in ORDERED else 'nominal', log)
    for v in XJ:
        collapse_sparse(d, v, d.in_xj, 'ordered' if v in ORDERED else 'nominal', log)
    d['in_ph_exper'] = d.in_xd_main & d.exper_ph.notna()
    d['in_ph_disc'] = d.in_xd_main & d.disclose_ph.notna()
    collapse_sparse(d, 'exper_ph', d.in_ph_exper, 'ordered', log)
    collapse_sparse(d, 'disclose_ph', d.in_ph_disc, 'ordered', log)
    d.attrs['collapse_log'] = log
    d.attrs['S_med_exposed'] = med
    return d


if __name__ == '__main__':
    d = load()
    print('flow', len(d), int((d.has_job == 1).sum()), int(d.in_base.sum()), int(d.in_lgbt.sum()),
          [(s, int(d[s].sum())) for s in ['in_main', 'in_xd_main', 'in_xd_alt', 'in_rq1']])
    print('collapse', d.attrs['collapse_log'])
    m = d[d.in_xd_main]
    print('phq4 estimation sample', round(m.phq4.mean(), 6), round(m.phq4.std(), 6), int(m.phq4.count()),
          round(m.phq4_zero.mean(), 6))

    def alpha(X):
        X = X.dropna()
        k = X.shape[1]
        return k / (k - 1) * (1 - X.var(ddof=1).sum() / X.sum(axis=1).var(ddof=1)), len(X)
    for name, cols in [('PHQ-4', PHQI), ('S8', STIG8), ('interpersonal', STIG_I), ('career', STIG_C),
                       ('gender expression', STIG_G)]:
        print('alpha', name, alpha(m[cols]))
    for j in range(1, 9):
        v = m[f'stig{j}_any']
        print(f'stig{j}', int(v.notna().sum()), int((v == 1).sum()))
    print('S_med_exposed', d.attrs['S_med_exposed'])

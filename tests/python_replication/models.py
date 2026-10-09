# Replicates sections 5-13 of phan_tich.do. Writes aggregate results only.
# Run: LGBT_DATA=/path/to/export.xlsx python3 tests/python_replication/models.py
import warnings
warnings.filterwarnings('ignore')
import numpy as np
import pandas as pd
from scipy import stats, optimize
from prep import load, XD, XJ, STIG7, STIG8, stata_pctile
from reg import lincom, build, ols

SEED = 20260928
SESOI = 1.0
import os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'output', 'tables', 'python_replication')
os.makedirs(OUT, exist_ok=True)


from models_helpers import ols_safe, R


rows = []


def post(part, outcome, spec, term, b=np.nan, se=np.nan, lb=np.nan, ub=np.nan, p=np.nan, N=np.nan, note=''):
    rows.append(dict(part=part, outcome=outcome, spec=spec, term=term, b=b, se=se, lb=lb, ub=ub, p=p, N=N, note=note))


def postf(f, part, outcome, spec, term, note=''):
    post(part, outcome, spec, term, f.b[term], f.se[term], f.lb[term], f.ub[term], f.p[term], f.n, note)


d = load()
xdalt = [v + '_alt' for v in XD]

# Table S1, after merging sparse categories
f = R(d, 'phq4', d.in_xd_main, factors=XD)
for t in f.names:
    if t == '_cons':
        continue
    lev, var = t.split('.', 1)
    if ((d.loc[f.sample, var] == float(lev)).sum()) < 10:
        post('TableS1', 'phq4', 'XD', t, note='Fewer than 10 respondents: not reported')
    else:
        postf(f, 'TableS1', 'phq4', 'XD', t)

# ---------------- 6. H1, H2a, H2b
for y, h in [('phq4', 'H1'), ('gad2', 'H2a'), ('phq2', 'H2b')]:
    f = R(d, y, d.in_xd_main, cont=['S'], factors=XD)
    postf(f, h, y, 'XD', 'S', f'MDE approx. {2.8 * f.se["S"]:.2f}')
    sdS = d.loc[f.sample, 'S'].std(ddof=1)
    sdY = d.loc[f.sample, y].std(ddof=1)
    post('PerSD', y, 'XD, per SD of S', 'S', f.b['S'] * sdS, f.se['S'] * sdS, f.lb['S'] * sdS, f.ub['S'] * sdS,
         f.p['S'], f.n, f'SD of S = {sdS:.3f}; standardized coefficient = {f.b["S"] * sdS / sdY:.3f}')
    if y == 'phq4':
        bS, seS, df = f.b['S'], f.se['S'], f.df
        q = stats.t.ppf(0.95, df)
        lo90, hi90 = bS - q * seS, bS + q * seS
        p1 = stats.t.sf((bS + SESOI) / seS, df)
        p2 = 1 - stats.t.sf((bS - SESOI) / seS, df)
        eq = 'yes' if (lo90 > -SESOI and hi90 < SESOI) else 'no'
        post('H1_TOST', 'phq4', 'XD, 90% CI', 'S', bS, seS, lo90, hi90, max(p1, p2), f.n, f'SESOI +/-1.0; equivalence: {eq}')
        h1 = f
    f2 = R(d, y, d.in_xj, cont=['S'], factors=XD + XJ)
    postf(f2, h, y, 'XD + XJ', 'S')
f = R(d, 'phq4', d.in_xd_alt, cont=['S'], factors=xdalt)
postf(f, 'H1', 'phq4', 'XD, prefer not to answer as missing', 'S')

# ---------------- 7. H3
for cv in ['C', 'C3']:
    s = d.in_xd_main & d[cv].notna()
    fa = R(d, cv, s, cont=['S'], factors=XD)
    postf(fa, 'H3_a', cv, cv, 'S')
    fb = R(d, 'phq4', s, cont=[cv, 'S'], factors=XD)
    postf(fb, 'H3_b', 'phq4', cv, cv)
    postf(fb, 'H3_c', 'phq4', cv, 'S')
    post('H3', 'phq4', cv, 'max(p_a, p_b)', p=max(fa.p['S'], fb.p[cv]), N=int(s.sum()),
         note=f'a > 0: {int(fa.b["S"] > 0)}; b > 0: {int(fb.b[cv] > 0)}')
    if cv == 'C':
        ab_obs = fa.b['S'] * fb.b['C']

# percentile bootstrap of a*b
s = d.in_xd_main & d.C.notna()
D = d.loc[s]
Xa, na, _ = build(D, pd.Series(True, D.index), ['S'], XD, extra=['C'])
Xb, nb, _ = build(D, pd.Series(True, D.index), ['C', 'S'], XD, extra=['phq4'])
yC, yP = D.C.to_numpy(), D.phq4.to_numpy()
rng = np.random.default_rng(SEED)
abs_ = []
n = len(D)
for r in range(5000):
    i = rng.integers(0, n, n)
    ba = np.linalg.lstsq(Xa[i], yC[i], rcond=None)[0][na.index('S')]
    bb = np.linalg.lstsq(Xb[i], yP[i], rcond=None)[0][nb.index('C')]
    abs_.append(ba * bb)
abs_ = np.array(abs_)
post('H3_ab', 'phq4', 'percentile bootstrap', 'a*b', ab_obs, abs_.std(ddof=1), np.percentile(abs_, 2.5),
     np.percentile(abs_, 97.5), N=n, note='5000 resamples')

# ---------------- 8. E1-E5
e3 = d[d.in_e3].copy()
e3['g'] = np.where(e3.lgbt == 0, 0, np.where(e3.ever_exposed == 0, 1, np.where(e3.ever_exposed == 1, 2, np.nan)))
E3 = e3.dropna(subset=['g']).groupby('g').phq4.agg(mean='mean', sd='std', median='median', n='count')
E3['pct_ge6'] = 100 * e3.dropna(subset=['g']).groupby('g').phq_ge6.mean()
E3.index = E3.index.map({0: 'Non-LGBT', 1: 'LGBT, no reported stigma', 2: 'LGBT, at least one situation'})
E3.to_csv(f'{OUT}/table_s4.csv')

f = R(d, 'phq4', d.in_xd_main, factors=['S3'] + XD)
postf(f, 'E1', 'phq4', 'low vs. none', '1.S3')
postf(f, 'E1', 'phq4', 'high vs. none', '2.S3')

for j in range(1, 9):
    v = f'stig{j}_any'
    nexp = int((d.in_xd_main & (d[v] == 1)).sum())
    nun = int((d.in_xd_main & (d[v] == 0)).sum())
    if nexp < 10 or nun < 10:
        post('E2_notest', 'phq4', f'situation {j}', f'1.{v}', note='Fewer than 10 respondents in one group')
        continue
    f = R(d, 'phq4', d.in_xd_main, factors=[v] + XD)
    postf(f, 'E2', 'phq4', f'situation {j}', f'1.{v}')

attr = ['stig5', 'stig6']
if (d.in_xd_main & (d.stig4_any == 1)).sum() >= 10:
    attr = ['stig4'] + attr
d['S_attr'] = d[attr].mean(axis=1)
d['S_event'] = d[['stig1', 'stig2', 'stig3', 'stig7']].mean(axis=1)
f = R(d, 'phq4', d.in_xd_main, cont=['S_event', 'S_attr'], factors=XD)
postf(f, 'E2_contrast', 'phq4', 'event-based', 'S_event')
postf(f, 'E2_contrast', 'phq4', 'attribution-dependent', 'S_attr', ' '.join(attr))
est, se, lb, ub, p = lincom(f, {'S_attr': 1, 'S_event': -1})
post('E2_contrast', 'phq4', 'attribution-dependent minus event-based', 'difference', est, se, lb, ub, p, f.n)

# Anxiety versus depression: GAD-2 minus PHQ-2 regressed on the same terms, robust variance as in suest
# (HC0 * N/(N-1)), z test. Approximates the suest contrast of the do-file.
d['gmp'] = d.gad2 - d.phq2
f = R(d, 'gmp', d.in_xd_main, cont=['S'], factors=XD, vce='hc0')
N = f.n
seS = f.se['S'] * np.sqrt(N / (N - 1))
z = f.b['S'] / seS
post('AnxDep', 'gad2 - phq2', 'suest', 'S', f.b['S'], seS, f.b['S'] - 1.959964 * seS,
     f.b['S'] + 1.959964 * seS, 2 * stats.norm.sf(abs(z)), N)

xd_nosex = [v for v in XD if v != 'sex_birth']
f = R(d, 'phq4', d.in_xd_main & (d.sex_birth_orig != 9), cont=['S'], factors=['sex_birth'] + xd_nosex,
      inter=[('sex_birth', 'S')], base={'sex_birth': 1})
postf(f, 'E4', 'phq4', 'S x female (ref. male)', '2.sex_birth#c.S')
e4sex = f
f = R(d, 'phq4', d.in_xd_main & d.orient3.notna(), cont=['S'], factors=['orient3'] + XD,
      inter=[('orient3', 'S')], base={'orient3': 1})
postf(f, 'E4', 'phq4', 'S x lesbian (ref. bisexual or pansexual)', '2.orient3#c.S')
postf(f, 'E4', 'phq4', 'S x gay (ref. bisexual or pansexual)', '3.orient3#c.S')
e4or = f

f = R(d, 'phq4', d.in_e5, cont=['S', 'Qc'], factors=XD, inter=[('S', 'Qc')])
postf(f, 'E5', 'phq4', 'S x Q', 'c.S#c.Qc')
postf(f, 'E5_aux', 'phq4', 'S at mean Q', 'S')
postf(f, 'E5_aux', 'phq4', 'Q at S = 0', 'Qc')

# ---------------- 9. Diagnostics (Table S2)
X, names, s = build(d, d.in_xd_main, ['S'], XD, extra=['phq4'])
y = d.loc[s, 'phq4'].to_numpy(float)
fo = ols(y, X, names, 'ols')
n, k = X.shape
diag = []
yhat = X @ fo.b.to_numpy()
g = fo.e ** 2 / (fo.rss / n)
Z = np.column_stack([np.ones(n), yhat])
gb = np.linalg.lstsq(Z, g, rcond=None)[0]
ess = ((Z @ gb - g.mean()) ** 2).sum()
diag.append(('Breusch-Pagan', ess / 2, 1, stats.chi2.sf(ess / 2, 1), ''))
Xr = np.column_stack([X, yhat ** 2, yhat ** 3, yhat ** 4])
fr = ols(y, Xr, names + ['y2', 'y3', 'y4'], 'ols')
F = ((fo.rss - fr.rss) / 3) / (fr.rss / (n - Xr.shape[1]))
diag.append(('Ramsey RESET', F, 3, stats.f.sf(F, 3, n - Xr.shape[1]), f'F(3,{n - Xr.shape[1]})'))
s2 = fo.rss / (n - k)
cook = fo.e ** 2 * fo.h / (k * s2 * (1 - fo.h) ** 2)
d['cook'] = np.nan
d.loc[s, 'cook'] = cook
d['flag_cook'] = np.where(d.cook.notna(), (d.cook > 4 / n).astype(float), np.nan)
diag.append(("Cook's distance > 4/n", int((cook > 4 / n).sum()), np.nan, np.nan, ''))
diag.append(('Leverage > 2k/n', int((fo.h > 2 * k / n).sum()), np.nan, np.nan, ''))
diag.append(('Largest leverage', fo.h.max(), np.nan, np.nan, ''))
Rm = np.corrcoef(X[:, :-1], rowvar=False)
dR = np.linalg.det(Rm)
groups = [('S', [0])]
for v in XD:
    groups.append((v, [i for i, nm in enumerate(names[:-1]) if nm.endswith('.' + v)]))
allidx = np.arange(Rm.shape[0])
for nm, idx in groups:
    rest = np.setdiff1d(allidx, idx)
    gv = np.linalg.det(Rm[np.ix_(idx, idx)]) * np.linalg.det(Rm[np.ix_(rest, rest)]) / dR
    diag.append((f'GVIF {nm}', gv, len(idx), np.nan, f'GVIF^(1/(2df)) = {gv ** (1 / (2 * len(idx))):.3f}'))
pd.DataFrame(diag, columns=['diagnostic', 'statistic', 'df', 'p', 'note']).to_csv(f'{OUT}/table_s2.csv', index=False)

# ---------------- 10. Robustness checks (Table 7)
f = R(d, 'phq4', d.in_xd_main, cont=['S_exposed'], factors=['ever_exposed'] + XD)
postf(f, 'Robust', 'phq4', 'any exposure', '1.ever_exposed')
postf(f, 'Robust', 'phq4', 'intensity among exposed', 'S_exposed')

sx = d.loc[d.in_xd_main & (d.S > 0), 'S']
k1, k2, k3 = (stata_pctile(sx, p) for p in (10, 50, 90))
if k1 < k2 < k3:
    x = d.S
    pos = lambda u: np.clip(u, 0, None) ** 3
    d['Ssp1'] = x
    d['Ssp2'] = (pos(x - k1) - pos(x - k2) * (k3 - k1) / (k3 - k2) + pos(x - k3) * (k2 - k1) / (k3 - k2)) / (k3 - k1) ** 2
    f = R(d, 'phq4', d.in_xd_main, cont=['Ssp1', 'Ssp2'], factors=XD)
    postf(f, 'Robust', 'phq4', 'restricted cubic spline', 'Ssp1', f'test of nonlinearity: p = {f.p["Ssp2"]:.3f}')
else:
    post('Robust', 'phq4', 'restricted cubic spline', '-', note='knots coincide')

# fractional logit; average marginal effect rescaled to PHQ-4 points
X, names, s = build(d, d.in_xd_main, ['S'], XD, extra=['phq4_frac'])
yf = d.loc[s, 'phq4_frac'].to_numpy(float)
b = np.zeros(X.shape[1])
for it in range(100):
    p_ = 1 / (1 + np.exp(-X @ b))
    gr = X.T @ (yf - p_)
    H = (X * (p_ * (1 - p_))[:, None]).T @ X
    step = np.linalg.solve(H, gr)
    b += step
    if np.abs(step).max() < 1e-12:
        break
p_ = 1 / (1 + np.exp(-X @ b))
H = (X * (p_ * (1 - p_))[:, None]).T @ X
Hi = np.linalg.inv(H)
sc = X * (yf - p_)[:, None]
nF = len(yf)
V = nF / (nF - 1) * Hi @ (sc.T @ sc) @ Hi
jS = names.index('S')
w = p_ * (1 - p_)
ame = w.mean() * b[jS]
grad = (X * (w * (1 - 2 * p_))[:, None]).mean(0) * b[jS]
grad[jS] += w.mean()
se_ame = np.sqrt(grad @ V @ grad)
post('Robust', 'phq4', 'fractional logit, AME x 12', 'S', 12 * ame, 12 * se_ame, 12 * (ame - 1.959964 * se_ame),
     12 * (ame + 1.959964 * se_ame), 2 * stats.norm.sf(abs(ame / se_ame)), nF)

f = R(d, 'phq4', d.in_xd_main & (d.flag_quality == 0), cont=['S'], factors=XD)
postf(f, 'Robust', 'phq4', 'excluding flagged responses', 'S')
f = R(d, 'phq4', d.in_xd_main & (d.flag_cook != 1), cont=['S'], factors=XD)
postf(f, 'Robust', 'phq4', "excluding Cook's distance > 4/n", 'S')

# restricted wild bootstrap, Webb weights, t statistic with HC1
X, names, s = build(d, d.in_xd_main, ['S'], XD, extra=['phq4'])
y = d.loc[s, 'phq4'].to_numpy(float)
n, k = X.shape
jS = names.index('S')
XtXi = np.linalg.inv(X.T @ X)
A = (XtXi @ X.T)[jS]
Xr = np.delete(X, jS, 1)
Pr = Xr @ np.linalg.inv(Xr.T @ Xr) @ Xr.T
sv = X[:, jS]
rng = np.random.default_rng(SEED)
B = 9999
webb = np.array([-np.sqrt(1.5), -1, -np.sqrt(0.5), np.sqrt(0.5), 1, np.sqrt(1.5)])
Vb = webb[rng.integers(0, 6, (n, B))]
M = np.eye(n) - X @ XtXi @ X.T


def tstat(yy, theta):
    bS = A @ yy
    e = yy - X @ (XtXi @ X.T @ yy)
    se = np.sqrt(n / (n - k) * (A ** 2 * e ** 2).sum())
    return (bS - theta) / se


def pwild(theta):
    yt = y - theta * sv
    fit_r = Pr @ yt
    u = yt - fit_r
    Ystar = (fit_r + theta * sv)[:, None] + u[:, None] * Vb
    bS = A @ Ystar
    E = M @ Ystar
    se = np.sqrt(n / (n - k) * ((A ** 2)[:, None] * E ** 2).sum(0))
    tb = (bS - theta) / se
    t0 = tstat(y, theta)
    return np.mean(np.abs(tb) >= abs(t0))


pW = pwild(0.0)
bW = A @ y
seW = np.sqrt(n / (n - k) * (A ** 2 * (M @ y) ** 2).sum())
lo = optimize.brentq(lambda th: pwild(th) - 0.05, bW - 5 * seW, bW, xtol=1e-6)
hi = optimize.brentq(lambda th: pwild(th) - 0.05, bW, bW + 5 * seW, xtol=1e-6)
post('Robust', 'phq4', 'restricted wild bootstrap, Webb', 'S', bW, np.nan, lo, hi, pW, n, '9999 replications')

d['orient4'] = d.orient3
d.loc[d.orient3.isna() & d.in_main, 'orient4'] = 4
f = R(d, 'phq4', d.in_xd_main, cont=['S'], factors=XD + ['orient4'])
postf(f, 'Robust', 'phq4', 'adding sexual orientation group', 'S')

# ---------------- multiple imputation (chained equations)
from mi import run_mi
mi_res = run_mi(d, XD, m=20, seed=SEED)
post('Robust', 'phq4', 'multiple imputation, m = 20', 'S', *mi_res)

# ---------------- sensemakr (Table S3)
from sens import sensemakr
sens_out = sensemakr(d, d.in_xd_main, XD, groups={'sex_birth': 'sex_birth', 'educ': 'educ'}, kd=(1, 2, 3))
sens_out.to_csv(f'{OUT}/sensemakr.csv', index=False)

# ---------------- 11. Post hoc sensitivity analyses (Table S7)
f = R(d, 'phq4', d.in_xd_main, cont=['S'])
postf(f, 'PostHoc', 'phq4', 'unadjusted', 'S')
f = R(d, 'phq4', d.s7_disc, cont=['S'], factors=XD + ['disclose_s7'])
postf(f, 'PostHoc', 'phq4', 'adding disclosure at work', 'S')
f = R(d, 'phq4', d.s7_exper, cont=['S'], factors=XD + ['exper_s7'])
postf(f, 'PostHoc', 'phq4', 'adding work experience', 'S')
f = R(d, 'phq4', d.in_xd_main, cont=['S'], factors=['agegrp', 'sex_birth', 'educ'])
postf(f, 'PostHoc', 'phq4', 'XD without relationship status and region', 'S')

# ---------------- 12. Specification curve (Table S6)
sp = []
for idx in ['S', 'S8', 'S_count7', 'S_complete7']:
    for ctl in ['XD', 'XDXJ']:
        for de in ['self', 'consistent']:
            for tg in ['keep', 'drop']:
                cond = d.in_analytic & d.phq4.notna() & d[idx].notna()
                cond &= (d.lgbt == 1) if de == 'self' else d.lgbt_consistent
                if tg == 'drop':
                    cond &= ~(d.gender_minority == 1)
                fac = XD + (XJ if ctl == 'XDXJ' else [])
                f = R(d, 'phq4', cond, cont=[idx], factors=fac)
                sdv = d.loc[f.sample, idx].std(ddof=1)
                sp.append(dict(spec=f'{idx}|{ctl}|{de}|{tg}', b=f.b[idx], se=f.se[idx], lb=f.lb[idx], ub=f.ub[idx],
                               p=f.p[idx], sd_index=sdv, N=f.n))
sp = pd.DataFrame(sp)
sp['b_sd'], sp['lb_sd'], sp['ub_sd'] = sp.b * sp.sd_index, sp.lb * sp.sd_index, sp.ub * sp.sd_index
sp.to_csv(f'{OUT}/table_s6.csv', index=False)

# ---------------- 13. Multiple-testing adjustment
res = pd.DataFrame(rows)


def holm(p):
    p = np.asarray(p, float)
    o = np.argsort(p)
    m = len(p)
    adj = np.empty(m)
    run = 0
    for r, i in enumerate(o):
        run = max(run, min(1, (m - r) * p[i]))
        adj[i] = run
    return adj


def bh(p):
    p = np.asarray(p, float)
    o = np.argsort(p)[::-1]
    m = len(p)
    adj = np.empty(m)
    run = 1
    for r, i in enumerate(o):
        rank = m - r
        run = min(run, min(1, m / rank * p[i]))
        adj[i] = run
    return adj


res['p_holm'] = np.nan
mask = (res.part.isin(['H2a', 'H2b']) & (res.spec == 'XD')) | ((res.part == 'H3') & (res.spec == 'C'))
res.loc[mask, 'p_holm'] = holm(res.loc[mask, 'p'])
res['p_bh'] = np.nan
for fam in ['E2', 'E4']:
    mk = res.part == fam
    res.loc[mk, 'p_bh'] = bh(res.loc[mk, 'p'])
res.to_csv(f'{OUT}/results.csv', index=False)
pd.set_option('display.width', 250)
pd.set_option('display.max_colwidth', 70)
print(res.drop(columns=[]).round(4).to_string())


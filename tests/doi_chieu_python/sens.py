# sensemakr (Cinelli & Hazlett, 2020), sai số chuẩn cổ điển, mốc so sánh theo nhóm biến giả
import numpy as np
import pandas as pd
from scipy import stats
from reg import build, ols


def rv(t, dof, q=1.0, alpha=1.0):
    fq = q * abs(t / np.sqrt(dof))
    fcrit = abs(stats.t.ppf(alpha / 2, dof - 1)) / np.sqrt(dof - 1) if alpha < 1 else 0.0
    fqa = fq - fcrit
    if fqa <= 0:
        return 0.0
    if fcrit > 0 and fq > 1 / fcrit:
        return (fq ** 2 - fcrit ** 2) / (1 + fq ** 2)
    return 0.5 * (np.sqrt(fqa ** 4 + 4 * fqa ** 2) - fqa ** 2)


def partial_r2_group(y, X, idx):
    full = np.linalg.lstsq(X, y, rcond=None)
    rss_f = ((y - X @ full[0]) ** 2).sum()
    Xr = np.delete(X, idx, 1)
    red = np.linalg.lstsq(Xr, y, rcond=None)
    rss_r = ((y - Xr @ red[0]) ** 2).sum()
    return (rss_r - rss_f) / rss_r


def sensemakr(d, touse, XD, groups, kd=(1, 2, 3)):
    X, names, s = build(d, touse, ['S'], XD, extra=['phq4'])
    y = d.loc[s, 'phq4'].to_numpy(float)
    f = ols(y, X, names, 'ols')
    est, se, dof = f.b['S'], f.se['S'], f.df
    t = est / se
    out = [dict(muc='S', k=np.nan, est=est, se=se, t=t, dof=dof,
                r2yd_x=t ** 2 / (t ** 2 + dof), rv_q1=rv(t, dof), rv_q1_a05=rv(t, dof, 1, 0.05),
                r2dz_x=np.nan, r2yz_dx=np.nan, adj_est=np.nan, adj_se=np.nan, adj_lb=np.nan, adj_ub=np.nan)]
    jS = names.index('S')
    Xn = np.delete(X, jS, 1)
    names_n = [n for i, n in enumerate(names) if i != jS]
    sv = X[:, jS]
    for gname, var in groups.items():
        idx_n = [i for i, n in enumerate(names_n) if n.endswith('.' + var)]
        idx_f = [i for i, n in enumerate(names) if n.endswith('.' + var)]
        r2dxj = partial_r2_group(sv, Xn, idx_n)
        r2yxj = partial_r2_group(y, X, idx_f)
        for k in kd:
            r2dz = k * r2dxj / (1 - r2dxj)
            r2zxj = k * r2dxj ** 2 / ((1 - k * r2dxj) * (1 - r2dxj))
            r2yz = ((np.sqrt(k) + np.sqrt(r2zxj)) / np.sqrt(1 - r2zxj)) ** 2 * (r2yxj / (1 - r2yxj))
            r2yz = min(r2yz, 1.0)
            bias = np.sqrt(r2yz * r2dz / (1 - r2dz)) * se * np.sqrt(dof)
            adj = np.sign(est) * (abs(est) - bias)
            adj_se = np.sqrt((1 - r2yz) / (1 - r2dz)) * se * np.sqrt(dof / (dof - 1))
            q = stats.t.ppf(0.975, dof - 1)
            out.append(dict(muc=gname, k=k, est=est, se=se, t=t, dof=dof, r2yd_x=np.nan, rv_q1=np.nan,
                            rv_q1_a05=np.nan, r2dxj_x=r2dxj, r2yxj_dx=r2yxj, r2dz_x=r2dz, r2yz_dx=r2yz,
                            adj_est=adj, adj_se=adj_se, adj_lb=adj - q * adj_se, adj_ub=adj + q * adj_se))
    return pd.DataFrame(out)

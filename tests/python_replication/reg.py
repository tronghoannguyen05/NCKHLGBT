# Stata-style regression: dummies for i.var (lowest level as base), HC3 / HC1 / OLS, t tests with df_r.
import numpy as np
import pandas as pd
from scipy import stats


class Fit:
    pass


def build(d, touse, cont=(), factors=(), inter=(), base=None, extra=None):
    """cont: continuous terms; factors: categorical terms; inter: (factor, cont) -> f#c.cont and c.a#c.b."""
    base = base or {}
    cols = list(cont) + list(factors) + [x for t in inter for x in t]
    if extra:
        cols += extra
    cols = list(dict.fromkeys(cols))
    s = touse & d[cols].notna().all(1)
    D = d.loc[s]
    X, names = [], []
    for c in cont:
        X.append(D[c].to_numpy(float))
        names.append(c)
    for f in factors:
        levs = sorted(D[f].unique())
        b = base.get(f, levs[0])
        for l in levs:
            if l == b:
                continue
            X.append((D[f] == l).to_numpy(float))
            names.append(f'{int(l)}.{f}')
    for a, c in inter:
        if a in factors:
            levs = sorted(D[a].unique())
            b = base.get(a, levs[0])
            for l in levs:
                if l == b:
                    continue
                X.append(((D[a] == l) * D[c]).to_numpy(float))
                names.append(f'{int(l)}.{a}#c.{c}')
        else:
            X.append((D[a] * D[c]).to_numpy(float))
            names.append(f'c.{a}#c.{c}')
    X.append(np.ones(len(D)))
    names.append('_cons')
    X = np.column_stack(X)
    # drop collinear columns as Stata does (the first column is kept)
    keep = []
    for j in range(X.shape[1]):
        cand = keep + [j]
        if np.linalg.matrix_rank(X[:, cand]) == len(cand):
            keep.append(j)
    X = X[:, keep]
    names = [names[j] for j in keep]
    return X, names, s


def ols(y, X, names, vce='hc3', level=0.95):
    n, k = X.shape
    XtXi = np.linalg.inv(X.T @ X)
    b = XtXi @ X.T @ y
    e = y - X @ b
    h = np.einsum('ij,jk,ik->i', X, XtXi, X)
    if vce == 'hc3':
        meat = (X * (e ** 2 / (1 - h) ** 2)[:, None]).T @ X
        V = XtXi @ meat @ XtXi
    elif vce == 'hc1':
        meat = (X * (e ** 2)[:, None]).T @ X
        V = n / (n - k) * XtXi @ meat @ XtXi
    elif vce == 'hc0':
        meat = (X * (e ** 2)[:, None]).T @ X
        V = XtXi @ meat @ XtXi
    else:
        V = (e @ e) / (n - k) * XtXi
    f = Fit()
    f.n, f.k, f.df = n, k, n - k
    f.b = pd.Series(b, names)
    f.V = pd.DataFrame(V, names, names)
    f.se = pd.Series(np.sqrt(np.diag(V)), names)
    f.t = f.b / f.se
    f.p = pd.Series(2 * stats.t.sf(np.abs(f.t), f.df), names)
    q = stats.t.ppf(1 - (1 - level) / 2, f.df)
    f.lb = f.b - q * f.se
    f.ub = f.b + q * f.se
    f.e, f.h, f.X, f.y, f.XtXi = e, h, X, y, XtXi
    f.rss = e @ e
    f.r2 = 1 - f.rss / ((y - y.mean()) @ (y - y.mean()))
    f.names = names
    return f


def lincom(f, w):
    """w: dict of term name -> weight."""
    g = pd.Series(0.0, f.b.index)
    for k, v in w.items():
        g[k] = v
    est = g @ f.b
    se = np.sqrt(g @ f.V @ g)
    t = est / se
    q = stats.t.ppf(0.975, f.df)
    return est, se, est - q * se, est + q * se, 2 * stats.t.sf(abs(t), f.df)

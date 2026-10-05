import numpy as np
import pandas as pd
from scipy import stats
from reg import build, ols


def ols_safe(y, X, names, vce='hc3', level=0.95):
    # HC3 kiểu Stata: quan sát có đòn bẩy 1 không đóng góp vào phần giữa
    f = ols(y, X, names, 'ols', level)
    n, k = X.shape
    e, h, XtXi = f.e, f.h, f.XtXi
    if vce in ('hc3', 'hc1', 'hc0'):
        if vce == 'hc3':
            w = np.where(h > 1 - 1e-9, 0.0, e ** 2 / (1 - h) ** 2)
            c = 1.0
        else:
            w = e ** 2
            c = n / (n - k) if vce == 'hc1' else 1.0
        V = c * XtXi @ ((X * w[:, None]).T @ X) @ XtXi
        f.V = pd.DataFrame(V, names, names)
        f.se = pd.Series(np.sqrt(np.diag(V)), names)
        f.t = f.b / f.se
        f.p = pd.Series(2 * stats.t.sf(np.abs(f.t), f.df), names)
        q = stats.t.ppf(1 - (1 - level) / 2, f.df)
        f.lb, f.ub = f.b - q * f.se, f.b + q * f.se
    f.maxh = h.max()
    f.nh1 = int((h > 1 - 1e-9).sum())
    return f


def R(d, y, touse, cont=(), factors=(), inter=(), base=None, vce='hc3'):
    X, names, s = build(d, touse, cont, factors, inter, base, extra=[y])
    f = ols_safe(d.loc[s, y].to_numpy(float), X, names, vce)
    f.sample = s
    return f

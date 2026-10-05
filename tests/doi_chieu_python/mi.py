# Gán giá trị đa lần theo chuỗi điều kiện (FCS), gần với mi impute chained của Stata:
# PMM knn(5) cho phq4 S C Q; logit đa thức (phạt nhẹ thay cho augment) cho các biến Xᴰ.
import numpy as np
import pandas as pd
from scipy import stats, optimize


def dummies(col, levels):
    return np.column_stack([(col == l).astype(float) for l in levels[1:]]) if len(levels) > 1 else np.zeros((len(col), 0))


def design(D, target, cont, cat, levels):
    parts = [np.ones(len(D))[:, None]]
    for c in cont:
        if c != target:
            parts.append(D[c].to_numpy(float)[:, None])
    for c in cat:
        if c != target:
            parts.append(dummies(D[c].to_numpy(), levels[c]))
    return np.column_stack(parts)


def draw_pmm(y, Z, mis, rng, knn=5):
    Zo, yo = Z[~mis], y[~mis]
    n, p = Zo.shape
    ZtZi = np.linalg.pinv(Zo.T @ Zo)
    bh = ZtZi @ Zo.T @ yo
    rss = ((yo - Zo @ bh) ** 2).sum()
    s2 = rss / rng.chisquare(n - p)
    L = np.linalg.cholesky(s2 * ZtZi + 1e-12 * np.eye(p))
    bs = bh + L @ rng.standard_normal(p)
    yo_hat = Zo @ bh
    ym_hat = Z[mis] @ bs
    out = np.empty(mis.sum())
    for i, v in enumerate(ym_hat):
        nn = np.argsort(np.abs(yo_hat - v), kind='stable')[:knn]
        out[i] = yo[rng.choice(nn)]
    return out


def draw_mlogit(y, Z, mis, levels, rng, lam=0.1):
    Zo, yo = Z[~mis], y[~mis]
    K = len(levels)
    n, p = Zo.shape
    Y = np.column_stack([(yo == l).astype(float) for l in levels])

    def nll(theta):
        B = np.column_stack([np.zeros(p), theta.reshape(p, K - 1)])
        eta = Zo @ B
        eta -= eta.max(1, keepdims=True)
        P = np.exp(eta)
        P /= P.sum(1, keepdims=True)
        val = -(Y * np.log(P + 1e-300)).sum() + lam / 2 * (theta ** 2).sum()
        G = Zo.T @ (P - Y)
        return val, G[:, 1:].ravel() + lam * theta

    th = optimize.minimize(nll, np.zeros(p * (K - 1)), jac=True, method='L-BFGS-B').x
    B = np.column_stack([np.zeros(p), th.reshape(p, K - 1)])
    eta = Zo @ B
    eta -= eta.max(1, keepdims=True)
    P = np.exp(eta)
    P /= P.sum(1, keepdims=True)
    # Hessian
    H = np.zeros((p * (K - 1), p * (K - 1)))
    for a in range(1, K):
        for b in range(1, K):
            w = P[:, a] * ((a == b) - P[:, b])
            H[(a - 1) * p:a * p, (b - 1) * p:b * p] = (Zo * w[:, None]).T @ Zo
    H += lam * np.eye(H.shape[0])
    V = np.linalg.inv(H)
    V = (V + V.T) / 2
    w_, U = np.linalg.eigh(V)
    ts = th + U @ (np.sqrt(np.clip(w_, 0, None)) * rng.standard_normal(len(th)))
    Bs = np.column_stack([np.zeros(p), ts.reshape(p, K - 1)])
    em = Z[mis] @ Bs
    em -= em.max(1, keepdims=True)
    Pm = np.exp(em)
    Pm /= Pm.sum(1, keepdims=True)
    return np.array([levels[rng.choice(K, p=pr)] for pr in Pm])


def run_mi(d, XD, m=20, seed=1, burnin=10):
    import models_helpers as mh
    D0 = d.loc[d.in_analytic & (d.lgbt == 1), ['phq4', 'S', 'C', 'Q'] + XD].copy()
    cont = ['phq4', 'S', 'C', 'Q']
    cat = list(XD)
    allv = cont + cat
    miss = {v: D0[v].isna().to_numpy() for v in allv}
    order = sorted(allv, key=lambda v: (miss[v].sum(), allv.index(v)))
    levels = {c: sorted(D0[c].dropna().unique()) for c in cat}
    rng = np.random.default_rng(seed)
    ests = []
    for imp in range(m):
        D = D0.copy()
        done = [v for v in allv if miss[v].sum() == 0]
        # khởi tạo: chỉ dùng biến đã đủ hoặc đã gán
        for v in order:
            if miss[v].sum() == 0:
                continue
            Dd = D[done + [v]]
            Z = design(Dd.fillna(0), v, [c for c in cont if c in done], [c for c in cat if c in done], levels)
            y = D[v].to_numpy(float)
            if v in cont:
                D.loc[miss[v], v] = draw_pmm(np.nan_to_num(y), Z, miss[v], rng)
            else:
                D.loc[miss[v], v] = draw_mlogit(y, Z, miss[v], levels[v], rng)
            done.append(v)
        for it in range(burnin):
            for v in order:
                if miss[v].sum() == 0:
                    continue
                Z = design(D, v, cont, cat, levels)
                y = D0[v].to_numpy(float)
                if v in cont:
                    D.loc[miss[v], v] = draw_pmm(np.nan_to_num(y), Z, miss[v], rng)
                else:
                    D.loc[miss[v], v] = draw_mlogit(y, Z, miss[v], levels[v], rng)
        D['_t'] = True
        f = mh.R(D, 'phq4', D._t, cont=['S'], factors=XD)
        ests.append((f.b['S'], f.se['S'] ** 2, f.df, f.n))
    q = np.array([e[0] for e in ests])
    u = np.array([e[1] for e in ests])
    qbar, ubar, bvar = q.mean(), u.mean(), q.var(ddof=1)
    T = ubar + (1 + 1 / m) * bvar
    lam = (1 + 1 / m) * bvar / T
    nu_m = (m - 1) / lam ** 2
    nu_com = ests[0][2]
    nu_obs = (nu_com + 1) / (nu_com + 3) * nu_com * (1 - lam)
    nu = 1 / (1 / nu_m + 1 / nu_obs)
    se = np.sqrt(T)
    qt = stats.t.ppf(0.975, nu)
    note = f'df {nu:.1f}; FMI~{lam:.3f}; thiếu: ' + ', '.join(f'{v} {int(miss[v].sum())}' for v in allv)
    return qbar, se, qbar - qt * se, qbar + qt * se, 2 * stats.t.sf(abs(qbar / se), nu), ests[0][3], note

# Replicates sections 3, 4, 6 and 7 of phan_tich_bai_tieng_viet.do: sample flow,
# descriptive tables with small-cell suppression, exploratory models and
# Benjamini-Hochberg adjustment. Writes aggregate results only.
# Run: python3 tests/python_replication_vi/run_vi.py (export in data/raw/, or LGBT_DATA set)
import os
import sys
import warnings

import numpy as np
import pandas as pd

warnings.filterwarnings('ignore')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from prep_vi import load, XD, XDO_D, XDO_A, POL, DEI, PHQI  # noqa: E402
from models_helpers import R  # noqa: E402  (from tests/python_replication)
from reg import lincom  # noqa: E402

MIN_CELL = 10
OUT = os.path.join(HERE, '..', '..', 'output', 'tables', 'python_replication_vi')
os.makedirs(OUT, exist_ok=True)


def supp_flags(counts):
    flags = [0 < k < MIN_CELL for k in counts]
    if sum(flags) == 1:
        cand = [(k, i) for i, k in enumerate(counts) if not flags[i] and k > 0]
        if cand:
            flags[min(cand)[1]] = True
    return flags


def cell_str(k, tot, f):
    if f:
        return f'<{MIN_CELL}' if k < MIN_CELL else 'không báo cáo'
    if tot == 0:
        return '0'
    return f'{k} ({100 * k / tot:.1f})'


def freq_table(d, v, touse, codes, labels, title):
    tot = int((touse & d[v].notna()).sum())
    counts = [int((touse & (d[v] == c)).sum()) for c in codes]
    assert sum(counts) == tot, (v, counts, tot)
    flags = supp_flags(counts)
    rows = [(title, '', '')]
    rows += [('', lab, cell_str(k, tot, f)) for lab, k, f in zip(labels, counts, flags)]
    return rows


def cell_fmt(k, tot, other):
    if 0 < k < MIN_CELL:
        return f'<{MIN_CELL}', ''
    if 0 < other < MIN_CELL:
        return 'không báo cáo', ''
    return str(k), f'{100 * k / tot:.1f}'


def save(rows, name, cols):
    df = pd.DataFrame(rows, columns=cols)
    df.to_csv(os.path.join(OUT, name + '.csv'), index=False)
    print(f'\n== {name}')
    print(df.to_string(index=False))
    return df


d = load()
m = d.in_xd_main
dei = d.in_dei

# section 3: sample flow
flow = [('Phiếu nhận được', len(d), 850), ('Có công việc chính tạo thu nhập', int((d.has_job == 1).sum()), 734),
        ('Trả lời ít nhất một câu sau phần sàng lọc', int(d.in_base.sum()), 719),
        ('Tự nhận là LGBT', int(d.in_lgbt.sum()), 300), ('Đủ PHQ-4 và chỉ số kỳ thị hợp lệ', int(d.in_main.sum()), 272),
        ('Mẫu chính: đủ tám nhóm biến kiểm soát', int(m.sum()), 235),
        ('Mẫu chính có chỉ số thực thi Q hợp lệ (mẫu H3)', int(d.in_h3.sum()), 223),
        ('Mẫu chính, làm việc trong một tổ chức', int((m & d.in_org).sum()), np.nan),
        ('Mẫu DEI', int(dei.sum()), np.nan), ('Mẫu DEI toàn bộ', int(d.in_dei_all.sum()), np.nan)]
fl = save(flow, 'luong_mau', ['buoc', 'n', 'ky_vong'])
assert all(r.n == r.ky_vong for r in fl.itertuples() if not pd.isna(r.ky_vong))
k25 = int((d.in_lgbt & d.c25_any).sum())
save([('Người LGBT có viết câu trả lời ở Câu 25', f'<{MIN_CELL}' if 0 < k25 < MIN_CELL else str(k25),
       int(d.in_lgbt.sum()))], 'cau25', ['noi_dung', 'so_nguoi', 'tren_tong'])

# section 4: descriptive tables
d['orient_t2'] = d.orient.where(d.orient.isin([2, 3, 4, 5]), 0)
d['ind_t2'] = d.industry.where(~d.industry.isin([4, 10]), 11)
rows = [('n', '', str(int(m.sum())))]
rows += freq_table(d, 'agegrp_orig', m, [1, 2, 3, 4, 9], ['18–24', '25–34', '35–44', 'Từ 45 trở lên', 'Không muốn trả lời'], 'Nhóm tuổi')
rows += freq_table(d, 'sex_birth_orig', m, [1, 2, 9], ['Nam', 'Nữ', 'Không muốn trả lời'], 'Giới tính khi sinh')
rows += freq_table(d, 'educ_orig', m, [1, 2, 3, 4, 9], ['THPT trở xuống', 'Cao đẳng', 'Đại học', 'Sau đại học', 'Không muốn trả lời'], 'Học vấn')
rows += freq_table(d, 'relstat_orig', m, [1, 2, 3, 9], ['Không có bạn đời', 'Có bạn đời', 'Ly thân, ly hôn hoặc góa', 'Không muốn trả lời'], 'Tình trạng quan hệ')
rows += freq_table(d, 'region_orig', m, [1, 2, 3, 4, 9], ['Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng', 'Nơi khác', 'Không muốn trả lời'], 'Địa bàn làm việc')
rows += freq_table(d, 'orient_t2', m, [2, 3, 4, 5, 0], ['Đồng tính nam', 'Đồng tính nữ', 'Song tính', 'Toàn tính', 'Khác, đang tự xác định hoặc không nêu'], 'Xu hướng tính dục')
rows += freq_table(d, 'ind_t2', m, [1, 2, 3, 5, 6, 7, 11, 9],
                   ['Tài chính, ngân hàng', 'Công nghệ thông tin', 'Giáo dục', 'Thương mại, dịch vụ', 'Sản xuất',
                    'Truyền thông, marketing', 'Y tế, du lịch hoặc khác', 'Không muốn trả lời'], 'Ngành')
rows += freq_table(d, 'orgtype', m, [1, 2, 3, 4, 5, 6, 9],
                   ['Cơ quan, doanh nghiệp nhà nước', 'Doanh nghiệp tư nhân trong nước', 'Doanh nghiệp FDI',
                    'NGO, tổ chức phi lợi nhuận', 'Tự doanh, hộ kinh doanh', 'Khác', 'Không muốn trả lời'],
                   'Loại hình nơi làm việc')
rows += freq_table(d, 'orgsize', m, [1, 2, 3, 4, 97, 9],
                   ['Dưới 50 người', '50–199 người', '200–499 người', 'Từ 500 người trở lên',
                    'Không áp dụng hoặc không rõ', 'Không muốn trả lời'], 'Quy mô nơi làm việc')
save(rows, 'dac_diem_mau', ['dac_diem', 'nhom', 'mau_chinh'])

PLAB = ['Chính sách bằng văn bản chống phân biệt đối xử dựa trên SOGIE', 'Kênh hoặc quy trình khiếu nại bảo mật',
        'Đào tạo về DEI cho quản lý hoặc nhân viên', 'Phúc lợi cho bạn đời cùng giới hoặc người phụ thuộc',
        'Hỗ trợ người chuyển giới về tên gọi, đại từ, trang phục, nhà vệ sinh']
DLAB = ['An toàn khi phản ánh phân biệt đối xử hoặc quấy rối', 'Quản lý trực tiếp tôn trọng người LGBT',
        'Hành vi nói đùa hoặc xúc phạm người LGBT bị nhắc nhở hoặc xử lý',
        'Được dùng tên gọi, đại từ, trang phục phù hợp với bản dạng giới']

rows = []
for j in range(5):
    v = d[POL[j]]
    tot = int((dei & v.notna()).sum())
    counts = [int((dei & (v == c)).sum()) for c in (1, 0, 8)]
    fl_ = supp_flags(counts)
    rows.append((PLAB[j], tot) + tuple(cell_str(k, tot, f) for k, f in zip(counts, fl_)))
save(rows, 'chinh_sach', ['chinh_sach', 'n', 'co', 'khong', 'khong_biet'])

d['npol_co_c'] = d.npol_co.clip(upper=3)
d['npol_kb_c'] = np.select([d.npol_kb == 0, d.npol_kb <= 2], [0, 1], 2)
d.loc[d.npol_kb.isna(), 'npol_kb_c'] = np.nan
rows = freq_table(d, 'npol_co_c', dei, [0, 1, 2, 3], ['0', '1', '2', 'Từ 3 trở lên'], 'Số chính sách được báo là có')
rows += freq_table(d, 'npol_kb_c', dei, [0, 1, 2], ['0', '1–2', 'Từ 3 trở lên'], 'Số câu trả lời không biết')
save(rows, 'so_chinh_sach', ['bien', 'nhom', 'n_pct'])

rows = []
for k in range(4):
    v = d[DEI[k]]
    tot = int((dei & v.notna()).sum())
    counts = [int((dei & v.between(1, 2)).sum()), int((dei & (v == 3)).sum()), int((dei & v.between(4, 5)).sum())]
    fl_ = supp_flags(counts)
    rows.append((DLAB[k], tot) + tuple(cell_str(c, tot, f) for c, f in zip(counts, fl_))
                + (v[dei].mean(), v[dei].std()))
rows.append(('Chỉ số thực thi Q (trung bình bốn phát biểu)', int(d.Q[dei].count()), '', '', '',
             d.Q[dei].mean(), d.Q[dei].std()))
save(rows, 'thuc_thi', ['phat_bieu', 'n', 'khong_dong_y', 'trung_lap', 'dong_y', 'tb', 'dlc'])

rows = []
for j in range(5):
    v = d[POL[j]]
    counts = [int((dei & (v == c)).sum()) for c in (1, 0, 8)]
    fl_ = supp_flags(counts)
    out = [PLAB[j]]
    for c, k, f in zip((1, 0, 8), counts, fl_):
        if f:
            out += [f'<{MIN_CELL}' if k < MIN_CELL else 'không báo cáo', '']
        elif k == 0:
            out += ['0', '']
        else:
            q = d.Q[dei & (v == c)]
            out += [str(k), f'{q.mean():.2f} ({q.std():.2f})']
    rows.append(tuple(out))
save(rows, 'khoang_cach', ['chinh_sach', 'n_co', 'q_co', 'n_khong', 'q_khong', 'n_kb', 'q_kb'])

rows = []
for pj, dk, lab in [(1, 0, 'Kênh khiếu nại bảo mật → an toàn khi phản ánh'),
                    (2, 1, 'Đào tạo DEI → quản lý tôn trọng người LGBT'),
                    (4, 3, 'Hỗ trợ người chuyển giới → được dùng tên gọi, đại từ, trang phục')]:
    v, w = d[POL[pj]], d[DEI[dk]]
    counts = [int((dei & (v == c)).sum()) for c in (1, 0, 8)]
    fl_ = supp_flags(counts)
    out = [lab]
    for c, k, f in zip((1, 0, 8), counts, fl_):
        nv = int((dei & (v == c) & w.notna()).sum())
        na = int((dei & (v == c) & w.between(4, 5)).sum())
        nd = nv - na
        if f:
            out.append(f'<{MIN_CELL}' if k < MIN_CELL else 'không báo cáo')
        elif nv == 0:
            out.append('')
        elif 0 < na < MIN_CELL or 0 < nd < MIN_CELL:
            out.append('không báo cáo')
        else:
            out.append(f'{100 * na / nv:.1f}')
    rows.append(tuple(out))
save(rows, 'cap_tuong_ung', ['cap', 'co', 'khong', 'khong_biet'])

OLAB = {1: 'Cơ quan, doanh nghiệp nhà nước', 2: 'Doanh nghiệp tư nhân trong nước', 3: 'Doanh nghiệp FDI',
        4: 'NGO, tổ chức phi lợi nhuận', 6: 'Khác', 9: 'Không muốn trả lời'}
ocodes = [1, 2, 3, 4, 6, 9]
counts = [int((dei & (d.orgtype == c)).sum()) for c in ocodes]
fl_ = supp_flags(counts)
rows = []
for c, k, f in zip(ocodes, counts, fl_):
    if f or k == 0:
        s = '0' if k == 0 else (f'<{MIN_CELL}' if k < MIN_CELL else 'không báo cáo')
        rows.append((OLAB[c], s, np.nan, np.nan, '', np.nan, np.nan))
        continue
    g = dei & (d.orgtype == c)
    a = int((g & (d.npol_co >= 1)).sum())
    b = k - a
    s1 = 'không báo cáo' if (0 < a < MIN_CELL or 0 < b < MIN_CELL) else f'{100 * a / k:.1f}'
    rows.append((OLAB[c], str(k), d.npol_co[g].mean(), d.npol_co[g].std(), s1, d.npol_kb[g].mean(), d.Q[g].mean()))
save(rows, 'theo_loai_hinh', ['loai_hinh', 'n', 'tb_so_chinh_sach', 'dlc_so_chinh_sach', 'pct_co_it_nhat_1',
                              'tb_so_khong_biet', 'tb_Q'])

LAB = {'all': 'Bất kỳ tình huống nào (1–8)', 'int': 'Giao tiếp: bất kỳ tình huống 1–3',
       'car': 'Nghề nghiệp: bất kỳ tình huống 4–6', 'gen': 'Thể hiện giới: bất kỳ tình huống 7–8',
       1: '1 Bị nói đùa, bình luận hoặc gửi nội dung xúc phạm', 2: '2 Bị hỏi những câu riêng tư không mong muốn',
       3: '3 Bị tiết lộ hoặc đe dọa tiết lộ khi chưa đồng ý', 4: '4 Bị loại khỏi đào tạo hoặc phát triển nghề nghiệp',
       5: '5 Bị đánh giá, trả lương hoặc thăng tiến không công bằng', 6: '6 Bị chuyển ca, phân công hoặc bố trí bất lợi',
       7: '7 Bị áp lực theo khuôn mẫu giới', 8: '8 Khó khăn với tên gọi, đại từ, trang phục, nhà vệ sinh'}


def t4_row(label, score, any_, often):
    nv = int((m & d[any_].notna()).sum())
    na = int((m & (d[any_] == 1)).sum())
    no = int((m & (d[often] == 1)).sum())
    n1, p1 = cell_fmt(na, nv, nv - na)
    n2, p2 = cell_fmt(no, nv, na - no)
    s = d.loc[m & d[any_].notna(), score]
    return (label, nv, n1, p1, n2, p2, s.mean(), s.std())


rows = [t4_row(LAB['all'], 'S', 'ever_exposed', 'ever_often')]
for g, sits in [('int', [1, 2, 3]), ('car', [4, 5, 6]), ('gen', [7, 8])]:
    rows.append(t4_row(LAB[g], 'S_' + g, g + '_any', g + '_often'))
    for j in sits:
        rows.append(t4_row(LAB[j], f'stig{j}', f'stig{j}_any', f'stig{j}_often'))
save(rows, 'hinh_thuc_ky_thi', ['hinh_thuc', 'n_hop_le', 'n_it_nhat_1_lan', 'pct_it_nhat_1_lan', 'n_thuong_xuyen',
                                'pct_thuong_xuyen', 'tb_diem', 'dlc_diem'])
d['S_count8_c'] = d.S_count8.clip(upper=3)
save(freq_table(d, 'S_count8_c', m, [0, 1, 2, 3], ['0', '1', '2', 'Từ 3 trở lên'], 'Số tình huống đã gặp trong tám'),
     'so_tinh_huong', ['bien', 'nhom', 'n_pct'])

scodes = [1, 2, 3, 4, 5, 9, 0]
slabs = ['Quản lý trực tiếp', 'Đồng nghiệp', 'Khách hàng, đối tác', 'Bộ phận nhân sự', 'Người khác',
         'Không muốn trả lời', 'Không trả lời']
groups = {'all': m & (d.ever_exposed == 1), 'car': m & (d.car_any == 1), 'gen': m & (d.gen_any == 1)}
cols = {}
for g, gg in groups.items():
    cnt = [int((gg & (d.src20c == c)).sum()) for c in scodes]
    cols[g] = (int(gg.sum()), cnt, supp_flags(cnt))
rows = [('n',) + tuple(str(cols[g][0]) for g in groups)]
for i, lab in enumerate(slabs):
    rows.append((lab,) + tuple(cell_str(cols[g][1][i], cols[g][0], cols[g][2][i]) for g in groups))
save(rows, 'nguon_ky_thi', ['nguon', 'tat_ca', 'nghe_nghiep', 'the_hien_gioi'])
print('Câu 20 answered by unexposed respondents (main sample):', int((m & (d.ever_exposed == 0) & d.src20.notna()).sum()))

rows = []
for v in ['phq4', 'S', 'Q', 'npol_co', 'npol_kb']:
    x = d.loc[dei, v]
    rows.append((v, int(x.count()), x.mean(), x.std(), x.median(), x.min(), x.max()))
save(rows, 'mo_ta', ['bien', 'n', 'tb', 'dlc', 'trung_vi', 'nho_nhat', 'lon_nhat'])


def alpha(X):
    X = X.dropna()
    k = X.shape[1]
    return k / (k - 1) * (1 - X.var(ddof=1).sum() / X.sum(axis=1).var(ddof=1)), len(X)


save([('Thực thi DEI (bốn phát biểu), mẫu DEI',) + alpha(d.loc[dei, DEI]),
      ('PHQ-4, mẫu DEI',) + alpha(d.loc[dei, PHQI])], 'tin_cay', ['thang_do', 'alpha', 'N'])

# section 6: exploratory models
res = []


def post(part, outcome, spec, term, fam='', b=np.nan, se=np.nan, lb=np.nan, ub=np.nan, p=np.nan, N=np.nan, note=''):
    res.append(dict(part=part, fam=fam, outcome=outcome, spec=spec, term=term, b=b, se=se, lb=lb, ub=ub, p=p, N=N,
                    note=note))


def postf(f, part, outcome, spec, term, fam='', note=''):
    post(part, outcome, spec, term, fam, f.b[term], f.se[term], f.lb[term], f.ub[term], f.p[term], f.n, note)


def postl(f, w, part, outcome, spec, term, note=''):
    est, se, lb, ub, p = lincom(f, w)
    post(part, outcome, spec, term, '', est, se, lb, ub, p, f.n, note)


f = R(d, 'phq4', m, cont=['S'], factors=XD)
postf(f, 'BoiCanh', 'phq4', 'H1, mẫu chính, XD', 'S')
f = R(d, 'phq4', dei, cont=['S'], factors=XDO_D)
postf(f, 'BoiCanh', 'phq4', 'Mẫu DEI, XD + loại hình, quy mô tổ chức', 'S')

f = R(d, 'S', dei, cont=['npol_co', 'npol_kb'], factors=XDO_D)
postf(f, 'A1', 'S', 'Số chính sách có (điều chỉnh số câu không biết)', 'npol_co', 'A')
postf(f, 'A1', 'S', 'Số câu không biết (cùng mô hình)', 'npol_kb')
f = R(d, 'S', dei, cont=['Q'], factors=XDO_D)
postf(f, 'A2', 'S', 'Chỉ số thực thi Q', 'Q', 'A')
for j in range(1, 6):
    k = j + 2
    v = f'pol{j}'
    if int((dei & (d[v] == 0)).sum()) < MIN_CELL:
        for lev in (1, 8):
            post(f'A{k}', 'S', PLAB[j - 1], f'{lev}.{v}', note=f'Nhóm tham chiếu dưới {MIN_CELL} người: không ước lượng')
        continue
    f = R(d, 'S', dei, factors=[v] + XDO_D, base={v: 0})
    for lev, lab, fam in ((1, 'có so với không', 'A'), (8, 'không biết so với không', '')):
        n1 = int((f.sample & (d[v] == lev)).sum())
        n0 = int((f.sample & (d[v] == 0)).sum())
        spec = f'{PLAB[j - 1]}: {lab}'
        if n1 < MIN_CELL or n0 < MIN_CELL:
            post(f'A{k}', 'S', spec, f'{lev}.{v}', N=f.n, note=f'Nhóm dưới {MIN_CELL} người: không báo cáo')
        else:
            postf(f, f'A{k}', 'S', spec, f'{lev}.{v}', fam)

f = R(d, 'phq4', dei, cont=['npol_co', 'npol_kb'], factors=XDO_D)
postf(f, 'B1', 'phq4', 'Số chính sách có (điều chỉnh số câu không biết)', 'npol_co', 'B')
f = R(d, 'phq4', dei, cont=['npol_co', 'npol_kb', 'S'], factors=XDO_D)
postf(f, 'B1s', 'phq4', 'Số chính sách có, thêm S', 'npol_co')
postf(f, 'B1s', 'phq4', 'S, cùng mô hình', 'S')
f = R(d, 'phq4', dei, cont=['Q'], factors=XDO_D)
postf(f, 'B2', 'phq4', 'Chỉ số thực thi Q', 'Q', 'B')
f = R(d, 'phq4', dei, cont=['Q', 'S'], factors=XDO_D)
postf(f, 'B2s', 'phq4', 'Chỉ số thực thi Q, thêm S', 'Q')
postf(f, 'B2s', 'phq4', 'S, cùng mô hình', 'S')

mQ, sdQ = d.Q[d.in_h3].mean(), d.Q[d.in_h3].std()
d['Qc'] = d.Q - mQ
note = f'ĐLC của Q = {sdQ:.3f}'
f = R(d, 'phq4', d.in_h3, cont=['S', 'Qc'], factors=XD, inter=[('S', 'Qc')])
postf(f, 'C1', 'phq4', 'S × Q (mẫu H3)', 'c.S#c.Qc', 'C')
postf(f, 'C1', 'phq4', 'Q tại S = 0', 'Qc')
postl(f, {'S': 1, 'c.S#c.Qc': -sdQ}, 'C1', 'phq4', 'S tại Q = trung bình − 1 ĐLC', 'S', note)
postf(f, 'C1', 'phq4', 'S tại Q trung bình', 'S', note=note)
postl(f, {'S': 1, 'c.S#c.Qc': sdQ}, 'C1', 'phq4', 'S tại Q = trung bình + 1 ĐLC', 'S', note)


def mod_count(part, touse, npol, covars, kb=None, label='', fam=''):
    mN, sdN = d.loc[touse, npol].mean(), d.loc[touse, npol].std()
    lowv = max(0.0, mN - sdN)
    lo = mN - lowv
    note = f'TB = {mN:.2f}; ĐLC = {sdN:.2f}'
    d['npol_c'] = d[npol] - mN
    cont = ['S', 'npol_c'] + ([kb] if kb else [])
    f = R(d, 'phq4', touse, cont=cont, factors=covars, inter=[('S', 'npol_c')])
    postf(f, part, 'phq4', f'{label}S × số chính sách', 'c.S#c.npol_c', fam, note)
    postf(f, part, 'phq4', f'{label}Số chính sách tại S = 0', 'npol_c', note=note)
    postl(f, {'S': 1, 'c.S#c.npol_c': -lo}, part, 'phq4', f'{label}S tại số chính sách = {lowv:.2f}', 'S', note)
    postf(f, part, 'phq4', f'{label}S tại số chính sách trung bình', 'S', note=note)
    postl(f, {'S': 1, 'c.S#c.npol_c': sdN}, part, 'phq4', f'{label}S tại số chính sách = TB + 1 ĐLC', 'S', note)


mod_count('C2', dei, 'npol_co', XDO_D, kb='npol_kb', fam='C')

for b, blab in (('lo', 'Cận dưới (không biết = không)'), ('hi', 'Cận trên (không biết = có)')):
    f = R(d, 'S', dei, cont=[f'npol_{b}'], factors=XDO_D)
    postf(f, 'DN_A1', 'S', blab, f'npol_{b}')
    f = R(d, 'phq4', dei, cont=[f'npol_{b}'], factors=XDO_D)
    postf(f, 'DN_B1', 'phq4', blab, f'npol_{b}')
    mod_count('DN_C2', dei, f'npol_{b}', XDO_D, label=f'{blab}: ')
nokb = dei & (d.npol_kb == 0)
f = R(d, 'S', nokb, cont=['npol_co'], factors=XDO_D)
postf(f, 'DN_A1', 'S', 'Không có câu không biết nào', 'npol_co')
f = R(d, 'phq4', nokb, cont=['npol_co'], factors=XDO_D)
postf(f, 'DN_B1', 'phq4', 'Không có câu không biết nào', 'npol_co')
mod_count('DN_C2', nokb, 'npol_co', XDO_D, label='Không có câu không biết nào: ')
al = d.in_dei_all
f = R(d, 'S', al, cont=['npol_co', 'npol_kb'], factors=XDO_A)
postf(f, 'DN_A1', 'S', 'Mẫu DEI toàn bộ', 'npol_co')
f = R(d, 'S', al, cont=['Q'], factors=XDO_A)
postf(f, 'DN_A2', 'S', 'Mẫu DEI toàn bộ', 'Q')
f = R(d, 'phq4', al, cont=['npol_co', 'npol_kb'], factors=XDO_A)
postf(f, 'DN_B1', 'phq4', 'Mẫu DEI toàn bộ', 'npol_co')
f = R(d, 'phq4', al, cont=['Q'], factors=XDO_A)
postf(f, 'DN_B2', 'phq4', 'Mẫu DEI toàn bộ', 'Q')
mod_count('DN_C2', al, 'npol_co', XDO_A, kb='npol_kb', label='Mẫu DEI toàn bộ: ')
d['Qc_d'] = d.Q - d.Q[dei].mean()
f = R(d, 'phq4', dei, cont=['S', 'Qc_d'], factors=XDO_D, inter=[('S', 'Qc_d')])
postf(f, 'DN_C1', 'phq4', 'S × Q trên mẫu DEI, XD + loại hình, quy mô tổ chức', 'c.S#c.Qc_d')

# section 7: Benjamini-Hochberg within families
r = pd.DataFrame(res)
r['p_bh'] = np.nan
for fam, g in r[(r.fam != '') & r.p.notna()].groupby('fam'):
    p = g.p.sort_values()
    mm = len(p)
    adj = (p * mm / np.arange(1, mm + 1)).clip(upper=1)
    adj = adj[::-1].cummin()[::-1]
    r.loc[adj.index, 'p_bh'] = adj
r = r[['part', 'fam', 'outcome', 'spec', 'term', 'b', 'se', 'lb', 'ub', 'p', 'p_bh', 'N', 'note']]
r.to_csv(os.path.join(OUT, 'ket_qua.csv'), index=False)
pd.set_option('display.width', 250)
pd.set_option('display.max_colwidth', 70)
print('\n== ket_qua')
print(r.drop(columns=['note']).round(4).to_string(index=False))
print('\nnotes:', r.loc[r.note != '', ['part', 'term', 'note']].values.tolist())
print('\ncollapse:', d.attrs['collapse_log'])

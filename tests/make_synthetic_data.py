#!/usr/bin/env python3
"""Sinh dữ liệu GIẢ LẬP có cùng cấu trúc với tệp Kobo (tên biến chuẩn trong
docs/codebook.md) để chạy thử pipeline Stata mà không cần dữ liệu thật.

Số đếm của luồng mẫu được dựng khớp đề cương (Bảng 2): 850 -> 727 -> 640
(340/300) -> 601 (323/278) -> 278 -> 256 / 247 -> 243. Quan hệ giữa các biến
là bịa, KHÔNG mang ý nghĩa thực nghiệm nào.

Chạy:  python3 tests/make_synthetic_data.py [--out data/raw/synthetic.csv]
Chỉ dùng thư viện chuẩn.
"""
import argparse
import csv
import os
import random

rng = random.Random(20260928)
PNTA = 9


def clip(x, lo, hi):
    return max(lo, min(hi, x))


def likert(mean, lo, hi, sd=1.0):
    return int(round(clip(rng.gauss(mean, sd), lo, hi)))


def person(kind):
    """kind: 'under18', 'nojob', 'undet9', 'undet8', 'undetblank', 'non', 'lgbt'"""
    r = {k: "" for k in FIELDS}
    r["age18"] = 0 if kind == "under18" else 1
    r["has_job"] = 0 if kind == "nojob" else 1
    r["lgbt_self"] = {"undet9": 9, "undet8": 8, "undetblank": "", "non": 0, "lgbt": 1}.get(kind, rng.choice([0, 1]))
    is_lgbt = kind == "lgbt"
    r["sex_birth"] = rng.choices([1, 2], [0.38, 0.62])[0]
    if is_lgbt:
        r["orient"] = rng.choices([4, 3, 2, 5, 1, 6], [87, 74, 68, 23, 10, 16])[0]
        r["gender_id"] = rng.choices([1, 2, 3, 4, 5], [130, 135, 4, 4, 5])[0]
    else:
        r["orient"] = 1
        r["gender_id"] = r["sex_birth"]
    r["agegrp"] = rng.choices([1, 2, 3, 4], [0.35, 0.45, 0.15, 0.05])[0]
    r["educ"] = rng.choices([1, 2, 3, 4], [0.1, 0.2, 0.55, 0.15])[0]
    r["relstat"] = rng.choices([1, 2, 3], [0.55, 0.3, 0.15])[0]
    r["region"] = rng.choices([1, 2, 3, 4], [0.3, 0.5, 0.08, 0.12] if is_lgbt else [0.25, 0.42, 0.05, 0.28])[0]
    r["exper"] = rng.randint(1, 5)
    r["industry"] = rng.randint(1, 10)
    r["position"] = rng.choices([1, 2, 3, 4, 5], [0.45, 0.25, 0.18, 0.1, 0.02])[0]
    r["emptype"] = rng.randint(1, 4)
    r["orgtype"] = rng.randint(1, 5)
    r["orgsize"] = rng.randint(1, 4)
    r["socins"] = rng.choice([0, 1])
    r["hours"] = rng.randint(1, 4)

    # Kỳ thị (chỉ người LGBT)
    S = 0.0
    if is_lgbt:
        exposed = rng.random() < 0.7
        vals = []
        for j in range(1, 8):
            base = [0.9, 0.8, 0.4, 0.05, 0.25, 0.3, 0.7][j - 1] if exposed else 0
            v = clip(int(round(rng.expovariate(1 / base))) if base > 0 else 0, 0, 4)
            vals.append(v)
            r[f"stig{j}"] = v
        r["stig8"] = clip(int(round(rng.expovariate(1 / 0.4))), 0, 4) if exposed else 0
        S = sum(vals) / 7
        for j in range(1, 5):
            r[f"conc{j}"] = likert(2.5 + 0.6 * S, 1, 5)
    # PHQ-4 phụ thuộc S (bịa)
    total = clip(rng.gauss(3.0 + 1.2 * S, 3.0), 0, 12)
    gad = clip(int(round(total * rng.uniform(0.4, 0.6))), 0, 6)
    dep = clip(int(round(total)) - gad, 0, 6)
    r["phqi1"], r["phqi2"] = clip(gad - gad // 2, 0, 3), clip(gad // 2, 0, 3)
    r["phqi3"], r["phqi4"] = clip(dep - dep // 2, 0, 3), clip(dep // 2, 0, 3)
    for j in range(1, 5):
        r[f"dei{j}"] = likert(3.3, 1, 5)
    return r


FIELDS = (["resp_id", "submit_time", "age18", "has_job", "lgbt_self", "orient", "gender_id",
           "sex_birth", "agegrp", "educ", "relstat", "region", "exper", "industry", "position",
           "emptype", "orgtype", "orgsize", "socins", "hours", "phqi1", "phqi2", "phqi3", "phqi4"]
          + [f"stig{j}" for j in range(1, 9)] + [f"conc{j}" for j in range(1, 5)]
          + [f"dei{j}" for j in range(1, 5)])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="data/raw/synthetic.csv")
    a = ap.parse_args()

    plan = (["under18"] * 37 + ["nojob"] * 86 + ["undet9"] * 32 + ["undet8"] * 29
            + ["undetblank"] * 26 + ["non"] * 340 + ["lgbt"] * 300)
    rows = [person(k) for k in plan]
    non = [r for r, k in zip(rows, plan) if k == "non"]
    lg = [r for r, k in zip(rows, plan) if k == "lgbt"]
    rng.shuffle(non)
    rng.shuffle(lg)

    # Non-LGBT: 17 người thiếu ít nhất một câu PHQ -> 323 đủ PHQ-4
    for r in non[:17]:
        r["phqi" + str(rng.randint(1, 4))] = ""
    # LGBT: 3 người bỏ cả phần kỳ thị và thiếu PHQ; thêm 19 người chỉ thiếu PHQ -> 278
    for r in lg[:3]:
        for j in range(1, 9):
            r[f"stig{j}"] = ""
        r["phqi2"] = ""
    for r in lg[3:22]:
        r["phqi" + str(rng.randint(1, 4))] = ""
    main_ = lg[22:]                       # 278 người, đủ PHQ-4, có >= 5 câu kỳ thị hợp lệ
    # 65 trong 297 người trả lời phần kỳ thị chọn "không áp dụng" ở câu 8
    for r in lg[3:68]:
        r["stig8"] = PNTA
    # vài câu kỳ thị "không muốn trả lời" (vẫn >= 5 câu hợp lệ)
    for r in main_[:30]:
        r[f"stig{rng.randint(1, 7)}"] = PNTA
    # 22 người thiếu thật một biến Xᴰ (không phải sex_birth) -> 256
    for r in main_[:22]:
        r[rng.choice(["agegrp", "educ", "relstat", "region"])] = ""
    # 9 người có mã 9 ở một biến Xᴰ -> 247 theo quy tắc thay thế
    for r in main_[22:31]:
        r[rng.choice(["agegrp", "educ", "relstat", "region"])] = PNTA
    # 13 người thiếu >= 2 câu DEI -> 243
    for r in main_[31:44]:
        r["dei1"], r["dei2"] = PNTA, ""
    # một ít thiếu ở Xᴶ
    for r in main_[44:60]:
        r[rng.choice(["exper", "industry", "orgsize", "hours"])] = ""

    for i, r in enumerate(rows, 1):
        r["resp_id"] = f"SYN{i:04d}"
        r["submit_time"] = f"2026-08-{1 + i % 28:02d}T10:00:00"
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    with open(a.out, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=FIELDS)
        w.writeheader()
        w.writerows(rows)
    print(f"Đã ghi {len(rows)} dòng giả lập vào {a.out}")


if __name__ == "__main__":
    main()

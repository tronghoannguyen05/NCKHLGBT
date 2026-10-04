# Kỳ thị nơi làm việc và sức khỏe tâm thần của người lao động LGBT tại Việt Nam

*Pathology or Prejudice? Workplace Stigma and Mental Health among LGBT Workers in Vietnam* — công trình NCKH sinh viên, Học viện Ngân hàng.

Đây là repo tái lập cho phân tích. **Dữ liệu cá nhân không bao giờ được commit** (xem `CLAUDE.md`, quy tắc 1).

## Trạng thái

Đã dựng khung pipeline Stata theo đề cương lần 2. Mã **chưa được chạy thử** trên Stata. Việc đầu tiên là chạy trên dữ liệu giả lập (`tests/make_synthetic_data.py`), sửa lỗi nếu có, rồi mới chạy trên dữ liệu thật. Các việc đang mở được liệt kê trong `CLAUDE.md` và `docs/review_notes.md`.

## Chạy

```
# 1. (tùy chọn) dữ liệu giả lập để thử pipeline
python3 tests/make_synthetic_data.py          # tạo data/raw/synthetic.csv

# 2. trong Stata 17, từ thư mục gốc của repo
do code/00_master.do
```

Tham số nằm trong `config/settings.do`. Ánh xạ tên biến Kobo nằm trong `config/variable_map.csv`.

## Pipeline

| Bước | Tệp | Ra |
|---|---|---|
| Nhập, sàng lọc, mã hóa giá trị đặc biệt | `01_import_clean.do` | `data/derived/clean.dta` |
| Dựng chỉ số, cờ chất lượng | `02_build_indices.do` | `data/derived/analysis.dta` |
| Luồng mẫu (Bảng 2) | `03_sample_flow.do` | `output/tables/T2_sample_flow.csv` |
| Mô tả, độ tin cậy, E3, Bảng 5–6 | `04_descriptives.do` | `T5`, `T6`, `reliability` |
| H1, H2a, H2b (Bảng 7) | `05_main_models.do` | `T7` |
| H3 (Bảng 8) | `06_path_H3.do` | `T8`, `S_indirect_bootstrap` |
| E1, E2, E4, E5 (Bảng 9) | `07_exploratory.do` | `T9`, `S_E1` |
| Chẩn đoán | `08_diagnostics.do` | `S_diagnostics` |
| Độ bền (Bảng 4 đề cương) | `09_robustness.do` | `S_robustness` |
| Đường cong đặc tả | `10_spec_curve.do` | `S_spec_curve`, hình |
| Hiệu chỉnh p theo họ, tổng hợp | `11_tables.do` | bảng cuối |

## Cấu trúc

`docs/` đề cương và tài liệu thiết kế · `config/` tham số · `code/` mã Stata · `tests/` dữ liệu giả lập và kiểm tra · `data/` (không commit) · `output/` kết quả.

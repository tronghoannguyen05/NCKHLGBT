# Hướng dẫn chạy trên Stata

Cách chạy: mở **`CHAY_PHAN_TICH.do`** (ở thư mục gốc của repo) trong Stata 17 trở lên, chọn chế độ ở dòng `local CHE_DO`, rồi bấm **Do** (Ctrl+D). Tệp này tự làm các việc sau:
- tìm thư mục repo; nếu không tìm thấy thì mở hộp thoại để bạn chọn chính tệp này;
- kiểm tra phiên bản Stata;
- cài `sensemakr` và `boottest` nếu máy chưa có (cần Internet ở lần đầu);
- tìm tệp dữ liệu; nếu không thấy thì mở hộp thoại chọn tệp;
- chạy toàn bộ quy trình và ghi nhật ký vào `output/logs/`.

Mã **chưa từng chạy trên Stata**, vì môi trường soạn mã không có Stata. Bước nhập dữ liệu và hai bảng ánh xạ đã được kiểm tra bằng Python trên tệp thật, chỉ xem số đếm:
- mọi mã chữ trong tệp đều có trong `config/value_map.csv`;
- luồng mẫu khớp đề cương: 850 → 727 → 640 (340/300) → 601 (323/278) → 278 → 256/247 → 243.

## Ba chế độ, chạy theo thứ tự

| Thứ tự | `CHE_DO` | Dữ liệu | Làm gì | Khi nào |
|---|---|---|---|---|
| 1 | `"thu"` (mặc định) | Giả lập, có sẵn trong `tests/synthetic_kobo.csv` | Toàn bộ quy trình | Ngay bây giờ, để chắc mã chạy được trên máy bạn. Kết quả là bịa |
| 2 | `"kiemtra"` | Thật | Từ nhập dữ liệu đến gộp mức thưa (01–04b); chưa ước lượng mô hình | Trước khi đăng ký OSF |
| 3 | `"chinhthuc"` | Thật | Toàn bộ quy trình; có hộp thoại xác nhận trước khi chạy | Sau khi đã đăng ký `docs/analysis_plan.md` trên OSF |

**Dữ liệu thật:**
- Chép tệp `.xlsx` xuất từ Kobo vào `data/raw/`, giữ nguyên tên gốc cũng được.
- Nếu `data/raw/` chỉ có một tệp `.xlsx`, tệp chạy tự dùng tệp đó. Nếu không, nó mở hộp thoại để bạn chọn.
- Thư mục `data/` không bao giờ được commit.

## Nếu Stata báo lỗi

Gửi cho Claude **đoạn cuối của nhật ký** trong `output/logs/` (lệnh cuối cùng và thông báo lỗi màu đỏ). Ở chế độ `"thu"`, dữ liệu là giả lập nên gửi được. Ở chế độ thật, chỉ gửi nhật ký hoặc bảng tổng hợp, không gửi dòng dữ liệu.

Các lỗi có chủ ý:
- `03_sample_flow.do` dừng nếu luồng mẫu khác đề cương (`STRICT_COUNTS = 1` trong `config/settings.do`).
- `01_import_clean.do` dừng nếu gặp mã chữ chưa có trong `config/value_map.csv`, và in ra giá trị đó.

## Kết quả nằm ở đâu

| Tệp trong `output/tables/` | Nội dung |
|---|---|
| `T2_sample_flow.csv` | Luồng mẫu, đối chiếu với đề cương |
| `T5_sample.csv`, `T5_symptoms.csv`, `S_reliability.csv`, `S_stigma_prevalence.csv`, `S_E3_distribution.csv`, `res_T6.csv` | Mô tả mẫu (đã ẩn ô dưới 10), độ tin cậy, E3, Bảng 6 |
| `level_collapsing.csv` | Các mức biến kiểm soát đã gộp (số đếm ghi "<5") |
| `res_main.csv` | H1, H2a, H2b (đặc tả 1, đặc tả 2, quy tắc thay thế) và kiểm định tương đương của H1 |
| `res_H3.csv`, `S_indirect_bootstrap.csv` | H3 (C và C3); hiệu ứng gián tiếp cho tài liệu bổ sung |
| `T7_T8_main_and_path.csv` | H1–H3 kèm p hiệu chỉnh Holm |
| `res_expl.csv`, `T9_exploratory.csv` | E1–E5, E2 đối chiếu, lo âu so với trầm cảm, p hiệu chỉnh BH |
| `S_diagnostics.csv` | Breusch–Pagan, RESET, GVIF, số quan sát ảnh hưởng lớn |
| `res_robust.csv` | Kiểm tra độ bền, wild bootstrap, thêm xu hướng tính dục, gán giá trị đa lần |
| `res_spec.csv` và `output/figures/spec_curve.png` | Đường cong đặc tả |

Kết quả sensemakr được in trong nhật ký. Ghi các giá trị RV vào bảng kết quả bằng tay.

## An toàn dữ liệu

- Không commit, không gửi, không dán tệp dữ liệu thật hay bất kỳ tệp `.dta` nào trong `data/derived/`.
- Chạy `bash tests/check_no_data.sh` trước mỗi lần commit.

# Hướng dẫn chạy trên Stata

Toàn bộ phân tích nằm trong một tệp: **`phan_tich.do`** ở thư mục gốc của repo. Bản mô tả gói tái lập bằng tiếng Anh nằm ở `README.md`.

## Cách chạy

1. Mở `phan_tich.do` trong Stata 17 trở lên.
2. Đặt **bản xuất gốc từ Kobo** (tệp giữ nguyên mã phiếu, chưa chỉnh sửa) ở đường dẫn `DATA`, hoặc sửa `DATA` cho đúng tên tệp. Kiểm tra hai dòng đường dẫn ở mục 0:
   ```
   global DATA "D:/NCKH chủ đề LGBT/Kỳ_thị_tại_nơi_làm_việc_và_bất_lợi_thu_nhập_-_Khảo_sát_người_lao_động_tại_Việt_Nam_n850.xlsx"
   global OUT  "D:/NCKH chủ đề LGBT/ket_qua"
   ```
3. Bấm **Do** (Ctrl+D).

Lần chạy đầu cần Internet để cài `sensemakr` và `boottest`. Nếu đang mở `results.xlsx` trong Excel, hãy đóng lại trước khi chạy.

Mặc định `RUN_MODELS 1`: chạy toàn bộ. Đặt `global RUN_MODELS 0` nếu chỉ muốn nhập dữ liệu, đối chiếu luồng mẫu và xuất bảng mô tả.

## Kết quả

Trong thư mục `OUT`:
- `results.xlsx`: mỗi bảng của bài một sheet (`Table1` đến `Table7`, `TableS1`, `TableS2`, `TableS4` đến `TableS7`). Sheet `AllResults` chứa mọi hệ số, kèm p hiệu chỉnh Holm và BH, cột `paper_table` cho biết hệ số thuộc bảng nào.
- `figure2.png`: Hình 2 (đường cong đặc tả).
- `analysis.log`: nhật ký đầy đủ. Bảng S3 (sensemakr) được in ở mục "Table S3".

Bảng đầy đủ ánh xạ sheet với bảng của bài nằm trong `README.md`.

## Mã dừng có chủ ý

- **Gặp mã chữ chưa có trong bảng mã hóa:** Stata in ra giá trị đó và dừng.
- **Luồng mẫu khác Bảng 1** (850 → 727 → 640 → 601 → 278 → 256/247 → 243): Stata dừng.
- **Bảng 2 có một ô bị ẩn có thể suy ngược từ tổng cột:** Stata dừng.

## Lịch sử chạy

- 5/10/2026: chạy đủ hai lần trên máy tác giả, không lỗi; kết quả tổng hợp lưu ở `output/tables/stata/`. Mọi ước lượng không phụ thuộc số ngẫu nhiên khớp bản tái lập Python (`tests/python_replication/`) đến 10⁻⁹.
- 9/10/2026 (lần 1): chuyển chú thích, nhãn và tên sheet sang tiếng Anh, xuất mỗi bảng của bài thành một sheet, thêm Bảng 2 và Hình 2. Tác giả chạy lại cùng ngày, không lỗi; 59/59 dòng của `AllResults` giống hệt kết quả ngày 5/10.
- 9/10/2026 (lần 2): đọc bản xuất gốc; thêm Bảng S7 (bốn mô hình độ nhạy làm sau khi có kết quả) và hệ số trên một độ lệch chuẩn của S ở Bảng 4; vẽ lại Hình 2 thành một đồ thị để các cột thẳng hàng. Các ghi chép ở `docs/deviations.md`. **Cần chạy lại một lần.** Số cần ra (bản Python): Bảng S7 lần lượt 1,53; 1,81; 1,78; 1,68; hiệu ứng trên một độ lệch chuẩn của S là 0,82 điểm PHQ-4. Kiểm tra bằng `tests/python_replication/compare.py`.
- 10/10/2026: tác giả chạy bản trên, không lỗi. 62/62 dòng tất định khớp bản Python; 59 dòng có từ trước (kể cả bootstrap, wild bootstrap, gán giá trị đa lần) giống hệt lần chạy 9/10. Hình 2 thẳng cột. Kết quả tổng hợp lưu ở `output/tables/stata/` (tên tệp tiếng Anh).

Không đưa tệp dữ liệu hay tệp kết quả có dữ liệu cá nhân lên GitHub.

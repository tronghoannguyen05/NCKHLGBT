# Hướng dẫn chạy trên Stata

Toàn bộ phân tích nằm trong một tệp: **`phan_tich.do`** ở thư mục gốc của repo. Bản mô tả gói tái lập bằng tiếng Anh nằm ở `README.md`.

## Cách chạy

Không cần sửa đường dẫn nào. Mã tự tìm tệp dữ liệu, nên chép sang máy khác vẫn chạy được.

1. Đặt `phan_tich.do` và **bản xuất gốc từ Kobo** (tệp giữ nguyên mã phiếu, chưa chỉnh sửa, tên tệp gì cũng được) vào cùng một thư mục dự án. Tệp dữ liệu có thể nằm ngay trong thư mục đó hoặc trong `data/raw/`. Ví dụ:
   ```
   D:/NCKH chủ đề LGBT/
       phan_tich.do
       Kỳ_thị_..._n850.xlsx        (hoặc data/raw/Kỳ_thị_..._n850.xlsx)
   ```
2. Mở Stata bằng cách **bấm đúp vào `phan_tich.do`**. Stata sẽ lấy thư mục chứa tệp làm thư mục làm việc. Nếu Stata đang mở sẵn, chọn File > Change Working Directory và trỏ tới thư mục dự án.
3. Bấm **Do** (Ctrl+D).

Cách mã tìm dữ liệu: xét thư mục làm việc và tối đa ba thư mục phía trên; ở mỗi thư mục tìm lần lượt trong `data/raw/`, `data/` và chính thư mục đó. Mã chỉ nhận tệp .xlsx có đúng các biến của bản xuất khảo sát, nên các tệp Excel khác trong thư mục bị bỏ qua. Nếu không tìm thấy, Stata mở hộp thoại để chọn tệp. Muốn tự đặt đường dẫn, bỏ dấu `*` ở hai dòng ví dụ `global DATA` và `global OUT` trong mục 0.

Lần chạy đầu cần Internet để cài `sensemakr` và `boottest`. Nếu đang mở `results.xlsx` trong Excel, hãy đóng lại trước khi chạy.

Mặc định `RUN_MODELS 1`: chạy toàn bộ. Đặt `global RUN_MODELS 0` nếu chỉ muốn nhập dữ liệu, đối chiếu luồng mẫu và xuất bảng mô tả.

## Kết quả

Trong thư mục `output/results/` bên trong thư mục dự án (Stata in đường dẫn đầy đủ ở đầu `analysis.log`):
- `results.xlsx`: mỗi bảng của bài một sheet (`Table1` đến `Table8`, kèm `Table3_Severity` và `Table4_Number`; `TableS1`, `TableS2`, `TableS4` đến `TableS6`). Sheet `AllResults` chứa mọi hệ số, kèm p hiệu chỉnh BH, cột `paper_table` cho biết hệ số thuộc bảng nào.
- `figure2.png`: Hình 2 (đường cong đặc tả).
- `analysis.log`: nhật ký đầy đủ. Bảng S3 (sensemakr) được in ở mục "Table S3".

Bảng đầy đủ ánh xạ sheet với bảng của bài nằm trong `README.md`.

## Mã dừng có chủ ý

- **Gặp mã chữ chưa có trong bảng mã hóa:** Stata in ra giá trị đó và dừng.
- **Luồng mẫu khác Bảng 1** (850 → 734 → 719 → 300 → 272 → 235/226 → 233 (RQ1)): Stata dừng.
- **Có người trong mẫu không qua câu sàng lọc tuổi:** Stata dừng (lệnh `assert`).
- **Bảng 2, bảng số tình huống đã gặp hoặc bảng mức PHQ-4 có đúng một ô bị ẩn (có thể suy ngược từ tổng):** Stata dừng.

## Lịch sử chạy

- 5/10/2026: chạy đủ hai lần trên máy tác giả, không lỗi; kết quả tổng hợp lưu ở `output/tables/stata/`. Mọi ước lượng không phụ thuộc số ngẫu nhiên khớp bản tái lập Python (`tests/python_replication/`) đến 10⁻⁹.
- 9/10/2026 (lần 1): chuyển chú thích, nhãn và tên sheet sang tiếng Anh, xuất mỗi bảng của bài thành một sheet, thêm Bảng 2 và Hình 2. Tác giả chạy lại cùng ngày, không lỗi; 59/59 dòng của `AllResults` giống hệt kết quả ngày 5/10.
- 9/10/2026 (lần 2): đọc bản xuất gốc; thêm Bảng S7 (bốn mô hình độ nhạy làm sau khi có kết quả) và hệ số trên một độ lệch chuẩn của S ở Bảng 4; vẽ lại Hình 2 thành một đồ thị để các cột thẳng hàng. Các ghi chép ở `docs/deviations.md`. **Cần chạy lại một lần.** Số cần ra (bản Python): Bảng S7 lần lượt 1,53; 1,81; 1,78; 1,68; hiệu ứng trên một độ lệch chuẩn của S là 0,82 điểm PHQ-4. Kiểm tra bằng `tests/python_replication/compare.py`.
- 10/10/2026: tác giả chạy bản trên, không lỗi. 62/62 dòng tất định khớp bản Python; 59 dòng có từ trước (kể cả bootstrap, wild bootstrap, gán giá trị đa lần) giống hệt lần chạy 9/10. Hình 2 thẳng cột. Kết quả tổng hợp lưu ở `output/tables/stata/` (tên tệp tiếng Anh).
- 12/10/2026: sắp xếp lại theo góp ý của giảng viên hướng dẫn: H1 (kỳ thị và PHQ-4), RQ1 (ba nhóm tình huống kỳ thị, mới), H2 (chuỗi che giấu danh tính), H3 (thực thi DEI điều tiết, kèm hệ số của kỳ thị ở mức DEI thấp, trung bình, cao). Bỏ các phân tích không dùng trong bài; Bảng 2 và độ tin cậy chỉ tính trên mẫu chính. Ghi chép ở `docs/deviations.md`. **Cần chạy lại một lần.** Số cần ra (bản Python) ở mục "Số dự kiến" dưới đây. Kiểm tra bằng `tests/python_replication/compare.py`.

- 13/10/2026: tác giả chạy bản trên, không lỗi. 68/68 dòng tất định khớp bản Python (sai khác lớn nhất 2·10⁻⁶, do điểm nút spline); 53 dòng có từ lần chạy 10/10 (kể cả bootstrap, wild bootstrap, gán giá trị đa lần) giống hệt; luồng mẫu khớp ở cả 9 bước. Kết quả tổng hợp lưu ở `output/tables/stata/`.

- 13/10/2026 (lần 2): theo giảng viên hướng dẫn: luồng mẫu mới (có việc làm, có dữ liệu thực chất), chỉ số kỳ thị 8 tình huống (ít nhất 6/8 câu hợp lệ), tám nhóm biến kiểm soát (thêm tình trạng chuyển giới hoặc đa dạng giới, nhóm xu hướng tính dục, ngành), nhóm thể hiện giới của RQ1 gồm tình huống 7 và 8. Ghi chép ở `docs/deviations.md`. **Cần chạy lại một lần.** Số dự kiến (bản Python) ở mục dưới.

- 13/10/2026 (lần 2, chạy lúc 16:54): tác giả chạy bản trên, không lỗi. Luồng mẫu khớp cả 10 bước; 72/72 dòng tất định khớp bản Python (sai khác lớn nhất 1·10⁻⁶). Bootstrap a × b: 29/5.000 lần lặp không ước lượng được, khoảng tin cậy tính trên 4.971 lần còn lại. Kết quả tổng hợp lưu ở `output/tables/stata/` (sensemakr chép từ log).

- 16/10/2026: định vị lại theo giảng viên hướng dẫn: bài xoay quanh H1 và các hình thức kỳ thị. Bỏ H2 và H3 khỏi mã (phương án B của tác giả); thêm Bảng 4 (các hình thức kỳ thị đã gặp, số tình huống đã gặp), Bảng 5 (PHQ-4 theo từng hình thức, mô tả) và bốn mức PHQ-4 ở Bảng 3; bảng H1, RQ1 nay là Bảng 6, Bảng 7. Ghi chép ở `docs/deviations.md`. Bản Python: 59/59 dòng tất định khớp lần chạy 13/10 (lần 2). **Cần chạy lại một lần.** Số dự kiến ở mục dưới. Kiểm tra bằng `tests/python_replication/compare.py` (so cả các bảng mô tả mới).

- 16/10/2026 (chạy lúc 20:58): tác giả chạy bản trên, không lỗi. Luồng mẫu khớp cả 8 bước; 59/59 dòng tất định khớp bản Python (sai khác lớn nhất 1·10⁻⁶); bốn bảng mô tả mới (`Table3_Severity`, `Table4`, `Table4_Number`, `Table5`) khớp từng ô. So với lần chạy 13/10 (lần 2), 60/61 dòng chung giống hệt; chỉ gán giá trị đa lần đổi từ 2,02 thành 2,04 [0,99; 3,08], đúng dự kiến vì mô hình gán bỏ C và Q. Kết quả tổng hợp lưu ở `output/tables/stata/` (sensemakr không đổi).

- 21/10/2026: mã tự tìm thư mục dữ liệu, không còn đường dẫn ổ D trong mục 0; kết quả ghi vào `output/results/`. Đổi tên các biến phụ của phân tích hậu kiểm (`exper_s7`, `disclose_s7` thành `exper_ph`, `disclose_ph`), nên sheet `MergedCategories` hiện tên mới. Phân tích không đổi. **Cần chạy lại một lần** để xác nhận: mọi con số phải giống hệt lần chạy 16/10/2026 (20:58).

## Số dự kiến cho lần chạy 16/10/2026

| Sheet | Dòng | Số dự kiến |
|---|---|---|
| `Table1` | luồng mẫu | 850, 734, 719, 300, 272, 235, 226, 233 |
| `Table3_Severity` | PHQ-4 0–2, 3–5, 6–8, 9–12 | 108 (46,0%), 73 (31,1%), 38 (16,2%), 16 (6,8%) |
| `Table4` | gặp ít nhất một lần: bất kỳ, giao tiếp, nghề nghiệp, thể hiện giới | 134 (57,0%), 111 (47,2%), 41 (17,4%), 42 (18,0%) |
| `Table4` | tình huống 1, 2 | 62 (26,8%), 77 (33,9%) |
| `Table4_Number` | 0, 1, 2, từ 3 tình huống | 101, 63, 36, 35 |
| `Table5` | bất kỳ tình huống: PHQ-4 đã gặp và chưa gặp; tỷ lệ PHQ-4 ≥ 6 | 4,02 và 2,64 (hiệu 1,38); 29,1% và 14,9% |
| `Table5` | tình huống 4 | không báo cáo (dưới 10 người) |
| `Table6` | H1, Xᴰ; trên một độ lệch chuẩn của S | 1,85 [0,71; 2,99]; 0,86 [0,33; 1,40] |
| `Table7` | separate: `z_S_int`, `z_S_car`, `z_S_gen` | 0,86 [0,38; 1,33]; 0,49 [−0,12; 1,09]; 0,35 [−0,30; 0,99] |
| `Table8` | gán giá trị đa lần (mô hình gán mới) | gần 2,0 (bản Python 2,08; lần trước Stata 2,02) |
| `AllResults` | cột p | chỉ còn `p_bh` (không còn `p_holm`) |

Wild bootstrap và gán giá trị đa lần của bản Python chỉ xấp xỉ Stata.

Không đưa tệp dữ liệu hay tệp kết quả có dữ liệu cá nhân lên GitHub.

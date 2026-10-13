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
- `results.xlsx`: mỗi bảng của bài một sheet (`Table1` đến `Table8`, `TableS1`, `TableS2`, `TableS4` đến `TableS6`). Sheet `AllResults` chứa mọi hệ số, kèm p hiệu chỉnh Holm và BH, cột `paper_table` cho biết hệ số thuộc bảng nào.
- `figure2.png`: Hình 2 (đường cong đặc tả).
- `analysis.log`: nhật ký đầy đủ. Bảng S3 (sensemakr) được in ở mục "Table S3".

Bảng đầy đủ ánh xạ sheet với bảng của bài nằm trong `README.md`.

## Mã dừng có chủ ý

- **Gặp mã chữ chưa có trong bảng mã hóa:** Stata in ra giá trị đó và dừng.
- **Luồng mẫu khác Bảng 1** (850 → 734 → 719 → 300 → 272 → 235/226 → 233 (H2), 233 (RQ1), 223 (H3)): Stata dừng.
- **Có người trong mẫu không qua câu sàng lọc tuổi:** Stata dừng (lệnh `assert`).
- **Bảng 2 có một ô bị ẩn có thể suy ngược từ tổng cột:** Stata dừng.

## Lịch sử chạy

- 5/10/2026: chạy đủ hai lần trên máy tác giả, không lỗi; kết quả tổng hợp lưu ở `output/tables/stata/`. Mọi ước lượng không phụ thuộc số ngẫu nhiên khớp bản tái lập Python (`tests/python_replication/`) đến 10⁻⁹.
- 9/10/2026 (lần 1): chuyển chú thích, nhãn và tên sheet sang tiếng Anh, xuất mỗi bảng của bài thành một sheet, thêm Bảng 2 và Hình 2. Tác giả chạy lại cùng ngày, không lỗi; 59/59 dòng của `AllResults` giống hệt kết quả ngày 5/10.
- 9/10/2026 (lần 2): đọc bản xuất gốc; thêm Bảng S7 (bốn mô hình độ nhạy làm sau khi có kết quả) và hệ số trên một độ lệch chuẩn của S ở Bảng 4; vẽ lại Hình 2 thành một đồ thị để các cột thẳng hàng. Các ghi chép ở `docs/deviations.md`. **Cần chạy lại một lần.** Số cần ra (bản Python): Bảng S7 lần lượt 1,53; 1,81; 1,78; 1,68; hiệu ứng trên một độ lệch chuẩn của S là 0,82 điểm PHQ-4. Kiểm tra bằng `tests/python_replication/compare.py`.
- 10/10/2026: tác giả chạy bản trên, không lỗi. 62/62 dòng tất định khớp bản Python; 59 dòng có từ trước (kể cả bootstrap, wild bootstrap, gán giá trị đa lần) giống hệt lần chạy 9/10. Hình 2 thẳng cột. Kết quả tổng hợp lưu ở `output/tables/stata/` (tên tệp tiếng Anh).
- 12/10/2026: sắp xếp lại theo góp ý của giảng viên hướng dẫn: H1 (kỳ thị và PHQ-4), RQ1 (ba nhóm tình huống kỳ thị, mới), H2 (chuỗi che giấu danh tính), H3 (thực thi DEI điều tiết, kèm hệ số của kỳ thị ở mức DEI thấp, trung bình, cao). Bỏ các phân tích không dùng trong bài; Bảng 2 và độ tin cậy chỉ tính trên mẫu chính. Ghi chép ở `docs/deviations.md`. **Cần chạy lại một lần.** Số cần ra (bản Python) ở mục "Số dự kiến" dưới đây. Kiểm tra bằng `tests/python_replication/compare.py`.

- 13/10/2026: tác giả chạy bản trên, không lỗi. 68/68 dòng tất định khớp bản Python (sai khác lớn nhất 2·10⁻⁶, do điểm nút spline); 53 dòng có từ lần chạy 10/10 (kể cả bootstrap, wild bootstrap, gán giá trị đa lần) giống hệt; luồng mẫu khớp ở cả 9 bước. Kết quả tổng hợp lưu ở `output/tables/stata/`.

- 13/10/2026 (lần 2): theo giảng viên hướng dẫn: luồng mẫu mới (có việc làm, có dữ liệu thực chất), chỉ số kỳ thị 8 tình huống (ít nhất 6/8 câu hợp lệ), tám nhóm biến kiểm soát (thêm tình trạng chuyển giới hoặc đa dạng giới, nhóm xu hướng tính dục, ngành), nhóm thể hiện giới của RQ1 gồm tình huống 7 và 8. Ghi chép ở `docs/deviations.md`. **Cần chạy lại một lần.** Số dự kiến (bản Python) ở mục dưới.

- 13/10/2026 (lần 2, chạy lúc 16:54): tác giả chạy bản trên, không lỗi. Luồng mẫu khớp cả 10 bước; 72/72 dòng tất định khớp bản Python (sai khác lớn nhất 1·10⁻⁶). Bootstrap a × b: 29/5.000 lần lặp không ước lượng được, khoảng tin cậy tính trên 4.971 lần còn lại. Kết quả tổng hợp lưu ở `output/tables/stata/` (sensemakr chép từ log).

## Số dự kiến cho lần chạy 13/10/2026 (lần 2)

| Sheet | Dòng | Hệ số [KTC 95%] |
|---|---|---|
| `Table1` | 850, 734, 719, 300, 272, 235, 226, 233, 233, 223 | |
| `Table4` | H1, Xᴰ | 1,85 [0,71; 2,99] |
| `Table4` | trên một độ lệch chuẩn của S | 0,86 [0,33; 1,40] |
| `Table4` | thêm Xᴶ (n = 206); "không muốn trả lời" là thiếu (n = 226) | 1,95 [0,52; 3,37]; 1,94 [0,78; 3,10] |
| `Table5` | separate: `z_S_int`, `z_S_car`, `z_S_gen` | 0,86 [0,38; 1,33]; 0,49 [−0,12; 1,09]; 0,35 [−0,30; 0,99] |
| `Table5` | joint: `z_S_int`, `z_S_car`, `z_S_gen` | 0,77 [0,25; 1,29]; 0,18 [−0,56; 0,92]; 0,06 [−0,56; 0,68] |
| `Table6` | a, b (chỉ số C); p IUT | 0,31 [−0,07; 0,70]; 0,29 [−0,15; 0,73]; 0,196 |
| `Table7` | S × Q; S tại Q thấp, trung bình, cao | −1,31 [−3,04; 0,42]; 3,43; 2,41; 1,39 [0,08; 2,70] |
| `Table8` | bỏ ngành khỏi biến kiểm soát | 1,83 [0,71; 2,95] |
| `AllResults` | p Holm của H2 và H3 | 0,275 và 0,275 |

Bootstrap a × b, wild bootstrap và gán giá trị đa lần của bản Python chỉ xấp xỉ Stata.

Không đưa tệp dữ liệu hay tệp kết quả có dữ liệu cá nhân lên GitHub.

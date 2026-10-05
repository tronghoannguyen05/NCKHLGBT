# Hướng dẫn chạy trên Stata

Toàn bộ phân tích nằm trong một tệp: **`phan_tich.do`** ở thư mục gốc của repo.

## Cách chạy

1. Mở `phan_tich.do` trong Stata 17 trở lên.
2. Kiểm tra hai dòng đường dẫn ở mục 0:
   ```
   global DATA "D:/NCKH chủ đề LGBT/Kỳ_thị_tại_nơi_làm_việc_và_bất_lợi_thu_nhập_-_Khảo_sát_người_lao_động_tại_Việt_Nam_n850.xlsx"
   global OUT  "D:/NCKH chủ đề LGBT/ket_qua"
   ```
   Nếu Stata không tìm thấy tệp dữ liệu, nó mở hộp thoại để bạn chọn tệp.
3. Bấm **Do** (Ctrl+D).

Lần chạy đầu cần Internet để cài `sensemakr` và `boottest`. Nếu đang mở `ket_qua.xlsx` trong Excel, hãy đóng lại trước khi chạy.

## Chạy một phần

Mặc định `RUN_MODELS 1`: chạy toàn bộ. Đặt `global RUN_MODELS 0` nếu chỉ muốn nhập dữ liệu, đối chiếu luồng mẫu và xuất thống kê mô tả. Toàn bộ mất vài phút (bootstrap 5.000 lần, wild bootstrap 9.999 lần, 20 bộ gán giá trị).

## Kết quả

Kết quả nằm trong thư mục `OUT`:
- `ket_qua.xlsx`, mỗi phần một sheet: LuongMau, MoTaMau, TrieuChung, DoTinCay, TyLeKyThi, MoTaBien, TuongQuan, SoSanhKhuyet, GopMuc, E3, ChanDoan, DuongCongDacTa, KetQua. Sheet KetQua chứa mọi hệ số (cả Bảng 6), kèm p hiệu chỉnh Holm (`p_holm`) và BH (`p_bh`). Trong MoTaMau, `<10` là ô dưới 10 người, `ẩn` là ô bị ẩn kèm để không suy ngược được ô nhỏ.
- `spec_curve.png`: hình đường cong đặc tả.
- `nhat_ky.log`: toàn bộ nhật ký chạy. Kết quả sensemakr được in ở đây.

## Mã dừng có chủ ý

- **Gặp mã chữ chưa có trong bảng mã hóa:** Stata in ra giá trị đó và dừng.
- **Luồng mẫu khác đề cương** (850 → 727 → 640 → 601 → 278 → 256/247 → 243): Stata dừng.

Nếu Stata báo lỗi khác, gửi Claude đoạn cuối của `nhat_ky.log`. Không gửi dữ liệu.

## Lưu ý

- Toàn bộ tệp đã chạy thành công trên máy tác giả (5/10/2026). Kết quả tổng hợp lưu ở `output/tables/stata/`.
- Toàn bộ mục 1–12 đã được tái lập bằng Python trên tệp thật (`tests/doi_chieu_python/`, chỉ xuất số tổng hợp). Phần mô tả và hồi quy HC3 khớp kết quả Stata của tác giả đến 6 chữ số. Kết quả Python nằm ở `output/tables/doi_chieu_python/`. Sau khi chạy Stata, đối chiếu sheet KetQua với `KetQua.csv`: các phần tất định phải khớp, riêng bootstrap, wild bootstrap và gán giá trị đa lần chỉ khớp gần đúng vì khác bộ sinh số ngẫu nhiên.
- Không đưa tệp dữ liệu hay tệp kết quả có dữ liệu cá nhân lên GitHub.

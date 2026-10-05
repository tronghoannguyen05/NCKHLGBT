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

## Hai giai đoạn

| `RUN_MODELS` | Chạy gì | Khi nào |
|---|---|---|
| `0` (mặc định) | Nhập và mã hóa dữ liệu, đối chiếu luồng mẫu với đề cương, thống kê mô tả, độ tin cậy, gộp mức thưa | Ngay bây giờ |
| `1` | Thêm toàn bộ mô hình: H1–H3, E1–E5, chẩn đoán, độ bền, đường cong đặc tả | Sau khi đã đăng ký `docs/analysis_plan.md` trên OSF |

## Kết quả

Kết quả nằm trong thư mục `OUT`:
- `ket_qua.xlsx`, mỗi phần một sheet: LuongMau, MoTaMau, TrieuChung, DoTinCay, TyLeKyThi, GopMuc, Bang6, E3, ChanDoan, DuongCongDacTa, KetQua. Sheet KetQua có p hiệu chỉnh Holm (`p_holm`) và BH (`p_bh`).
- `spec_curve.png`: hình đường cong đặc tả.
- `nhat_ky.log`: toàn bộ nhật ký chạy. Kết quả sensemakr được in ở đây.

## Mã dừng có chủ ý

- **Gặp mã chữ chưa có trong bảng mã hóa:** Stata in ra giá trị đó và dừng.
- **Luồng mẫu khác đề cương** (850 → 727 → 640 → 601 → 278 → 256/247 → 243): Stata dừng.

Nếu Stata báo lỗi khác, gửi Claude đoạn cuối của `nhat_ky.log`. Không gửi dữ liệu.

## Lưu ý

- Mã chưa từng được chạy trên Stata (môi trường soạn mã không có Stata). Phần nhập và mã hóa dữ liệu đã được đối chiếu bằng Python trên tệp thật, chỉ xem số đếm: không có mã chưa ánh xạ, và luồng mẫu khớp đề cương.
- Không đưa tệp dữ liệu hay tệp kết quả có dữ liệu cá nhân lên GitHub.

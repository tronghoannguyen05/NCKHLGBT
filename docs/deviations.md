# Nhật ký lệch khỏi kế hoạch

Kế hoạch được chốt ngày 5/10/2026 (`docs/analysis_plan.md`, gồm mục 8), trước khi ước lượng mô hình chính. Kế hoạch **chưa được đăng ký OSF** khi ước lượng (xem dòng 1). Mọi thay đổi so với kế hoạch đã chốt phải ghi vào bảng dưới.

Ghi **trước** khi chạy lại phân tích. Mỗi dòng: ngày, phần bị ảnh hưởng, kế hoạch gốc, thay đổi, lý do, đã xem kết quả liên quan chưa.

| Ngày | Phần | Kế hoạch gốc | Thay đổi | Lý do | Đã xem kết quả? |
|---|---|---|---|---|---|
| 5/10/2026 | Đăng ký | Đăng ký kế hoạch trên OSF trước khi chạy mô hình chính | Chạy toàn bộ mô hình trước, đăng ký OSF sau. Bản đăng ký phải ghi rõ là được nộp sau khi ước lượng, kèm lịch sử commit của kế hoạch làm bằng chứng về thời điểm chốt | Quyết định của tác giả ngày 5/10/2026 | Không. Quyết định trước khi chạy mô hình |
| 5/10/2026 | Bảng 6 (mô tả) | Ước lượng trước khi gộp mức thưa | Ước lượng sau khi gộp mức thưa (mục 8, D2), như mọi mô hình khác | Ở mức gốc, một mức của nhóm tuổi chỉ có 1 người, đòn bẩy bằng 1 và sai số chuẩn HC3 của mức đó vô nghĩa | Đã xem Bảng 6 bản cũ. Chưa xem kết quả mô hình nào có S |
| 5/10/2026 | Phần mềm | Stata 17 | Bản thảo đầu tiên dùng số của bản tái lập Python (`tests/doi_chieu_python/`). Cùng ngày, tác giả chạy đủ `phan_tich.do` trên Stata; mọi số trong bài nay lấy từ Stata | Mọi ước lượng tất định của bản Python khớp Stata đến 10⁻⁹. Ba ước lượng dùng số ngẫu nhiên (bootstrap a×b, wild bootstrap, gán giá trị đa lần) khác chút ít và đã thay bằng số Stata | Không áp dụng |
| 5/10/2026 | sensemakr (mục 8, D11) | Mốc so sánh theo nhóm (`gbenchmark()`) cho cả giới tính khi sinh và học vấn | Giới tính khi sinh chỉ có một biến giả, nên dùng `benchmark()`. Với một biến, hai cách cho cùng giới hạn | `gbenchmark()` của Stata báo lỗi khi nhóm có dưới hai biến | Đã xem kết quả mốc học vấn. Lần chạy Stata thứ hai (5/10/2026) cho mốc giới tính khớp bản Python |

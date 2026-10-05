# Nhật ký lệch khỏi kế hoạch

Kế hoạch được chốt ngày 5/10/2026 (`docs/analysis_plan.md`, gồm mục 8), trước khi ước lượng mô hình chính. Kế hoạch **chưa được đăng ký OSF** khi ước lượng (xem dòng 1). Mọi thay đổi so với kế hoạch đã chốt phải ghi vào bảng dưới.

Ghi **trước** khi chạy lại phân tích. Mỗi dòng: ngày, phần bị ảnh hưởng, kế hoạch gốc, thay đổi, lý do, đã xem kết quả liên quan chưa.

| Ngày | Phần | Kế hoạch gốc | Thay đổi | Lý do | Đã xem kết quả? |
|---|---|---|---|---|---|
| 5/10/2026 | Đăng ký | Đăng ký kế hoạch trên OSF trước khi chạy mô hình chính | Chạy toàn bộ mô hình trước, đăng ký OSF sau. Bản đăng ký phải ghi rõ là được nộp sau khi ước lượng, kèm lịch sử commit của kế hoạch làm bằng chứng về thời điểm chốt | Quyết định của tác giả ngày 5/10/2026 | Không. Quyết định trước khi chạy mô hình |
| 5/10/2026 | Bảng 6 (mô tả) | Ước lượng trước khi gộp mức thưa | Ước lượng sau khi gộp mức thưa (mục 8, D2), như mọi mô hình khác | Ở mức gốc, một mức của nhóm tuổi chỉ có 1 người, đòn bẩy bằng 1 và sai số chuẩn HC3 của mức đó vô nghĩa | Đã xem Bảng 6 bản cũ. Chưa xem kết quả mô hình nào có S |
| 5/10/2026 | Phần mềm | Stata 17 | Số liệu trong bản thảo bài báo ngày 5/10/2026 được tính bằng bản tái lập Python của `phan_tich.do` (`tests/doi_chieu_python/`). Sẽ thay bằng kết quả Stata khi tác giả chạy | Môi trường soạn thảo không có Stata. Phần mô tả và hồi quy HC3 của bản Python khớp kết quả Stata của tác giả đến 6 chữ số. Bootstrap, wild bootstrap và gán giá trị đa lần chỉ khớp gần đúng (khác bộ sinh số ngẫu nhiên; bản Python dùng logit đa thức có phạt nhẹ thay cho `augment`) | Không áp dụng |

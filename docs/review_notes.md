# Nhận xét đề cương lần 2 và vấn đề đang mở

Xếp theo mức độ ưu tiên. Đánh dấu [x] khi đã xử lý và ghi vị trí đã sửa.

## A. Có thể chặn việc công bố

- [ ] **A1. Đạo đức nghiên cứu.** Dữ liệu được thu khi chưa có phê duyệt hoặc xác nhận miễn xét duyệt. Bảng hỏi không có trường ghi nhận đồng thuận riêng và không cung cấp thông tin hỗ trợ tâm lý, trong khi lại hỏi về triệu chứng lo âu và trầm cảm. Nhiều tạp chí không nhận phê duyệt hồi tố. Việc cần làm:
  - hỏi ngay bộ phận quản lý khoa học của Học viện Ngân hàng xem có cơ chế xác nhận miễn xét duyệt hoặc xét duyệt hồi tố hay không;
  - đọc chính sách đạo đức của từng tạp chí dự định gửi trước khi viết bản thảo;
  - chuẩn bị phương án dự phòng: trình bày kết quả như báo cáo NCKH nội bộ, và lấy mục 7.4 (mẫu độc lập, hai thời điểm, có phê duyệt) làm hướng công bố.

  Chi tiết ở `docs/ethics_data_protection.md`.
- [ ] **A2. Bảo vệ dữ liệu.** Dữ liệu về xu hướng tính dục và sức khỏe là dữ liệu nhạy cảm theo Luật 91/2025/QH15 và Nghị định 356/2025/NĐ-CP. Cần một kế hoạch bảo vệ dữ liệu bằng văn bản: ai giữ dữ liệu, lưu ở đâu, có mã hóa không, khi nào xóa. Cần kiểm tra cả việc tài khoản KoboToolbox có còn giữ bản sao không.

## B. Phương pháp

- [ ] **B1. Kiểm tra cấu trúc hai nhân tố của PHQ-4** (CFA trên n = 601, hoặc ít nhất trên n = 278). Phiên bản tiếng Việt chưa được thẩm định, trong khi H2a và H2b dựa vào việc tách lo âu và trầm cảm. Báo cáo CFI, RMSEA và tương quan giữa hai nhân tố trong tài liệu bổ sung. Đây là một bổ sung rẻ nhưng tăng độ tin cậy. Việc này phải ghi vào `deviations.md` như một phân tích mô tả thêm sau đăng ký.
- [ ] **B2. Đường cong đặc tả.** Đề cương nói “bốn cách tính chỉ số kỳ thị” và “hai định nghĩa nhóm LGBT” nhưng không liệt kê. Cần đối chiếu với OSF (`analysis_plan.md` mục 6).
- [ ] **B3. E4 theo xu hướng tính dục.** Có 103 + 64 + 64 = 231 người trong 256, nên 25 người không thuộc ba nhóm. Cần ghi rõ cách xử lý họ.
- [ ] **B4. Họ BH.** E2 và E4 là một họ hay hai họ hiệu chỉnh? Bảng 9 hiện ghi chung “p đã hiệu chỉnh”.
- [ ] **B5. E2 với tình huống 4.** Chỉ 1,6% người từng gặp, tức khoảng 4 người, nên hệ số gần như không ước lượng được. Nên tuyên bố trước rằng tình huống có dưới 10 người gặp chỉ được báo cáo số người, không báo cáo hệ số. Ghi vào `deviations.md` nếu OSF chưa có quy tắc này.
- [ ] **B6. Số câu hợp lệ tối thiểu của chỉ số che giấu** chưa được nêu.
- [ ] **B7. Góp ý bổ sung ngày 4/10/2026** (hiệu ứng nhỏ nhất có ý nghĩa và kiểm định tương đương, nhóm thưa và HC3, wild bootstrap, thứ tự câu hỏi kỳ thị → PHQ-4, sai lệch chọn mẫu, xu hướng tính dục trong Xᴰ, kiểm định hiệu ở E2, cách trình bày tương tác): xem `docs/gop_y_phuong_phap.md`.

## C. Trình bày

- [ ] **C1. Tóm tắt** ghi “kỳ thị được đo bằng tám tình huống”, trong khi chỉ số chính dùng bảy. Nên viết: “tám tình huống, trong đó bảy tình huống tạo thành chỉ số chính”.
- [ ] **C2. Lỗi chính tả** “Trinhf cơ quan xét duyệt” ở mục 9.3.
- [ ] **C3. Tiêu đề** “Bệnh lý hay định kiến?” có thể bị phản biện cho là hứa nhiều hơn thiết kế cắt ngang làm được. Mục 1.1 đã giải thích, nhưng có thể cân nhắc thêm phụ đề như “bằng chứng tương quan từ một khảo sát cắt ngang”.
- [ ] **C4. Mục 9.1** gọi Herry và Dyar (2025) là “bài mẫu về cách trình bày”. Trong bản thảo gửi tạp chí nên bỏ cách gọi này và viết thẳng yêu cầu của tạp chí.
- [ ] **C5. Bảng 2** nên tách rõ: có 300 người LGBT, 297 người trả lời phần kỳ thị, 278 người có đủ PHQ-4 và S.

## D. Đã kiểm tra, không có vấn đề

- Tính MDE: SE(η) ≈ 3,19 / (0,48 × √256) ≈ 0,415, nên MDE ≈ 2,8 × 0,415 ≈ 1,16 điểm, tương đương ≈ 0,56 điểm trên một SD của S. Khớp với đề cương.
- Số đếm E4 theo giới tính khi sinh: 159 + 97 = 256. Khớp.
- Cách xác định p của H3 bằng giao–hợp (lấy giá trị p lớn hơn) đúng với lập luận của đề cương.

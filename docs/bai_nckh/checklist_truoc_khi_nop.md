# Việc cần làm trước khi nộp bài

Bài: `docs/bai_nckh/manuscript_en_article.md` (bản gốc) và `manuscript_en_article.docx` (bản nộp). Các chỗ cần tác giả điền được đánh dấu trong ngoặc vuông `[...]`.

## Bắt buộc

1. **Chạy lại `phan_tich.do` bản tiếng Anh (9/10/2026) một lần.** Logic không đổi, nhưng tên sheet, nhãn, Bảng 2 và Hình 2 là mã mới. Đối chiếu sheet `AllResults` với `output/tables/stata/KetQua.csv`: mọi hệ số phải giống hệt.
2. **Hồ sơ đạo đức.** Điền tên hội đồng, số và ngày phê duyệt ở mục *Ethics Approval*. Đây là vấn đề lớn nhất (`docs/ethics_data_protection.md`). Hầu hết tạp chí Q1 không nhận bài thiếu mục này.
3. **Đăng ký OSF.** Nộp `docs/analysis_plan.md` bản ngày 5/10/2026, ghi rõ nộp sau ước lượng. Điền đường dẫn vào hai chỗ `[registration link]` (mục *Analysis history and registration* và *Data Availability*).
4. **Trang đầu.** Tên tác giả, đơn vị, tác giả liên hệ, email, ORCID.
5. **Declarations.** Lời cảm ơn (giảng viên hướng dẫn, chuyên gia góp ý bảng hỏi), đóng góp của tác giả theo CRediT, nguồn tài trợ. Kiểm tra lại hai câu đã viết sẵn: cách người tham gia đồng ý (đọc trang thông tin rồi tiếp tục trả lời) và *no competing interests*.

## Nên làm

6. **Tìm kiếm tài liệu có hệ thống** (Scopus, Web of Science, PubMed, các tạp chí tiếng Việt) để xác nhận hai câu "to our knowledge" ở mục *The Vietnamese Context* và *Current Study*. Lần tìm nhanh ngày 9/10/2026 không thấy nghiên cứu nào đo kỳ thị nơi làm việc và lo âu, trầm cảm ở người lao động LGBT tại Việt Nam.
7. **Trích dẫn thứ cấp.** Dyar và cộng sự (2020) và Pachankis và cộng sự (2018) đang được trích qua Herry và Dyar (2025). Nếu đọc được bản gốc, chuyển thành trích trực tiếp và thêm vào danh mục tài liệu.
8. **DOI** của L. V. Nguyen và cộng sự (2026), *Health Psychology Report*: hiện ghi đường dẫn trang bài, chưa xác nhận được DOI.
9. **Chọn tạp chí** và đối chiếu hướng dẫn tác giả. Bài hiện có: tóm tắt khoảng 250 từ theo năm mục như Herry và Dyar (2025), phần chính khoảng 9.500 từ (chưa tính bảng và tài liệu tham khảo), 7 bảng, 2 hình, tài liệu bổ sung (Supplementary Methods và Bảng S1–S6). Nếu tạp chí yêu cầu, tách tài liệu bổ sung thành tệp riêng.

## Đã xong

- Số liệu trong bài lấy từ hai lần chạy Stata ngày 5/10/2026, khớp bản tái lập Python.
- Trích dẫn Schmitt và cộng sự (2014), r = −.23, đã đối chiếu với tóm tắt bài gốc.
- Hình 1 (sơ đồ nhân quả) vẽ lại bằng tiếng Anh: `docs/bai_nckh/figures/fig1_causal_diagram.py`.
- Mọi bảng chéo theo nhóm đã ẩn ô dưới 10 người; nhóm chuyển giới và phi nhị nguyên không được trình bày riêng.

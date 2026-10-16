# Việc cần làm trước khi nộp bài

Bài: `docs/bai_nckh/manuscript_en_article.md` (bản gốc) và `manuscript_en_article.docx` (bản nộp, dựng lại từ bản gốc). Các chỗ cần tác giả điền được đánh dấu trong ngoặc vuông `[...]`.

Bản viết lại ngày 16/10/2026 theo cấu trúc giảng viên hướng dẫn đã chốt: câu hỏi trung tâm là người lao động LGBT gặp những hình thức kỳ thị nào và các hình thức đó liên hệ thế nào với sức khỏe tâm thần; H1 là kiểm định duy nhất, RQ1 (ba nhóm hình thức) là thăm dò. Số liệu lấy từ lần chạy Stata 13/10/2026 (lần 2); Bảng 3–5 lấy từ bản Python (tất định, phải khớp Stata).

## Bắt buộc

1. **Chạy lại `phan_tich.do` (bản 16/10/2026).** Sau khi có kết quả:
   - điền hệ số gán giá trị đa lần vào ba chỗ `[to be updated]` (Bảng 8, dòng 5, và câu cuối đoạn đầu mục *Robustness and Sensitivity Analyses*);
   - đối chiếu Bảng 3, 4, 5 với các sheet `Table3_*`, `Table4`, `Table4_Number`, `Table5` (chạy `tests/python_replication/compare.py`).
2. **Hồ sơ đạo đức.** Điền tên hội đồng, số và ngày phê duyệt ở mục *Ethics Approval*. Đây là vấn đề lớn nhất (`docs/ethics_data_protection.md`). Hầu hết tạp chí Q1 không nhận bài thiếu mục này.
3. **Nơi công bố mã.** Bài không nói kế hoạch đã đăng ký trước. Điền đường dẫn công bố mã và kế hoạch phân tích vào hai chỗ `[registration link]` (mục *Software* và *Data Availability*). Nếu đăng ký OSF, ghi rõ nộp sau ước lượng.
4. **Trang đầu.** Tên tác giả, đơn vị, tác giả liên hệ, email, ORCID.
5. **Declarations.** Lời cảm ơn (giảng viên hướng dẫn, chuyên gia góp ý bảng hỏi), đóng góp của tác giả theo CRediT, nguồn tài trợ. Kiểm tra lại hai câu đã viết sẵn: cách người tham gia đồng ý (đọc trang thông tin rồi tiếp tục trả lời) và *no competing interests*.

## Nên làm

6. **Tìm kiếm tài liệu có hệ thống** (Scopus, Web of Science, PubMed, các tạp chí tiếng Việt) để xác nhận câu "to our knowledge" ở mục *Current Study*.
7. **Trích dẫn thứ cấp.** Dyar và cộng sự (2020) và Pachankis và cộng sự (2018) đang được trích qua Herry và Dyar (2025). Nếu đọc được bản gốc, chuyển thành trích trực tiếp và thêm vào danh mục tài liệu.
8. **DOI** của L. V. Nguyen và cộng sự (2026), *Health Psychology Report*: hiện ghi đường dẫn trang bài, chưa xác nhận được DOI.
9. **Chọn tạp chí** và đối chiếu hướng dẫn tác giả. Bài hiện có: tóm tắt khoảng 260 từ theo năm mục như Herry và Dyar (2025), phần chính khoảng 9.000 từ (chưa tính bảng và tài liệu tham khảo), 8 bảng, 2 hình, tài liệu bổ sung (Supplementary Methods và Bảng S1–S6). Nếu tạp chí yêu cầu, tách tài liệu bổ sung thành tệp riêng.

## Đã xong

- Bỏ H2, H3 khỏi bài; chỉ còn một câu về phạm vi ở mục *Other measures* (phương án B). Không còn dấu vết của các phân tích đã bỏ ngày 12/10/2026.
- Thêm phần mô tả các hình thức kỳ thị (Bảng 4) và PHQ-4 theo từng hình thức (Bảng 5); Bảng 3 có bốn mức PHQ-4.
- Mục *Analysis history* và Supplementary Methods S3 nêu thẳng các lần sửa kế hoạch sau khi đã có kết quả ban đầu, kèm ngày.
- Hình 1 vẽ lại với tám nhóm biến kiểm soát; Hình 2 vẽ lại từ kết quả Stata (`docs/bai_nckh/figures/fig2_specification_curve.py`).
- Trích dẫn Schmitt và cộng sự (2014), r = −.23, đã đối chiếu với tóm tắt bài gốc.
- Mọi bảng chéo theo nhóm và mọi bảng trải nghiệm kỳ thị đã ẩn ô dưới 10 người, kể cả ô suy ra được; nhóm chuyển giới và phi nhị nguyên không được trình bày riêng.

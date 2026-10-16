# Việc cần làm trước khi nộp bài

Bài: `docs/bai_nckh/manuscript_en_article.md` (bản gốc) và `manuscript_en_article.docx` (bản nộp, dựng lại từ bản gốc). Các chỗ cần tác giả điền được đánh dấu trong ngoặc vuông `[...]`.

Bản viết lại ngày 16/10/2026 theo cấu trúc giảng viên hướng dẫn đã chốt và theo trình tự của bài mẫu Herry và Dyar (2025): câu hỏi trung tâm là người lao động LGBT gặp những hình thức kỳ thị nào và các hình thức đó liên hệ thế nào với sức khỏe tâm thần; H1 là kiểm định duy nhất, RQ1 (ba nhóm hình thức) là thăm dò. Mọi số liệu lấy từ lần chạy Stata ngày 16/10/2026 (`output/tables/stata/`). Bài không có mục lịch sử phân tích và không nhắc đến đăng ký OSF (quyết định của tác giả ngày 16/10/2026).

## Bắt buộc

1. **Hồ sơ đạo đức.** Điền tên hội đồng, số và ngày phê duyệt ở hai chỗ: cuối đoạn đầu mục *Participants and Procedures* và mục *Ethics Approval*. Đây là vấn đề lớn nhất (`docs/ethics_data_protection.md`). Hầu hết tạp chí Q1 không nhận bài thiếu mục này.
2. **Trang đầu.** Tên tác giả, đơn vị, tác giả liên hệ, email, ORCID.
3. **Declarations.** Lời cảm ơn (giảng viên hướng dẫn, chuyên gia góp ý bảng hỏi), đóng góp của tác giả theo CRediT, nguồn tài trợ. Kiểm tra lại các câu đã viết sẵn: cách người tham gia đồng ý (đọc trang thông tin rồi tiếp tục trả lời), *Data Availability* (mã và kết quả tổng hợp cung cấp theo yêu cầu) và *no competing interests*.

## Nên làm

4. **Tìm kiếm tài liệu có hệ thống** (Scopus, Web of Science, PubMed, các tạp chí tiếng Việt) để xác nhận ba câu "to our knowledge": cuối mục *Workplace Stigma in the Vietnamese Context*, trong mục *Current Study* và câu đầu phần *Discussion*.
5. **Trích dẫn thứ cấp.** Dyar và cộng sự (2020) và Pachankis và cộng sự (2018) đang được trích qua Herry và Dyar (2025). Nếu đọc được bản gốc, chuyển thành trích trực tiếp và thêm vào danh mục tài liệu.
6. **Ngo và cộng sự (2026)**, *Tạp chí Nghiên cứu Y học*, về tự kỳ thị ở cộng đồng LGBTQ+ miền Bắc và miền Trung: đã bỏ khỏi bài vì không xác minh được đủ danh sách tác giả, số tập và trang. Nếu muốn dùng lại, lấy thông tin từ bản PDF của tạp chí rồi mới thêm.
7. **Chọn tạp chí** và đối chiếu hướng dẫn tác giả. Bài hiện có: tóm tắt khoảng 250 từ theo năm mục như Herry và Dyar (2025), phần chính khoảng 10.000 từ (chưa tính bảng và tài liệu tham khảo), 8 bảng, 2 hình, tài liệu bổ sung (Supplementary Methods S1–S2 và Bảng S1–S6). Nếu tạp chí giới hạn độ dài, phần nên rút trước là *Analytic Plan* và các đoạn số liệu lặp lại bảng ở *Results*.

## Đã xong

- Toàn bài viết lại theo trình tự của bài mẫu: Introduction (hai mục lý thuyết, bối cảnh Việt Nam, Current Study, Hypotheses), Methods (Participants and Procedures, Measures với câu hỏi nguyên văn, Analytic Plan), Results, Discussion (các mục theo phát hiện, Policy Implications, Limitations and Future Directions, Conclusions).
- Bỏ H2, H3; chỉ còn một câu về phạm vi ở mục *Other Measures and Response Quality* (phương án B). Không còn dấu vết của các phân tích đã bỏ ngày 12/10/2026.
- Bỏ mục *Analysis history* và Supplementary Methods S3 theo yêu cầu tác giả. Bài không nói các phân tích được đăng ký trước; các phân tích sau kết quả vẫn được gắn nhãn *post hoc* (Bảng S6).
- Điền hệ số gán giá trị đa lần (2,04 [0,99; 3,08]) và sửa khoảng hệ số của các kiểm tra độ bền thành 1,56–2,04.
- Đối chiếu từng tài liệu tham khảo với nguồn gốc trên web (16/10/2026): sửa tác giả của báo cáo iSEE 2015 (Luong & Pham), thêm DOI của L. V. Nguyen và cộng sự (2026), thay van Buuren và Groothuis-Oudshoorn (2011) bằng White và cộng sự (2011) cho phương pháp gán giá trị đa lần, sửa câu trích Owens và cộng sự (2022) cho đúng nội dung bài gốc.
- Hình 1 vẽ lại với tám nhóm biến kiểm soát; Hình 2 vẽ lại từ kết quả Stata (`docs/bai_nckh/figures/fig2_specification_curve.py`).
- Mọi bảng chéo theo nhóm và mọi bảng trải nghiệm kỳ thị đã ẩn ô dưới 10 người, kể cả ô suy ra được; nhóm chuyển giới và phi nhị nguyên không được trình bày riêng.

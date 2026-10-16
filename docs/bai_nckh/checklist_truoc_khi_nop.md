# Việc cần làm trước khi nộp bài

Bài gốc: `docs/bai_nckh/manuscript_en_article.md`. Bộ hồ sơ nộp *Sexuality Research and Social Policy* (SRSP) nằm ở `docs/bai_nckh/srsp/`:

| Tệp | Nộp ở mục | Nội dung |
|---|---|---|
| `Manuscript.docx` | Bản thảo (ẩn danh) | Trang 1 chỉ có tên bài; tóm tắt và từ khóa; phần chính; Declarations; Compliance with Ethical Standards; Acknowledgments; References; mỗi bảng một trang; trang chú thích hình; mỗi hình một trang |
| `Title_Page.docx` | Trang tiêu đề (mục nộp riêng) | Tên bài, tác giả, đơn vị (chú thích chân trang), tác giả liên hệ, Acknowledgments, Statements and Declarations |
| `Supplementary_Material.docx` | Tài liệu bổ sung | Supplementary Methods S1–S4 và Bảng S1–S6, không có tên tác giả |
| `docs/bai_nckh/figures/fig1_causal_diagram.png`, `fig2_specification_curve.png` | Tệp hình, nếu hệ thống yêu cầu | 300 dpi |

Ba tệp Word được dựng bằng `python3 docs/bai_nckh/srsp/build_srsp.py` (cần pandoc và python-docx). Muốn sửa nội dung thì sửa `manuscript_en_article.md` hoặc `srsp/title_page.md`, rồi chạy lại script; không sửa trực tiếp tệp Word, vì lần dựng sau sẽ ghi đè. Các chỗ cần tác giả điền nằm trong ngoặc vuông `[...]`.

Bản viết lại ngày 16/10/2026 theo cấu trúc giảng viên hướng dẫn đã chốt và theo trình tự của bài mẫu Herry và Dyar (2025): câu hỏi trung tâm là người lao động LGBT gặp những hình thức kỳ thị nào và các hình thức đó liên hệ thế nào với sức khỏe tâm thần; H1 là kiểm định duy nhất, RQ1 (ba nhóm hình thức) là thăm dò. Mọi số liệu lấy từ lần chạy Stata ngày 16/10/2026 (`output/tables/stata/`). Bài không có mục lịch sử phân tích và không nhắc đến đăng ký OSF (quyết định của tác giả ngày 16/10/2026).

## Bắt buộc

1. **Hồ sơ đạo đức.** Đây là vấn đề lớn nhất (`docs/ethics_data_protection.md`). Hướng dẫn của SRSP ghi rằng phê duyệt hồi cứu thường không được chấp nhận và bài có thể không được đưa đi phản biện. Câu về đạo đức phải điền ở ba chỗ:
   - cuối đoạn đầu mục *Participants and Procedures* (`Manuscript.docx`);
   - mục *Research Involving Human Participants* trong *Compliance with Ethical Standards* (`Manuscript.docx`);
   - mục *Ethics Approval* (`Title_Page.docx`).

   Trong bản ẩn danh, nếu tên hội đồng làm lộ tên trường thì ghi "masked for review". Chỉ viết câu tuân thủ Tuyên bố Helsinki khi nghiên cứu thật sự đã được hội đồng phê duyệt hoặc cho miễn xét duyệt.
2. **Trang tiêu đề** (`srsp/title_page.md`):
   - tên và thứ tự tác giả, trong đó có ít nhất một viên chức của Học viện;
   - khoa và đơn vị (chỉ ghi *Banking Academy of Vietnam*);
   - địa chỉ gửi thư, điện thoại, fax (nếu có), email `@hvnh.edu.vn`;
   - ORCID của từng tác giả.
3. **Statements and Declarations** (`srsp/title_page.md`):
   - *Funding* và *Acknowledgments*: dùng câu chữ đã thống nhất với VNC;
   - *Author Contributions*;
   - *Ethics Approval*.

   Kiểm tra lại các câu đã viết sẵn: *Consent to Participate* (đọc trang thông tin rồi tiếp tục trả lời), *Consent to Publish* (không áp dụng), *Data Availability* và *Code Availability* (cung cấp theo yêu cầu hợp lý), *Competing Interests*.
4. **Trước khi tải lên.**
   - Mở `Manuscript.docx` trong Word, tìm chuỗi `[Authors` để chắc không còn chỗ trống (không tìm dấu `[`, vì khoảng tin cậy và tài liệu tham khảo cũng dùng ngoặc vuông). Trong `Title_Page.docx`, mọi chỗ trong ngoặc vuông đều phải điền.
   - Nếu đã lưu lại tệp bằng Word, chạy File > Info > Check for Issues > Inspect Document và xóa thông tin cá nhân, vì Word tự ghi tên người sửa vào tệp.
   - Tên tệp không được chứa tên tác giả.

## Cần tác giả và giảng viên quyết

5. **Độ dài.** SRSP ghi: "generally no longer than 40 double-spaced pages". `Manuscript.docx` hiện có 57 trang, phân bổ như sau:

   | Phần | Số trang |
   |---|---|
   | Trang tên bài | 1 |
   | Tóm tắt và từ khóa | 2 |
   | Phần chính, từ Introduction đến Conclusions | khoảng 31 |
   | Declarations, Compliance with Ethical Standards, Acknowledgments | 2 |
   | Tài liệu tham khảo | 9 |
   | Tám bảng (Bảng 2 dài hai trang) | 9 |
   | Chú thích hình | 1 |
   | Hai hình | 2 |

   Phần không phải chữ của bài đã chiếm khoảng 26 trang, nên không thể về 40 trang mà vẫn giữ đủ 8 bảng và nội dung đã chốt. Đã làm trong lần dựng này:
   - chuyển chi tiết kỹ thuật của *Analytic Plan* sang Supplementary Methods S2–S3;
   - rút tóm tắt còn 247 từ.

   Nếu muốn rút thêm, có thể:
   - chuyển Bảng 1 (luồng mẫu, đã có trong đoạn văn) và Bảng 8 (độ bền, đã tóm tắt trong đoạn văn và Hình 2) sang tài liệu bổ sung, bớt khoảng 2 trang;
   - rút các đoạn ở *Results* lặp lại số liệu của Bảng 4 và Bảng 5, cùng các đoạn ở *Limitations* lặp lại *Methods*, bớt khoảng 2–3 trang.

   Cả hai việc đổi cấu trúc mà giảng viên đã chốt, nên cần giảng viên đồng ý.
6. **Kiểu trích dẫn.** Tài liệu tham khảo đang theo APA 7. Hướng dẫn SRSP dẫn APA 6 (2010) "in general" và chỉ "suggested", nên APA 7 thường vẫn được nhận; nhà xuất bản dàn lại theo kiểu của tạp chí sau khi bài được chấp nhận. Nếu tạp chí yêu cầu đúng APA 6, cần sửa ba điểm:
   - thêm nơi xuất bản cho sách;
   - liệt kê tác giả theo quy tắc sáu tác giả;
   - trích lần đầu đủ tên khi bài có 3–5 tác giả.

## Nên làm

7. **Tìm kiếm tài liệu có hệ thống** (Scopus, Web of Science, PubMed, các tạp chí tiếng Việt) để xác nhận ba câu "to our knowledge":
   - cuối mục *Workplace Stigma in the Vietnamese Context*;
   - trong mục *Current Study*;
   - câu đầu phần *Discussion*.
8. **Trích dẫn thứ cấp.** Dyar và cộng sự (2020) và Pachankis và cộng sự (2018) đang được trích qua Herry và Dyar (2025). Nếu đọc được bản gốc, chuyển thành trích trực tiếp và thêm vào danh mục tài liệu.
9. **Ngo và cộng sự (2026)**, *Tạp chí Nghiên cứu Y học*, về tự kỳ thị ở cộng đồng LGBTQ+ miền Bắc và miền Trung: đã bỏ khỏi bài vì không xác minh được đủ danh sách tác giả, số tập và trang. Nếu muốn dùng lại, lấy thông tin từ bản PDF của tạp chí rồi mới thêm.

## Điều kiện nhận tài trợ công bố quốc tế của Học viện

Căn cứ: Quy chế chi tiêu nội bộ (Quyết định 3272/QĐ-HVNH ngày 23/6/2026, mục 2.1.7) và Thông báo 5711/TB-HVNH ngày 13/11/2025, theo tài liệu hướng dẫn tác giả cung cấp ngày 16/10/2026. Việc tạp chí nhận bài không tự động bảo đảm được tài trợ; Viện Nghiên cứu khoa học ngân hàng (VNC) xét hồ sơ.

**Trước khi nộp**

- [ ] Có ít nhất một viên chức hoặc người lao động của Học viện cùng đứng tên (thường là giảng viên hướng dẫn). Sinh viên nộp bài khi còn đang học; lưu email xác nhận ngày nộp.
- [ ] Thứ tự tác giả đúng đóng góp thực tế; khai đóng góp theo CRediT. Mức hỗ trợ chia đều theo tổng số tác giả.
- [ ] Đơn vị ghi đúng *Banking Academy of Vietnam*, chỉ một đơn vị. Sai thứ tự đơn vị: chỉ nhận 50%; nhiều đơn vị ngoài trường hợp cho phép: không được tài trợ.
- [ ] Email dạng `@hvnh.edu.vn` và ORCID đúng cho từng tác giả của Học viện. Nếu chưa có email Học viện, hỏi VNC trước; không thay bằng email khác.
- [ ] *Acknowledgments* và *Funding* (trên trang tiêu đề) ghi nhận hỗ trợ của Học viện (thiếu: chỉ nhận 90%). Thống nhất câu chữ với VNC; không tự đặt mã tài trợ. Trong bản ẩn danh, hai mục này ghi "removed for masked review".
- [ ] Nhờ VNC xác nhận: SRSP thuộc nhóm nào (Scopus Q mấy, theo hệ thống, năm và ngành nào; có thuộc SSCI không); đề tài có được coi là phù hợp lĩnh vực của Học viện không. Lưu phản hồi và minh chứng xếp hạng, ISSN.
- [ ] Loại bài là *original research article*, không thuộc các loại bị loại trừ (review, commentary, note, letter...).
- [ ] Phê duyệt đạo đức (mục 1 ở trên). Bài bị rút đăng hoặc có bằng chứng vi phạm đạo đức nghiên cứu thì phải hoàn lại 100% tài trợ.

**Sau khi công bố**

- [ ] Có Online First, DOI: cập nhật ORCID của các tác giả Học viện, chuẩn bị hồ sơ (Mẫu 01a, 02, 03, 04 nếu áp dụng; toàn văn, bìa, mục lục; minh chứng xếp hạng, ISSN, ORCID).
- [ ] Sau 3 tháng từ Online First, nếu đã có DOI nhưng chưa có số tập: được gửi hồ sơ.
- [ ] Gửi hồ sơ trong 12 tháng từ Online First, quá hạn thì không được chi.
- [ ] Khi sửa bản proof, kiểm tra lại tên tác giả, đơn vị, email, ORCID và lời cảm ơn.

## Đã xong

- **Định dạng theo hướng dẫn SRSP (16/10/2026).**
  - Bản thảo ẩn danh: trang 1 chỉ có tên bài, siêu dữ liệu của tệp Word không có tên người tạo, tên tệp không chứa tên tác giả.
  - Giãn dòng đôi toàn bộ, kể cả bảng, chú thích bảng và tài liệu tham khảo; lề 1 inch; đánh số trang liên tục từ trang tên bài.
  - Tóm tắt có cấu trúc (Introduction, Methods, Results, Conclusions, Policy Implications), 247 từ, có cỡ mẫu và năm thu dữ liệu (2026, tác giả đồng ý; không nêu ngày, tháng). Có 7 từ khóa.
  - Conclusions thành mục chính. Mục Policy Implications vẫn nằm trong Discussion.
  - Thứ tự cuối bài: Declarations (Funding; Conflicts of Interest/Competing Interests; Availability of Data and Material; Code Availability; Authors' Contributions), Compliance with Ethical Standards, Acknowledgments (một đoạn, ngay trước References).
  - Bảng: mỗi bảng một trang, tên bảng ở giữa phía trên, chú thích đánh bằng chữ cái thường viết trên. Bảng 3, 5, 7 đặt trang ngang.
  - Hình: danh sách chú thích hình ở trang riêng, mỗi hình một trang.
- Toàn bài viết lại theo trình tự của bài mẫu: Introduction (hai mục lý thuyết, bối cảnh Việt Nam, Current Study, Hypotheses), Methods (Participants and Procedures, Measures với câu hỏi nguyên văn, Analytic Plan), Results, Discussion (các mục theo phát hiện, Policy Implications, Limitations and Future Directions), Conclusions.
- Bỏ H2, H3; chỉ còn một câu về phạm vi ở mục *Other Measures and Response Quality* (phương án B). Không còn dấu vết của các phân tích đã bỏ ngày 12/10/2026.
- Bỏ mục *Analysis history* và phụ lục lịch sử phân tích (S3 của bản trước) theo yêu cầu tác giả. Bài không nói các phân tích được đăng ký trước; các phân tích sau kết quả vẫn được gắn nhãn *post hoc* (Bảng S6). Supplementary Methods hiện gồm:
  - S1, gộp nhóm thưa;
  - S2, danh mục kiểm tra độ bền và đường cong đặc tả;
  - S3, nhiễu không đo được và chẩn đoán;
  - S4, các cách tiếp cận không dùng.
- Điền hệ số gán giá trị đa lần (2,04 [0,99; 3,08]) và sửa khoảng hệ số của các kiểm tra độ bền thành 1,56–2,04.
- Đối chiếu từng tài liệu tham khảo với nguồn gốc trên web (16/10/2026):
  - sửa tác giả của báo cáo iSEE 2015 (Luong & Pham);
  - thêm DOI của L. V. Nguyen và cộng sự (2026);
  - thay van Buuren và Groothuis-Oudshoorn (2011) bằng White và cộng sự (2011) cho phương pháp gán giá trị đa lần;
  - sửa câu trích Owens và cộng sự (2022) cho đúng nội dung bài gốc.
- Hình 1 vẽ lại với tám nhóm biến kiểm soát; Hình 2 vẽ lại từ kết quả Stata (`docs/bai_nckh/figures/fig2_specification_curve.py`).
- Mọi bảng chéo theo nhóm và mọi bảng trải nghiệm kỳ thị đã ẩn ô dưới 10 người, kể cả ô suy ra được; nhóm chuyển giới và phi nhị nguyên không được trình bày riêng.

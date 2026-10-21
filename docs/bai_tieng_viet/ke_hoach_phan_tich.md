# Kế hoạch phân tích của bài tiếng Việt

Bài gửi *Tạp chí Nghiên cứu Con người, Gia đình và Giới*. Tên tạm: *Chính sách DEI tại nơi làm việc, kỳ thị và sức khỏe tâm thần của người lao động LGBT ở Việt Nam: phân tích thăm dò và hàm ý chính sách*.

Kế hoạch được ghi ngày 21/10/2026, **trước** khi chạy bất kỳ phân tích nào dưới đây. Mọi thay đổi sau ngày này ghi vào mục 9 của tệp này, kèm ngày và lý do.

## 1. Quan hệ với bài SRSP

- Hai bài dùng chung bộ dữ liệu nhưng có **do-file riêng**. Bài SRSP dùng `phan_tich.do`. Bài tiếng Việt dùng `phan_tich_bai_tieng_viet.do`. Do-file này tự đọc dữ liệu, tự mã hóa và tự dựng mẫu, không gọi `phan_tich.do`.
- Theo lựa chọn (a) của tác giả (21/10/2026), bài tiếng Việt có đóng góp riêng. Bài tập trung vào chính sách DEI, nguồn gây kỳ thị (Câu 20), góp ý của người lao động (Câu 25) và đối chiếu pháp lý. Bài khai rõ việc dùng chung dữ liệu với bài SRSP. Tác giả báo cho cả hai ban biên tập.
- Bài SRSP không đổi. Trong bài SRSP, các câu DEI vẫn chỉ được dùng để dựng cờ chất lượng `flag_straight`.
- Kết quả H3 (thực thi DEI được cảm nhận điều tiết liên hệ giữa kỳ thị và PHQ-4) **đã biết** từ lần chạy Stata ngày 13/10/2026: hệ số tương tác −1,31, KTC 95% [−3,04; 0,42], n = 223, tức chưa xác định. Mọi phân tích DEI của bài tiếng Việt vì vậy là **thăm dò**, được chốt sau khi đã thấy một phần kết quả. Bài phải báo cáo đầy đủ, kể cả các kết quả không ủng hộ.

## 2. Câu hỏi nghiên cứu

1. Theo người lao động LGBT, nơi làm việc có những chính sách DEI nào (Câu 23), và họ cảm nhận việc thực thi ra sao (Câu 24)? Mô tả.
2. Người lao động LGBT gặp những hình thức kỳ thị nào (Câu 19), và ai gây ảnh hưởng nghiêm trọng nhất (Câu 20)? Mô tả.
3. Chính sách DEI và mức thực thi được cảm nhận liên hệ thế nào với mức kỳ thị đã gặp và với điểm PHQ-4? Liên hệ giữa kỳ thị và PHQ-4 có khác nhau theo mức thực thi và theo số chính sách không? Thăm dò.
4. Người lao động LGBT đề xuất gì để nơi làm việc an toàn và công bằng hơn (Câu 25)? Mô tả, phân tích nội dung.
5. Pháp luật hiện hành điều chỉnh các hình thức kỳ thị đến đâu? Đối chiếu văn bản, không có kiểm định.

## 3. Mẫu

| Mẫu | Định nghĩa | Dùng cho |
|---|---|---|
| Mẫu LGBT (`in_lgbt`) | 300 người tự nhận LGBT, có dữ liệu thực chất | Câu 25 |
| Mẫu chính (`in_xd_main`) | 235 người, như bài SRSP | Mô tả kỳ thị, Câu 20, H1 làm bối cảnh |
| Mẫu H3 (`in_h3`) | Mẫu chính có chỉ số Q hợp lệ (223) | Mô hình C1, đúng đặc tả 13/10/2026 |
| Mẫu DEI (`in_dei`) | Mẫu chính, làm việc trong một tổ chức, trả lời đủ năm câu của Câu 23, có Q hợp lệ, không trống loại hình và quy mô tổ chức | Mọi bảng và mô hình DEI khác |
| Mẫu DEI toàn bộ (`in_dei_all`) | Như mẫu DEI nhưng giữ cả người tự doanh và freelancer | Độ nhạy |

- "Làm việc trong một tổ chức" (lựa chọn a): loại hình nơi làm việc (Câu 8) không phải "tự doanh/hộ kinh doanh", và quan hệ việc làm (Câu 6) không phải "freelancer độc lập". Lý do: Câu 23–24 hỏi về chính sách của nơi làm việc. "Không muốn trả lời" ở Câu 8 được giữ thành nhóm riêng, như quy tắc chính của biến kiểm soát.
- Mọi mô hình DEI dùng chung một mẫu (`in_dei`), để các hệ số so sánh được với nhau.

## 4. Biến

**Chính sách DEI (Câu 23).** Năm câu: (1) chính sách bằng văn bản chống phân biệt đối xử dựa trên SOGIE; (2) kênh hoặc quy trình khiếu nại bảo mật; (3) đào tạo về DEI cho quản lý hoặc nhân viên; (4) phúc lợi cho bạn đời cùng giới hoặc người phụ thuộc ngoài hôn nhân truyền thống; (5) biện pháp hỗ trợ người chuyển giới về tên gọi, đại từ, trang phục, nhà vệ sinh hoặc thủ tục nhân sự.

- `pol1`–`pol5`: 1 có, 0 không, 8 không biết.
- **"Không biết" không được gán thành "không"** (quyết định của tác giả, 21/10/2026). Người trả lời không biết là chưa rõ nơi làm việc có hay không có chính sách. "Không biết" là một nhóm riêng trong mọi bảng và mô hình.
- `npol_co`: số chính sách được báo là có (0–5). `npol_kb`: số câu trả lời "không biết" (0–5). Hai biến chỉ tính khi đủ năm câu.
- Mô hình chính dùng `npol_co` và **điều chỉnh `npol_kb`**. Hệ số của `npol_co` so sánh hai người có cùng số câu "không biết", khác nhau một chính sách đã biết là có thay vì đã biết là không. Không câu "không biết" nào bị quy về có hoặc không.
- Độ nhạy: (i) cận dưới, `npol_lo` = `npol_co`, không điều chỉnh `npol_kb` (như thể "không biết" là không); (ii) cận trên, `npol_hi` = `npol_co` + `npol_kb` (như thể "không biết" là có); (iii) chỉ những người không có câu "không biết" nào. Hai cận chỉ dùng để xem kết luận có phụ thuộc vào cách hiểu "không biết" hay không.

**Thực thi DEI được cảm nhận (Câu 24).** Bốn phát biểu (1–5): an toàn khi phản ánh; quản lý trực tiếp tôn trọng người LGBT; hành vi nói đùa hoặc xúc phạm người LGBT bị nhắc nhở hoặc xử lý; được dùng tên gọi, đại từ, trang phục phù hợp. Mã 9 (không rõ, không áp dụng, không muốn trả lời) là giá trị thiếu.

- `Q`: trung bình bốn câu, tính khi có ít nhất 3 câu hợp lệ (định nghĩa cũ, không đổi).
- Đồng ý: mức 4–5. Trung lập: 3. Không đồng ý: 1–2.

**Nguồn gây ảnh hưởng nghiêm trọng nhất (Câu 20).** Chỉ hỏi người đã gặp ít nhất một tình huống. Một lựa chọn: quản lý trực tiếp, đồng nghiệp, khách hàng hoặc đối tác, bộ phận nhân sự, người khác, không muốn trả lời. Câu trả lời tự do của "người khác" (`c20_source_other`) không được đọc.

**Kỳ thị và PHQ-4.** Như bài SRSP: chỉ số S (trung bình 8 tình huống, ít nhất 6 câu), ba chỉ số con, các biến đã gặp và gặp thường xuyên, PHQ-4 (0–12).

**Biến kiểm soát của mô hình DEI (lựa chọn b).** Tám nhóm Xᴰ, thêm loại hình nơi làm việc (Câu 8) và quy mô (Câu 9). Hai đặc điểm này vừa quyết định nơi làm việc có chính sách DEI hay không, vừa có thể liên quan đến kỳ thị. "Không muốn trả lời" và "không rõ" là nhóm riêng. Mức thưa (dưới 5 người) được gộp trong mẫu DEI theo cùng quy tắc chỉ dựa vào số đếm như bài SRSP. Mẫu DEI toàn bộ được gộp riêng.

## 5. Bảng mô tả

Mọi bảng theo đặc điểm nơi làm việc hoặc nhóm SOGIE ẩn ô dưới 10 người và ô suy ra được ô bị ẩn (`MIN_CELL`).

1. Luồng mẫu, thêm bước mẫu DEI.
2. Đặc điểm mẫu DEI, gồm loại hình và quy mô tổ chức.
3. Năm chính sách DEI: số người trả lời, có, không, không biết. Phân bố `npol_co` (0, 1, 2, từ 3 trở lên) và `npol_kb` (0, 1–2, từ 3 trở lên).
4. Bốn phát biểu thực thi: số trả lời hợp lệ, tỷ lệ không đồng ý, trung lập, đồng ý, trung bình và độ lệch chuẩn; chỉ số Q và hệ số α.
5. Khoảng cách giữa chính sách và thực thi, chỉ mô tả. Với mỗi chính sách: trung bình Q ở nhóm có, không, không biết. Ba cặp tương ứng: kênh khiếu nại (23.2) với an toàn khi phản ánh (24.1); đào tạo DEI (23.3) với quản lý tôn trọng (24.2); hỗ trợ người chuyển giới (23.5) với được dùng tên gọi, đại từ, trang phục (24.4), mỗi cặp báo tỷ lệ đồng ý theo nhóm. Nhóm dưới 10 người không được báo cáo.
6. Chính sách DEI theo loại hình nơi làm việc: số chính sách trung bình và tỷ lệ có ít nhất một chính sách. Nhóm dưới 10 người không được báo cáo.
7. Các hình thức kỳ thị đã gặp trên mẫu chính (giống Bảng 4 của bài SRSP).
8. Câu 20 trong số người đã gặp ít nhất một tình huống (mẫu chính), và trong số người đã gặp từng nhóm hình thức.
9. Câu 25: chủ đề góp ý (mục 7).

## 6. Mô hình thăm dò

OLS, sai số chuẩn HC3. Hệ số của một nhóm phân loại chỉ được báo cáo khi nhóm đó và nhóm tham chiếu đều có ít nhất 10 người trong mẫu của mô hình. Khoảng tin cậy được đọc như bài SRSP: chứa cả 0 và các giá trị có ý nghĩa thực tiễn thì kết luận là chưa xác định.

**Họ A: DEI và mức kỳ thị (biến phụ thuộc S), mẫu DEI.** BH trên 7 kiểm định có tên A1–A7.

- A1: `npol_co`, điều chỉnh `npol_kb`.
- A2: Q.
- A3–A7: từng chính sách (`i.pol_j`, tham chiếu "không"). Kiểm định trong họ là "có" so với "không". Hệ số "không biết" so với "không" được báo cáo, không nằm trong họ.

**Họ B: DEI và PHQ-4, mẫu DEI.** BH trên 2 kiểm định.

- B1: `npol_co`, điều chỉnh `npol_kb`. B2: Q.
- Mỗi mô hình được ước lượng lại khi thêm S (B1s, B2s), để xem liên hệ giữa DEI và PHQ-4 thay đổi bao nhiêu khi xét cùng mức kỳ thị. Đây là so sánh mô tả, không phải phân tích trung gian.

**Họ C: điều tiết (biến phụ thuộc PHQ-4).** BH trên 2 kiểm định tương tác.

- C1: S × Qc, đúng đặc tả ngày 13/10/2026 (lựa chọn d): mẫu H3 (223), Xᴰ, Q trừ trung bình của mẫu. Hệ số của S tại Q trung bình và tại trung bình ± 1 độ lệch chuẩn.
- C2: S × `npol_co` (trừ trung bình), điều chỉnh `npol_kb`, Xᴰ, loại hình và quy mô tổ chức, mẫu DEI. Hệ số của S tại `npol_co` trung bình và tại trung bình ± 1 độ lệch chuẩn; điểm thấp không nhỏ hơn 0.

**Bối cảnh.** Hệ số của S trong mô hình H1 trên mẫu chính (nhắc lại kết quả của bài SRSP) và trên mẫu DEI với cùng biến kiểm soát của mô hình DEI.

**Độ nhạy (không hiệu chỉnh đa kiểm định).**

- A1, B1, C2: cận dưới, cận trên, chỉ người không có câu "không biết", mẫu DEI toàn bộ.
- A2, B2: mẫu DEI toàn bộ.
- C1: trên mẫu DEI, với biến kiểm soát của mô hình DEI.

## 7. Câu 25: góp ý của người lao động

- Mẫu: 300 người của mẫu LGBT. Phân tích nội dung không cần đủ biến kiểm soát.
- Câu trả lời có nội dung: không trống và không chỉ là "không", "không có", "chưa", "không ý kiến" hoặc dấu câu.
- Cách mã hóa: phân tích nội dung có hướng dẫn (directed content analysis; Hsieh và Shannon, 2005). Bộ mã ban đầu lấy từ năm chính sách của Câu 23, bốn phát biểu của Câu 24 và các hình thức kỳ thị. Bộ mã được bổ sung từ tần suất cụm từ, trong đó chỉ xem các cụm xuất hiện từ 10 lần trở lên. Mỗi câu trả lời có thể thuộc nhiều chủ đề.
- Quy tắc mã hóa là danh sách từ khóa, viết thẳng trong do-file, áp dụng trên văn bản đã chuyển về chữ thường và bỏ dấu. Nhờ vậy, ai chạy do-file cũng nhận được cùng kết quả.
- **Bảo vệ dữ liệu.** Không câu trả lời nào được in ra, chép vào repo, đưa vào trò chuyện hay trích nguyên văn trong bài. Trang thông tin của khảo sát cam kết kết quả được trình bày ở dạng tổng hợp. Bài chỉ báo số câu trả lời theo chủ đề (chủ đề dưới 10 câu trả lời ghi là "dưới 10") và mô tả nội dung chủ đề bằng lời của tác giả.
- **Kiểm tra độ tin cậy.** Trên máy của nhóm, hai thành viên đọc độc lập toàn bộ câu trả lời có nội dung, gán chủ đề theo bộ mã, rồi so với kết quả của do-file (Cohen's κ cho từng chủ đề). Nếu phải sửa quy tắc, ghi vào mục 9 trước khi chạy lại. Bài chỉ nêu kết quả kiểm tra này sau khi nhóm đã làm.

## 8. Phần mềm và kiểm tra

- Stata 17 (`phan_tich_bai_tieng_viet.do`). Kết quả ghi vào `output/results_vi/`: `ket_qua.xlsx` (mỗi bảng một sheet) và `nhat_ky.log`.
- Bản tái lập Python (`tests/python_replication_vi/`) cho lại mọi ước lượng. Bản thảo đầu dùng số của bản Python. Khi tác giả chạy Stata, mọi số được đối chiếu và thay bằng số Stata.

## 9. Thay đổi sau ngày 21/10/2026

| Ngày | Phần | Thay đổi | Lý do | Đã xem kết quả liên quan chưa |
|---|---|---|---|---|

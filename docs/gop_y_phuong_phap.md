# Góp ý phương pháp trước khi chạy phân tích (4/10/2026)

Tệp này bổ sung cho `docs/review_notes.md` (mục B). Nội dung dựa trên đề cương lần 2 (mục 2–3), `docs/analysis_plan.md` và bảng hỏi. Chưa có phân tích nào được chạy khi viết tệp này.

## Nguyên tắc chung

Kế hoạch hiện tại đã chặt hơn mức thường gặp ở nghiên cứu cắt ngang: có đại lượng ước lượng, chọn biến kiểm soát theo thứ tự thời gian, cố định HC3 trước khi ước lượng, có họ kiểm định, có phân tích độ nhạy và đường cong đặc tả. Rủi ro lớn nhất của bài không nằm ở phương pháp ước lượng. Rủi ro nằm ở ba chỗ: tác giả đã tiếp xúc với dữ liệu trước khi đăng ký, thiên lệch trong báo cáo kỳ thị và triệu chứng, và cách mẫu được hình thành.

Vì vậy không nên thêm nhiều phân tích. Mỗi phân tích thêm là một bậc tự do của nhà nghiên cứu. Chỉ thêm phân tích nào trả lời một câu hỏi cụ thể mà phản biện chắc chắn sẽ đặt ra. Mọi bổ sung dưới đây phải được ghi vào `docs/deviations.md` **trước** khi chạy. Cột "Đã xem kết quả?" phải ghi đúng sự thật. Trong bài, các bổ sung này được trình bày là phân tích bổ sung sau đăng ký.

Mức ưu tiên: **[Bắt buộc]** cần xử lý trước khi chạy; **[Nên]** nên làm; **[Cân nhắc]** tác giả tự quyết.

---

## 1. Cần chốt trước khi chạy

### 1.1. Hiệu ứng nhỏ nhất có ý nghĩa và kiểm định tương đương [Bắt buộc]

Quy tắc 4 trong `CLAUDE.md` viết: nếu khoảng tin cậy chứa cả 0 và "các giá trị có ý nghĩa thực tiễn" thì kết luận là "chưa xác định". Phần Introduction cũng lập luận rằng "một sự vắng mặt được ước lượng chính xác của gradient" sẽ làm yếu lý thuyết. Cả hai đều cần một ngưỡng cụ thể, nhưng kế hoạch chưa có ngưỡng này. Nếu đặt ngưỡng sau khi thấy kết quả, kết luận "không có liên hệ đáng kể" sẽ không đứng vững.

Đề xuất: đặt trước một hiệu ứng nhỏ nhất có ý nghĩa (smallest effect size of interest, SESOI), rồi dùng kiểm định tương đương hai phía (TOST; Lakens, 2017; Lakens và cộng sự, 2018). Kết luận "không có liên hệ đáng kể về thực tiễn" chỉ được đưa ra khi khoảng tin cậy 90% của η nằm trọn trong (−SESOI; +SESOI).

Bảng dưới tính gần đúng từ số liệu của đề cương (SD của PHQ-4 = 3,19; SD của S = 0,48; SE(η) ≈ 0,415, bỏ qua phần phương sai do Xᴰ giải thích). Nửa độ rộng của khoảng tin cậy 90% ≈ 1,645 × 0,415 ≈ 0,68.

| SESOI (β chuẩn hóa) | SESOI (điểm PHQ-4 trên 1 đơn vị S) | Kết luận tương đương được khi η̂ nhỏ hơn khoảng |
|---|---|---|
| 0,10 | 0,66 | −0,02 (gần như không thể đạt) |
| 0,15 | 1,00 | 0,32 |
| 0,20 | 1,33 | 0,65 |

Cách đọc: với n ≈ 256, nghiên cứu chỉ có thể loại trừ các mối liên hệ từ khoảng β = 0,15–0,20 trở lên. Nghiên cứu không loại trừ được một mối liên hệ nhỏ. Điều này cần được nói thẳng trong bài. Ngưỡng phải được chọn dựa trên lý do thực chất, ví dụ độ lớn hiệu ứng trong các phân tích tổng hợp như Schmitt và cộng sự (2014), không dựa vào kết quả của nghiên cứu này. Đây là quyết định của tác giả.

### 1.2. Nhóm thưa trong biến phân loại và độ ổn định của HC3 [Bắt buộc]

HC3 chia bình phương phần dư cho (1 − hᵢᵢ)², trong đó hᵢᵢ là giá trị đòn bẩy. Một mức của biến phân loại chỉ có 1–2 người sẽ làm hᵢᵢ tiến gần 1. Khi đó sai số chuẩn HC3 trở nên không ổn định hoặc không xác định được. Nguy cơ này cao ở Đặc tả 2: Xᴶ có 8 biến phân loại, thêm vào 5 biến của Xᴰ, trên khoảng 250 quan sát. Các mức "không muốn trả lời" được giữ thành nhóm riêng theo quy tắc chính cũng có thể rất nhỏ.

Việc cần làm trước khi chạy:

- Đếm số người ở từng mức của Xᴰ và Xᴶ trong mẫu 256. Bảng đếm này chỉ dùng nội bộ và không công bố các ô dưới 10.
- Đặt quy tắc gộp mức, ví dụ gộp mức có dưới 10 người vào mức liền kề hoặc vào nhóm "khác". Ghi quy tắc vào `deviations.md` trước khi ước lượng.
- Báo cáo giá trị hᵢᵢ lớn nhất và số tham số của từng đặc tả.

### 1.3. Ô nhỏ trong văn bản [Bắt buộc]

Đề cương (mục 2.3.2 và review_notes B5) ghi tình huống 4 có "1,6% người từng gặp, tức khoảng 4 người". Con số này vi phạm quy tắc ẩn ô dưới 10 người. Trong bài nên ghi "dưới 10 người" và không báo cáo hệ số của tình huống này.

### 1.4. Phạm vi của gán giá trị đa lần [Bắt buộc]

Kế hoạch ghi mô hình gán giá trị "gồm kết quả, phơi nhiễm, Xᴰ và biến phụ trợ", nhưng chưa nói gán trên quần thể nào: 278 người (đã đủ PHQ-4 và S, chỉ thiếu Xᴰ) hay 297–300 người LGBT (thiếu cả PHQ-4). Hai lựa chọn cho hai đại lượng ước lượng khác nhau.

- Nếu gán cả biến kết quả, nên cân nhắc cách "gán rồi loại" (multiple imputation, then deletion): dùng Y đã gán để gán biến khác, nhưng không đưa các quan sát có Y được gán vào mô hình phân tích (von Hippel, 2007).
- 20 bộ dữ liệu là đủ khi tỷ lệ quan sát thiếu khoảng 8% (256 trên 278), theo quy tắc kinh nghiệm của White và cộng sự (2011).

### 1.5. Các điểm còn treo trong kế hoạch [Bắt buộc]

- Quy tắc mã hóa thay thế (mẫu 247) có trong luồng mẫu nhưng chưa có trong Bảng 4 (độ bền). Cần đưa vào nếu bản OSF có.
- Họ BH của E2 và E4 (review_notes B4), 25 người ngoài ba nhóm xu hướng tính dục (B3), số câu hợp lệ tối thiểu của chỉ số che giấu (B6), danh sách đặc tả của đường cong (B2). Tất cả cần chốt và đối chiếu OSF trước khi chạy.

---

## 2. Phương sai sai số thay đổi và suy luận

### 2.1. Giữ HC3 và không đổi theo kết quả kiểm định [Đã có trong kế hoạch]

Phương sai sai số thay đổi gần như chắc chắn xảy ra, vì PHQ-4 bị chặn trong 0–12 và 26,6% người trả lời có điểm 0. Kiểm định Breusch–Pagan và White chỉ có giá trị mô tả. Phương sai thay đổi không làm OLS bị chệch; nó chỉ ảnh hưởng đến sai số chuẩn. Vì vậy không cần WLS hay FGLS, và không đổi phương pháp ước lượng theo kết quả của hai kiểm định này. Có thể bỏ kiểm định White, vì với nhiều biến giả, kiểm định này có rất nhiều bậc tự do mà không thêm thông tin.

### 2.2. Wild bootstrap cho H1 [Nên]

Với khoảng 250 quan sát và nhiều biến giả, suy luận bằng HC3 có thể kém chính xác khi có điểm đòn bẩy cao. Có thể bổ sung một phân tích độ nhạy cho H1: giá trị p và khoảng tin cậy của η theo wild bootstrap có ràng buộc giả thuyết không (restricted wild bootstrap, trọng số Rademacher hoặc Webb, 9.999 lần lặp). Phương pháp này cho suy luận đáng tin cậy hơn trong mẫu nhỏ có phương sai thay đổi (Davidson & Flachaire, 2008). Trong Stata có thể dùng lệnh `boottest` (Roodman và cộng sự, 2019). Một phương án nhẹ hơn là báo cáo thêm HC4 (Cribari-Neto, 2004) nếu có quan sát đòn bẩy cao. Phương án chính vẫn là HC3 như đã đăng ký.

### 2.3. Các quan sát không độc lập [Nêu trong hạn chế]

HC3 giả định các quan sát độc lập với nhau. Mẫu quả cầu tuyết qua mạng lưới cộng đồng có thể gồm những người quen nhau hoặc cùng nơi làm việc. Khi đó sai số của họ tương quan, và sai số chuẩn có thể bị đánh giá thấp. Bảng hỏi không ghi nơi làm việc hay kênh giới thiệu, nên không thể dùng sai số chuẩn theo cụm. Cần nêu điều này như một hạn chế. Nghiên cứu sau nên ghi mã kênh hoặc đợt giới thiệu.

### 2.4. Cách trình bày kết quả chính [Nên]

- Báo cáo cả ước lượng chưa điều chỉnh và đã điều chỉnh. STROBE yêu cầu điều này (von Elm và cộng sự, 2007, mục 16a).
- Báo cáo η theo một đơn vị S và theo một độ lệch chuẩn của S, kèm R² riêng phần.
- Thêm một đồ thị binned scatter có điều chỉnh Xᴰ (Cattaneo và cộng sự, 2024), để người đọc thấy phân bố của S, hiện tượng dồn về 0 của PHQ-4 và dạng của mối liên hệ.

---

## 3. Dạng hàm và biến phụ thuộc

### 3.1. Không thêm mô hình cho biến bị chặn [Đã đủ]

Kế hoạch đã có hồi quy logit phân số, đặc tả "đã gặp kỳ thị + cường độ" và spline bậc ba có giới hạn. Không nên thêm Tobit, Poisson hay logit thứ bậc. Mỗi mô hình thêm là một bậc tự do mà không trả lời câu hỏi mới. Kiểm định RESET có độ mạnh thấp, nên kết luận về dạng hàm nên dựa vào spline. Không cần kiểm định phân phối chuẩn của phần dư.

### 3.2. Logit phân số cho GAD-2 và PHQ-2 [Cân nhắc]

Kế hoạch chỉ áp dụng logit phân số cho PHQ-4. GAD-2 và PHQ-2 chỉ có 7 mức (0–6), nên vấn đề biến bị chặn còn rõ hơn. Nếu phần Thảo luận diễn giải H2a và H2b, nên áp dụng cùng kiểm tra này cho GAD-2/6 và PHQ-2/6.

### 3.3. So sánh lo âu với trầm cảm [Bắt buộc nếu Thảo luận có so sánh]

Herry và Dyar (2025) thảo luận khác biệt giữa lo âu và trầm cảm. Nếu bài này cũng muốn viết rằng kỳ thị "liên hệ mạnh hơn" với một chiều triệu chứng, phải kiểm định trực tiếp hiệu η_GAD − η_PHQ2, ví dụ bằng `suest` hoặc mô hình xếp chồng với sai số chuẩn vững, và gắn nhãn thăm dò. Hai thang có cùng phạm vi 0–6, nên hiệu của hai hệ số có thể diễn giải được. Nếu không kiểm định, không được viết "mạnh hơn" (Gelman & Stern, 2006).

---

## 4. Vấn đề nội sinh

Tôi đồng ý với các quyết định của đề cương: không dùng biến công cụ (không có biến thỏa điều kiện loại trừ), không dùng ghép điểm xu hướng (không xử lý được gây nhiễu không quan sát), không dùng Heckman (không có dữ liệu về người không tham gia), và không dùng kiểm định một nhân tố của Harman. Các điểm dưới đây là bổ sung.

### 4.1. Thứ tự câu hỏi trong bảng hỏi [Bắt buộc nêu trong bài]

Đây là điểm quan trọng nhất mà đề cương chưa nêu. Trong bảng hỏi, Phần IV (trải nghiệm kỳ thị, Câu 19–20) nằm ngay trước Phần V (PHQ-4, Câu 21). Người trả lời vừa nhớ lại các sự kiện kỳ thị rồi tự đánh giá triệu chứng ngay sau đó. Câu hỏi đứng trước có thể định hướng cách trả lời câu hỏi đứng sau (Schwarz, 1999). Nếu người nhớ lại nhiều sự kiện hơn bị tác động mạnh hơn, η sẽ lớn hơn giá trị thực.

Lập luận "phân tách về thủ tục" ở đề cương mục 3.6.3 vì vậy cần viết lại. Hai phần dùng thang khác nhau và kỳ tham chiếu khác nhau, nhưng nằm liền kề và thứ tự không được đảo ngẫu nhiên. Dữ liệu hiện có không kiểm định được hiệu ứng này. Bài phải nêu nó như một hạn chế có hướng sai lệch rõ ràng. Nghiên cứu sau nên đảo ngẫu nhiên thứ tự hai phần.

### 4.2. Sai lệch do chọn mẫu [Nên nêu trong bài]

Có hai cơ chế.

- Việc tham gia khảo sát có thể phụ thuộc đồng thời vào trải nghiệm kỳ thị (người từng bị kỳ thị muốn kể lại) và vào tình trạng tâm lý (người đang căng thẳng có thể tham gia nhiều hơn hoặc ít hơn). Chọn mẫu theo cả phơi nhiễm và kết quả tạo ra sai lệch, và hướng của sai lệch không xác định trước được (Hernán và cộng sự, 2004).
- Tiêu chí "có công việc chính tạo thu nhập" loại những người đã nghỉ việc vì kỳ thị và triệu chứng. Đây là dạng hiệu ứng người lao động khỏe mạnh, và nó có xu hướng làm η nhỏ đi.

Thiết kế so sánh trong nội bộ nhóm LGBT loại được sai lệch do hai nhóm được tiếp cận qua kênh khác nhau, nhưng không loại được hai cơ chế trên.

### 4.3. Bộ biến Xᴰ [Nên]

- **Xu hướng tính dục không có trong Xᴰ.** Biến này có trước phơi nhiễm. Nó liên quan đến mức độ dễ nhận biết của danh tính (do đó đến phơi nhiễm) và đến triệu chứng: người song tính có tỷ lệ trầm cảm và lo âu cao hơn (Ross và cộng sự, 2018). Nên thêm một đặc tả độ nhạy Xᴰ + nhóm xu hướng tính dục, ghi vào `deviations.md` trước khi chạy.
- **Hai biến trong Xᴰ có thể không hoàn toàn có trước phơi nhiễm.** Tình trạng quan hệ có thể chịu ảnh hưởng của triệu chứng. Địa bàn làm việc có thể là hệ quả của kỳ thị, vì người lao động có thể chuyển đến thành phố cởi mở hơn. Không đổi đặc tả chính. Nên nêu điểm này trong phần lập luận về đồ thị nhân quả. Nếu muốn, có thể thêm một đặc tả bỏ hai biến này.

### 4.4. Phân tích độ nhạy theo Cinelli và Hazlett [Nên chỉnh cách làm]

- Với biến phân loại, dùng mốc so sánh theo nhóm: toàn bộ biến giả của học vấn được đưa vào cùng lúc, không phải từng biến giả.
- Báo cáo đủ ba đại lượng: R² riêng phần của S với PHQ-4, RV với q = 1, và RV với q = 1, α = 0,05 (Cinelli & Hazlett, 2020).
- Diễn giải theo dạng "một biến bị bỏ sót phải mạnh gấp k lần học vấn mới xóa được kết quả", không viết "kết quả vững". Mốc so sánh yếu sẽ làm giá trị độ bền trông yên tâm hơn thực tế.
- Có thể áp dụng cùng phân tích cho đường b của H3 (che giấu → triệu chứng). Đường này có thể bị gây nhiễu bởi các biến không đo, như kỳ thị nội tâm hóa hay mức công khai với gia đình.

### 4.5. Kiểm tra thiên lệch quy nguyên ở E2 [Bắt buộc nếu dùng làm lập luận]

Đề cương dùng E2 để đánh giá thiên lệch quy nguyên: nếu liên hệ chỉ xuất hiện ở tình huống 4–6 mà không ở tình huống 1, 2, 3 và 7. Nhưng so sánh "có ý nghĩa ở nhóm này, không có ý nghĩa ở nhóm kia" chính là loại so sánh mà Gelman và Stern (2006) cảnh báo. Cần một kiểm định trực tiếp: đưa hai chỉ số con vào cùng một mô hình (phụ thuộc quy nguyên gồm tình huống 5–6, vì tình huống 4 có dưới 10 người; không phụ thuộc quy nguyên gồm 1, 2, 3 và 7), rồi kiểm định hiệu hai hệ số.

Lưu ý: hai thang con "liên cá nhân" và "thể chế" đã được chạy trước khi đăng ký (đề cương mục 3.11). Phải nói rõ điều này. Không được trình bày như một kiểm định mới.

### 4.6. Không có biến kiểm soát âm hay biến đánh dấu [Nêu trong hạn chế]

Bảng hỏi không có biến nào có thể dùng làm biến kiểm soát âm (negative control; Lipsitch và cộng sự, 2010) hay biến đánh dấu cho thiên lệch phương pháp chung (marker variable; Lindell & Whitney, 2001). Nên nêu điều này và đề xuất cho nghiên cứu sau.

### 4.7. Sai số đo của S [Nêu trong bài]

Sai số đo ngẫu nhiên của S làm η nhỏ đi. Thiên lệch hồi tưởng là sai số không ngẫu nhiên, tương quan với triệu chứng, và làm η lớn lên. Hai cơ chế có hướng ngược nhau. Bài nên nêu cả hai, không chỉ nêu một.

---

## 5. Phân tích thăm dò

### 5.1. E4 và E5: cách trình bày tương tác [Nên]

Kiểm định tương tác có độ mạnh thấp (McClelland & Judd, 1993). Nên báo cáo hệ số góc của S theo từng nhóm (E4) hoặc theo các mức Q (E5), kèm khoảng tin cậy và kiểm định hiệu. Không kết luận theo kiểu "có ý nghĩa ở nhóm A, không có ở nhóm B".

### 5.2. E5: các kiểm tra riêng [Cân nhắc]

- Kiểm tra vùng hỗ trợ chung và tính tuyến tính của tương tác bằng ước lượng chia khoảng (binning estimator) của Hainmueller và cộng sự (2019).
- Thêm S² khi ước lượng S × Q, để không nhầm một quan hệ cong với một tương tác (Ganzach, 1997).
- Ước lượng lại với chỉ số Q bỏ phát biểu "hành vi nói đùa hoặc xúc phạm người LGBT bị nhắc nhở hoặc xử lý", vì phát biểu này trùng nội dung với tình huống kỳ thị 1.

### 5.3. Mức công khai tại nơi làm việc (Câu 18) [Cân nhắc]

Bảng hỏi có câu về mức công khai, nhưng kế hoạch không dùng. Có thể mô tả S và C theo mức công khai (ẩn ô dưới 10) để minh họa vị trí hai chiều của che giấu danh tính. Không nên đưa biến này vào mô hình chính. Mức công khai có thể là hệ quả của kỳ thị, nên điều chỉnh theo nó có thể chặn một phần mối liên hệ cần đo hoặc tạo sai lệch.

---

## 6. Đo lường

### 6.1. CFA của PHQ-4 (review_notes B1) [Nên]

Mô hình hai nhân tố với bốn câu chỉ có 1 bậc tự do, nên kiểm định độ phù hợp rất yếu. Nên dùng phương pháp ước lượng cho biến thứ bậc (WLSMV), so sánh mô hình một nhân tố với mô hình hai nhân tố, và báo cáo tương quan giữa hai nhân tố. Kết quả chỉ có giá trị mô tả.

### 6.2. Mô tả chỉ số kỳ thị [Nên]

S là chỉ số cấu thành. Nên báo cáo phân bố của S, tỷ lệ người có S = 0 và số người gặp từng tình huống, ẩn các ô dưới 10.

---

## 7. Báo cáo và minh bạch

### 7.1. Thông tin về khảo sát trong phần Phương pháp [Tác giả quyết định]

Tác giả đã yêu cầu không nêu nền tảng, hình thức và thời gian khảo sát. Yêu cầu này đã được áp dụng cho Introduction. Tuy nhiên, STROBE (von Elm và cộng sự, 2007) yêu cầu phần Phương pháp mô tả bối cảnh và thời gian thu thập dữ liệu (mục 5) và cách tuyển chọn người tham gia (mục 6). Herry và Dyar (2025) cũng nêu các thông tin này ngay trong phần tóm tắt. Phản biện của hầu hết tạp chí sẽ hỏi. Khi viết phần Phương pháp, tác giả cần quyết định có nêu hay không.

### 7.2. Kiểm tra mã [Bắt buộc]

Mã Stata chưa từng được chạy. Cần chạy toàn bộ pipeline trên dữ liệu giả lập trước (`tests/make_synthetic_data.py`). Nên đối chiếu sai số chuẩn HC3 của Stata với một phần mềm khác (ví dụ gói `sandwich` của R) trên cùng dữ liệu giả lập.

### 7.3. Kết quả đã biết từ trước [Bắt buộc nêu]

Đặc tả 2 (Xᴰ + Xᴶ) gần với các phân tích đã chạy trước khi đăng ký bằng statsmodels (HC1, cả Xᴰ và Xᴶ). Ước lượng điểm của Đặc tả 2 vì vậy về cơ bản đã được biết. Bài phải nói rõ điều này khi trình bày Đặc tả 2.

---

## 8. Thứ tự ưu tiên

1. Chốt hiệu ứng nhỏ nhất có ý nghĩa và cách kiểm định tương đương (1.1).
2. Đếm nhóm thưa, đặt quy tắc gộp mức, kiểm tra đòn bẩy cho HC3 (1.2).
3. Nêu hiệu ứng thứ tự câu hỏi và viết lại lập luận "phân tách về thủ tục" (4.1).
4. Thêm đặc tả độ nhạy có xu hướng tính dục trong Xᴰ (4.3).
5. Thay so sánh "có/không có ý nghĩa" ở E2 bằng kiểm định hiệu trực tiếp (4.5).
6. Chốt các điểm còn treo với OSF (1.4, 1.5) và ghi toàn bộ vào `deviations.md`.

---

## Tài liệu tham khảo cho tệp này

Cattaneo, M. D., Crump, R. K., Farrell, M. H., & Feng, Y. (2024). On binscatter. *American Economic Review, 114*(5), 1488–1514. https://doi.org/10.1257/aer.20221576

Cinelli, C., & Hazlett, C. (2020). Making sense of sensitivity: Extending omitted variable bias. *Journal of the Royal Statistical Society: Series B (Statistical Methodology), 82*(1), 39–67. https://doi.org/10.1111/rssb.12348

Cribari-Neto, F. (2004). Asymptotic inference under heteroskedasticity of unknown form. *Computational Statistics & Data Analysis, 45*(2), 215–233. https://doi.org/10.1016/S0167-9473(02)00366-3

Davidson, R., & Flachaire, E. (2008). The wild bootstrap, tamed at last. *Journal of Econometrics, 146*(1), 162–169. https://doi.org/10.1016/j.jeconom.2008.08.003

Ganzach, Y. (1997). Misleading interaction and curvilinear terms. *Psychological Methods, 2*(3), 235–247. https://doi.org/10.1037/1082-989X.2.3.235

Gelman, A., & Stern, H. (2006). The difference between "significant" and "not significant" is not itself statistically significant. *The American Statistician, 60*(4), 328–331. https://doi.org/10.1198/000313006X152649

Hainmueller, J., Mummolo, J., & Xu, Y. (2019). How much should we trust estimates from multiplicative interaction models? Simple tools to improve empirical practice. *Political Analysis, 27*(2), 163–192. https://doi.org/10.1017/pan.2018.46

Hernán, M. A., Hernández-Díaz, S., & Robins, J. M. (2004). A structural approach to selection bias. *Epidemiology, 15*(5), 615–625. https://doi.org/10.1097/01.ede.0000135174.63482.43

Herry, E., & Dyar, C. (2025). LGBTQ+ policies in the United States and mental health: The mediating role of sexual orientation discrimination among sexual minority women and gender diverse individuals assigned female at birth. *Sexuality Research and Social Policy*. Advance online publication. https://doi.org/10.1007/s13178-025-01246-w

Lakens, D. (2017). Equivalence tests: A practical primer for t tests, correlations, and meta-analyses. *Social Psychological and Personality Science, 8*(4), 355–362. https://doi.org/10.1177/1948550617697177

Lakens, D., Scheel, A. M., & Isager, P. M. (2018). Equivalence testing for psychological research: A tutorial. *Advances in Methods and Practices in Psychological Science, 1*(2), 259–269. https://doi.org/10.1177/2515245918770963

Lindell, M. K., & Whitney, D. J. (2001). Accounting for common method variance in cross-sectional research designs. *Journal of Applied Psychology, 86*(1), 114–121. https://doi.org/10.1037/0021-9010.86.1.114

Lipsitch, M., Tchetgen Tchetgen, E., & Cohen, T. (2010). Negative controls: A tool for detecting confounding and bias in observational studies. *Epidemiology, 21*(3), 383–388. https://doi.org/10.1097/EDE.0b013e3181d61eeb

McClelland, G. H., & Judd, C. M. (1993). Statistical difficulties of detecting interactions and moderator effects. *Psychological Bulletin, 114*(2), 376–390. https://doi.org/10.1037/0033-2909.114.2.376

Roodman, D., MacKinnon, J. G., Nielsen, M. Ø., & Webb, M. D. (2019). Fast and wild: Bootstrap inference in Stata using boottest. *The Stata Journal, 19*(1), 4–60. https://doi.org/10.1177/1536867X19830877

Ross, L. E., Salway, T., Tarasoff, L. A., MacKay, J. M., Hawkins, B. W., & Fehr, C. P. (2018). Prevalence of depression and anxiety among bisexual people compared to gay, lesbian, and heterosexual individuals: A systematic review and meta-analysis. *The Journal of Sex Research, 55*(4–5), 435–456. https://doi.org/10.1080/00224499.2017.1387755

Schmitt, M. T., Branscombe, N. R., Postmes, T., & Garcia, A. (2014). The consequences of perceived discrimination for psychological well-being: A meta-analytic review. *Psychological Bulletin, 140*(4), 921–948. https://doi.org/10.1037/a0035754

Schwarz, N. (1999). Self-reports: How the questions shape the answers. *American Psychologist, 54*(2), 93–105. https://doi.org/10.1037/0003-066X.54.2.93

von Elm, E., Altman, D. G., Egger, M., Pocock, S. J., Gøtzsche, P. C., & Vandenbroucke, J. P. (2007). The Strengthening the Reporting of Observational Studies in Epidemiology (STROBE) statement: Guidelines for reporting observational studies. *The Lancet, 370*(9596), 1453–1457. https://doi.org/10.1016/S0140-6736(07)61602-X

von Hippel, P. T. (2007). Regression with missing Ys: An improved strategy for analyzing multiply imputed data. *Sociological Methodology, 37*(1), 83–117. https://doi.org/10.1111/j.1467-9531.2007.00180.x

White, I. R., Royston, P., & Wood, A. M. (2011). Multiple imputation using chained equations: Issues and guidance for practice. *Statistics in Medicine, 30*(4), 377–399. https://doi.org/10.1002/sim.4067

*Ghi chú.* Môi trường làm việc chặn Crossref và doi.org, nên DOI chưa được kiểm tra trực tiếp. Thông tin xuất bản của Cattaneo và cộng sự (2024), Davidson và Flachaire (2008), Cribari-Neto (2004), von Hippel (2007) và Ganzach (1997) đã được đối chiếu qua tìm kiếm web; DOI của ba bài đầu khớp với kết quả tìm kiếm. Các DOI còn lại cần bấm kiểm tra trước khi đưa vào bài.

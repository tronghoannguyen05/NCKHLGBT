# Kế hoạch phân tích (đặc tả cho mã)

Tệp này chép lại đặc tả của đề cương lần 2 (mục 2–3) dưới dạng mã có thể đối chiếu. Thứ tự ưu tiên khi có mâu thuẫn: **bản đăng ký OSF > tệp này > đề cương**. Chỗ đề cương chưa đủ chi tiết được đánh dấu `TODO(OSF)` và có giá trị mặc định trong `config/settings.do`. Khi xác nhận được với OSF thì sửa mặc định và xóa dấu.

- Bản đăng ký OSF: **chưa đăng ký**. Theo quyết định của tác giả ngày 5/10/2026, mô hình được chạy trước và kế hoạch sẽ được đăng ký sau (`docs/deviations.md`, dòng 1). Khi đăng ký, nộp đúng bản chốt ngày 5/10/2026 của tệp này, ghi rõ ngày nộp sau ước lượng, rồi dán đường dẫn và ngày đăng ký vào đây.
- Bản chốt ngày 5/10/2026: mọi chỗ trước đây đánh dấu `TODO(OSF)` đã được quyết định. Các quyết định và bổ sung nằm ở mục 8. Vì chưa đăng ký, chúng là một phần của kế hoạch, không phải lệch kế hoạch.
- Những phân tích đã chạy trước khi đăng ký (bằng Python/statsmodels, HC1, cả Xᴰ và Xᴶ) được liệt kê ở đề cương mục 3.11. Không chạy lại chúng như thể là kết quả mới.

## 1. Mẫu

| Mẫu | Định nghĩa | n kỳ vọng | Biến |
|---|---|---|---|
| Đủ điều kiện | ≥ 18 tuổi và có công việc chính tạo thu nhập | 727 | `eligible` |
| Phân tích | đủ điều kiện và xác định được nhóm ở câu tự nhận diện | 640 (340 non-LGBT, 300 LGBT) | `in_analytic` |
| E3 | phân tích và có đủ 4 câu PHQ-4 | 601 (323 / 278) | `in_e3` |
| Chính | LGBT, có đủ PHQ-4 và chỉ số kỳ thị | 278 | `in_main` |
| Chính + Xᴰ (quy tắc chính) | “không muốn trả lời” là một mức riêng | 256 | `in_xd_main` |
| Chính + Xᴰ (quy tắc thay thế) | “không muốn trả lời” coi là khuyết | 247 | `in_xd_alt` |
| E5 | `in_xd_main` và có chỉ số DEI | 243 | `in_e5` |

`03_sample_flow.do` dừng với cảnh báo nếu số đếm khác các con số này. Lệch số không phải lỗi mã thì phải giải thích trong `docs/deviations.md`.

## 2. Biến

Xem `docs/codebook.md`. Tóm tắt:

- `phq4` = phqi1 + phqi2 + phqi3 + phqi4 (0–12). `gad2` = phqi1 + phqi2. `phq2` = phqi3 + phqi4 (tên câu hỏi là `phqi*` để không trùng với thang con `phq2`). Chỉ tính khi đủ cả 4 câu (hoặc đủ 2 câu tương ứng).
- `S` = trung bình `stig1`–`stig7`, tính khi có ít nhất 4 câu hợp lệ (thang 0–4). Mã 9 (“không áp dụng / không muốn trả lời”) chuyển thành khuyết.
- `C` = trung bình `conc1`–`conc4` (1–5), cần đủ cả 4 câu. `C3` bỏ câu mệt mỏi (`CONC_FATIGUE_ITEM` trong settings), cần đủ cả 3 câu.
- `Q` = trung bình `dei1`–`dei4`, tính khi có ít nhất 3 câu hợp lệ; `Qc` = Q trừ trung bình của mẫu E5.
- Xᴰ = `agegrp sex_birth educ relstat region` (biến phân loại).
- Xᴶ = `exper industry position emptype orgtype orgsize socins hours` (biến phân loại).
- Mức thưa của Xᴰ và Xᴶ được gộp trước khi ước lượng (`04b_collapse_levels.do`, mục 8, D2). Bảng mô tả dùng mức gốc.

## 3. Mô hình và quy tắc quyết định

| Mã | Mô hình | Mẫu | Suy luận | Quy tắc |
|---|---|---|---|---|
| H1 | `regress phq4 S i.(Xᴰ), vce(hc3)` | `in_xd_main` | p hai phía, 5% | Ủng hộ nếu η > 0 và p < 0,05. Không hiệu chỉnh (kiểm định chính). |
| H1, tương đương | TOST trên cùng mô hình, ngưỡng ±1,0 điểm PHQ-4 trên 1 đơn vị S | `in_xd_main` | CI 90% | Chỉ kết luận "không có liên hệ đáng kể" khi CI 90% nằm trọn trong (−1,0; 1,0) (mục 8, D1) |
| H2a | như H1, biến phụ thuộc `gad2` | `in_xd_main` | Holm trên {H2a, H2b, H3} | |
| H2b | như H1, biến phụ thuộc `phq2` | `in_xd_main` | Holm trên {H2a, H2b, H3} | |
| H3 | (a) `regress C S i.(Xᴰ), vce(hc3)`; (b) `regress phq4 C S i.(Xᴰ), vce(hc3)` | `in_xd_main` & C không khuyết | p_H3 = max(p_a, p_b) (giao–hợp), rồi Holm | Phù hợp nếu a > 0, b > 0 và p_H3 sau Holm < 0,05 |
| Đặc tả 2 | thêm `i.(Xᴶ)` cho H1, H2a, H2b | Xᴰ & Xᴶ đủ | báo cáo cạnh đặc tả 1 | Không dùng để chọn kết quả |
| E1 | thay S bằng `i.S3` (0 = không gặp; 1 = thấp; 2 = cao, cắt tại trung vị S trong số người đã gặp) | `in_xd_main` | thăm dò | |
| E2 | Mỗi tình huống một mô hình, thay S bằng `stigX_any` | `in_xd_main` (câu 8: n nhỏ hơn) | BH trên các tình huống được ước lượng | E2 và E4 là hai họ BH riêng. Tình huống có dưới 10 người gặp hoặc không gặp: không ước lượng, không ghi số đếm |
| E2 đối chiếu | `regress phq4 S_event S_attr i.(Xᴰ), vce(hc3)`; `lincom S_attr − S_event` | `in_xd_main` | thăm dò, một kiểm định | `S_event` = trung bình tình huống 1, 2, 3, 7; `S_attr` = trung bình 5, 6 (thêm 4 nếu ≥ 10 người gặp). Hai thang con gần tương tự đã chạy trước khi chốt kế hoạch (đề cương 3.11) |
| E3 | phân bố PHQ-4: non-LGBT / LGBT chưa gặp / LGBT đã gặp | `in_e3` | chỉ mô tả, không kiểm định | |
| E4 | `c.S##i.sex_birth` (loại người không muốn trả lời, theo `sex_birth_orig`); `c.S##i.orient3` (song tính và toàn tính / đồng tính nữ / đồng tính nam) | `in_xd_main` | BH trên các hệ số tương tác | 25 người không thuộc 3 nhóm xu hướng tính dục không vào mô hình `orient3`, nhưng vẫn có trong mọi phân tích khác |
| E5 | `regress phq4 c.S##c.Qc i.(Xᴰ), vce(hc3)` | `in_e5` | thăm dò | κ < 0 phù hợp với điều tiết |

Bootstrap hiệu ứng gián tiếp a×b: 5.000 lần, khoảng tin cậy percentile, hạt giống trong settings. Kết quả **chỉ đưa vào tài liệu bổ sung**.

Hiệu ứng nhỏ nhất phát hiện được sau ước lượng: MDE ≈ 2,8 × SE(η). Trước ước lượng: khoảng 1,2 điểm PHQ-4 trên một đơn vị S (SD_PHQ = 3,19; SD_S = 0,48; n = 256).

## 4. Chẩn đoán (`08_diagnostics.do`)

Chạy trên mô hình H1 ước lượng bằng `regress` không có `vce`, chỉ để chẩn đoán:

- Breusch–Pagan (`estat hettest`). Chỉ để mô tả; HC3 được dùng bất kể kết quả. Kiểm định White đã bỏ (mục 8, D7).
- VIF và GVIF theo nhóm biến giả của cùng một biến (Fox & Monette). GVIF được tính bằng Mata trong `code/lib/programs.do`.
- RESET (`estat ovtest`).
- Khoảng cách Cook > 4/n và đòn bẩy > 2k/n. Đánh dấu các quan sát này, không loại trong phân tích chính.

## 5. Độ bền (`09_robustness.do`, theo Bảng 4 của đề cương)

| Nghi vấn | Kiểm tra |
|---|---|
| Đường dẫn qua đặc điểm việc làm | Đặc tả 2 (thêm Xᴶ) |
| Tính tuyến tính | (i) `ever_exposed` cùng S trong số người đã gặp; (ii) spline bậc ba có giới hạn, nút tại p10/p50/p90 của S trong số người đã gặp |
| Biến phụ thuộc bị chặn | `fracreg logit` trên PHQ-4/12, báo cáo AME × 12 |
| Gây nhiễu không quan sát | `sensemakr`, mốc so sánh là giới tính khi sinh và học vấn (kd = 1, 2, 3) |
| Dữ liệu khuyết | `mi impute chained`, 20 bộ, gồm kết quả, phơi nhiễm, Xᴰ và biến phụ trợ |
| Phiếu chất lượng thấp | Loại `flag_quality == 1` |
| Quan sát ảnh hưởng lớn | Loại Cook > 4/n |
| Câu che giấu trùng nội dung với PHQ | H3 với `C3` |
| Phụ thuộc vào lựa chọn phân tích | Đường cong đặc tả 32 đặc tả (mục 6) |
| Quy tắc mã hóa "không muốn trả lời" | Mẫu 247, coi là khuyết (`05_main_models.do`) |
| Suy luận với mẫu vài trăm quan sát | Wild bootstrap có ràng buộc, trọng số Webb, 9.999 lần (`boottest`) (mục 8, D4) |
| Xu hướng tính dục không có trong Xᴰ | Thêm `orient4` (3 nhóm + khác/không xác định) vào Xᴰ (mục 8, D5) |

Không đặt ngưỡng “bao nhiêu đặc tả cùng dấu thì vững”. Báo cáo toàn bộ và chỉ ra lựa chọn nào làm đổi kết luận suy luận.

## 6. Đường cong đặc tả (32 = 4 × 2 × 2 × 2)

| Chiều | Các mức | Ghi chú |
|---|---|---|
| Cách tính chỉ số kỳ thị | (1) trung bình 7 câu; (2) trung bình 8 câu; (3) số tình huống đã gặp trong 7 câu (0–7); (4) trung bình 7 câu, chỉ người đủ cả 7 câu | Chốt 5/10/2026 |
| Bộ biến kiểm soát | Xᴰ; Xᴰ + Xᴶ | |
| Định nghĩa nhóm LGBT | (1) câu tự nhận diện; (2) tự nhận diện **và** có xu hướng tính dục không dị tính hoặc bản dạng giới thiểu số | Chốt 5/10/2026. Không dùng phép "hoặc", vì phần kỳ thị chỉ hỏi người tự nhận LGBT |
| Người chuyển giới và phi nhị nguyên | giữ; loại | |

## 7. Quy tắc trình bày

- Mọi hệ số đi kèm SE, khoảng tin cậy 95% và p. Bảng 9 dùng p đã hiệu chỉnh BH.
- Bảng chéo theo nhóm phải ẩn ô dưới 10 người. Bảng ghi việc gộp mức (`level_collapsing.csv`) ghi số đếm là "<5", không ghi số cụ thể.
- H1 luôn báo cáo kèm CI 90% và kết luận của kiểm định tương đương.
- Câu chữ tuân theo `CLAUDE.md`, quy tắc 3–6.

## 8. Quyết định chốt ngày 5/10/2026 (trước khi ước lượng mô hình chính)

Các quyết định này được đưa ra khi chưa chạy mô hình chính, H2a, H2b, E2, E4, E5 và các kiểm tra độ bền (đề cương mục 3.11). Chúng phải có trong bản đăng ký OSF. Các mô hình được ước lượng lần đầu ngày 5/10/2026, sau khi chốt.

| Mã | Quyết định | Lý do |
|---|---|---|
| D1 | **Ngưỡng hiệu ứng nhỏ nhất có ý nghĩa:** 1,0 điểm PHQ-4 trên 1 đơn vị S, tương đương khoảng 0,15 độ lệch chuẩn của PHQ-4 trên 1 độ lệch chuẩn của S (0,15 × 3,19 / 0,48). Cố định bằng số. H1 có thêm kiểm định tương đương hai phía (TOST, Lakens, 2017) bằng CI 90%. Quy tắc ủng hộ H1 giữ nguyên | (i) Thấp hơn mức liên hệ trung bình giữa phân biệt đối xử được cảm nhận và sức khỏe tâm lý trong phân tích tổng hợp của Schmitt và cộng sự (2014), nên một liên hệ cỡ thường gặp trong tài liệu không bị coi là "không đáng kể". (ii) Gần hiệu ứng nhỏ nhất mà thiết kế phát hiện được (khoảng 1,2 điểm, tức 0,175 SD). (iii) Nếu η thật bằng 0, xác suất kết luận được tương đương chỉ khoảng 55%, nên kết quả "chưa xác định" là hoàn toàn có thể. Mức 0,20 sẽ coi các liên hệ cỡ trung bình trong tài liệu là không đáng kể |
| D2 | **Gộp mức thưa:** trong mẫu ước lượng, mức có dưới 5 người được gộp. Biến thứ bậc (`agegrp educ exper orgsize hours`) gộp với mức liền kề phía trung vị. Biến danh nghĩa gộp vào mức "khác (gộp)" (mã 98). Mức "không muốn trả lời" gộp vào mức "khác (gộp)" nếu đã có, nếu không thì vào mức đông nhất. Chỉ dựa trên số đếm | Một mức chỉ có 1 người làm đòn bẩy bằng 1, và HC3 không xác định. Ngưỡng 5 nhắm vào độ ổn định của ước lượng, không phải việc ẩn ô nhỏ, nên giữ nguyên tối đa cách mã hóa đã chốt |
| D3 | **Số câu hợp lệ tối thiểu:** C cần đủ 4 câu, C3 cần đủ 3 câu, S8 cần ít nhất 4 câu. E1 lấy trung vị S trong mẫu chính 278 người | Khớp với hệ số α đã tính trên quan sát đủ câu; giữ quy tắc của S |
| D4 | **Wild bootstrap có ràng buộc** cho H1 (`boottest`, trọng số Webb, 9.999 lần) | Kiểm tra suy luận HC3 trong mẫu khoảng 250 quan sát có nhiều biến giả (Davidson & Flachaire, 2008; Roodman và cộng sự, 2019) |
| D5 | **Thêm xu hướng tính dục vào Xᴰ** như một kiểm tra gây nhiễu | Biến này có trước phơi nhiễm, liên quan đến mức dễ nhận biết của danh tính và đến triệu chứng (Ross và cộng sự, 2018) |
| D6 | **E2:** không ước lượng tình huống có dưới 10 người gặp hoặc không gặp. Thêm kiểm định trực tiếp hiệu giữa nhóm tình huống phụ thuộc quy nguyên và nhóm tình huống sự kiện | Ẩn ô nhỏ. Tránh so sánh "có ý nghĩa / không có ý nghĩa" (Gelman & Stern, 2006) |
| D7 | **Bỏ kiểm định White** | Chỉ có giá trị mô tả, nhiều bậc tự do, không ảnh hưởng đến lựa chọn HC3 |
| D8 | **BH:** E2 và E4 là hai họ riêng. **E4:** 25 người không thuộc 3 nhóm xu hướng tính dục không vào mô hình `orient3`. **Đường cong đặc tả:** các mức ở mục 6 | Chốt các điểm đề cương chưa nêu |
| D9 | **Gán giá trị đa lần** giữ đúng như đề cương: 300 người LGBT của mẫu phân tích; gán PHQ-4, S, C, Q và Xᴰ bị khuyết thật; 20 bộ | Không đổi so với đề cương |
| D10 | **Lo âu so với trầm cảm (thăm dò):** kiểm định trực tiếp hiệu η_GAD-2 − η_PHQ-2 bằng `suest` (sai số chuẩn vững), ngoài các họ hiệu chỉnh | Giả thuyết không dự báo chiều của hiệu. Hai thang có cùng phạm vi 0–6. Không được kết luận "mạnh hơn" chỉ vì một hệ số có ý nghĩa, hệ số kia không |
| D11 | **sensemakr:** cả giới tính khi sinh và học vấn dùng mốc so sánh theo nhóm (mọi biến giả của biến đó cùng lúc), k = 1, 2, 3. Báo cáo R² riêng phần của S với PHQ-4, RV_q=1 và RV_q=1,α=0,05 | Biến có nhiều mức phải được so sánh như một khối. RV với α dùng sai số chuẩn cổ điển, nên được diễn giải như một chỉ báo, không phải kiểm định HC3 |

**Hạn chế phải nêu trong bài, không có phân tích tương ứng:**
- Phần kỳ thị (Câu 19–20) nằm ngay trước PHQ-4 (Câu 21). Việc vừa nhớ lại các sự kiện kỳ thị có thể làm tăng điểm triệu chứng tự đánh giá (Schwarz, 1999). Lập luận "phân tách về thủ tục" ở đề cương mục 3.6.3 vì vậy chỉ đúng một phần.
- Sai lệch do chọn mẫu: việc tham gia có thể phụ thuộc cả trải nghiệm kỳ thị lẫn tình trạng tâm lý (Hernán và cộng sự, 2004). Tiêu chí "có việc làm" loại những người đã nghỉ việc vì kỳ thị và triệu chứng.
- Mẫu quả cầu tuyết làm các quan sát có thể không độc lập. Không có biến cụm (mạng lưới, nơi làm việc) để điều chỉnh sai số chuẩn, nên sai số chuẩn có thể bị đánh giá thấp.
- GAD-2 và PHQ-2 mỗi thang chỉ có hai câu, nên sai số đo lớn hơn PHQ-4 và độ mạnh của H2a, H2b thấp hơn H1.

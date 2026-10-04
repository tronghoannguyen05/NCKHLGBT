# Kế hoạch phân tích (đặc tả cho mã)

Tệp này chép lại đặc tả của đề cương lần 2 (mục 2–3) dưới dạng mã có thể đối chiếu. Thứ tự ưu tiên khi có mâu thuẫn: **bản đăng ký OSF > tệp này > đề cương**. Chỗ đề cương chưa đủ chi tiết được đánh dấu `TODO(OSF)` và có giá trị mặc định trong `config/settings.do`. Khi xác nhận được với OSF thì sửa mặc định và xóa dấu.

- Bản đăng ký OSF: `TODO(OSF): dán đường dẫn và ngày đăng ký`
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
- `C` = trung bình `conc1`–`conc4` (1–5). `C3` bỏ câu mệt mỏi (`conc_fatigue_item` trong settings). `TODO(OSF)`: số câu hợp lệ tối thiểu.
- `Q` = trung bình `dei1`–`dei4`, tính khi có ít nhất 3 câu hợp lệ; `Qc` = Q trừ trung bình của mẫu E5.
- Xᴰ = `agegrp sex_birth educ relstat region` (biến phân loại).
- Xᴶ = `exper industry position emptype orgtype orgsize socins hours` (biến phân loại).

## 3. Mô hình và quy tắc quyết định

| Mã | Mô hình | Mẫu | Suy luận | Quy tắc |
|---|---|---|---|---|
| H1 | `regress phq4 S i.(Xᴰ), vce(hc3)` | `in_xd_main` | p hai phía, 5% | Ủng hộ nếu η > 0 và p < 0,05. Không hiệu chỉnh (kiểm định chính). |
| H2a | như H1, biến phụ thuộc `gad2` | `in_xd_main` | Holm trên {H2a, H2b, H3} | |
| H2b | như H1, biến phụ thuộc `phq2` | `in_xd_main` | Holm trên {H2a, H2b, H3} | |
| H3 | (a) `regress C S i.(Xᴰ), vce(hc3)`; (b) `regress phq4 C S i.(Xᴰ), vce(hc3)` | `in_xd_main` & C không khuyết | p_H3 = max(p_a, p_b) (giao–hợp), rồi Holm | Phù hợp nếu a > 0, b > 0 và p_H3 sau Holm < 0,05 |
| Đặc tả 2 | thêm `i.(Xᴶ)` cho H1, H2a, H2b | Xᴰ & Xᴶ đủ | báo cáo cạnh đặc tả 1 | Không dùng để chọn kết quả |
| E1 | thay S bằng `i.S3` (0 = không gặp; 1 = thấp; 2 = cao, cắt tại trung vị S trong số người đã gặp) | `in_xd_main` | thăm dò | |
| E2 | 8 mô hình, mỗi mô hình thay S bằng `stigX_any` | `in_xd_main` (câu 8: n nhỏ hơn) | BH trên 8 p | `TODO(OSF)`: E2 và E4 là một họ BH hay hai họ. Mặc định: hai họ riêng |
| E3 | phân bố PHQ-4: non-LGBT / LGBT chưa gặp / LGBT đã gặp | `in_e3` | chỉ mô tả, không kiểm định | |
| E4 | `c.S##i.sex_birth`; `c.S##i.orient3` (song tính và toàn tính / đồng tính nữ / đồng tính nam) | `in_xd_main` | BH trên các hệ số tương tác | `TODO(OSF)`: 25 người không thuộc 3 nhóm xu hướng tính dục được xử lý thế nào. Mặc định: loại khỏi mô hình `orient3` |
| E5 | `regress phq4 c.S##c.Qc i.(Xᴰ), vce(hc3)` | `in_e5` | thăm dò | κ < 0 phù hợp với điều tiết |

Bootstrap hiệu ứng gián tiếp a×b: 5.000 lần, khoảng tin cậy percentile, hạt giống trong settings. Kết quả **chỉ đưa vào tài liệu bổ sung**.

Hiệu ứng nhỏ nhất phát hiện được sau ước lượng: MDE ≈ 2,8 × SE(η). Trước ước lượng: khoảng 1,2 điểm PHQ-4 trên một đơn vị S (SD_PHQ = 3,19; SD_S = 0,48; n = 256).

## 4. Chẩn đoán (`08_diagnostics.do`)

Chạy trên mô hình H1 ước lượng bằng `regress` không có `vce`, chỉ để chẩn đoán:

- Breusch–Pagan (`estat hettest`) và White (`estat imtest, white`). Chỉ để mô tả; HC3 được dùng bất kể kết quả.
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

Không đặt ngưỡng “bao nhiêu đặc tả cùng dấu thì vững”. Báo cáo toàn bộ và chỉ ra lựa chọn nào làm đổi kết luận suy luận.

## 6. Đường cong đặc tả (32 = 4 × 2 × 2 × 2)

| Chiều | Các mức | Ghi chú |
|---|---|---|
| Cách tính chỉ số kỳ thị | `TODO(OSF)`. Mặc định: (1) trung bình 7 câu; (2) trung bình 8 câu; (3) số tình huống đã gặp trong 7 câu (0–7); (4) trung bình 7 câu, chỉ người đủ cả 7 câu | Đề cương chỉ nói “bốn cách tính” |
| Bộ biến kiểm soát | Xᴰ; Xᴰ + Xᴶ | |
| Định nghĩa nhóm LGBT | `TODO(OSF)`. Mặc định: (1) câu tự nhận diện; (2) tự nhận diện, hoặc xu hướng tính dục không dị tính, hoặc bản dạng giới thiểu số | Đề cương chỉ nói “hai định nghĩa” |
| Người chuyển giới và phi nhị nguyên | giữ; loại | |

## 7. Quy tắc trình bày

- Mọi hệ số đi kèm SE, khoảng tin cậy 95% và p. Bảng 9 dùng p đã hiệu chỉnh BH.
- Bảng chéo theo nhóm phải ẩn ô dưới 10 người.
- Câu chữ tuân theo `CLAUDE.md`, quy tắc 3–6.

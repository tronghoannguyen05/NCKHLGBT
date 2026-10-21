# Codebook — tên biến chuẩn

Tệp xuất từ Kobo dùng tên cột riêng và **mã chữ** cho phương án (ví dụ `co`, `1824`, `kmtl`). `config/variable_map.csv` ánh xạ tên cột sang tên chuẩn dưới đây. `config/value_map.csv` ánh xạ mã chữ sang mã số, kèm nhãn. `phan_tich.do` (mục 1, lệnh `map_codes`) dừng nếu gặp mã chữ chưa có trong bảng. Hai bảng đã được đối chiếu với tệp thật ngày 5/10/2026: không có giá trị chưa ánh xạ. Luồng mẫu (từ 13/10/2026): 850 → 734 có việc làm → 719 có dữ liệu thực chất → 300 tự nhận LGBT → 272 đủ PHQ-4 và chỉ số kỳ thị → 235 đủ biến kiểm soát (226 theo quy tắc thay thế) → 233 (RQ1).

Ghi chú về mã:
- `agegrp` 4 = 45+: gộp hai phương án 45–54 và từ 55 của bảng hỏi, như codebook và đề cương.
- `orient` 7 = đang tự xác định/chưa chắc chắn (bảng hỏi có, codebook cũ chưa có). Mã 7 không được tính là xu hướng không dị tính trong `lgbt_consistent`.
- `orgsize` 97 = không áp dụng/không rõ; khi gộp mức thưa, mã này được xử lý như mã 9.
- `position` 4 = quản lý cấp cao (dùng cho `flag_contra`); 6 = không áp dụng/khác.
- PHQ-4: bảng hỏi đặt câu "buồn bã, chán nản" ở vị trí 3 và "ít hứng thú" ở vị trí 4. `phqi3` và `phqi4` được ánh xạ theo nội dung câu.

## Sàng lọc và nhận diện

| Tên chuẩn | Nội dung | Mã |
|---|---|---|
| `age18` | từ 18 tuổi trở lên | 1 có, 0 không |
| `has_job` | có công việc chính tạo thu nhập tại Việt Nam | 1 có, 0 không |
| `lgbt_self` | câu tự nhận diện | 1 LGBT, 0 không phải LGBT, 8 không chắc/đang tự xác định, 9 không muốn trả lời, `.` bỏ trống |
| `orient` | xu hướng tính dục | 1 dị tính, 2 đồng tính nam, 3 đồng tính nữ, 4 song tính, 5 toàn tính, 6 khác, 9 không muốn trả lời |
| `gender_id` | bản dạng giới | 1 nam, 2 nữ, 3 người chuyển giới nam, 4 người chuyển giới nữ, 5 phi nhị nguyên, 6 khác, 9 không muốn trả lời |
| `sex_birth` | giới tính khi sinh | 1 nam, 2 nữ, 9 không muốn trả lời |

## Kết quả: PHQ-4 (0 không hề … 3 gần như mỗi ngày; hai tuần gần nhất)

| Tên chuẩn | Câu |
|---|---|
| `phqi1` | cảm thấy bồn chồn, lo âu |
| `phqi2` | không thể ngừng hoặc kiểm soát lo lắng |
| `phqi3` | ít hứng thú hoặc niềm vui khi làm việc |
| `phqi4` | cảm thấy buồn, chán nản, tuyệt vọng |

Biến dựng: `phq4` (0–12), `phq4_frac` = phq4/12, `phq4_zero` (PHQ-4 = 0), `phq4_cat` (1 = 0–2, 2 = 3–5, 3 = 6–8, 4 = 9–12; Kroenke và cộng sự, 2009).

## Phơi nhiễm: kỳ thị tại nơi làm việc (0 không bao giờ … 4 rất thường xuyên; 12 tháng gần nhất; chỉ hỏi người LGBT)

| Tên | Tình huống | Nhóm (RQ1) |
|---|---|---|
| `stig1` | bị nói đùa hoặc bình luận xúc phạm | giao tiếp |
| `stig2` | bị hỏi câu riêng tư không mong muốn | giao tiếp |
| `stig3` | bị tiết lộ hoặc đe dọa tiết lộ XHTD/BDG khi chưa đồng ý | giao tiếp |
| `stig4` | bị loại khỏi cơ hội đào tạo, phát triển | nghề nghiệp |
| `stig5` | bị đánh giá, trả lương, thăng tiến không công bằng | nghề nghiệp |
| `stig6` | bị phân công công việc bất lợi | nghề nghiệp |
| `stig7` | bị áp lực tuân theo khuôn mẫu giới | thể hiện giới |
| `stig8` | khó khăn về tên gọi, đại từ, trang phục, nhà vệ sinh | thể hiện giới |

Thang tần suất: 0 không bao giờ, 1 một lần, 2 thỉnh thoảng, 3 thường xuyên, 4 rất thường xuyên. Mã 9 (“không áp dụng / không muốn trả lời”) chuyển thành khuyết, không gán 0. Biến dựng: `S` (trung bình 8 câu, cần ít nhất 6 câu hợp lệ), `S7` (trung bình câu 1–7, cần ít nhất 4 câu; phương án của đường cong đặc tả), `S_count8`, `S_complete8`, `stigX_any` (1 nếu ≥ 1 lần), `stigX_often` (1 nếu mức 3–4), `ever_exposed` (S > 0), `ever_often` (ít nhất một tình huống ở mức 3–4), `int_any`, `car_any`, `gen_any` (chỉ số con của nhóm > 0), `int_often`, `car_often`, `gen_often` (ít nhất một tình huống của nhóm ở mức 3–4), `S3` (0 không, 1 thấp, 2 cao; cắt tại trung vị của S trong số người có phơi nhiễm ở mẫu ước lượng).

Chỉ số con của RQ1: `S_int` (tình huống 1–3, cần ít nhất 2 câu hợp lệ), `S_car` (4–6, cần ít nhất 2 câu), `S_gen` (tình huống 7 và 8, cần ít nhất 1 câu). Trong mô hình, mỗi chỉ số được chuẩn hóa trong mẫu RQ1.

## Hai thang Likert khác của bảng hỏi (1–5)

`conc1`–`conc4` (che giấu danh tính, chỉ hỏi người LGBT) và `dei1`–`dei4` (thực thi DEI được cảm nhận; mã 9 chuyển thành khuyết). Từ 16/10/2026, hai thang này chỉ được đọc để dựng cờ `flag_straight`; không có chỉ số hay mô hình nào dùng chúng.

**Riêng bài tiếng Việt (`phan_tich_bai_tieng_viet.do`, từ 21/10/2026):**

- `Q`: trung bình `dei1`–`dei4`, tính khi có ít nhất 3 câu hợp lệ (định nghĩa cũ, không đổi).
- `pol1`–`pol5` (Câu 23, `c23_1`–`c23_5`): chính sách bằng văn bản chống phân biệt đối xử dựa trên SOGIE; kênh khiếu nại bảo mật; đào tạo DEI; phúc lợi cho bạn đời cùng giới; hỗ trợ người chuyển giới. Mã: `co` 1, `khong` 0, `khong_biet` 8. "Không biết" là nhóm riêng, không gán thành "không".
- `npol_co`, `npol_kb`: số câu "có" và số câu "không biết" (0–5), chỉ tính khi đủ năm câu. `npol_lo` = `npol_co`; `npol_hi` = `npol_co` + `npol_kb` (hai cận của độ nhạy).
- `src20` (Câu 20, `c20_source`): người gây ảnh hưởng nghiêm trọng nhất. `ql_truc_tiep` 1, `dong_nghiep` 2, `khach_hang` 3, `nhan_su` 4, `khac` 5, `kmtl` 9. Câu trả lời tự do `c20_source_other` không được đọc.
- `c25_any`: có viết câu trả lời ở Câu 25 hay không. Văn bản bị bỏ ngay sau khi đọc.
- `in_org`: loại hình nơi làm việc không phải tự doanh, hộ kinh doanh và quan hệ việc làm không phải freelancer. `in_dei`: mẫu chính, `in_org`, đủ năm câu Câu 23, `Q` hợp lệ, không trống loại hình và quy mô tổ chức (176). `in_dei_all`: như `in_dei` nhưng không yêu cầu `in_org` (218).

## Biến kiểm soát

| Khối | Tên chuẩn | Ghi chú |
|---|---|---|
| Xᴰ (tám nhóm, từ 13/10/2026) | `agegrp` (1 18–24, 2 25–34, 3 35–44, 4 45+), `educ`, `sex_birth`, `gmin` (0 nam hoặc nữ; 1 chuyển giới nam, chuyển giới nữ, phi nhị nguyên, khác), `orientg` (1 đồng tính nam, 2 đồng tính nữ, 3 song tính hoặc toàn tính, 98 khác, đang tự xác định hoặc dị tính), `relstat`, `region` (1 Hà Nội, 2 TP.HCM, 3 Đà Nẵng, 4 nơi khác), `industry` | Mã 9 = không muốn trả lời: quy tắc chính giữ thành mức riêng; quy tắc thay thế coi là khuyết. Bỏ trống là khuyết. Hệ số của `gmin` không được báo cáo |
| Xᴶ | `exper`, `position`, `emptype`, `orgtype`, `orgsize`, `socins`, `hours` | phân loại |

## Cờ chất lượng

- `flag_straight`: chọn cùng một mức cho mọi câu ở **cả ba** thang PHQ-4, che giấu và DEI cùng lúc.
- `flag_contra`: thông tin mâu thuẫn rõ. `agegrp == 1` (18–24 tuổi) và `position == 4` (quản lý cấp cao). Có thể bổ sung quy tắc, nhưng phải ghi vào `deviations.md`.
- `flag_quality` = `flag_straight | flag_contra`. Biến này chỉ dùng trong kiểm tra độ bền.

# Codebook — tên biến chuẩn

Dữ liệu xuất từ KoboToolbox có tên biến riêng. `config/variable_map.csv` ánh xạ `raw_name` sang `std_name` dưới đây. Mã trong `code/` chỉ dùng tên chuẩn. Các mã số giá trị trong bảng là **mặc định** của bộ dữ liệu giả lập. Nếu tệp Kobo dùng mã khác, khai báo bảng chuyển mã trong `01_import_clean.do`, mục “recode theo bảng hỏi”.

## Sàng lọc và nhận diện

| Tên chuẩn | Nội dung | Mã |
|---|---|---|
| `resp_id` | mã phiếu do Kobo sinh (không phải định danh cá nhân) | chuỗi |
| `submit_time` | thời điểm nộp phiếu | datetime |
| `age18` | từ 18 tuổi trở lên | 1 có, 0 không |
| `has_job` | có công việc chính tạo thu nhập tại Việt Nam | 1 có, 0 không |
| `lgbt_self` | câu tự nhận diện | 1 LGBT, 0 không phải LGBT, 8 không chắc/đang tự xác định, 9 không muốn trả lời, `.` bỏ trống |
| `orient` | xu hướng tính dục | 1 dị tính, 2 đồng tính nam, 3 đồng tính nữ, 4 song tính, 5 toàn tính, 6 khác, 9 không muốn trả lời |
| `gender_id` | bản dạng giới | 1 nam, 2 nữ, 3 người chuyển giới nam, 4 người chuyển giới nữ, 5 phi nhị nguyên, 6 khác, 9 không muốn trả lời |
| `sex_birth` | giới tính khi sinh | 1 nam, 2 nữ, 9 không muốn trả lời |

## Kết quả: PHQ-4 (0 không hề … 3 gần như mỗi ngày; hai tuần gần nhất)

| Tên chuẩn | Câu | Thang con |
|---|---|---|
| `phqi1` | cảm thấy bồn chồn, lo âu | GAD-2 |
| `phqi2` | không thể ngừng hoặc kiểm soát lo lắng | GAD-2 |
| `phqi3` | ít hứng thú hoặc niềm vui khi làm việc | PHQ-2 |
| `phqi4` | cảm thấy buồn, chán nản, tuyệt vọng | PHQ-2 |

Biến dựng: `phq4` (0–12), `gad2` (0–6), `phq2` (0–6), `phq4_frac` = phq4/12, `phq_ge6` (chỉ để mô tả, không diễn giải như tỷ lệ hiện mắc).

## Phơi nhiễm: kỳ thị tại nơi làm việc (0 không bao giờ … 4 rất thường xuyên; 12 tháng gần nhất; chỉ hỏi người LGBT)

| Tên | Tình huống | Nhóm (mục 3.6.3 đề cương) |
|---|---|---|
| `stig1` | bị nói đùa hoặc bình luận xúc phạm | sự kiện cụ thể |
| `stig2` | bị hỏi câu riêng tư không mong muốn | sự kiện cụ thể |
| `stig3` | bị tiết lộ hoặc đe dọa tiết lộ XHTD/BDG khi chưa đồng ý | sự kiện cụ thể |
| `stig4` | bị loại khỏi cơ hội đào tạo, phát triển | quy nguyên quyết định nhân sự |
| `stig5` | bị đánh giá, trả lương, thăng tiến không công bằng | quy nguyên quyết định nhân sự |
| `stig6` | bị phân công công việc bất lợi | quy nguyên quyết định nhân sự |
| `stig7` | bị áp lực tuân theo khuôn mẫu giới | sự kiện cụ thể |
| `stig8` | khó khăn về tên gọi, đại từ, trang phục, nhà vệ sinh | sự kiện cụ thể (không vào chỉ số chính) |

Mã 9 (“không áp dụng / không muốn trả lời”) chuyển thành khuyết. Biến dựng: `S` (trung bình 7 câu, cần ít nhất 4 câu hợp lệ), `S8`, `S_count7`, `S_complete7`, `stigX_any` (1 nếu ≥ 1 lần), `ever_exposed` (S > 0), `S3` (0/1/2, xem kế hoạch phân tích).

## Che giấu danh tính (1–5, chỉ hỏi người LGBT)

`conc1`–`conc4`. Câu về sự mệt mỏi do phải kiểm soát thông tin được khai trong `config/settings.do` (`CONC_FATIGUE_ITEM`, mặc định `conc4`). Biến dựng: `C` (4 câu), `C3` (3 câu còn lại).

## Thực thi DEI được cảm nhận (1–5)

`dei1`–`dei4` (an toàn khi phản ánh; quản lý tôn trọng; hành vi xúc phạm bị xử lý; được dùng tên gọi, đại từ, trang phục phù hợp). Mã 9 chuyển thành khuyết. Biến dựng: `Q` (cần ít nhất 3 câu hợp lệ), `Qc` (trung tâm hóa trên mẫu E5).

## Biến kiểm soát

| Khối | Tên chuẩn | Ghi chú |
|---|---|---|
| Xᴰ | `agegrp` (1 18–24, 2 25–34, 3 35–44, 4 45+), `sex_birth`, `educ`, `relstat`, `region` (1 Hà Nội, 2 TP.HCM, 3 Đà Nẵng, 4 nơi khác) | Mã 9 = không muốn trả lời: quy tắc chính giữ thành mức riêng; quy tắc thay thế coi là khuyết |
| Xᴶ | `exper`, `industry`, `position`, `emptype`, `orgtype`, `orgsize`, `socins`, `hours` | phân loại |

## Cờ chất lượng

- `flag_straight`: chọn cùng một mức cho mọi câu ở **cả ba** thang PHQ-4, che giấu và DEI cùng lúc.
- `flag_contra`: thông tin mâu thuẫn rõ. Mặc định là `agegrp == 1` và `position` thuộc nhóm quản lý cấp cao (mã trong settings). Có thể bổ sung quy tắc, nhưng phải ghi vào `deviations.md`.
- `flag_quality` = `flag_straight | flag_contra`. Biến này chỉ dùng trong kiểm tra độ bền.

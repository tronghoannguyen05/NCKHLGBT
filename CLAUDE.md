# CLAUDE.md — hướng dẫn cho các phiên làm việc với Claude

Đọc tệp này trước mọi việc. Sau đó đọc `docs/analysis_plan.md` (đặc tả phân tích, nguồn chân lý cho mã) và `docs/review_notes.md` (các vấn đề đang mở của đề cương).

## Đề tài

**Bệnh lý hay định kiến? Kỳ thị nơi làm việc và sức khỏe tâm thần của người lao động LGBT tại Việt Nam.**
Đây là công trình NCKH sinh viên, Học viện Ngân hàng. Đề cương hiện hành là `docs/de_cuong/De_cuong_lan_2.docx`; bản văn bản để đọc nhanh là `docs/de_cuong/de_cuong_lan_2.md`.

- Thiết kế: khảo sát trực tuyến cắt ngang, ẩn danh, KoboToolbox, thu từ 24/7 đến 28/9/2026, 850 phiếu.
- Mẫu chính: 278 người lao động LGBT có đủ PHQ-4 và chỉ số kỳ thị. Mẫu có đủ biến kiểm soát Xᴰ là 256 người theo quy tắc chính, 247 người theo quy tắc thay thế. Mẫu E5 là 243 người.
- Kết quả: PHQ-4 (0–12), GAD-2 (0–6), PHQ-2 (0–6).
- Phơi nhiễm: chỉ số kỳ thị S, là trung bình 7 tình huống (thang 0–4), tính khi có ít nhất 4 câu hợp lệ.
- Mô hình chính: OLS với sai số chuẩn HC3, điều chỉnh Xᴰ. Đặc tả 2 điều chỉnh thêm Xᴶ.
- Giả thuyết: H1 là chính. H2a, H2b và H3 là phụ, hiệu chỉnh Holm. E1–E5 là thăm dò, hiệu chỉnh BH.
- Công cụ: Stata 17 (theo đề cương). Mã nằm trong `code/`.

## Trạng thái (cập nhật khi thay đổi)

- [x] Thu dữ liệu xong. Dữ liệu thô **không** nằm trong repo.
- [x] Đề cương lần 2.
- [ ] Hồ sơ xét duyệt đạo đức. Đây là vấn đề lớn nhất, xem `docs/ethics_data_protection.md`.
- [ ] Đăng ký OSF. Cần xác nhận đã nộp hay chưa, rồi ghi đường dẫn vào `docs/analysis_plan.md`.
- [ ] Điền `config/variable_map.csv` (tên biến Kobo → tên chuẩn).
- [ ] Chạy thử toàn bộ `code/` trên dữ liệu giả lập (`tests/make_synthetic_data.py`). **Mã chưa từng được chạy trên Stata.**
- [ ] Chạy trên dữ liệu thật → điền Bảng 5–9 → viết bài.
- [ ] Bài NCKH 5 chương (khung ~80 trang: Mở đầu 5–6, Ch1 8–10, Ch2 16–17, Ch3 21–23, Ch4 13–15, Ch5 11–13, Tổng kết 2–3). Ch2 = cơ sở lý thuyết và khoảng trống; khung khái niệm và giả thuyết nằm ở mục 3.1 (theo yêu cầu tác giả). Mở đầu, Ch1, Ch2 và mục 3.1 đã có bản chờ tác giả duyệt trong `docs/bai_nckh/`, kèm biên bản phản biện. Chưa viết 3.2–3.9 và Ch4–5. Thời điểm hình thành giả thuyết đã bỏ khỏi phần giả thuyết, nhưng phải trình bày ở mục 3.8. Không viết Ch4–5 khi chưa có kết quả thật. Bản tiếng Anh (Introduction, Ch1, Ch2; Ch3–5 và Conclusion để trống theo yêu cầu tác giả vì phương pháp chưa chốt) ở `docs/bai_nckh/manuscript_en_intro_ch1_ch2.md`; trình bày học theo Herry & Dyar (2025).

## Quy tắc bắt buộc

1. **Không bao giờ commit, dán vào chat hay tải lên bất kỳ đâu** dữ liệu cấp cá nhân: tệp Kobo, `.dta`, `.csv` hay `.xlsx` có từng dòng người trả lời. Bộ dữ liệu chứa xu hướng tính dục và tình trạng sức khỏe, thuộc nhóm dữ liệu cá nhân nhạy cảm theo Luật 91/2025/QH15 và Nghị định 356/2025/NĐ-CP. `.gitignore` đã chặn `data/`. Chạy `bash tests/check_no_data.sh` trước khi commit.
2. **Ẩn ô nhỏ.** Mọi bảng chéo xuất ra theo nhóm SOGIE, nhân khẩu học hoặc đặc điểm nơi làm việc phải ẩn các ô có dưới 10 người. Dùng `small_cell_guard` trong `code/lib/programs.do`. Nhóm chuyển giới và phi nhị nguyên không được trình bày như một nhóm riêng.
3. **Không diễn giải nhân quả.** Viết “liên hệ”, “đi kèm”, “phù hợp với”. Không viết “tác động”, “làm tăng”, “gây ra” khi nói về η.
4. **Không viết “gần có ý nghĩa”.** Luôn báo cáo khoảng tin cậy 95%. Nếu khoảng tin cậy chứa cả 0 và các giá trị có ý nghĩa thực tiễn, kết luận là “chưa xác định”.
5. **Không đổi lựa chọn đã đăng ký** (Xᴰ, quy tắc mã hóa “không muốn trả lời”, HC3, các họ kiểm định, danh mục độ bền) sau khi thấy kết quả. Mọi lệch khỏi kế hoạch phải ghi vào `docs/deviations.md`, kèm ngày và lý do, **trước** khi chạy lại.
6. **Phân tích thăm dò phải gắn nhãn thăm dò** và không được dùng để củng cố kết luận chính. Một hệ số có ý nghĩa đặt cạnh một hệ số không có ý nghĩa không chứng minh hai hệ số khác nhau.
7. Chỗ nào đề cương chưa đủ chi tiết để viết mã thì đánh dấu `TODO(OSF)` và đối chiếu với bản đăng ký OSF. Không tự đặt quy tắc mới mà không ghi lại.

## Văn phong khi viết bài

- Tiếng Việt học thuật, câu ngắn, mỗi câu một ý, chủ ngữ rõ. Theo giọng của đề cương hiện có.
- Dùng thuật ngữ nhất quán theo bảng dưới. Lần đầu xuất hiện thì ghi kèm tiếng Anh nếu cần.
- Số thập phân dùng dấu phẩy (0,56); khoảng giá trị dùng gạch nối (0–12).
- Trích dẫn theo APA 7, viết “và cộng sự” trong văn bản tiếng Việt.

| Thuật ngữ | Tiếng Anh |
|---|---|
| lý thuyết căng thẳng thiểu số | minority stress theory |
| tác nhân xa / tác nhân gần | distal / proximal stressors |
| che giấu danh tính | identity concealment |
| kỳ thị thể hiện | enacted stigma |
| kỳ thị nội tâm hóa | internalized stigma |
| thực thi DEI được cảm nhận | perceived DEI enforcement |
| đặc điểm có trước phơi nhiễm (Xᴰ) | pre-exposure characteristics |
| đại lượng ước lượng | estimand |
| giá trị độ bền | robustness value (Cinelli & Hazlett) |
| đường cong đặc tả | specification curve |

## Bản đồ repo

| Đường dẫn | Nội dung |
|---|---|
| `docs/de_cuong/` | Đề cương (.docx gốc, .md, hình) |
| `docs/analysis_plan.md` | Đặc tả phân tích, quy tắc quyết định, ánh xạ giả thuyết → do-file → bảng |
| `docs/codebook.md` | Tên biến chuẩn, quy tắc mã hóa, cách dựng chỉ số |
| `docs/review_notes.md` | Nhận xét và vấn đề đang mở của đề cương lần 2 |
| `docs/ethics_data_protection.md` | Tình trạng đạo đức, kế hoạch bảo vệ dữ liệu, danh mục hồ sơ |
| `docs/deviations.md` | Nhật ký lệch khỏi kế hoạch đăng ký |
| `config/` | `settings.do` (tham số), `variable_map.csv` (ánh xạ biến Kobo) |
| `code/` | Pipeline Stata `00_master.do` → `11_tables.do` |
| `tests/` | Dữ liệu giả lập, kiểm tra không lộ dữ liệu |
| `data/` | **Không commit.** Đặt tệp thô vào `data/raw/` |
| `output/` | Bảng, hình, nhật ký (chỉ commit bảng đã ẩn ô nhỏ) |

## Cách chạy

1. Đặt tệp xuất từ Kobo vào `data/raw/` và khai tên tệp trong `config/settings.do`.
2. Điền cột `raw_name` của `config/variable_map.csv`.
3. Trong Stata: `cd` tới thư mục gốc của repo, rồi `do code/00_master.do`.
4. Muốn chạy thử mà chưa có dữ liệu thật: `python3 tests/make_synthetic_data.py`, đặt `USE_SYNTHETIC = 1` trong `config/settings.do`, rồi chạy master.

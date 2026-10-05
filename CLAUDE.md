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
- [ ] Đăng ký OSF: **chưa nộp** (tác giả xác nhận 5/10/2026). Nộp `docs/analysis_plan.md` (gồm mục 8, các quyết định chốt ngày 5/10/2026) **trước khi chạy `05_main_models.do`**, rồi ghi đường dẫn vào `docs/analysis_plan.md` và bài báo.
- [x] Chốt phương pháp (5/10/2026): hết `TODO(OSF)`; thêm ngưỡng hiệu ứng nhỏ nhất (1,0 điểm PHQ-4, TOST), gộp mức thưa (`04b_collapse_levels.do`), wild bootstrap, đặc tả thêm xu hướng tính dục, kiểm định hiệu ở E2; bỏ kiểm định White. Mã Stata đã sửa nhưng **chưa chạy thử**.
- [x] Điền `config/variable_map.csv` và tạo `config/value_map.csv` (mã chữ Kobo → mã số), 5/10/2026. Đã đối chiếu bằng Python trên tệp thật (chỉ số đếm): không có mã chưa ánh xạ; luồng mẫu khớp 850 → … → 243.
- [x] **Tệp chạy chính thức: `phan_tich.do`** (một tệp, theo yêu cầu tác giả 5/10/2026): đường dẫn dữ liệu trên máy tác giả (ổ D), xuất `ket_qua.xlsx`; `RUN_MODELS 0` chỉ chạy dữ liệu và mô tả, `1` chạy mô hình (sau khi đăng ký OSF). Hướng dẫn: `docs/huong_dan_chay_stata.md`. Pipeline nhiều tệp trong `code/` là bản trước, giữ để tham chiếu; mọi sửa đổi làm trên `phan_tich.do` trước. Dữ liệu giả lập định dạng Kobo: `tests/synthetic_kobo.csv`.
- [ ] Chạy `phan_tich.do` trên máy tác giả. **Mã chưa từng được chạy trên Stata.**
- [ ] Chạy trên dữ liệu thật → điền Bảng 5–9 → viết bài.
- [ ] Bài NCKH 5 chương (khung ~80 trang: Mở đầu 5–6, Ch1 8–10, Ch2 16–17, Ch3 21–23, Ch4 13–15, Ch5 11–13, Tổng kết 2–3). Ch2 = cơ sở lý thuyết và khoảng trống; khung khái niệm và giả thuyết nằm ở mục 3.1 (theo yêu cầu tác giả). Mở đầu, Ch1, Ch2 và mục 3.1 đã có bản chờ tác giả duyệt trong `docs/bai_nckh/`, kèm biên bản phản biện. Chưa viết 3.2–3.9 và Ch4–5. Thời điểm hình thành giả thuyết đã bỏ khỏi phần giả thuyết, nhưng phải trình bày ở mục 3.8. Không viết Ch4–5 khi chưa có kết quả thật. Bản tiếng Anh 5 chương dài (Introduction, Ch1, Ch2) ở `docs/bai_nckh/manuscript_en_intro_ch1_ch2.md`, giữ để tham khảo.
- [ ] **Bản chính hiện nay (từ 4/10/2026, theo yêu cầu tác giả): bài báo tiếng Anh trình bày theo Herry & Dyar (2025)**, ở `docs/bai_nckh/manuscript_en_article.md`. Bố cục: Abstract có cấu trúc, Keywords, Introduction (các mục không đánh số, kết thúc bằng Current Study và Hypotheses), Methods, Results, Discussion, Conclusions, Declarations, References. Đã viết Abstract (Introduction, Methods), Introduction và Methods (5/10/2026, theo `docs/analysis_plan.md`). Results, Discussion, Conclusions để trống cho đến khi có kết quả thật. Không phát triển thêm bản tiếng Việt và bản 5 chương trừ khi tác giả yêu cầu.
- [ ] Góp ý phương pháp trước khi chạy (hiệu ứng nhỏ nhất có ý nghĩa, nhóm thưa và HC3, thứ tự câu hỏi, sai lệch chọn mẫu, Xᴰ, E2): `docs/gop_y_phuong_phap.md`. Chưa ghi gì vào `deviations.md`; tác giả quyết định trước.

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
- Trong bài (cả bản tiếng Việt và tiếng Anh), không nêu nền tảng khảo sát (KoboToolbox), hình thức khảo sát (trực tuyến, ẩn danh) và thời gian thu dữ liệu. Vẫn nêu thiết kế cắt ngang (theo yêu cầu tác giả).
- Hạn chế câu dùng dấu gạch ngang (—) để chen ý; viết lại thành câu riêng, dấu phẩy, dấu hai chấm hoặc ngoặc đơn. Nếu cần gạch thì dùng gạch ngắn (-). Khoảng số và số trang vẫn dùng gạch nối (0–12) theo APA 7.

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

Mở `phan_tich.do` trong Stata 17 và bấm Do. Chi tiết ở `docs/huong_dan_chay_stata.md`.
- Đường dẫn dữ liệu và thư mục kết quả ở mục 0 (`global DATA`, `global OUT`).
- `RUN_MODELS 0`: dữ liệu, luồng mẫu, mô tả. `RUN_MODELS 1`: toàn bộ mô hình, chỉ sau khi đăng ký OSF.
- Mã hóa mã chữ của Kobo nằm ở mục 1 (lệnh `map_codes`), khớp `config/value_map.csv`. Nếu Kobo có mã mới, sửa cả hai.

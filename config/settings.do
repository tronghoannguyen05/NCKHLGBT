* =============================================================================
* settings.do — tham số dự án. Sửa ở đây, không sửa trong từng do-file.
* Được 00_master.do gọi sau khi đã cd tới thư mục gốc của repo.
* =============================================================================

* ---- Dữ liệu vào ------------------------------------------------------------
* Tệp xuất từ KoboToolbox (CSV, UTF-8). Đặt trong data/raw/ — KHÔNG commit.
global RAW_FILE        "data/raw/kobo_export.csv"
* 1 = chạy trên dữ liệu giả lập (tests/make_synthetic_data.py)
global USE_SYNTHETIC   0
global SYNTH_FILE      "data/raw/synthetic.csv"

* ---- Thư mục ----------------------------------------------------------------
global DERIVED "data/derived"
global TAB     "output/tables"
global FIG     "output/figures"
global LOGS    "output/logs"

* ---- Tham số suy luận (cố định trước khi ước lượng) --------------------------
global SEED       20260928
global MI_M       20        // số bộ gán giá trị
global BOOT_REPS  5000      // bootstrap hiệu ứng gián tiếp (tài liệu bổ sung)
global MIN_CELL   10        // ẩn ô có dưới 10 người trong bảng chéo; E2 không ước lượng tình huống có < 10 người gặp
global WILD_REPS  9999      // wild bootstrap cho H1 (boottest, trọng số Webb)

* ---- Ngưỡng hiệu ứng nhỏ nhất có ý nghĩa (chốt 5/10/2026, deviations D1) ----
* 1,0 điểm PHQ-4 trên 1 đơn vị S, tương đương khoảng 0,15 SD của PHQ-4 trên 1 SD của S
* (0,15 x 3,19 / 0,48 theo độ lệch chuẩn ở đề cương). Cố định bằng số, không tính lại từ dữ liệu.
global SESOI_PHQ4 1.0

* ---- Gộp mức thưa của biến kiểm soát phân loại (chốt 5/10/2026, deviations D2) ----
global MIN_LEVEL_N  5        // mức có dưới 5 người trong mẫu ước lượng được gộp (lý do: đòn bẩy và HC3)
global POOLED_CODE  98       // mã của mức "khác (gộp)" cho biến danh nghĩa
global ORDERED_VARS "agegrp educ exper orgsize hours"   // biến thứ bậc: gộp với mức liền kề

* ---- Biến kiểm soát ----------------------------------------------------------
* Xᴰ: có trước phơi nhiễm (đặc tả chính). Xᴶ: đặc điểm việc làm (đặc tả 2).
global XD "agegrp sex_birth educ relstat region"
global XJ "exper industry position emptype orgtype orgsize socins hours"

* ---- Danh sách câu hỏi (liệt kê tường minh, không dùng dải a-b) -------------
global PHQI  "phqi1 phqi2 phqi3 phqi4"
global STIG7 "stig1 stig2 stig3 stig4 stig5 stig6 stig7"
global STIG8 "stig1 stig2 stig3 stig4 stig5 stig6 stig7 stig8"
global CONC  "conc1 conc2 conc3 conc4"
global DEI   "dei1 dei2 dei3 dei4"

* ---- Quy tắc dựng chỉ số -----------------------------------------------------
global S_MIN_VALID   4      // chỉ số kỳ thị 7 câu: tối thiểu 4 câu hợp lệ (đề cương)
global S8_MIN_VALID  4      // chỉ số 8 câu: tối thiểu 4 câu hợp lệ (chốt 5/10/2026, như chỉ số 7 câu)
global C_MIN_VALID   4      // che giấu: đủ cả 4 câu (chốt 5/10/2026; khớp alpha 0,78 tính trên quan sát đủ câu)
global C3_MIN_VALID  3      // che giấu 3 câu: đủ cả 3 câu (chốt 5/10/2026)
global Q_MIN_VALID   3      // DEI: tối thiểu 3 câu hợp lệ (đề cương)
global CONC_FATIGUE_ITEM "conc4"   // câu "mệt mỏi do phải kiểm soát thông tin"

* Mã "không muốn trả lời" trong các biến nhân khẩu học và mã "không áp dụng"
global CODE_PNTA 9

* Mã position của quản lý cấp cao (dùng cho cờ thông tin mâu thuẫn)
global SENIOR_POSITION_CODES "5"

* Mẫu dùng để lấy trung vị S trong số người đã gặp kỳ thị (E1). Chốt 5/10/2026: mẫu chính 278.
global E1_MEDIAN_SAMPLE "in_main"

* ---- Đối chiếu luồng mẫu (đề cương Bảng 2) ----------------------------------
* 1 = dừng nếu số đếm khác kỳ vọng; 0 = chỉ cảnh báo
global STRICT_COUNTS 1
global N_TOTAL      850
global N_ELIGIBLE   727
global N_ANALYTIC   640
global N_ANALYTIC_NON 340
global N_ANALYTIC_LGBT 300
global N_E3_NON     323
global N_E3_LGBT    278
global N_MAIN       278
global N_XD_MAIN    256
global N_XD_ALT     247
global N_E5         243

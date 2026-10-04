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
global MIN_CELL   10        // ẩn ô có dưới 10 người trong bảng chéo

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
global S8_MIN_VALID  4      // TODO(OSF): chỉ số 8 câu
global C_MIN_VALID   4      // TODO(OSF): che giấu 4 câu (mặc định: đủ cả 4)
global C3_MIN_VALID  3      // TODO(OSF): che giấu 3 câu
global Q_MIN_VALID   3      // DEI: tối thiểu 3 câu hợp lệ (đề cương)
global CONC_FATIGUE_ITEM "conc4"   // câu "mệt mỏi do phải kiểm soát thông tin"

* Mã "không muốn trả lời" trong các biến nhân khẩu học và mã "không áp dụng"
global CODE_PNTA 9

* Mã position của quản lý cấp cao (dùng cho cờ thông tin mâu thuẫn)
global SENIOR_POSITION_CODES "5"

* Mẫu dùng để lấy trung vị S trong số người đã gặp kỳ thị (E1). TODO(OSF)
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

* =============================================================================
* CHAY_PHAN_TICH.do — chạy toàn bộ phân tích bằng một lần bấm
*
* Cách dùng (Stata 17 trở lên):
*   1. Mở tệp này trong Stata: nháy đúp vào tệp, hoặc File > Open.
*   2. Chọn chế độ ở dòng  local CHE_DO  ngay bên dưới.
*   3. Bấm nút Do trên thanh công cụ của Do-file Editor (hoặc Ctrl+D).
*
* Ba chế độ, theo đúng thứ tự nên chạy:
*   "thu"       Chạy thử trên dữ liệu GIẢ LẬP có sẵn (tests/synthetic_kobo.csv).
*               Không cần dữ liệu thật. Kết quả là bịa, chỉ để kiểm tra mã chạy
*               được trên máy của bạn.
*   "kiemtra"   Dữ liệu thật: nhập dữ liệu, dựng chỉ số, luồng mẫu, thống kê mô
*               tả, gộp mức thưa (các bước 01 đến 04b). CHƯA ước lượng mô hình.
*               Dùng được trước khi đăng ký OSF.
*   "chinhthuc" Dữ liệu thật: toàn bộ phân tích. Chỉ chạy SAU KHI đã đăng ký
*               docs/analysis_plan.md trên OSF.
*
* Dữ liệu thật: chép tệp .xlsx xuất từ Kobo vào thư mục data/raw/. Nếu không
* thấy, tệp này sẽ mở hộp thoại để bạn chọn tệp.
* Kết quả: output/tables (bảng), output/figures (hình), output/logs (nhật ký).
* =============================================================================

local CHE_DO "thu"

* -----------------------------------------------------------------------------
* Từ đây trở xuống không cần sửa.
* -----------------------------------------------------------------------------
set more off

* ---- 1. Phiên bản Stata --------------------------------------------------------
if c(stata_version) < 17 {
    di as error "Cần Stata 17 trở lên. Máy đang dùng Stata `c(stata_version)'."
    exit 9
}
version 17

if !inlist("`CHE_DO'", "thu", "kiemtra", "chinhthuc") {
    di as error `"CHE_DO phải là "thu", "kiemtra" hoặc "chinhthuc" (đang là "`CHE_DO'")."'
    exit 198
}

* ---- 2. Tìm thư mục gốc của repo ------------------------------------------------
capture confirm file "config/settings.do"
if _rc {
    di as text "Thư mục hiện tại (`c(pwd)') không phải thư mục gốc của repo."
    di as text "Hãy chọn chính tệp CHAY_PHAN_TICH.do trong hộp thoại vừa mở."
    global CHAY_PATH ""
    capture window fopen CHAY_PATH "Chọn tệp CHAY_PHAN_TICH.do trong thư mục NCKHLGBT" "Do-file (*.do)|*.do"
    if _rc | `"$CHAY_PATH"' == "" {
        di as error "Chưa xác định được thư mục repo."
        di as error `"Cách khác: gõ  cd "đường/dẫn/tới/NCKHLGBT"  vào cửa sổ lệnh, rồi chạy lại tệp này."'
        exit 601
    }
    local chay_p = subinstr(`"$CHAY_PATH"', "\", "/", .)
    local chay_dir = substr(`"`chay_p'"', 1, strrpos(`"`chay_p'"', "/") - 1)
    macro drop CHAY_PATH
    quietly cd `"`chay_dir'"'
    capture confirm file "config/settings.do"
    if _rc {
        di as error `"Thư mục `chay_dir' không có config/settings.do. Hãy chọn tệp CHAY_PHAN_TICH.do nằm ở thư mục gốc của repo."'
        exit 601
    }
}
di as result "Thư mục repo: `c(pwd)'"

* ---- 3. Cài gói Stata còn thiếu (cần Internet ở lần chạy đầu) -------------------
foreach pkg in sensemakr boottest {
    capture which `pkg'
    if _rc {
        di as text "Đang cài `pkg' từ SSC..."
        capture noisily ssc install `pkg', replace
        if _rc di as error "Không cài được `pkg'. Phần phân tích dùng `pkg' sẽ được bỏ qua (xem nhật ký)."
    }
}

* ---- 4. Dữ liệu theo chế độ ---------------------------------------------------
if "`CHE_DO'" == "thu" {
    capture confirm file "tests/synthetic_kobo.csv"
    if _rc {
        di as error "Thiếu tests/synthetic_kobo.csv. Hãy tải lại mã mới nhất của repo."
        exit 601
    }
    di as result "Chế độ THỬ: dùng dữ liệu giả lập. Kết quả KHÔNG được dùng cho bài."
}
else {
    capture confirm file "data/raw/kobo_export.xlsx"
    if _rc {
        local xl_files : dir "data/raw" files "*.xlsx"
        local n_xl : word count `xl_files'
        if `n_xl' == 1 {
            local xl_one : word 1 of `xl_files'
            copy `"data/raw/`xl_one'"' "data/raw/kobo_export.xlsx"
            di as text `"Đã dùng tệp data/raw/`xl_one' (chép thành data/raw/kobo_export.xlsx)."'
        }
        else {
            if `n_xl' > 1 di as text "Có nhiều tệp .xlsx trong data/raw; hãy chọn tệp xuất từ Kobo."
            else di as text "Chưa có tệp dữ liệu trong data/raw; hãy chọn tệp .xlsx xuất từ Kobo."
            global CHAY_XLSX ""
            capture window fopen CHAY_XLSX "Chọn tệp dữ liệu xuất từ Kobo (.xlsx)" "Excel (*.xlsx)|*.xlsx"
            if _rc | `"$CHAY_XLSX"' == "" {
                di as error "Chưa có dữ liệu. Chép tệp .xlsx xuất từ Kobo vào data/raw/ rồi chạy lại."
                exit 601
            }
            copy `"$CHAY_XLSX"' "data/raw/kobo_export.xlsx", replace
            macro drop CHAY_XLSX
            di as text "Đã chép dữ liệu vào data/raw/kobo_export.xlsx (thư mục này không được commit)."
        }
    }
    if "`CHE_DO'" == "kiemtra" {
        di as result "Chế độ KIỂM TRA: chạy đến bước 04b, chưa ước lượng mô hình."
    }
    else {
        capture window stopbox rusure ///
            "Chế độ CHÍNH THỨC sẽ ước lượng toàn bộ mô hình trên dữ liệu thật." ///
            "Chỉ chạy khi đã đăng ký docs/analysis_plan.md trên OSF." ///
            "Bấm OK để tiếp tục, Cancel để dừng."
        if _rc {
            di as error "Đã dừng theo lựa chọn của bạn (hoặc không hiển thị được hộp thoại xác nhận)."
            exit 1
        }
        di as result "Chế độ CHÍNH THỨC: chạy toàn bộ phân tích."
    }
}

* ---- 5. Chạy -------------------------------------------------------------------
do "code/00_master.do" `CHE_DO'

* ---- 6. Kết thúc ----------------------------------------------------------------
di as result _n "Hoàn tất chế độ `CHE_DO'."
di as result "Bảng: output/tables   Hình: output/figures   Nhật ký: output/logs"
if "`CHE_DO'" == "thu" {
    di as result `"Mã đã chạy được trên máy này. Bước tiếp theo: đặt CHE_DO là "kiemtra" và chạy lại."'
}
if "`CHE_DO'" == "kiemtra" {
    di as result `"Kiểm tra output/tables/T2_sample_flow.csv. Sau khi đăng ký OSF, đặt CHE_DO là "chinhthuc"."'
}

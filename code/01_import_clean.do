* =============================================================================
* 01_import_clean.do — nhập dữ liệu, đổi tên theo variable_map, sàng lọc,
*                      mã hóa giá trị đặc biệt (đề cương mục 3.2, bước 1–2)
* Vào: tệp xuất từ Kobo (.xlsx hoặc .csv, mã chữ của phương án)
* Ra: $DERIVED/clean.dta
* =============================================================================

local infile = cond($USE_SYNTHETIC, "$SYNTH_FILE", "$RAW_FILE")
capture confirm file "`infile'"
if _rc {
    di as error "Không thấy tệp dữ liệu `infile'. Xem config/settings.do."
    exit 601
}
* Đọc mọi cột dưới dạng chuỗi; mã hóa ở các bước dưới.
if lower(substr("`infile'", -5, .)) == ".xlsx" {
    import excel using "`infile'", firstrow allstring clear
}
else {
    import delimited using "`infile'", varnames(1) clear encoding("utf-8") case(preserve) stringcols(_all)
}

* ---- Đổi tên theo config/variable_map.csv (raw_name trống = trùng std_name) --
* Chỉ giữ các biến có trong bảng ánh xạ: câu trả lời tự do, thu nhập và siêu dữ
* liệu của Kobo bị bỏ ngay từ đầu.
frame create vmap
frame vmap: import delimited using "config/variable_map.csv", varnames(1) clear stringcols(_all) encoding("utf-8")
frame vmap: quietly count
local nmap = r(N)
local keepvars
forvalues i = 1/`nmap' {
    local std = strtrim(_frval(vmap, std_name, `i'))
    local raw = strtrim(_frval(vmap, raw_name, `i'))
    if "`raw'" == "" local raw "`std'"
    capture confirm variable `raw', exact
    if _rc {
        di as error "variable_map: không thấy biến `raw' (cho `std')"
        exit 111
    }
    if "`raw'" != "`std'" rename `raw' `std'
    local keepvars `keepvars' `std'
}
frame drop vmap
keep `keepvars'

* ---- Chuyển mã chữ của Kobo sang mã số (config/value_map.csv) -----------------
* Dừng nếu gặp một giá trị chưa có trong bảng ánh xạ.
foreach v of varlist _all {
    capture confirm string variable `v'
    if !_rc quietly replace `v' = strtrim(`v')
}
frame create vval
frame vval: import delimited using "config/value_map.csv", varnames(1) clear stringcols(_all) encoding("utf-8")
frame vval: quietly levelsof std_name, local(valvars) clean
frame vval: quietly count
local nval = r(N)
foreach v of local valvars {
    capture confirm string variable `v'
    if !_rc quietly gen double _n_`v' = .
}
forvalues i = 1/`nval' {
    local v   = strtrim(_frval(vval, std_name, `i'))
    local raw = strtrim(_frval(vval, raw_value, `i'))
    local cd  = strtrim(_frval(vval, code, `i'))
    local lb  = strtrim(_frval(vval, label, `i'))
    capture confirm variable _n_`v'
    if _rc continue
    quietly replace _n_`v' = `cd' if `v' == "`raw'"
    label define `v'_lb `cd' `"`lb'"', modify
}
frame drop vval
foreach v of local valvars {
    capture confirm variable _n_`v'
    if _rc continue
    quietly count if `v' != "" & missing(_n_`v')
    if r(N) > 0 {
        di as error "value_map: `v' có giá trị chưa được ánh xạ (thêm vào config/value_map.csv):"
        tab `v' if `v' != "" & missing(_n_`v')
        exit 459
    }
    drop `v'
    rename _n_`v' `v'
    label values `v' `v'_lb
}

* ---- Các thang đo đã là số trong tệp Kobo: chuyển kiểu --------------------------
local numvars $PHQI $STIG8 $CONC $DEI
foreach v of local numvars {
    capture confirm numeric variable `v'
    if _rc destring `v', replace
}

* ---- Kiểm tra miền giá trị -----------------------------------------------------
foreach v of varlist $PHQI {
    assert inrange(`v', 0, 3) | missing(`v')
}
foreach v of varlist $STIG8 {
    assert inrange(`v', 0, 4) | `v' == $CODE_PNTA | missing(`v')
}
foreach v of varlist $CONC {
    assert inrange(`v', 1, 5) | missing(`v')
}
foreach v of varlist $DEI {
    assert inrange(`v', 1, 5) | `v' == $CODE_PNTA | missing(`v')
}

* ---- Bước 1: đủ điều kiện và nhóm LGBT ----------------------------------------
gen byte eligible = (age18 == 1 & has_job == 1)
gen byte lgbt = .
replace lgbt = 1 if lgbt_self == 1
replace lgbt = 0 if lgbt_self == 0
label define lgbt_lb 0 "Non-LGBT" 1 "LGBT"
label values lgbt lgbt_lb
gen byte in_analytic = eligible & !missing(lgbt)

* Bản dạng giới thiểu số (chuyển giới, phi nhị nguyên, khác)
gen byte gender_minority = inlist(gender_id, 3, 4, 5, 6) if !missing(gender_id) & gender_id != $CODE_PNTA

* Nhóm xu hướng tính dục cho E4
gen byte orient3 = .
replace orient3 = 1 if inlist(orient, 4, 5)
replace orient3 = 2 if orient == 3
replace orient3 = 3 if orient == 2
label define orient3_lb 1 "Song tính/toàn tính" 2 "Đồng tính nữ" 3 "Đồng tính nam"
label values orient3 orient3_lb

* ---- Bước 2: giá trị đặc biệt ----------------------------------------------------
* Kỳ thị và DEI: "không áp dụng / không muốn trả lời" -> khuyết
foreach v of varlist $STIG8 $DEI {
    replace `v' = . if `v' == $CODE_PNTA
}
* Xᴰ: quy tắc chính giữ mã 9 như một mức riêng; quy tắc thay thế coi là khuyết
foreach v of global XD {
    gen `v'_alt = `v'
    replace `v'_alt = . if `v' == $CODE_PNTA
}

* Nhãn giá trị lấy từ cột label của config/value_map.csv.

compress
save "$DERIVED/clean.dta", replace

* =============================================================================
* 01_import_clean.do — nhập dữ liệu, đổi tên theo variable_map, sàng lọc,
*                      mã hóa giá trị đặc biệt (đề cương mục 3.2, bước 1–2)
* Ra: $DERIVED/clean.dta
* =============================================================================

local infile = cond($USE_SYNTHETIC, "$SYNTH_FILE", "$RAW_FILE")
capture confirm file "`infile'"
if _rc {
    di as error "Không thấy tệp dữ liệu `infile'. Xem config/settings.do."
    exit 601
}
import delimited using "`infile'", varnames(1) clear encoding("utf-8") case(preserve)

* ---- Đổi tên theo config/variable_map.csv (raw_name trống = trùng std_name) --
frame create vmap
frame vmap: import delimited using "config/variable_map.csv", varnames(1) clear stringcols(_all)
frame vmap: quietly count
local nmap = r(N)
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
}
frame drop vmap

* ---- Kiểu số -----------------------------------------------------------------
local numvars age18 has_job lgbt_self orient gender_id sex_birth $XD $XJ ///
    $PHQI $STIG8 $CONC $DEI
foreach v of varlist `numvars' {
    capture confirm numeric variable `v'
    if _rc destring `v', replace force
}

* ---- Recode theo bảng hỏi ----------------------------------------------------
* Nếu mã trong tệp Kobo khác codebook (docs/codebook.md), chuyển mã ở đây.
* Ví dụ: recode phqi1-phqi4 (1=0) (2=1) (3=2) (4=3)

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

label define sex_lb 1 "Nam" 2 "Nữ" 9 "Không muốn trả lời"
label values sex_birth sex_lb
label define age_lb 1 "18-24" 2 "25-34" 3 "35-44" 4 "45+" 9 "Không muốn trả lời"
label values agegrp age_lb
label define region_lb 1 "Hà Nội" 2 "TP.HCM" 3 "Đà Nẵng" 4 "Nơi khác" 9 "Không muốn trả lời"
label values region region_lb

compress
save "$DERIVED/clean.dta", replace

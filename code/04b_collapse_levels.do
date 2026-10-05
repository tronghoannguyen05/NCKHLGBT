* =============================================================================
* 04b_collapse_levels.do — gộp mức thưa của biến kiểm soát phân loại trước khi
*                          ước lượng (kế hoạch phân tích mục 2.6, chốt 5/10/2026)
* Lý do: một mức chỉ có 1 người làm đòn bẩy bằng 1 và sai số chuẩn HC3 không xác
* định; mức có vài người làm HC3 không ổn định. Quy tắc chỉ dựa trên số đếm.
* Chạy sau 04_descriptives.do, nên bảng mô tả dùng mức gốc (đã ẩn ô nhỏ).
* Biến gốc giữ ở <biến>_orig. Mô hình (05 trở đi) dùng biến đã gộp.
* Vào/ra: $DERIVED/analysis.dta   Ra thêm: $TAB/level_collapsing.csv
* =============================================================================
use "$DERIVED/analysis.dta", clear

tempname H
postfile `H' str24 variable double(from_level to_level) str8 n_in_estimation_sample ///
    using "$DERIVED/level_collapsing.dta", replace

local xd_alt
foreach v of global XD {
    local xd_alt `xd_alt' `v'_alt
}
foreach v in $XD `xd_alt' $XJ {
    capture confirm variable `v'_orig
    if _rc clonevar `v'_orig = `v'
}

local ordered $ORDERED_VARS
foreach v of global XD {
    local isord : list v in ordered
    local kind = cond(`isord', "ordered", "nominal")
    collapse_sparse `v', touse(in_xd_main) min($MIN_LEVEL_N) kind(`kind') ///
        pna($CODE_PNTA) pooled($POOLED_CODE) handle(`H')
}
foreach v of local xd_alt {
    local base : subinstr local v "_alt" "", all
    local isord : list base in ordered
    local kind = cond(`isord', "ordered", "nominal")
    collapse_sparse `v', touse(in_xd_alt) min($MIN_LEVEL_N) kind(`kind') ///
        pna($CODE_PNTA) pooled($POOLED_CODE) handle(`H')
}
foreach v of global XJ {
    local isord : list v in ordered
    local kind = cond(`isord', "ordered", "nominal")
    collapse_sparse `v', touse(in_xj) min($MIN_LEVEL_N) kind(`kind') ///
        pna($CODE_PNTA) pooled($POOLED_CODE) handle(`H')
}
postclose `H'

save "$DERIVED/analysis.dta", replace

use "$DERIVED/level_collapsing.dta", clear
if _N == 0 {
    di as text "Không có mức nào cần gộp."
}
else {
    list, noobs abbreviate(24)
}
export delimited using "$TAB/level_collapsing.csv", replace

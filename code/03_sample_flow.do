* =============================================================================
* 03_sample_flow.do — luồng mẫu (đề cương Bảng 2) và đối chiếu số đếm
* Ra: $TAB/T2_sample_flow.csv
* =============================================================================
use "$DERIVED/analysis.dta", clear

tempname F
postfile `F' str60 step long(n_total n_non n_lgbt expected_total expected_non expected_lgbt) ///
    using "$DERIVED/T2_sample_flow.dta", replace

quietly count
local tot = r(N)
post `F' ("Tổng số phiếu") (`tot') (.) (.) ($N_TOTAL) (.) (.)

quietly count if eligible
post `F' ("Đủ điều kiện (>=18 tuổi, có việc làm)") (r(N)) (.) (.) ($N_ELIGIBLE) (.) (.)

quietly count if eligible & missing(lgbt)
local undet = r(N)
quietly count if eligible & lgbt_self == 9
local u9 = r(N)
quietly count if eligible & lgbt_self == 8
local u8 = r(N)
quietly count if eligible & missing(lgbt_self)
local ublank = r(N)
di as text "Không xác định nhóm: `undet' (không muốn trả lời `u9'; không chắc `u8'; bỏ trống `ublank')"

foreach s in in_analytic in_e3 {
    quietly count if `s'
    local a = r(N)
    quietly count if `s' & lgbt == 0
    local b = r(N)
    quietly count if `s' & lgbt == 1
    local c = r(N)
    if "`s'" == "in_analytic" post `F' ("Mẫu phân tích") (`a') (`b') (`c') ($N_ANALYTIC) ($N_ANALYTIC_NON) ($N_ANALYTIC_LGBT)
    if "`s'" == "in_e3"       post `F' ("Mẫu E3 (đủ PHQ-4)") (`a') (`b') (`c') ($N_E3_NON + $N_E3_LGBT) ($N_E3_NON) ($N_E3_LGBT)
}
foreach s in in_main in_xd_main in_xd_alt in_e5 {
    quietly count if `s'
    local a = r(N)
    if "`s'" == "in_main"    post `F' ("Mẫu chính (LGBT, đủ PHQ-4 và S)") (`a') (.) (`a') ($N_MAIN) (.) ($N_MAIN)
    if "`s'" == "in_xd_main" post `F' ("Mẫu chính, đủ Xᴰ (quy tắc chính)") (`a') (.) (`a') ($N_XD_MAIN) (.) ($N_XD_MAIN)
    if "`s'" == "in_xd_alt"  post `F' ("Mẫu chính, đủ Xᴰ (quy tắc thay thế)") (`a') (.) (`a') ($N_XD_ALT) (.) ($N_XD_ALT)
    if "`s'" == "in_e5"      post `F' ("Mẫu E5 (đủ chỉ số DEI)") (`a') (.) (`a') ($N_E5) (.) ($N_E5)
}
postclose `F'

use "$DERIVED/T2_sample_flow.dta", clear
gen byte mismatch = (n_total != expected_total) | (!missing(expected_non) & n_non != expected_non) ///
    | (!missing(expected_lgbt) & n_lgbt != expected_lgbt)
list, noobs abbreviate(16)
export delimited using "$TAB/T2_sample_flow.csv", replace

quietly count if mismatch
if r(N) > 0 {
    di as error "Luồng mẫu khác đề cương ở " r(N) " bước. Kiểm tra mã hóa hoặc ghi lý do vào docs/deviations.md."
    if $STRICT_COUNTS exit 9
}

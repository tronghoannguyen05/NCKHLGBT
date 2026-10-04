* =============================================================================
* 10_spec_curve.do — đường cong đặc tả, 32 đặc tả (đề cương Bảng 4)
* 4 cách tính chỉ số × 2 bộ kiểm soát × 2 định nghĩa LGBT × 2 (giữ/loại
* người chuyển giới, phi nhị nguyên). Các mức mặc định: xem analysis_plan.md §6.
* Hệ số được báo cáo cả theo đơn vị gốc và theo 1 SD của chỉ số (để so sánh).
* =============================================================================
use "$DERIVED/analysis.dta", clear

results_open res_spec
local idx_list S S8 S_count7 S_complete7
local ctl_list XD XDXJ
local def_list self consistent
local tg_list keep drop

foreach idx of local idx_list {
foreach ctl of local ctl_list {
foreach def of local def_list {
foreach tg of local tg_list {
    local cond "in_analytic & !missing(phq4) & !missing(`idx')"
    if "`def'" == "self"       local cond "`cond' & lgbt == 1"
    if "`def'" == "consistent" local cond "`cond' & lgbt_consistent == 1"
    if "`tg'" == "drop"        local cond "`cond' & gender_minority != 1"
    local rhs "i.(${XD})"
    if "`ctl'" == "XDXJ" local rhs "`rhs' i.(${XJ})"

    capture noisily regress phq4 `idx' `rhs' if `cond', vce(hc3)
    if _rc continue
    matrix RT = r(table)
    quietly summarize `idx' if e(sample)
    local sd = r(sd)
    local sdtxt = string(`sd', "%9.4f")
    post_coef, handle(res_spec) coef(`idx') analysis("spec") depvar("phq4") ///
        spec("`idx'|`ctl'|`def'|`tg'") table(RT) note("sd_idx=`sdtxt'")
}
}
}
}
results_close res_spec

* ---- Hình: ước lượng theo 1 SD, sắp xếp tăng dần --------------------------------
use "$DERIVED/res_spec.dta", clear
gen double sd_idx = real(substr(note, strpos(note, "=") + 1, .))
gen double b_sd = b * sd_idx
gen double lb_sd = lb * sd_idx
gen double ub_sd = ub * sd_idx
gen byte is_main = spec == "S|XD|self|keep"
sort b_sd
gen rank = _n
twoway (rcap lb_sd ub_sd rank, lcolor(gs10)) ///
       (scatter b_sd rank if !is_main, mcolor(navy) msize(small)) ///
       (scatter b_sd rank if is_main, mcolor(cranberry) msymbol(D)), ///
       yline(0, lpattern(dash)) ytitle("Chênh lệch PHQ-4 trên 1 SD chỉ số kỳ thị") ///
       xtitle("Đặc tả (sắp theo ước lượng)") legend(order(2 "Đặc tả khác" 3 "Đặc tả chính")) ///
       graphregion(color(white))
graph export "$FIG/spec_curve.png", replace width(2000)
quietly summarize b_sd, detail
di as text "Trung vị ước lượng theo 1 SD: " %6.3f r(p50) "; khoảng: " %6.3f r(min) " đến " %6.3f r(max)
export delimited using "$TAB/res_spec.csv", replace

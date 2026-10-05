* =============================================================================
* 04_descriptives.do — đặc điểm mẫu (Bảng 5), độ tin cậy, E3, Bảng 6
*                      (đề cương mục 3.3)
* =============================================================================
use "$DERIVED/analysis.dta", clear

* ---- Bảng 5: thành phần mẫu theo nhóm (mẫu E3), có ẩn ô nhỏ -------------------
capture erase "$TAB/T5_sample.csv"
local first 1
foreach v in agegrp sex_birth gender_minority orient educ relstat region {
    if `first' tabsafe `v' if in_e3, by(lgbt) saving("$TAB/T5_sample.csv")
    else       tabsafe `v' if in_e3, by(lgbt) saving("$TAB/T5_sample.csv") append
    local first 0
}

* Trung bình (SD) của PHQ-4, GAD-2, PHQ-2 theo nhóm
preserve
keep if in_e3
collapse (mean) m_phq4=phq4 m_gad2=gad2 m_phq2=phq2 (sd) sd_phq4=phq4 sd_gad2=gad2 sd_phq2=phq2 ///
    (count) n=phq4 (mean) share_zero=phq4_zero, by(lgbt)
export delimited using "$TAB/T5_symptoms.csv", replace
restore

* ---- Độ tin cậy (mục 2.3, Bảng 3) ---------------------------------------------
tempname R
postfile `R' str24 scale str16 sample double(alpha r_items) long N ///
    using "$DERIVED/reliability.dta", replace
quietly alpha $PHQI if in_e3
post `R' ("PHQ-4") ("E3") (r(alpha)) (.) (r(N))
quietly corr phqi1 phqi2 if in_e3
post `R' ("GAD-2 (tương quan 2 câu)") ("E3") (.) (r(rho)) (r(N))
quietly corr phqi3 phqi4 if in_e3
post `R' ("PHQ-2 (tương quan 2 câu)") ("E3") (.) (r(rho)) (r(N))
quietly alpha $CONC if lgbt == 1 & in_analytic, casewise
post `R' ("Che giấu (4 câu)") ("LGBT") (r(alpha)) (.) (r(N))
quietly alpha $DEI if in_analytic, casewise
post `R' ("DEI (4 câu)") ("Phân tích") (r(alpha)) (.) (r(N))
quietly alpha $STIG7 if lgbt == 1 & in_analytic, casewise
post `R' ("Kỳ thị 7 câu (tham khảo)") ("LGBT") (r(alpha)) (.) (r(N))
quietly alpha $STIG8 if lgbt == 1 & in_analytic, casewise
post `R' ("Kỳ thị 8 câu (tham khảo)") ("LGBT") (r(alpha)) (.) (r(N))
postclose `R'
preserve
use "$DERIVED/reliability.dta", clear
export delimited using "$TAB/S_reliability.csv", replace
restore

* ---- Tỷ lệ từng tình huống kỳ thị (trên câu trả lời hợp lệ, mẫu chính) --------
preserve
keep if in_main
tempname P
postfile `P' str8 item long(n_valid n_any) double pct using "$DERIVED/stig_prev.dta", replace
forvalues j = 1/8 {
    quietly count if !missing(stig`j'_any)
    local nv = r(N)
    quietly count if stig`j'_any == 1
    post `P' ("stig`j'") (`nv') (r(N)) (100 * r(N) / `nv')
}
postclose `P'
use "$DERIVED/stig_prev.dta", clear
* Ẩn số đếm nhỏ khi công bố
* (tỷ lệ cũng được ẩn, vì có thể tính ngược số đếm từ tỷ lệ và n_valid)
gen str12 n_any_show = cond(n_any > 0 & n_any < $MIN_CELL, "<$MIN_CELL", string(n_any))
gen str8 pct_show = cond(n_any > 0 & n_any < $MIN_CELL, "", string(pct, "%5.1f"))
export delimited item n_valid n_any_show pct_show using "$TAB/S_stigma_prevalence.csv", replace
restore

* ---- E3: phân bố PHQ-4 theo ba nhóm (chỉ mô tả, không kiểm định) -------------
gen byte e3_group = .
replace e3_group = 0 if in_e3 & lgbt == 0
replace e3_group = 1 if in_e3 & lgbt == 1 & ever_exposed == 0
replace e3_group = 2 if in_e3 & lgbt == 1 & ever_exposed == 1
label define e3_lb 0 "Non-LGBT" 1 "LGBT, chưa gặp kỳ thị" 2 "LGBT, đã gặp kỳ thị"
label values e3_group e3_lb
preserve
keep if !missing(e3_group)
collapse (mean) mean=phq4 (sd) sd=phq4 (p50) median=phq4 (mean) pct_ge6=phq_ge6 (count) n=phq4, by(e3_group)
replace pct_ge6 = 100 * pct_ge6
export delimited using "$TAB/S_E3_distribution.csv", replace
restore

* ---- Bảng 6: hồi quy mô tả PHQ-4 theo nhân khẩu học (LGBT) --------------------
results_open res_T6
regress phq4 i.(${XD}) if in_xd_main, vce(hc3)
matrix RT = r(table)
local nT6 = e(N)
local cn : colnames RT
foreach c of local cn {
    if "`c'" == "_cons" | strpos("`c'", "b.") continue   // bỏ hằng số và mức gốc
    post_coef, handle(res_T6) coef(`c') analysis("T6") depvar("phq4") spec("XD") table(RT) nobs(`nT6')
}
results_close res_T6

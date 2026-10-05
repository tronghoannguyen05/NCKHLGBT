* =============================================================================
* 02_build_indices.do — dựng chỉ số, cờ chất lượng và cờ mẫu
*                       (đề cương mục 2.3, 3.2 bước 3–4; codebook)
* Vào: $DERIVED/clean.dta   Ra: $DERIVED/analysis.dta
* =============================================================================
use "$DERIVED/clean.dta", clear

* ---- PHQ-4, GAD-2, PHQ-2 ----------------------------------------------------
egen byte phq_n = rownonmiss($PHQI)
gen byte phq4 = phqi1 + phqi2 + phqi3 + phqi4 if phq_n == 4
gen byte gad2 = phqi1 + phqi2 if !missing(phqi1, phqi2)
gen byte phq2 = phqi3 + phqi4 if !missing(phqi3, phqi4)
gen double phq4_frac = phq4 / 12
gen byte phq_ge6 = phq4 >= 6 if !missing(phq4)   // chỉ để mô tả
gen byte phq4_zero = phq4 == 0 if !missing(phq4)
label var phq4 "PHQ-4 (0-12)"
label var gad2 "GAD-2, lo âu (0-6)"
label var phq2 "PHQ-2, trầm cảm (0-6)"

* ---- Chỉ số kỳ thị (chỉ người LGBT được hỏi) ----------------------------------
egen byte S_n = rownonmiss($STIG7)
egen double S_raw = rowmean($STIG7)
gen double S = S_raw if S_n >= $S_MIN_VALID & lgbt == 1
label var S "Chỉ số kỳ thị, 7 tình huống (0-4)"

egen byte S8_n = rownonmiss($STIG8)
egen double S8_raw = rowmean($STIG8)
gen double S8 = S8_raw if S8_n >= $S8_MIN_VALID & lgbt == 1
label var S8 "Chỉ số kỳ thị, 8 tình huống (0-4)"

egen byte S_count7 = anycount($STIG7), values(1 2 3 4)
replace S_count7 = . if S_n < $S_MIN_VALID | lgbt != 1
label var S_count7 "Số tình huống đã gặp (0-7)"

gen double S_complete7 = S if S_n == 7
label var S_complete7 "Chỉ số kỳ thị, chỉ người đủ 7 câu"

forvalues j = 1/8 {
    gen byte stig`j'_any = stig`j' >= 1 if !missing(stig`j')
}
gen byte ever_exposed = S > 0 if !missing(S)
gen double S_exposed = cond(ever_exposed == 1, S, 0) if !missing(S)

* ---- Che giấu danh tính ---------------------------------------------------------
local conc_all  $CONC
local conc_fat  $CONC_FATIGUE_ITEM
local conc3 : list conc_all - conc_fat
egen byte C_n = rownonmiss($CONC)
egen double C_raw = rowmean($CONC)
gen double C = C_raw if C_n >= $C_MIN_VALID & lgbt == 1
egen byte C3_n = rownonmiss(`conc3')
egen double C3_raw = rowmean(`conc3')
gen double C3 = C3_raw if C3_n >= $C3_MIN_VALID & lgbt == 1
label var C "Che giấu danh tính, 4 câu (1-5)"
label var C3 "Che giấu danh tính, 3 câu (bỏ câu mệt mỏi)"

* ---- DEI ----------------------------------------------------------------------
egen byte Q_n = rownonmiss($DEI)
egen double Q_raw = rowmean($DEI)
gen double Q = Q_raw if Q_n >= $Q_MIN_VALID
label var Q "Thực thi DEI được cảm nhận (1-5)"

* ---- Cờ chất lượng (mục 3.2 bước 4) --------------------------------------------
foreach sc in PHQI CONC DEI {
    egen double _sd_`sc' = rowsd(${`sc'})
    egen byte _n_`sc' = rownonmiss(${`sc'})
    local k : word count ${`sc'}
    gen byte _flat_`sc' = (_sd_`sc' == 0 & _n_`sc' == `k')
}
gen byte flag_straight = _flat_PHQI & _flat_CONC & _flat_DEI
local senior : subinstr global SENIOR_POSITION_CODES " " ",", all
gen byte flag_contra = (agegrp == 1 & inlist(position, `senior'))
gen byte flag_quality = flag_straight | flag_contra
drop _sd_* _n_* _flat_*

* ---- Cờ mẫu (đề cương Bảng 2) ------------------------------------------------
gen byte in_e3   = in_analytic & phq_n == 4
gen byte in_main = in_analytic & lgbt == 1 & !missing(phq4) & !missing(S)
egen byte _xd_miss = rowmiss($XD)
local xd_alt
foreach v of global XD {
    local xd_alt `xd_alt' `v'_alt
}
egen byte _xd_alt_miss = rowmiss(`xd_alt')
gen byte in_xd_main = in_main & _xd_miss == 0
gen byte in_xd_alt  = in_main & _xd_alt_miss == 0
gen byte in_e5      = in_xd_main & !missing(Q)
egen byte _xj_miss = rowmiss($XJ)
gen byte in_xj      = in_xd_main & _xj_miss == 0
drop _xd_miss _xd_alt_miss _xj_miss

quietly summarize Q if in_e5
gen double Qc = Q - r(mean) if !missing(Q)
label var Qc "DEI, trung tâm hóa trên mẫu E5"

* ---- E1: ba mức kỳ thị ----------------------------------------------------------
quietly summarize S if $E1_MEDIAN_SAMPLE & S > 0, detail
scalar S_med_exposed = r(p50)
gen byte S3 = .
replace S3 = 0 if S == 0
replace S3 = 1 if S > 0 & S <= S_med_exposed & !missing(S)
replace S3 = 2 if S > S_med_exposed & !missing(S)
label define S3_lb 0 "Không gặp" 1 "Thấp" 2 "Cao"
label values S3 S3_lb
di as text "Trung vị S trong số người đã gặp kỳ thị: " %5.3f S_med_exposed

* ---- Định nghĩa LGBT thay thế cho đường cong đặc tả (chốt 5/10/2026) ------------
* Mặc định: tự nhận LGBT VÀ câu trả lời SOGI nhất quán (xu hướng không dị tính
* hoặc bản dạng giới thiểu số). Lý do: câu hỏi kỳ thị chỉ hỏi người tự nhận LGBT.
gen byte lgbt_consistent = lgbt == 1 & (inrange(orient, 2, 6) | gender_minority == 1)

compress
save "$DERIVED/analysis.dta", replace

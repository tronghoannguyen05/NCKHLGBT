* =============================================================================
* 09_robustness.do — kiểm tra độ bền (đề cương mục 3.7, Bảng 4)
* Đặc tả 2 (Xᴶ) nằm ở 05; H3 với C3 nằm ở 06; đường cong đặc tả nằm ở 10.
* Ra: $TAB/res_robust.csv
* =============================================================================
use "$DERIVED/analysis.dta", clear
merge 1:1 resp_id using "$DERIVED/influence.dta", nogenerate keep(master match)

results_open res_robust

* Tham chiếu: mô hình chính
regress phq4 S i.(${XD}) if in_xd_main, vce(hc3)
post_coef, handle(res_robust) coef(S) analysis("H1") depvar("phq4") spec("main")

* ---- Tính tuyến tính (i): đã gặp + cường độ trong số người đã gặp -------------
regress phq4 i.ever_exposed S_exposed i.(${XD}) if in_xd_main, vce(hc3)
matrix RT = r(table)
post_coef, handle(res_robust) coef(1.ever_exposed) analysis("linearity") depvar("phq4") spec("ever_exposed") table(RT)
post_coef, handle(res_robust) coef(S_exposed) analysis("linearity") depvar("phq4") spec("intensity_among_exposed") table(RT)

* ---- Tính tuyến tính (ii): spline bậc ba có giới hạn, nút p10/p50/p90 --------
* Chốt 5/10/2026: spline trên toàn dải S, nút lấy từ phân phối S của người đã gặp kỳ thị.
quietly _pctile S if in_xd_main & S > 0, percentiles(10 50 90)
local k1 = r(r1)
local k2 = r(r2)
local k3 = r(r3)
if `k1' < `k2' & `k2' < `k3' {
    mkspline Ssp = S, cubic knots(`k1' `k2' `k3')
    regress phq4 Ssp1 Ssp2 i.(${XD}) if in_xd_main, vce(hc3)
    matrix RT = r(table)
    test Ssp2
    local pnl = string(r(p), "%5.3f")
    post_coef, handle(res_robust) coef(Ssp1) analysis("linearity") depvar("phq4") spec("rcs3_term1") table(RT) ///
        note("Kiểm định phi tuyến (Ssp2 = 0): p = `pnl'")
}
else {
    post_value, handle(res_robust) analysis("linearity") depvar("phq4") spec("rcs3") coef("-") ///
        note("Không ước lượng: các nút trùng nhau (`k1', `k2', `k3')")
}

* ---- Biến phụ thuộc bị chặn: fracreg logit, AME × 12 --------------------------
fracreg logit phq4_frac S i.(${XD}) if in_xd_main
margins, dydx(S) post
nlcom (ame12: _b[S] * 12), post
post_bse, handle(res_robust) coef(ame12) analysis("bounded_dv") depvar("phq4") spec("fracreg_logit_AMEx12")

* ---- Phiếu chất lượng thấp ------------------------------------------------------
regress phq4 S i.(${XD}) if in_xd_main & flag_quality == 0, vce(hc3)
post_coef, handle(res_robust) coef(S) analysis("quality") depvar("phq4") spec("drop_flagged")

* ---- Quan sát ảnh hưởng lớn -----------------------------------------------------
regress phq4 S i.(${XD}) if in_xd_main & flag_cook != 1, vce(hc3)
post_coef, handle(res_robust) coef(S) analysis("influence") depvar("phq4") spec("drop_cook_gt_4n")

* ---- Gán giá trị đa lần (20 bộ) --------------------------------------------------
* Phạm vi: người LGBT trong mẫu phân tích. Gán phq4, S và các Xᴰ bị khuyết thật
* (mã 9 vẫn là một mức riêng, theo quy tắc chính). Biến phụ trợ: C, Q, lgbt_consistent.
preserve
keep if in_analytic & lgbt == 1
mi set wide
mi register imputed phq4 S C Q ${XD}
mi impute chained (pmm, knn(5)) phq4 S C Q (mlogit, augment) ${XD}, ///
    add($MI_M) rseed($SEED)
mi estimate, post: regress phq4 S i.(${XD}), vce(hc3)
matrix DFM = e(df_mi)
local dfS = DFM[1, colnumb(DFM, "S")]
post_bse, handle(res_robust) coef(S) analysis("missing") depvar("phq4") spec("mi_chained_m${MI_M}") df(`dfS')
restore

* ---- Suy luận: wild bootstrap cho H1 (Davidson & Flachaire, 2008) ---------------
* Bổ sung chốt 5/10/2026 (kế hoạch mục 6.4). Phương án chính vẫn là HC3.
capture which boottest
if !_rc {
    regress phq4 S i.(${XD}) if in_xd_main, vce(robust)
    boottest S, reps($WILD_REPS) weighttype(webb) seed($SEED) nograph
    local pw = r(p)
    local wlo = .
    local whi = .
    capture matrix WCI = r(CI)
    if !_rc {
        local wlo = WCI[1,1]
        local whi = WCI[1,2]
    }
    post_value, handle(res_robust) analysis("inference") depvar("phq4") spec("wild_bootstrap_webb") ///
        coef("S") b(`=_b[S]') lb(`wlo') ub(`whi') p(`pw') nobs(`e(N)') ///
        note("Wild bootstrap có ràng buộc, $WILD_REPS lần, trọng số Webb")
}
else di as text "Bỏ qua wild bootstrap: chưa cài boottest."

* ---- Gây nhiễu: thêm xu hướng tính dục vào Xᴰ -----------------------------------
* Bổ sung chốt 5/10/2026 (kế hoạch mục 6.4): xu hướng tính dục có trước phơi nhiễm
* nhưng không có trong Xᴰ đã chốt ở đề cương. Mức 4 = khác / không xác định.
gen byte orient4 = orient3
replace orient4 = 4 if missing(orient3) & in_main
regress phq4 S i.(${XD}) i.orient4 if in_xd_main, vce(hc3)
post_coef, handle(res_robust) coef(S) analysis("confounding") depvar("phq4") spec("XD_plus_orientation")

* ---- Gây nhiễu không quan sát: Cinelli & Hazlett (2020) -------------------------
capture which sensemakr
if !_rc {
    preserve
    keep if in_xd_main
    local xd_dum
    local educ_dum
    foreach v of global XD {
        quietly tab `v', gen(_x_`v'_)
        * bỏ mức đầu làm mức gốc
        drop _x_`v'_1
        unab these : _x_`v'_*
        local xd_dum `xd_dum' `these'
        if "`v'" == "educ" local educ_dum `these'
    }
    unab sexd : _x_sex_birth_*
    sensemakr phq4 S `xd_dum', treat(S) benchmark(`sexd') kd(1 2 3)
    sensemakr phq4 S `xd_dum', treat(S) gbenchmark(`educ_dum') gname(educ) kd(1 2 3)
    restore
    di as text "Ghi giá trị độ bền RV_q và RV_qa từ bảng sensemakr ở trên vào báo cáo."
}

results_close res_robust

* =============================================================================
* 05_main_models.do — H1, H2a, H2b; đặc tả 1 (Xᴰ) và đặc tả 2 (Xᴰ + Xᴶ)
*                     (đề cương mục 2.5.1, 3.4; Bảng 7)
* Ra: $DERIVED/res_main.dta, $TAB/res_main.csv
* =============================================================================
use "$DERIVED/analysis.dta", clear

results_open res_main
foreach y in phq4 gad2 phq2 {
    local hyp = cond("`y'" == "phq4", "H1", cond("`y'" == "gad2", "H2a", "H2b"))

    * Đặc tả 1: Xᴰ (đặc tả chính, mẫu 256)
    regress `y' S i.(${XD}) if in_xd_main, vce(hc3)
    matrix RT = r(table)
    local mde = string(2.8 * _se[S], "%5.2f")
    post_coef, handle(res_main) coef(S) analysis("`hyp'") depvar("`y'") spec("1_XD") ///
        note("MDE ~ `mde' (2.8 x SE)") table(RT)

    * Kiểm định tương đương (TOST) cho H1, ngưỡng $SESOI_PHQ4 điểm (kế hoạch mục 6.3).
    * Kết luận "không có liên hệ đáng kể" chỉ khi CI 90% nằm trọn trong (-SESOI; SESOI).
    if "`y'" == "phq4" {
        local df = e(df_r)
        local b = _b[S]
        local se = _se[S]
        local lo90 = `b' - invttail(`df', 0.05) * `se'
        local hi90 = `b' + invttail(`df', 0.05) * `se'
        local p_lo = ttail(`df', (`b' + $SESOI_PHQ4) / `se')
        local p_hi = 1 - ttail(`df', (`b' - $SESOI_PHQ4) / `se')
        local p_tost = max(`p_lo', `p_hi')
        local verdict = cond(`lo90' > -$SESOI_PHQ4 & `hi90' < $SESOI_PHQ4, "trong vùng tương đương", "không kết luận được tương đương")
        post_value, handle(res_main) analysis("H1_equivalence") depvar("phq4") spec("1_XD_TOST") ///
            coef("S") b(`b') se(`se') lb(`lo90') ub(`hi90') p(`p_tost') nobs(`e(N)') ///
            note("CI 90%; SESOI = +/-$SESOI_PHQ4; `verdict'")
    }

    * Đặc tả 2: Xᴰ + Xᴶ (không dùng để chọn kết quả)
    regress `y' S i.(${XD}) i.(${XJ}) if in_xj, vce(hc3)
    post_coef, handle(res_main) coef(S) analysis("`hyp'") depvar("`y'") spec("2_XD_XJ")
}

* Quy tắc thay thế cho "không muốn trả lời" (mẫu 247)
local xd_alt
foreach v of global XD {
    local xd_alt `xd_alt' `v'_alt
}
regress phq4 S i.(`xd_alt') if in_xd_alt, vce(hc3)
post_coef, handle(res_main) coef(S) analysis("H1") depvar("phq4") spec("1_XD_alt_PNTA_missing")
results_close res_main

* =============================================================================
* 06_path_H3.do — đường dẫn kỳ thị -> che giấu -> PHQ-4 (đề cương 2.5.2, 3.8)
* p_H3 = max(p_a, p_b) theo nguyên tắc giao–hợp; Holm được áp ở 11_tables.do
* Bootstrap a×b chỉ đưa vào tài liệu bổ sung.
* =============================================================================
use "$DERIVED/analysis.dta", clear

results_open res_H3
foreach cv in C C3 {
    local spec = cond("`cv'" == "C", "C4_main", "C3_robust")
    gen byte _h3 = in_xd_main & !missing(`cv')

    regress `cv' S i.(${XD}) if _h3, vce(hc3)
    matrix RA = r(table)
    local pa = RA[4, colnumb(RA, "S")]
    post_coef, handle(res_H3) coef(S) analysis("H3_a") depvar("`cv'") spec("`spec'") table(RA)

    regress phq4 `cv' S i.(${XD}) if _h3, vce(hc3)
    matrix RB = r(table)
    local pb = RB[4, colnumb(RB, "`cv'")]
    post_coef, handle(res_H3) coef(`cv') analysis("H3_b") depvar("phq4") spec("`spec'") table(RB)
    post_coef, handle(res_H3) coef(S) analysis("H3_cprime") depvar("phq4") spec("`spec'") table(RB)

    local apos = RA[1, colnumb(RA, "S")] > 0
    local bpos = RB[1, colnumb(RB, "`cv'")] > 0
    local piut = max(`pa', `pb')
    quietly count if _h3
    local nh3 = r(N)
    post_value, handle(res_H3) analysis("H3") depvar("phq4") spec("`spec'") coef("IUT max(p_a,p_b)") ///
        p(`piut') nobs(`nh3') note("a>0: `apos'; b>0: `bpos'")
    drop _h3
}
results_close res_H3

* ---- Bootstrap hiệu ứng gián tiếp (tài liệu bổ sung) --------------------------
capture program drop h3_ab
program define h3_ab, rclass
    syntax [if]
    quietly regress C S i.(${XD}) `if'
    local a = _b[S]
    quietly regress phq4 C S i.(${XD}) `if'
    return scalar ab = `a' * _b[C]
end

gen byte _h3 = in_xd_main & !missing(C)
preserve
keep if _h3
bootstrap ab = r(ab), reps($BOOT_REPS) seed($SEED) nodots: h3_ab
estat bootstrap, percentile
matrix CI = e(ci_percentile)
tempname BS
postfile `BS' double(ab ll ul) long(reps N) using "$DERIVED/S_indirect_bootstrap.dta", replace
post `BS' (_b[ab]) (CI[1,1]) (CI[2,1]) ($BOOT_REPS) (e(N))
postclose `BS'
use "$DERIVED/S_indirect_bootstrap.dta", clear
export delimited using "$TAB/S_indirect_bootstrap.csv", replace
restore
drop _h3

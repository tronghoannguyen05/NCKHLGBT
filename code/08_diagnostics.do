* =============================================================================
* 08_diagnostics.do — chẩn đoán mô hình H1 (đề cương mục 3.5)
* Chỉ để mô tả: HC3 được dùng trong mọi mô hình bất kể kết quả ở đây.
* Ra: $TAB/S_diagnostics.csv, $DERIVED/influence.dta (cờ Cook/đòn bẩy)
* =============================================================================
use "$DERIVED/analysis.dta", clear
gen byte diag_sample = in_xd_main

tempname D
postfile `D' str40 test double(stat df p) str80 note using "$DERIVED/S_diagnostics.dta", replace

quietly regress phq4 S i.(${XD}) if diag_sample
local n = e(N)
local k = e(df_m) + 1

quietly estat hettest
post `D' ("Breusch-Pagan") (r(chi2)) (r(df)) (r(p)) ("")
* Kiểm định White đã bỏ (chốt 5/10/2026): chỉ có giá trị mô tả, nhiều bậc tự do
* với các biến giả, và HC3 được dùng bất kể kết quả.
quietly estat ovtest
post `D' ("Ramsey RESET") (r(F)) (r(df)) (r(p)) ("F(" + string(r(df)) + "," + string(r(df_r)) + ")")

* ---- Ảnh hưởng: Cook > 4/n, đòn bẩy > 2k/n ------------------------------------
predict double cook if e(sample), cooksd
predict double lev if e(sample), leverage
gen byte flag_cook = cook > 4 / `n' if !missing(cook)
gen byte flag_lev  = lev > 2 * `k' / `n' if !missing(lev)
quietly count if flag_cook == 1
post `D' ("Số quan sát Cook > 4/n") (r(N)) (.) (.) ("")
quietly count if flag_lev == 1
post `D' ("Số quan sát đòn bẩy > 2k/n") (r(N)) (.) (.) ("")

* ---- GVIF theo nhóm biến giả ----------------------------------------------------
local gvars S
local gsizes 1
local gnames S
foreach v of global XD {
    quietly levelsof `v' if diag_sample, local(levs)
    local first : word 1 of `levs'
    local cnt 0
    foreach l of local levs {
        if `l' == `first' continue
        quietly gen byte _d_`v'_`l' = (`v' == `l') if diag_sample
        local gvars `gvars' _d_`v'_`l'
        local ++cnt
    }
    local gsizes `gsizes' `cnt'
    local gnames `gnames' `v'
}
gen byte _gv_touse = diag_sample & !missing(S)
gvif_calc, vars(`gvars') sizes(`gsizes') names(`gnames') touse(_gv_touse)
matrix G = r(gvif)
local j 0
foreach nm of local gnames {
    local ++j
    local dfj : word `j' of `gsizes'
    post `D' ("GVIF `nm'") (G[1,`j']) (`dfj') (.) ("GVIF^(1/(2df)) = " + string(G[1,`j']^(1/(2*`dfj')), "%5.3f"))
}
drop _d_* _gv_touse
postclose `D'

preserve
keep resp_id cook lev flag_cook flag_lev
save "$DERIVED/influence.dta", replace
restore

use "$DERIVED/S_diagnostics.dta", clear
list, noobs abbreviate(20)
export delimited using "$TAB/S_diagnostics.csv", replace

* =============================================================================
* 11_tables.do — hiệu chỉnh p theo họ và dựng Bảng 7, 8, 9
*   Họ Holm: {H2a, H2b, H3} trên đặc tả chính (đề cương 3.8)
*   Họ BH:   E2 (8 hệ số); E4 (các hệ số tương tác). TODO(OSF): một hay hai họ
* =============================================================================

* ---- Bảng 7 và họ Holm ----------------------------------------------------------
use "$DERIVED/res_main.dta", clear
append using "$DERIVED/res_H3.dta"
gen str12 holm_family = ""
replace holm_family = "secondary" if inlist(analysis, "H2a", "H2b") & spec == "1_XD"
replace holm_family = "secondary" if analysis == "H3" & spec == "C4_main"
gen double p_for_holm = p if holm_family == "secondary"
padjust p_for_holm, gen(p_holm) method(holm)
drop p_for_holm
order analysis depvar spec coef b se lb ub p p_holm N note
export delimited using "$TAB/T7_T8_main_and_path.csv", replace
list analysis depvar spec coef b se p p_holm N, noobs abbreviate(12) sepby(analysis)

* ---- Bảng 9: thăm dò, BH theo họ ------------------------------------------------
use "$DERIVED/res_expl.dta", clear
gen str8 bh_family = ""
replace bh_family = "E2" if analysis == "E2"
replace bh_family = "E4" if analysis == "E4"
gen double p_for_bh = p if bh_family != ""
padjust p_for_bh, gen(p_bh) method(bh) by(bh_family)
drop p_for_bh
order analysis depvar spec coef b se lb ub p p_bh N note
export delimited using "$TAB/T9_exploratory.csv", replace
list analysis spec b se p p_bh N, noobs abbreviate(12) sepby(analysis)

di as text "Nhắc: H1 không hiệu chỉnh (kiểm định chính). Kết luận theo quy tắc ở CLAUDE.md (3-6)."

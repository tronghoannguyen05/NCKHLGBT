* =============================================================================
* 07_exploratory.do — E1, E2, E4, E5 (đề cương 2.5.3; Bảng 9). THĂM DÒ.
* BH được áp theo họ ở 11_tables.do.
* =============================================================================
use "$DERIVED/analysis.dta", clear

results_open res_expl

* ---- E1: ba mức kỳ thị (tài liệu bổ sung) -------------------------------------
regress phq4 i.S3 i.(${XD}) if in_xd_main, vce(hc3)
matrix RT = r(table)
post_coef, handle(res_expl) coef(1.S3) analysis("E1") depvar("phq4") spec("low_vs_none") table(RT)
post_coef, handle(res_expl) coef(2.S3) analysis("E1") depvar("phq4") spec("high_vs_none") table(RT)

* ---- E2: từng tình huống (8 mô hình) ------------------------------------------
forvalues j = 1/8 {
    quietly count if in_xd_main & stig`j'_any == 1
    local nexp = r(N)
    quietly count if in_xd_main & stig`j'_any == 0
    local nunexp = r(N)
    if `nexp' == 0 | `nunexp' == 0 {
        post_value, handle(res_expl) analysis("E2") depvar("phq4") spec("stig`j'") ///
            coef("1.stig`j'_any") note("Không ước lượng: n_exposed = `nexp'")
        continue
    }
    regress phq4 i.stig`j'_any i.(${XD}) if in_xd_main, vce(hc3)
    post_coef, handle(res_expl) coef(1.stig`j'_any) analysis("E2") depvar("phq4") spec("stig`j'") ///
        note("n_exposed = `nexp'")
}

* ---- E4: khác biệt theo giới tính khi sinh và xu hướng tính dục ---------------
local _xd $XD
local _sx sex_birth
local xd_nosex : list _xd - _sx
regress phq4 ib1.sex_birth##c.S i.(`xd_nosex') if in_xd_main & sex_birth != $CODE_PNTA, vce(hc3)
post_coef, handle(res_expl) coef(2.sex_birth#c.S) analysis("E4") depvar("phq4") spec("S_x_female")

* TODO(OSF): người không thuộc 3 nhóm xu hướng tính dục -> mặc định loại
regress phq4 ib1.orient3##c.S i.(${XD}) if in_xd_main & !missing(orient3), vce(hc3)
matrix RT = r(table)
post_coef, handle(res_expl) coef(2.orient3#c.S) analysis("E4") depvar("phq4") spec("S_x_lesbian_vs_bipan") table(RT)
post_coef, handle(res_expl) coef(3.orient3#c.S) analysis("E4") depvar("phq4") spec("S_x_gay_vs_bipan") table(RT)

* ---- E5: điều tiết bởi mức thực thi DEI ---------------------------------------
regress phq4 c.S##c.Qc i.(${XD}) if in_e5, vce(hc3)
post_coef, handle(res_expl) coef(c.S#c.Qc) analysis("E5") depvar("phq4") spec("kappa")

results_close res_expl

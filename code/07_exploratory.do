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
    * Tình huống có dưới $MIN_CELL người gặp (hoặc không gặp): không ước lượng và
    * không ghi số đếm, để không lộ ô nhỏ (kế hoạch mục 5.2).
    if `nexp' < $MIN_CELL | `nunexp' < $MIN_CELL {
        post_value, handle(res_expl) analysis("E2_not_estimated") depvar("phq4") spec("stig`j'") ///
            coef("1.stig`j'_any") note("Không ước lượng: dưới $MIN_CELL người ở một nhóm")
        continue
    }
    regress phq4 i.stig`j'_any i.(${XD}) if in_xd_main, vce(hc3)
    post_coef, handle(res_expl) coef(1.stig`j'_any) analysis("E2") depvar("phq4") spec("stig`j'") ///
        note("n_exposed = `nexp'")
}

* ---- E2b: tình huống phụ thuộc quy nguyên so với tình huống sự kiện ------------
* Kiểm định trực tiếp hiệu hai hệ số (Gelman & Stern, 2006), thay cho việc so sánh
* "có ý nghĩa / không có ý nghĩa" giữa các mô hình E2 (kế hoạch mục 5.2). THĂM DÒ.
* Lưu ý: hai thang con gần tương tự (liên cá nhân, thể chế) đã được chạy trước khi
* chốt kế hoạch (đề cương mục 3.11), nên kết quả này không phải kiểm định mới.
quietly count if in_xd_main & stig4_any == 1
local attr_items "stig5 stig6"
if r(N) >= $MIN_CELL local attr_items "stig4 stig5 stig6"
egen double S_attr  = rowmean(`attr_items')
egen double S_event = rowmean(stig1 stig2 stig3 stig7)
regress phq4 S_event S_attr i.(${XD}) if in_xd_main, vce(hc3)
matrix RT = r(table)
post_coef, handle(res_expl) coef(S_event) analysis("E2_contrast") depvar("phq4") spec("event_items") table(RT)
post_coef, handle(res_expl) coef(S_attr) analysis("E2_contrast") depvar("phq4") spec("attribution_items") ///
    table(RT) note("Gồm: `attr_items'")
lincom S_attr - S_event
post_value, handle(res_expl) analysis("E2_contrast") depvar("phq4") spec("attribution_minus_event") ///
    coef("diff") b(`r(estimate)') se(`r(se)') lb(`r(lb)') ub(`r(ub)') p(`r(p)') nobs(`e(N)')

* ---- E4: khác biệt theo giới tính khi sinh và xu hướng tính dục ---------------
local _xd $XD
local _sx sex_birth
local xd_nosex : list _xd - _sx
* Điều kiện dùng sex_birth_orig vì 04b có thể đã gộp mức "không muốn trả lời".
regress phq4 ib1.sex_birth##c.S i.(`xd_nosex') if in_xd_main & sex_birth_orig != $CODE_PNTA, vce(hc3)
post_coef, handle(res_expl) coef(2.sex_birth#c.S) analysis("E4") depvar("phq4") spec("S_x_female")

* Chốt 5/10/2026: người không thuộc 3 nhóm xu hướng tính dục không vào mô hình này
* (vẫn có trong mọi phân tích khác).
regress phq4 ib1.orient3##c.S i.(${XD}) if in_xd_main & !missing(orient3), vce(hc3)
matrix RT = r(table)
post_coef, handle(res_expl) coef(2.orient3#c.S) analysis("E4") depvar("phq4") spec("S_x_lesbian_vs_bipan") table(RT)
post_coef, handle(res_expl) coef(3.orient3#c.S) analysis("E4") depvar("phq4") spec("S_x_gay_vs_bipan") table(RT)

* ---- E5: điều tiết bởi mức thực thi DEI ---------------------------------------
regress phq4 c.S##c.Qc i.(${XD}) if in_e5, vce(hc3)
post_coef, handle(res_expl) coef(c.S#c.Qc) analysis("E5") depvar("phq4") spec("kappa")

results_close res_expl

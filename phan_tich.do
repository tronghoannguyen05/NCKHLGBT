* =============================================================================
* Kỳ thị tại nơi làm việc và sức khỏe tâm thần của người lao động LGBT
* Stata 17 trở lên. Mở tệp và bấm Do.
* Kết quả: ket_qua.xlsx, spec_curve.png và nhat_ky.log trong thư mục OUT.
* =============================================================================

version 17
clear all
set more off
set varabbrev off
set linesize 120

* -----------------------------------------------------------------------------
* 0. Thiết lập
* -----------------------------------------------------------------------------
global DATA "D:/NCKH chủ đề LGBT/Kỳ_thị_tại_nơi_làm_việc_và_bất_lợi_thu_nhập_-_Khảo_sát_người_lao_động_tại_Việt_Nam_n850.xlsx"
global OUT  "D:/NCKH chủ đề LGBT/ket_qua"

* 1: chạy toàn bộ. 0: chỉ dữ liệu, luồng mẫu và thống kê mô tả.
global RUN_MODELS 1

global SEED      20260928
global MIN_CELL  10
global MIN_LEVEL 5
global SESOI     1.0
global MI_M      20
global BOOT_REPS 5000
global WILD_REPS 9999

global XD      "agegrp sex_birth educ relstat region"
global XJ      "exper industry position emptype orgtype orgsize socins hours"
global ORDERED "agegrp educ exper orgsize hours"
global PHQI    "phqi1 phqi2 phqi3 phqi4"
global STIG7   "stig1 stig2 stig3 stig4 stig5 stig6 stig7"
global STIG8   "stig1 stig2 stig3 stig4 stig5 stig6 stig7 stig8"
global CONC    "conc1 conc2 conc3 conc4"
global CONC3   "conc1 conc2 conc3"
global DEI     "dei1 dei2 dei3 dei4"

capture mkdir "$OUT"
capture log close _all
log using "$OUT/nhat_ky.log", replace text name(main)

capture confirm file "$DATA"
if _rc {
    di as text "Không thấy tệp dữ liệu theo đường dẫn DATA. Hãy chọn tệp trong hộp thoại."
    global PICK ""
    capture window fopen PICK "Chọn tệp dữ liệu (.xlsx)" "Excel (*.xlsx)|*.xlsx"
    if _rc | `"$PICK"' == "" {
        di as error "Chưa có tệp dữ liệu. Sửa đường dẫn ở dòng global DATA rồi chạy lại."
        exit 601
    }
    global DATA `"$PICK"'
}

foreach p in sensemakr boottest {
    capture which `p'
    if _rc {
        capture noisily ssc install `p', replace
    }
}

capture erase "$OUT/ket_qua.xlsx"
capture confirm file "$OUT/ket_qua.xlsx"
if !_rc {
    di as error "Hãy đóng tệp ket_qua.xlsx trong Excel rồi chạy lại."
    exit 608
}

* -----------------------------------------------------------------------------
* Chương trình dùng chung
* -----------------------------------------------------------------------------
capture program drop map_codes
program define map_codes
    syntax varname(string), GENerate(name) FROM(string) TO(numlist)
    local nf : word count `from'
    local nt : word count `to'
    if `nf' != `nt' {
        di as error "map_codes `varlist': from() và to() khác số phần tử"
        exit 198
    }
    quietly gen double `generate' = .
    forvalues i = 1/`nf' {
        local f : word `i' of `from'
        local t : word `i' of `to'
        quietly replace `generate' = `t' if `varlist' == "`f'"
    }
    quietly count if `varlist' != "" & missing(`generate')
    if r(N) > 0 {
        di as error "map_codes: `varlist' có giá trị chưa được mã hóa"
        tab `varlist' if `varlist' != "" & missing(`generate')
        exit 459
    }
end

capture program drop xl_out
program define xl_out
    args sheet
    capture confirm file "$OUT/ket_qua.xlsx"
    if _rc {
        export excel using "$OUT/ket_qua.xlsx", sheet("`sheet'") firstrow(variables) replace
    }
    else {
        export excel using "$OUT/ket_qua.xlsx", sheet("`sheet'") firstrow(variables) sheetreplace
    }
end

capture program drop post_coef
program define post_coef
    syntax, PART(string) OUTCOME(string) SPEC(string) COEF(string) [NOTE(string) TABLE(name)]
    tempname T
    if "`table'" != "" matrix `T' = `table'
    else matrix `T' = r(table)
    local j = colnumb(`T', "`coef'")
    if missing(`j') {
        di as error "post_coef: không thấy hệ số `coef'"
        exit 111
    }
    post res ("`part'") ("`outcome'") ("`spec'") ("`coef'") (`T'[1,`j']) (`T'[2,`j']) ///
        (`T'[5,`j']) (`T'[6,`j']) (`T'[4,`j']) (e(N)) (`"`note'"')
end

capture program drop post_val
program define post_val
    syntax, PART(string) OUTCOME(string) SPEC(string) COEF(string) ///
        [EST(string) STDERR(string) LOWER(string) UPPER(string) PVAL(string) NOBS(string) NOTE(string)]
    foreach x in est stderr lower upper pval nobs {
        if `"``x''"' == "" local `x' .
    }
    post res ("`part'") ("`outcome'") ("`spec'") ("`coef'") (`est') (`stderr') (`lower') (`upper') ///
        (`pval') (`nobs') (`"`note'"')
end

* Holm và Benjamini-Hochberg theo họ kiểm định
capture program drop padjust
program define padjust
    syntax varname(numeric), GENerate(name) Method(string) [BY(varname)]
    tempvar grp ord m raw rev
    if "`by'" == "" gen byte `grp' = 1
    else egen `grp' = group(`by'), missing
    bysort `grp' (`varlist'): gen long `ord' = _n if !missing(`varlist')
    by `grp': egen long `m' = count(`varlist')
    if "`method'" == "holm" {
        gen double `raw' = min(1, (`m' - `ord' + 1) * `varlist') if !missing(`varlist')
        bysort `grp' (`ord'): replace `raw' = max(`raw', `raw'[_n-1]) ///
            if _n > 1 & !missing(`raw') & !missing(`raw'[_n-1])
    }
    else {
        gen double `raw' = min(1, `m' / `ord' * `varlist') if !missing(`varlist')
        gen long `rev' = -`ord'
        bysort `grp' (`rev'): replace `raw' = min(`raw', `raw'[_n-1]) ///
            if _n > 1 & !missing(`raw') & !missing(`raw'[_n-1])
    }
    gen double `generate' = `raw'
end

* Bảng tần số theo nhóm, ẩn ô dưới MIN_CELL (kèm ẩn thứ cấp), cộng dồn vào tệp dta
capture program drop tabsafe
program define tabsafe
    syntax varname [if], BY(varname) SAVing(string)
    marksample touse, novarlist
    preserve
    quietly {
        keep if `touse'
        local vlab : value label `varlist'
        local blab : value label `by'
        gen _level = `varlist'
        gen _group = `by'
        contract _group _level, freq(n) zero
        bysort _group: egen long total = total(n)
        gen double pct = 100 * n / total
        gen byte suppressed = (n > 0 & n < $MIN_CELL)
        bysort _group: egen n_supp = total(suppressed)
        gen double _key = cond(suppressed | n == 0, ., n)
        gen byte secondary = 0
        bysort _group (_key): replace secondary = 1 if n_supp == 1 & _n == 1 & !missing(_key)
        gen str12 n_show = string(n)
        replace n_show = "<$MIN_CELL" if suppressed
        replace n_show = "ẩn" if secondary
        gen str8 pct_show = cond(suppressed | secondary, "", string(pct, "%5.1f"))
        gen str32 variable = "`varlist'"
        if "`vlab'" != "" {
            label values _level `vlab'
            decode _level, gen(level)
        }
        else gen str32 level = string(_level)
        replace level = "Khuyết" if missing(_level)
        if "`blab'" != "" {
            label values _group `blab'
            decode _group, gen(group)
        }
        else gen str32 group = string(_group)
        keep variable group level n_show pct_show total
        order variable group level n_show pct_show total
        capture confirm file "`saving'"
        if !_rc append using "`saving'"
        save "`saving'", replace
    }
    restore
end

* Cronbach's alpha trên các quan sát đủ câu, kèm số quan sát
capture program drop rel_post
program define rel_post
    syntax varlist [if], NAME(string) SAMPLE(string)
    marksample touse
    quietly alpha `varlist' if `touse'
    local a = r(alpha)
    quietly count if `touse'
    post rel ("`name'") ("`sample'") (`a') (.) (r(N))
end

* Gộp mức có dưới min người trong mẫu ước lượng (chỉ dựa trên số đếm)
capture program drop modal_level
program define modal_level, rclass
    syntax varname, Touse(varname) [Exclude(numlist)]
    quietly levelsof `varlist' if `touse', local(levs)
    local best .
    local bestn -1
    foreach l of local levs {
        local skip : list posof "`l'" in exclude
        if `skip' continue
        quietly count if `touse' & `varlist' == `l'
        if r(N) > `bestn' {
            local bestn = r(N)
            local best = `l'
        }
    }
    return scalar level = `best'
end

capture program drop collapse_sparse
program define collapse_sparse
    syntax varname, Touse(varname) Min(integer) Kind(string) Special(numlist) Pooled(integer)
    local v `varlist'
    local guard 0
    while 1 {
        local ++guard
        if `guard' > 50 {
            di as error "collapse_sparse: quá nhiều vòng lặp ở `v'"
            exit 498
        }
        quietly levelsof `v' if `touse', local(levs)
        local nlev : word count `levs'
        if `nlev' <= 1 continue, break
        local l .
        foreach x of local levs {
            quietly count if `touse' & `v' == `x'
            if r(N) < `min' {
                local l = `x'
                continue, break
            }
        }
        if missing(`l') continue, break

        local haspooled : list posof "`pooled'" in levs
        local isspecial : list posof "`l'" in special
        local target .
        if `isspecial' {
            if `haspooled' local target = `pooled'
            else {
                modal_level `v', touse(`touse') exclude(`special')
                local target = r(level)
            }
        }
        else if "`kind'" == "ordered" {
            local excl `special' `pooled'
            local exclc : subinstr local excl " " ",", all
            quietly summarize `v' if `touse' & !inlist(`v', `exclc'), detail
            local med = r(p50)
            local up .
            local down .
            foreach x of local levs {
                local skipx : list posof "`x'" in excl
                if `skipx' continue
                if `x' > `l' & missing(`up') local up = `x'
                if `x' < `l' local down = `x'
            }
            if `l' < `med' local target = cond(!missing(`up'), `up', `down')
            else local target = cond(!missing(`down'), `down', `up')
        }
        else {
            if `l' == `pooled' {
                modal_level `v', touse(`touse') exclude(`pooled' `special')
                local target = r(level)
            }
            else local target = `pooled'
        }
        if missing(`target') | `target' == `l' continue, break
        quietly replace `v' = `target' if `v' == `l'
        post lv ("`v'") (`l') (`target') ("<`min'")
        local lbl : value label `v'
        if "`lbl'" != "" & `target' == `pooled' {
            capture label define `lbl' `pooled' "Khác (gộp)", add
        }
    }
end

* Hiệu ứng gián tiếp a*b cho bootstrap
capture program drop h3_ab
program define h3_ab, rclass
    quietly regress C S i.($XD)
    local a = _b[S]
    quietly regress phq4 C S i.($XD)
    return scalar ab = `a' * _b[C]
end

* VIF tổng quát cho nhóm biến giả (Fox & Monette, 1992)
mata:
real rowvector gvif(string scalar vars, string scalar touse, real rowvector sizes)
{
    real matrix X, R
    real scalar j, start, dR, k
    real rowvector out, idx, all, rest
    st_view(X=., ., tokens(vars), touse)
    R = correlation(X)
    dR = det(R)
    k = cols(R)
    all = 1..k
    out = J(1, cols(sizes), .)
    start = 1
    for (j = 1; j <= cols(sizes); j++) {
        idx = start..(start + sizes[j] - 1)
        rest = select(all, (all :< start) :| (all :> start + sizes[j] - 1))
        out[j] = det(R[idx, idx]) * det(R[rest, rest]) / dR
        start = start + sizes[j]
    }
    return(out)
}
end

* -----------------------------------------------------------------------------
* 1. Nhập dữ liệu và mã hóa
* -----------------------------------------------------------------------------
import excel using "$DATA", firstrow allstring clear
foreach v of varlist _all {
    quietly replace `v' = strtrim(`v')
}

rename _id resp_id
map_codes s1_age18,               gen(age18)     from(co khong) to(1 0)
map_codes s2_has_job,             gen(has_job)   from(co khong) to(1 0)
map_codes c17_lgbt_self_id,       gen(lgbt_self) from(co khong khong_chac kmtl) to(1 0 8 9)
map_codes c16_sexual_orientation, gen(orient)    from(di_tinh gay lesbian bisexual pansexual khac dang_tu_xd kmtl) to(1 2 3 4 5 6 7 9)
map_codes c15_gender_identity,    gen(gender_id) from(nam nu nam_ctg nu_ctg phi_nhi_nguyen khac kmtl) to(1 2 3 4 5 6 9)
map_codes c14_sex_assigned,       gen(sex_birth) from(nam nu kmtl) to(1 2 9)
map_codes c1_age_group,           gen(agegrp)    from(1824 2534 3544 4554 tu55 kmtl) to(1 2 3 4 4 9)
map_codes c2_education,           gen(educ)      from(thpt cd dh sdh kmtl) to(1 2 3 4 9)
map_codes c11_relationship,       gen(relstat)   from(doc_than co_bandoi ly_than kmtl) to(1 2 3 9)
map_codes c10_province,           gen(region)    from(hn hcm dn khac kmtl) to(1 2 3 4 9)
map_codes c3_experience,          gen(exper)     from(duoi1 13 35 510 tu10 kmtl) to(1 2 3 4 5 9)
map_codes c4_industry,            gen(industry)  from(tcnh cntt gd yt tmdv sxcn ttmkt dlnhks khac kmtl) to(1 2 3 4 5 6 7 10 11 9)
map_codes c5_position,            gen(position)  from(nv tn_gs qlct qlcc kad_khac kmtl) to(1 2 3 4 6 9)
map_codes c6_employment,          gen(emptype)   from(tt_luong bt_luong thoivu ctv freelancer khac kmtl) to(1 2 3 4 5 7 9)
map_codes c8_employer_type,       gen(orgtype)   from(nn tn_trongnuoc fdi ngo tudoanh khac kmtl) to(1 2 3 4 5 6 9)
map_codes c9_employer_size,       gen(orgsize)   from(duoi50 50199 200499 tu500 kad_kr kmtl) to(1 2 3 4 97 9)
map_codes c7_social_insurance,    gen(socins)    from(co khong kad kr kmtl) to(1 2 3 4 9)
map_codes c13_hours,              gen(hours)     from(duoi20 2035 3545 4555 tu55 kxd_kmtl) to(1 2 3 4 5 9)

* Câu 21: vị trí 3 là "buồn bã", vị trí 4 là "ít hứng thú"
destring c21_1, gen(phqi1)
destring c21_2, gen(phqi2)
destring c21_4, gen(phqi3)
destring c21_3, gen(phqi4)
forvalues j = 1/8 {
    destring c19_`j', gen(stig`j')
}
forvalues j = 1/4 {
    destring c22_`j', gen(conc`j')
    destring c24_`j', gen(dei`j')
}

keep resp_id age18 has_job lgbt_self orient gender_id $XD $XJ $PHQI $STIG8 $CONC $DEI

foreach v of global PHQI {
    assert inrange(`v', 0, 3) | missing(`v')
}
foreach v of global STIG8 {
    assert inrange(`v', 0, 4) | `v' == 9 | missing(`v')
}
foreach v of global CONC {
    assert inrange(`v', 1, 5) | missing(`v')
}
foreach v of global DEI {
    assert inrange(`v', 1, 5) | `v' == 9 | missing(`v')
}

label define yesno_lb   0 "Không" 1 "Có"
label define lgbtself_lb 0 "Không" 1 "Có" 8 "Không chắc" 9 "Không muốn trả lời"
label define orient_lb  1 "Dị tính" 2 "Đồng tính nam" 3 "Đồng tính nữ" 4 "Song tính" 5 "Toàn tính" ///
                        6 "Khác" 7 "Đang tự xác định" 9 "Không muốn trả lời"
label define gender_lb  1 "Nam" 2 "Nữ" 3 "Nam chuyển giới" 4 "Nữ chuyển giới" 5 "Phi nhị nguyên" ///
                        6 "Khác" 9 "Không muốn trả lời"
label define sex_lb     1 "Nam" 2 "Nữ" 9 "Không muốn trả lời"
label define age_lb     1 "18-24" 2 "25-34" 3 "35-44" 4 "45+" 9 "Không muốn trả lời"
label define educ_lb    1 "THPT trở xuống" 2 "Cao đẳng" 3 "Đại học" 4 "Sau đại học" 9 "Không muốn trả lời"
label define rel_lb     1 "Không có bạn đời" 2 "Có bạn đời" 3 "Ly thân/ly hôn/góa" 9 "Không muốn trả lời"
label define region_lb  1 "Hà Nội" 2 "TP.HCM" 3 "Đà Nẵng" 4 "Nơi khác" 9 "Không muốn trả lời"
label values age18 has_job yesno_lb
label values lgbt_self lgbtself_lb
label values orient orient_lb
label values gender_id gender_lb
label values sex_birth sex_lb
label values agegrp age_lb
label values educ educ_lb
label values relstat rel_lb
label values region region_lb

* -----------------------------------------------------------------------------
* 2. Biến dựng và cờ mẫu
* -----------------------------------------------------------------------------
gen byte eligible = (age18 == 1 & has_job == 1)
gen byte lgbt = .
replace lgbt = 1 if lgbt_self == 1
replace lgbt = 0 if lgbt_self == 0
label define lgbt_lb 0 "Non-LGBT" 1 "LGBT"
label values lgbt lgbt_lb
gen byte in_analytic = eligible & !missing(lgbt)

gen byte gender_minority = inlist(gender_id, 3, 4, 5, 6) if !missing(gender_id) & gender_id != 9
gen byte orient3 = .
replace orient3 = 1 if inlist(orient, 4, 5)
replace orient3 = 2 if orient == 3
replace orient3 = 3 if orient == 2
label define orient3_lb 1 "Song tính/toàn tính" 2 "Đồng tính nữ" 3 "Đồng tính nam"
label values orient3 orient3_lb

foreach v of varlist $STIG8 $DEI {
    replace `v' = . if `v' == 9
}
foreach v of global XD {
    gen `v'_alt = `v'
    replace `v'_alt = . if `v' == 9
}

egen byte phq_n = rownonmiss($PHQI)
gen byte phq4 = phqi1 + phqi2 + phqi3 + phqi4 if phq_n == 4
gen byte gad2 = phqi1 + phqi2 if !missing(phqi1, phqi2)
gen byte phq2 = phqi3 + phqi4 if !missing(phqi3, phqi4)
gen double phq4_frac = phq4 / 12
gen byte phq_ge6 = phq4 >= 6 if !missing(phq4)
gen byte phq4_zero = phq4 == 0 if !missing(phq4)

egen byte S_n = rownonmiss($STIG7)
egen double S_raw = rowmean($STIG7)
gen double S = S_raw if S_n >= 4 & lgbt == 1
egen byte S8_n = rownonmiss($STIG8)
egen double S8_raw = rowmean($STIG8)
gen double S8 = S8_raw if S8_n >= 4 & lgbt == 1
egen byte S_count7 = anycount($STIG7), values(1 2 3 4)
replace S_count7 = . if S_n < 4 | lgbt != 1
gen double S_complete7 = S if S_n == 7
forvalues j = 1/8 {
    gen byte stig`j'_any = stig`j' >= 1 if !missing(stig`j')
}
gen byte ever_exposed = S > 0 if !missing(S)
gen double S_exposed = cond(ever_exposed == 1, S, 0) if !missing(S)

egen byte C_n = rownonmiss($CONC)
egen double C_raw = rowmean($CONC)
gen double C = C_raw if C_n == 4 & lgbt == 1
egen byte C3_n = rownonmiss($CONC3)
egen double C3_raw = rowmean($CONC3)
gen double C3 = C3_raw if C3_n == 3 & lgbt == 1

egen byte Q_n = rownonmiss($DEI)
egen double Q_raw = rowmean($DEI)
gen double Q = Q_raw if Q_n >= 3

foreach sc in PHQI CONC DEI {
    egen double sd_`sc' = rowsd(${`sc'})
    egen byte n_`sc' = rownonmiss(${`sc'})
    local k : word count ${`sc'}
    gen byte flat_`sc' = (sd_`sc' == 0 & n_`sc' == `k')
}
gen byte flag_straight = flat_PHQI & flat_CONC & flat_DEI
gen byte flag_contra = (agegrp == 1 & position == 4)
gen byte flag_quality = flag_straight | flag_contra
drop sd_* n_PHQI n_CONC n_DEI flat_*

gen byte in_e3   = in_analytic & phq_n == 4
gen byte in_main = in_analytic & lgbt == 1 & !missing(phq4) & !missing(S)
local xdalt
foreach v of global XD {
    local xdalt `xdalt' `v'_alt
}
egen byte xd_miss  = rowmiss($XD)
egen byte xda_miss = rowmiss(`xdalt')
egen byte xj_miss  = rowmiss($XJ)
gen byte in_xd_main = in_main & xd_miss == 0
gen byte in_xd_alt  = in_main & xda_miss == 0
gen byte in_xj      = in_xd_main & xj_miss == 0
gen byte in_e5      = in_xd_main & !missing(Q)
drop xd_miss xda_miss xj_miss

quietly summarize Q if in_e5
gen double Qc = Q - r(mean) if !missing(Q)

quietly summarize S if in_main & S > 0, detail
scalar S_med_exposed = r(p50)
gen byte S3 = .
replace S3 = 0 if S == 0
replace S3 = 1 if S > 0 & S <= S_med_exposed & !missing(S)
replace S3 = 2 if S > S_med_exposed & !missing(S)
label define S3_lb 0 "Không gặp" 1 "Thấp" 2 "Cao"
label values S3 S3_lb

gen byte lgbt_consistent = lgbt == 1 & (inrange(orient, 2, 6) | gender_minority == 1)

* -----------------------------------------------------------------------------
* 3. Luồng mẫu
* -----------------------------------------------------------------------------
tempname F
tempfile flow
postfile `F' str48 buoc long(n_tong n_non n_lgbt ky_vong) using "`flow'", replace
quietly count
post `F' ("Tổng số phiếu") (r(N)) (.) (.) (850)
quietly count if eligible
post `F' ("Đủ điều kiện") (r(N)) (.) (.) (727)
foreach s in in_analytic in_e3 in_main in_xd_main in_xd_alt in_e5 {
    quietly count if `s'
    local a = r(N)
    quietly count if `s' & lgbt == 0
    local b = r(N)
    quietly count if `s' & lgbt == 1
    local c = r(N)
    if "`s'" == "in_analytic" post `F' ("Mẫu phân tích") (`a') (`b') (`c') (640)
    if "`s'" == "in_e3"       post `F' ("Đủ PHQ-4") (`a') (`b') (`c') (601)
    if "`s'" == "in_main"     post `F' ("Mẫu chính") (`a') (`b') (`c') (278)
    if "`s'" == "in_xd_main"  post `F' ("Mẫu chính, đủ XD (quy tắc chính)") (`a') (`b') (`c') (256)
    if "`s'" == "in_xd_alt"   post `F' ("Mẫu chính, đủ XD (quy tắc thay thế)") (`a') (`b') (`c') (247)
    if "`s'" == "in_e5"       post `F' ("Mẫu E5") (`a') (`b') (`c') (243)
}
postclose `F'
preserve
use "`flow'", clear
gen byte khop = n_tong == ky_vong
list, noobs abbreviate(20)
xl_out "LuongMau"
quietly count if !khop
local nmis = r(N)
restore
if `nmis' > 0 {
    di as error "Luồng mẫu khác đề cương ở `nmis' bước. Kiểm tra lại dữ liệu đầu vào."
    exit 9
}

* -----------------------------------------------------------------------------
* 4. Thống kê mô tả
* -----------------------------------------------------------------------------
tempfile t5
foreach v in agegrp sex_birth gender_minority orient educ relstat region {
    tabsafe `v' if in_e3, by(lgbt) saving("`t5'")
}
preserve
use "`t5'", clear
xl_out "MoTaMau"
restore

preserve
keep if in_e3
collapse (mean) tb_phq4=phq4 tb_gad2=gad2 tb_phq2=phq2 (sd) sd_phq4=phq4 sd_gad2=gad2 sd_phq2=phq2 ///
    (count) n=phq4 (mean) ty_le_0=phq4_zero, by(lgbt)
xl_out "TrieuChung"
restore

tempfile relfile
postfile rel str40 thang_do str12 mau double(alpha r_2cau) long N using "`relfile'", replace
rel_post $PHQI if in_e3, name("PHQ-4") sample("E3")
quietly corr phqi1 phqi2 if in_e3
post rel ("GAD-2") ("E3") (.) (r(rho)) (r(N))
quietly corr phqi3 phqi4 if in_e3
post rel ("PHQ-2") ("E3") (.) (r(rho)) (r(N))
rel_post $CONC if lgbt == 1 & in_analytic, name("Che giấu (4 câu)") sample("LGBT")
rel_post $DEI if in_analytic, name("DEI (4 câu)") sample("Phân tích")
rel_post $STIG7 if lgbt == 1 & in_analytic, name("Kỳ thị 7 câu (tham khảo)") sample("LGBT")
rel_post $STIG8 if lgbt == 1 & in_analytic, name("Kỳ thị 8 câu (tham khảo)") sample("LGBT")
postclose rel
preserve
use "`relfile'", clear
xl_out "DoTinCay"
restore

tempname P
tempfile prev
postfile `P' str8 tinh_huong long n_hop_le str12 n_gap str8 ty_le using "`prev'", replace
forvalues j = 1/8 {
    quietly count if in_main & !missing(stig`j'_any)
    local nv = r(N)
    quietly count if in_main & stig`j'_any == 1
    local na = r(N)
    local nshow = cond(`na' > 0 & `na' < $MIN_CELL, "<$MIN_CELL", string(`na'))
    local pshow = cond(`na' > 0 & `na' < $MIN_CELL, "", string(100 * `na' / `nv', "%5.1f"))
    post `P' ("stig`j'") (`nv') ("`nshow'") ("`pshow'")
}
postclose `P'
preserve
use "`prev'", clear
xl_out "TyLeKyThi"
restore

* Các biến nghiên cứu trong mẫu chính đủ XD: trung bình, độ lệch chuẩn, tương quan từng cặp
preserve
keep if in_xd_main
tempname MB
tempfile mbfile
postfile `MB' str12 bien long n double(tb sd trung_vi nho_nhat lon_nhat) using "`mbfile'", replace
foreach v in phq4 gad2 phq2 S C Q {
    quietly summarize `v', detail
    post `MB' ("`v'") (r(N)) (r(mean)) (r(sd)) (r(p50)) (r(min)) (r(max))
}
quietly count if S > 0
post `MB' ("ty_le_S>0") (r(N)) (100 * r(N) / _N) (.) (.) (.) (.)
quietly count if phq4 >= 6
post `MB' ("ty_le_PHQ>=6") (r(N)) (100 * r(N) / _N) (.) (.) (.) (.)
postclose `MB'
quietly pwcorr phq4 gad2 phq2 S C Q
matrix TQ = r(C)
use "`mbfile'", clear
xl_out "MoTaBien"
clear
svmat TQ, names(col)
gen str8 bien = ""
local i 0
foreach v in phq4 gad2 phq2 S C Q {
    local ++i
    quietly replace bien = "`v'" in `i'
}
order bien
xl_out "TuongQuan"
restore

* So sánh người thiếu và đủ dữ liệu
preserve
keep if in_analytic & lgbt == 1
gen byte co_phq4 = !missing(phq4)
collapse (mean) tb_S=S (count) n_S=S n=lgbt, by(co_phq4)
gen so_sanh = "LGBT phân tích: có / không có PHQ-4"
tempfile mis1
save "`mis1'"
restore
preserve
keep if in_main
collapse (mean) tb_phq4=phq4 tb_S=S (sd) sd_phq4=phq4 sd_S=S (count) n=phq4, by(in_xd_main)
gen so_sanh = "Mẫu chính: đủ / thiếu XD"
append using "`mis1'"
order so_sanh
xl_out "SoSanhKhuyet"
restore

* -----------------------------------------------------------------------------
* 5. Gộp mức thưa của biến kiểm soát
* -----------------------------------------------------------------------------
tempfile lvfile
postfile lv str24 bien double(muc_cu muc_moi) str8 so_nguoi using "`lvfile'", replace

foreach v of global XD {
    clonevar `v'_orig = `v'
}
local ordered $ORDERED
foreach v of global XD {
    local isord : list v in ordered
    local kind = cond(`isord', "ordered", "nominal")
    collapse_sparse `v', touse(in_xd_main) min($MIN_LEVEL) kind(`kind') special(9 97) pooled(98)
}
foreach v of local xdalt {
    local base = substr("`v'", 1, length("`v'") - 4)
    local isord : list base in ordered
    local kind = cond(`isord', "ordered", "nominal")
    collapse_sparse `v', touse(in_xd_alt) min($MIN_LEVEL) kind(`kind') special(9 97) pooled(98)
}
foreach v of global XJ {
    local isord : list v in ordered
    local kind = cond(`isord', "ordered", "nominal")
    collapse_sparse `v', touse(in_xj) min($MIN_LEVEL) kind(`kind') special(9 97) pooled(98)
}
postclose lv
preserve
use "`lvfile'", clear
if _N == 0 {
    set obs 1
    replace bien = "Không có mức nào cần gộp"
}
xl_out "GopMuc"
restore

* Bảng 6: PHQ-4 theo đặc điểm nhân khẩu học (mô tả, chưa có biến kỳ thị), sau khi gộp mức thưa
tempfile resfile
postfile res str20 part str16 outcome str60 spec str40 term double(b se lb ub p) long N str244 note ///
    using "`resfile'", replace
regress phq4 i.($XD) if in_xd_main, vce(hc3)
matrix RT = r(table)
local cn : colnames RT
foreach c of local cn {
    if "`c'" == "_cons" | strpos("`c'", "b.") continue
    post_coef, part("Bang6") outcome("phq4") spec("XD") coef(`c') table(RT)
}

if $RUN_MODELS == 0 {
    postclose res
    preserve
    use "`resfile'", clear
    xl_out "Bang6"
    restore
    di as result "Xong phần dữ liệu và mô tả. Kết quả: $OUT/ket_qua.xlsx"
    di as result "Để chạy mô hình: đặt global RUN_MODELS 1 rồi chạy lại."
    log close main
    exit
}

* -----------------------------------------------------------------------------
* 6. H1, H2a, H2b
* -----------------------------------------------------------------------------
foreach y in phq4 gad2 phq2 {
    local h = cond("`y'" == "phq4", "H1", cond("`y'" == "gad2", "H2a", "H2b"))

    regress `y' S i.($XD) if in_xd_main, vce(hc3)
    matrix RT = r(table)
    local mde = string(2.8 * _se[S], "%5.2f")
    post_coef, part("`h'") outcome("`y'") spec("XD") coef(S) table(RT) note("MDE ~ `mde'")

    if "`y'" == "phq4" {
        local df = e(df_r)
        local bS = _b[S]
        local seS = _se[S]
        local lo90 = `bS' - invttail(`df', 0.05) * `seS'
        local hi90 = `bS' + invttail(`df', 0.05) * `seS'
        local p1 = ttail(`df', (`bS' + $SESOI) / `seS')
        local p2 = 1 - ttail(`df', (`bS' - $SESOI) / `seS')
        local ptost = max(`p1', `p2')
        local kl = cond(`lo90' > -$SESOI & `hi90' < $SESOI, "tương đương", "không kết luận được tương đương")
        post_val, part("H1_TOST") outcome("phq4") spec("XD, CI 90%") coef("S") est(`bS') stderr(`seS') ///
            lower(`lo90') upper(`hi90') pval(`ptost') nobs(`e(N)') note("SESOI +/-$SESOI; `kl'")
    }

    regress `y' S i.($XD) i.($XJ) if in_xj, vce(hc3)
    post_coef, part("`h'") outcome("`y'") spec("XD + XJ") coef(S)
}
regress phq4 S i.(`xdalt') if in_xd_alt, vce(hc3)
post_coef, part("H1") outcome("phq4") spec("XD, PNTA = missing") coef(S)

* -----------------------------------------------------------------------------
* 7. H3: kỳ thị -> che giấu -> PHQ-4
* -----------------------------------------------------------------------------
foreach cv in C C3 {
    gen byte h3s = in_xd_main & !missing(`cv')
    regress `cv' S i.($XD) if h3s, vce(hc3)
    matrix RA = r(table)
    local pa = RA[4, colnumb(RA, "S")]
    local apos = RA[1, colnumb(RA, "S")] > 0
    post_coef, part("H3_a") outcome("`cv'") spec("`cv'") coef(S) table(RA)

    regress phq4 `cv' S i.($XD) if h3s, vce(hc3)
    matrix RB = r(table)
    local pb = RB[4, colnumb(RB, "`cv'")]
    local bpos = RB[1, colnumb(RB, "`cv'")] > 0
    post_coef, part("H3_b") outcome("phq4") spec("`cv'") coef(`cv') table(RB)
    post_coef, part("H3_c") outcome("phq4") spec("`cv'") coef(S) table(RB)

    quietly count if h3s
    post_val, part("H3") outcome("phq4") spec("`cv'") coef("max(p_a, p_b)") pval(`=max(`pa', `pb')') ///
        nobs(`r(N)') note("a>0: `apos'; b>0: `bpos'")
    drop h3s
}

* Lỗi ở bước này không được làm dừng phần sau, và dữ liệu luôn được khôi phục
preserve
keep if in_xd_main & !missing(C)
capture noisily {
    bootstrap ab = r(ab), reps($BOOT_REPS) seed($SEED) nodots: h3_ab
    estat bootstrap, percentile
    matrix CI = e(ci_percentile)
    local bab = _b[ab]
    local lab = CI[1,1]
    local uab = CI[2,1]
    local nab = e(N)
}
local rc = _rc
restore
if `rc' == 0 {
    post_val, part("H3_ab") outcome("phq4") spec("bootstrap percentile") coef("a*b") ///
        est(`bab') lower(`lab') upper(`uab') nobs(`nab') note("$BOOT_REPS lần; chỉ cho tài liệu bổ sung")
}
else {
    post_val, part("H3_ab") outcome("phq4") spec("bootstrap percentile") coef("a*b") note("Lỗi Stata `rc'")
}

* -----------------------------------------------------------------------------
* 8. Phân tích thăm dò E1-E5
* -----------------------------------------------------------------------------
* E3: phân bố PHQ-4 theo ba nhóm (chỉ mô tả)
gen byte e3_group = .
replace e3_group = 0 if in_e3 & lgbt == 0
replace e3_group = 1 if in_e3 & lgbt == 1 & ever_exposed == 0
replace e3_group = 2 if in_e3 & lgbt == 1 & ever_exposed == 1
label define e3_lb 0 "Non-LGBT" 1 "LGBT, chưa gặp kỳ thị" 2 "LGBT, đã gặp kỳ thị"
label values e3_group e3_lb
preserve
keep if !missing(e3_group)
collapse (mean) tb=phq4 (sd) sd=phq4 (p50) trung_vi=phq4 (mean) ty_le_ge6=phq_ge6 (count) n=phq4, by(e3_group)
replace ty_le_ge6 = 100 * ty_le_ge6
decode e3_group, gen(nhom)
drop e3_group
order nhom
xl_out "E3"
restore

* E1: ba mức kỳ thị
regress phq4 i.S3 i.($XD) if in_xd_main, vce(hc3)
matrix RT = r(table)
post_coef, part("E1") outcome("phq4") spec("thấp so với không gặp") coef(1.S3) table(RT)
post_coef, part("E1") outcome("phq4") spec("cao so với không gặp") coef(2.S3) table(RT)

* E2: từng tình huống; tình huống có dưới MIN_CELL người ở một nhóm thì không ước lượng
forvalues j = 1/8 {
    quietly count if in_xd_main & stig`j'_any == 1
    local nexp = r(N)
    quietly count if in_xd_main & stig`j'_any == 0
    local nun = r(N)
    if `nexp' < $MIN_CELL | `nun' < $MIN_CELL {
        post_val, part("E2_bo_qua") outcome("phq4") spec("stig`j'") coef("1.stig`j'_any") ///
            note("Dưới $MIN_CELL người ở một nhóm")
        continue
    }
    regress phq4 i.stig`j'_any i.($XD) if in_xd_main, vce(hc3)
    post_coef, part("E2") outcome("phq4") spec("stig`j'") coef(1.stig`j'_any)
}

* E2 đối chiếu: tình huống phụ thuộc quy nguyên so với tình huống sự kiện
quietly count if in_xd_main & stig4_any == 1
local attr "stig5 stig6"
if r(N) >= $MIN_CELL local attr "stig4 stig5 stig6"
egen double S_attr  = rowmean(`attr')
egen double S_event = rowmean(stig1 stig2 stig3 stig7)
regress phq4 S_event S_attr i.($XD) if in_xd_main, vce(hc3)
matrix RT = r(table)
local nE = e(N)
post_coef, part("E2_doi_chieu") outcome("phq4") spec("sự kiện") coef(S_event) table(RT)
post_coef, part("E2_doi_chieu") outcome("phq4") spec("quy nguyên") coef(S_attr) table(RT) note("`attr'")
lincom S_attr - S_event
post_val, part("E2_doi_chieu") outcome("phq4") spec("quy nguyên - sự kiện") coef("hiệu") ///
    est(`r(estimate)') stderr(`r(se)') lower(`r(lb)') upper(`r(ub)') pval(`r(p)') nobs(`nE')

* Lo âu so với trầm cảm: kiểm định trực tiếp hiệu hai hệ số
quietly regress gad2 S i.($XD) if in_xd_main
estimates store m_gad
quietly regress phq2 S i.($XD) if in_xd_main
estimates store m_phq
suest m_gad m_phq, vce(robust)
local nE = e(N)
lincom [m_gad_mean]S - [m_phq_mean]S
post_val, part("E_lo_au_tram_cam") outcome("gad2 - phq2") spec("suest") coef("S") ///
    est(`r(estimate)') stderr(`r(se)') lower(`r(lb)') upper(`r(ub)') pval(`r(p)') nobs(`nE')
estimates drop m_gad m_phq

* E4: theo giới tính khi sinh và nhóm xu hướng tính dục
local xd_all $XD
local sx_one sex_birth
local xd_nosex : list xd_all - sx_one
regress phq4 ib1.sex_birth##c.S i.(`xd_nosex') if in_xd_main & sex_birth_orig != 9, vce(hc3)
post_coef, part("E4") outcome("phq4") spec("S x nữ (giới tính khi sinh)") coef(2.sex_birth#c.S)
regress phq4 ib1.orient3##c.S i.($XD) if in_xd_main & !missing(orient3), vce(hc3)
matrix RT = r(table)
post_coef, part("E4") outcome("phq4") spec("S x đồng tính nữ") coef(2.orient3#c.S) table(RT)
post_coef, part("E4") outcome("phq4") spec("S x đồng tính nam") coef(3.orient3#c.S) table(RT)

* E5: mức thực thi DEI được cảm nhận
regress phq4 c.S##c.Qc i.($XD) if in_e5, vce(hc3)
matrix RT = r(table)
post_coef, part("E5") outcome("phq4") spec("S x DEI") coef(c.S#c.Qc) table(RT)
post_coef, part("E5_phu") outcome("phq4") spec("S tại DEI trung bình") coef(S) table(RT)
post_coef, part("E5_phu") outcome("phq4") spec("DEI khi S = 0") coef(Qc) table(RT)

* -----------------------------------------------------------------------------
* 9. Chẩn đoán mô hình H1 (chỉ để mô tả)
* -----------------------------------------------------------------------------
tempname D
tempfile diag
postfile `D' str40 kiem_dinh double(thong_ke df p) str60 ghi_chu using "`diag'", replace
quietly regress phq4 S i.($XD) if in_xd_main
local nD = e(N)
local kD = e(df_m) + 1
quietly estat hettest
post `D' ("Breusch-Pagan") (r(chi2)) (r(df)) (r(p)) ("")
quietly estat ovtest
post `D' ("Ramsey RESET") (r(F)) (r(df)) (r(p)) ("F(" + string(r(df)) + "," + string(r(df_r)) + ")")
predict double cook if e(sample), cooksd
predict double lev if e(sample), leverage
gen byte flag_cook = cook > 4 / `nD' if !missing(cook)
gen byte flag_lev  = lev > 2 * `kD' / `nD' if !missing(lev)
quietly count if flag_cook == 1
post `D' ("Số quan sát Cook > 4/n") (r(N)) (.) (.) ("")
quietly count if flag_lev == 1
post `D' ("Số quan sát đòn bẩy > 2k/n") (r(N)) (.) (.) ("")
quietly summarize lev
post `D' ("Đòn bẩy lớn nhất") (r(max)) (.) (.) ("")

local gvars S
local gsizes 1
local gnames S
foreach v of global XD {
    quietly tab `v' if in_xd_main, gen(gv_`v'_)
    drop gv_`v'_1
    unab dv : gv_`v'_*
    local k : word count `dv'
    local gvars `gvars' `dv'
    local gsizes `gsizes' `k'
    local gnames `gnames' `v'
}
gen byte gv_touse = in_xd_main
local szc : subinstr local gsizes " " ",", all
mata: st_matrix("GV", gvif("`gvars'", "gv_touse", (`szc')))
local j 0
foreach nm of local gnames {
    local ++j
    local dfj : word `j' of `gsizes'
    post `D' ("GVIF `nm'") (GV[1,`j']) (`dfj') (.) ("GVIF^(1/(2df)) = " + string(GV[1,`j']^(1/(2*`dfj')), "%5.3f"))
}
drop gv_*
postclose `D'
preserve
use "`diag'", clear
xl_out "ChanDoan"
restore

* -----------------------------------------------------------------------------
* 10. Kiểm tra độ bền
* -----------------------------------------------------------------------------
regress phq4 i.ever_exposed S_exposed i.($XD) if in_xd_main, vce(hc3)
matrix RT = r(table)
post_coef, part("Ben_vung") outcome("phq4") spec("đã gặp kỳ thị") coef(1.ever_exposed) table(RT)
post_coef, part("Ben_vung") outcome("phq4") spec("cường độ trong số đã gặp") coef(S_exposed) table(RT)

quietly _pctile S if in_xd_main & S > 0, percentiles(10 50 90)
local k1 = r(r1)
local k2 = r(r2)
local k3 = r(r3)
if `k1' < `k2' & `k2' < `k3' {
    mkspline Ssp = S, cubic knots(`k1' `k2' `k3')
    regress phq4 Ssp1 Ssp2 i.($XD) if in_xd_main, vce(hc3)
    matrix RT = r(table)
    test Ssp2
    local pnl = string(r(p), "%5.3f")
    post_coef, part("Ben_vung") outcome("phq4") spec("spline bậc ba") coef(Ssp1) table(RT) ///
        note("Kiểm định phi tuyến: p = `pnl'")
}
else {
    post_val, part("Ben_vung") outcome("phq4") spec("spline bậc ba") coef("-") note("Các nút trùng nhau")
}

fracreg logit phq4_frac S i.($XD) if in_xd_main
local nF = e(N)
margins, dydx(S) post
nlcom (ame12: _b[S] * 12), post
post_val, part("Ben_vung") outcome("phq4") spec("fracreg logit, AME x 12") coef("S") ///
    est(`=_b[ame12]') stderr(`=_se[ame12]') lower(`=_b[ame12] - invnormal(0.975) * _se[ame12]') ///
    upper(`=_b[ame12] + invnormal(0.975) * _se[ame12]') pval(`=2 * normal(-abs(_b[ame12] / _se[ame12]))') nobs(`nF')

regress phq4 S i.($XD) if in_xd_main & flag_quality == 0, vce(hc3)
post_coef, part("Ben_vung") outcome("phq4") spec("bỏ phiếu chất lượng thấp") coef(S)

regress phq4 S i.($XD) if in_xd_main & flag_cook != 1, vce(hc3)
post_coef, part("Ben_vung") outcome("phq4") spec("bỏ quan sát Cook > 4/n") coef(S)

regress phq4 S i.($XD) if in_xd_main, vce(robust)
local nW = e(N)
local bW = _b[S]
capture noisily boottest S, reps($WILD_REPS) weighttype(webb) seed($SEED) nograph
if !_rc {
    local pW = r(p)
    local loW = .
    local hiW = .
    capture matrix WCI = r(CI)
    if !_rc {
        local loW = WCI[1,1]
        local hiW = WCI[1,2]
    }
    post_val, part("Ben_vung") outcome("phq4") spec("wild bootstrap, Webb") coef("S") ///
        est(`bW') lower(`loW') upper(`hiW') pval(`pW') nobs(`nW') note("$WILD_REPS lần")
}
else {
    post_val, part("Ben_vung") outcome("phq4") spec("wild bootstrap, Webb") coef("S") note("Lỗi Stata `=_rc'")
}

gen byte orient4 = orient3
replace orient4 = 4 if missing(orient3) & in_main
regress phq4 S i.($XD) i.orient4 if in_xd_main, vce(hc3)
post_coef, part("Ben_vung") outcome("phq4") spec("thêm xu hướng tính dục vào XD") coef(S)

preserve
keep if in_analytic & lgbt == 1
capture noisily {
    mi set wide
    mi register imputed phq4 S C Q $XD
    mi impute chained (pmm, knn(5)) phq4 S C Q (mlogit, augment) $XD, add($MI_M) rseed($SEED)
    mi estimate, post: regress phq4 S i.($XD), vce(hc3)
    matrix DFM = e(df_mi)
    local dfS = DFM[1, colnumb(DFM, "S")]
    local bM = _b[S]
    local seM = _se[S]
    local nM = e(N)
    local dfS_s : display %6.1f `dfS'
}
local rc = _rc
restore
if `rc' == 0 {
    post_val, part("Ben_vung") outcome("phq4") spec("gán giá trị đa lần, m = $MI_M") coef("S") ///
        est(`bM') stderr(`seM') lower(`=`bM' - invttail(`dfS', 0.025) * `seM'') ///
        upper(`=`bM' + invttail(`dfS', 0.025) * `seM'') pval(`=2 * ttail(`dfS', abs(`bM' / `seM'))') ///
        nobs(`nM') note("df = `dfS_s'")
}
else {
    post_val, part("Ben_vung") outcome("phq4") spec("gán giá trị đa lần, m = $MI_M") coef("S") note("Lỗi Stata `rc'")
}

* sensemakr chỉ in kết quả ra nhật ký
preserve
keep if in_xd_main
local xd_dum
foreach v of global XD {
    quietly tab `v', gen(sx_`v'_)
    drop sx_`v'_1
    unab these : sx_`v'_*
    local xd_dum `xd_dum' `these'
}
unab sexd : sx_sex_birth_*
unab educd : sx_educ_*
foreach g in sex_birth educ {
    local gb = cond("`g'" == "educ", "`educd'", "`sexd'")
    di as text _n "{hline 60}" _n "sensemakr, mốc so sánh: `g'" _n "{hline 60}"
    capture noisily sensemakr phq4 S `xd_dum', treat(S) gbenchmark(`gb') gname(`g') kd(1 2 3)
    if _rc capture noisily sensemakr phq4 `xd_dum', treat(S) gbenchmark(`gb') gname(`g') kd(1 2 3)
}
restore

* -----------------------------------------------------------------------------
* 11. Đường cong đặc tả (32 đặc tả)
* -----------------------------------------------------------------------------
tempname SP
tempfile specfile
postfile `SP' str40 dac_ta double(b se lb ub p sd_chi_so) long N using "`specfile'", replace
foreach idx in S S8 S_count7 S_complete7 {
foreach ctl in XD XDXJ {
foreach def in self consistent {
foreach tg in keep drop {
    local cond "in_analytic & !missing(phq4) & !missing(`idx')"
    if "`def'" == "self"       local cond "`cond' & lgbt == 1"
    if "`def'" == "consistent" local cond "`cond' & lgbt_consistent == 1"
    if "`tg'" == "drop"        local cond "`cond' & gender_minority != 1"
    local rhs "i.($XD)"
    if "`ctl'" == "XDXJ" local rhs "`rhs' i.($XJ)"
    capture noisily regress phq4 `idx' `rhs' if `cond', vce(hc3)
    if _rc continue
    matrix RT = r(table)
    local j = colnumb(RT, "`idx'")
    local nS = e(N)
    quietly summarize `idx' if e(sample)
    post `SP' ("`idx'|`ctl'|`def'|`tg'") (RT[1,`j']) (RT[2,`j']) (RT[5,`j']) (RT[6,`j']) (RT[4,`j']) (r(sd)) (`nS')
}
}
}
}
postclose `SP'
preserve
use "`specfile'", clear
gen double b_sd  = b * sd_chi_so
gen double lb_sd = lb * sd_chi_so
gen double ub_sd = ub * sd_chi_so
gen byte chinh = dac_ta == "S|XD|self|keep"
sort b_sd
gen thu_tu = _n
twoway (rcap lb_sd ub_sd thu_tu, lcolor(gs10)) ///
       (scatter b_sd thu_tu if !chinh, mcolor(navy) msize(small)) ///
       (scatter b_sd thu_tu if chinh, mcolor(cranberry) msymbol(D)), ///
       yline(0, lpattern(dash)) ytitle("Chênh lệch PHQ-4 trên 1 SD chỉ số kỳ thị") ///
       xtitle("Đặc tả (sắp theo ước lượng)") legend(order(2 "Đặc tả khác" 3 "Đặc tả chính")) ///
       graphregion(color(white))
graph export "$OUT/spec_curve.png", replace width(2000)
xl_out "DuongCongDacTa"
restore

* -----------------------------------------------------------------------------
* 12. Hiệu chỉnh kiểm định đa lần và xuất kết quả
* -----------------------------------------------------------------------------
postclose res
preserve
use "`resfile'", clear
gen str8 ho_holm = ""
replace ho_holm = "phu" if inlist(part, "H2a", "H2b") & spec == "XD"
replace ho_holm = "phu" if part == "H3" & spec == "C"
gen double p_tmp = p if ho_holm != ""
padjust p_tmp, gen(p_holm) method(holm)
drop p_tmp
gen str8 ho_bh = ""
replace ho_bh = "E2" if part == "E2"
replace ho_bh = "E4" if part == "E4"
gen double p_tmp = p if ho_bh != ""
padjust p_tmp, gen(p_bh) method(bh) by(ho_bh)
drop p_tmp ho_holm ho_bh
order part outcome spec term b se lb ub p p_holm p_bh N note
xl_out "KetQua"
restore

di as result "Xong. Kết quả: $OUT/ket_qua.xlsx"
log close main

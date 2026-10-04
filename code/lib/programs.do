* =============================================================================
* programs.do — chương trình dùng chung. Được 00_master.do nạp một lần.
* =============================================================================

* -----------------------------------------------------------------------------
* results_open / results_close: tệp kết quả hệ số dùng chung một cấu trúc
*   results_open res_main  -> postfile handle tên res_main, lưu $DERIVED/res_main.dta
* -----------------------------------------------------------------------------
capture program drop results_open
program define results_open
    args name
    capture postclose `name'
    postfile `name' str24 analysis str12 depvar str32 spec str48 coef ///
        double(b se lb ub p) long N str120 note ///
        using "$DERIVED/`name'.dta", replace
end

capture program drop results_close
program define results_close
    args name
    postclose `name'
    preserve
    use "$DERIVED/`name'.dta", clear
    export delimited using "$TAB/`name'.csv", replace
    restore
end

* -----------------------------------------------------------------------------
* post_coef: ghi một hệ số từ r(table) của lệnh ước lượng vừa chạy.
*   Dùng được sau regress, fracreg, mi estimate, margins (đều trả r(table)).
*   Gọi NGAY sau lệnh ước lượng, trước bất kỳ lệnh r-class nào khác; hoặc lưu
*   matrix RT = r(table) rồi truyền table(RT).
* -----------------------------------------------------------------------------
capture program drop post_coef
program define post_coef
    syntax , Handle(name) Coef(string) Analysis(string) Depvar(string) ///
        Spec(string) [Note(string) Nobs(real -1) Table(name)]
    tempname T
    if "`table'" != "" matrix `T' = `table'
    else matrix `T' = r(table)
    local j = colnumb(`T', "`coef'")
    if missing(`j') {
        di as error "post_coef: không thấy hệ số `coef' trong r(table)"
        matrix list `T'
        exit 111
    }
    local N = cond(`nobs' >= 0, `nobs', e(N))
    post `handle' ("`analysis'") ("`depvar'") ("`spec'") ("`coef'") ///
        (`T'[1,`j']) (`T'[2,`j']) (`T'[5,`j']) (`T'[6,`j']) (`T'[4,`j']) ///
        (`N') (`"`note'"')
end

* -----------------------------------------------------------------------------
* post_bse: ghi một hệ số từ _b/_se (sau nlcom, post hoặc mi estimate, post)
*   df(.) -> dùng phân phối chuẩn
* -----------------------------------------------------------------------------
capture program drop post_bse
program define post_bse
    syntax , Handle(name) Coef(string) Analysis(string) Depvar(string) ///
        Spec(string) [DF(real .) Note(string) Nobs(real -1)]
    local b = _b[`coef']
    local se = _se[`coef']
    if missing(`df') {
        local crit = invnormal(0.975)
        local p = 2 * normal(-abs(`b' / `se'))
    }
    else {
        local crit = invttail(`df', 0.025)
        local p = 2 * ttail(`df', abs(`b' / `se'))
    }
    local N = cond(`nobs' >= 0, `nobs', e(N))
    post `handle' ("`analysis'") ("`depvar'") ("`spec'") ("`coef'") ///
        (`b') (`se') (`b' - `crit' * `se') (`b' + `crit' * `se') (`p') ///
        (`N') (`"`note'"')
end

* -----------------------------------------------------------------------------
* post_value: ghi một giá trị tự tính (không có SE), ví dụ p giao–hợp của H3
* -----------------------------------------------------------------------------
capture program drop post_value
program define post_value
    syntax , Handle(name) Analysis(string) Depvar(string) Spec(string) ///
        Coef(string) [B(real .) SE(real .) LB(real .) UB(real .) P(real .) ///
        Nobs(real .) Note(string)]
    post `handle' ("`analysis'") ("`depvar'") ("`spec'") ("`coef'") ///
        (`b') (`se') (`lb') (`ub') (`p') (`nobs') (`"`note'"')
end

* -----------------------------------------------------------------------------
* padjust: hiệu chỉnh p theo họ (Holm 1979; Benjamini–Hochberg 1995)
*   padjust p, gen(p_holm) method(holm) by(family)
* -----------------------------------------------------------------------------
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
    else if "`method'" == "bh" {
        gen double `raw' = min(1, `m' / `ord' * `varlist') if !missing(`varlist')
        gen long `rev' = -`ord'
        bysort `grp' (`rev'): replace `raw' = min(`raw', `raw'[_n-1]) ///
            if _n > 1 & !missing(`raw') & !missing(`raw'[_n-1])
    }
    else {
        di as error "padjust: method() phải là holm hoặc bh"
        exit 198
    }
    gen double `generate' = `raw'
end

* -----------------------------------------------------------------------------
* tabsafe: bảng tần số theo nhóm, ẩn ô < $MIN_CELL (kèm ẩn thứ cấp),
*          nối vào một CSV.
*   tabsafe agegrp if in_e3, by(lgbt) saving("$TAB/T5_sample.csv") [append]
* -----------------------------------------------------------------------------
capture program drop tabsafe
program define tabsafe
    syntax varname [if], BY(varname) SAVing(string) [APPend]
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
        * ẩn thứ cấp: nếu trong một nhóm chỉ có đúng một ô bị ẩn, ẩn thêm ô
        * khác 0 nhỏ nhất còn lại để không suy ngược được từ tổng
        bysort _group: egen n_supp = total(suppressed)
        gen double _key = cond(suppressed | n == 0, ., n)
        bysort _group (_key): replace suppressed = 1 if n_supp == 1 & _n == 1 & !missing(_key)
        gen str12 n_show = string(n)
        replace n_show = "<$MIN_CELL" if suppressed
        gen str8 pct_show = cond(suppressed, "", string(pct, "%5.1f"))
        gen str12 total_show = string(total)
        gen str32 variable = "`varlist'"
        if "`vlab'" != "" {
            label values _level `vlab'
            decode _level, gen(level)
        }
        else gen str32 level = string(_level)
        if "`blab'" != "" {
            label values _group `blab'
            decode _group, gen(group)
        }
        else gen str32 group = string(_group)
        keep variable group level n_show pct_show total_show
        order variable group level n_show pct_show total_show
    }
    if "`append'" != "" {
        capture confirm file "`saving'"
        if !_rc {
            tempfile new
            save `new'
            import delimited using "`saving'", clear varnames(1) stringcols(_all)
            append using `new'
        }
    }
    export delimited using "`saving'", replace
    restore
end

* -----------------------------------------------------------------------------
* gvif: VIF tổng quát cho các nhóm biến giả (Fox & Monette, 1992)
*   gvif_calc, vars(biến_1 ... biến_k) sizes(1 3 1 ...) names(S agegrp ...) touse(var)
*   GVIF_j = det(R_jj) * det(R_-j,-j) / det(R)
* -----------------------------------------------------------------------------
mata:
mata clear
real rowvector _gvif(string scalar vars, string scalar touse, real rowvector sizes)
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

capture program drop gvif_calc
program define gvif_calc, rclass
    syntax , Vars(string) Sizes(numlist) Names(string) Touse(varname)
    local sz : subinstr local sizes " " ",", all
    mata: st_matrix("_G", _gvif("`vars'", "`touse'", (`sz')))
    local k : word count `names'
    matrix colnames _G = `names'
    matrix list _G, format(%9.3f) title("GVIF")
    return matrix gvif = _G
end

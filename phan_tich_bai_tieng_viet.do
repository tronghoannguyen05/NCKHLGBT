* =============================================================================
* Chính sách DEI tại nơi làm việc, kỳ thị và sức khỏe tâm thần của người lao
* động LGBT ở Việt Nam: phân tích thăm dò và hàm ý chính sách
*
* Mã tái lập cho mọi bảng của bài tiếng Việt (Tạp chí Nghiên cứu Con người,
* Gia đình và Giới). Kế hoạch phân tích: docs/bai_tieng_viet/ke_hoach_phan_tich.md.
* Bài tiếng Anh dùng do-file riêng (phan_tich.do); hai tệp chỉ dùng chung dữ liệu.
*
* Yêu cầu    Stata 17 trở lên. Không cần gói cài thêm.
* Đầu vào    Bản xuất khảo sát (.xlsx), không chỉnh sửa. Dữ liệu chứa thông tin
*            cá nhân nhạy cảm và không công khai. Ngay sau khi đọc, chỉ giữ các
*            biến dùng trong phân tích; không giữ câu trả lời tự do nào.
* Đầu ra     ket_qua.xlsx   mỗi bảng của bài một sheet
*            nhat_ky.log    nhật ký đầy đủ
*
* Cách chạy  1. Để tệp này và bản xuất khảo sát trong cùng thư mục dự án; bản
*               xuất có thể nằm ngay trong thư mục hoặc trong data/raw/.
*            2. Mở Stata bằng cách bấm đúp vào tệp này, hoặc đặt thư mục làm
*               việc là thư mục dự án (File > Change Working Directory), rồi
*               chạy toàn bộ tệp.
*            Không cần sửa đường dẫn. Kết quả ghi vào output/results_vi/.
* =============================================================================

version 17
clear all
set more off
set varabbrev off
set linesize 120

* -----------------------------------------------------------------------------
* 0. Thiết lập
* -----------------------------------------------------------------------------
* Vị trí dữ liệu và thư mục kết quả. Để trống thì được tìm tự động (xem "Tìm
* dữ liệu" bên dưới). Muốn tự đặt thì bỏ dấu sao ở hai dòng ví dụ và sửa đường dẫn.
global ROOT ""
global DATA ""
global OUT  ""
* global DATA "D:/du_an/data/raw/ban_xuat_khao_sat.xlsx"
* global OUT  "D:/du_an/output/results_vi"

global MIN_CELL  10          // kiểm soát nhận diện: ô nhỏ nhất được báo cáo
global MIN_LEVEL 5           // mức của biến kiểm soát dưới cỡ này được gộp

* Biến kiểm soát: tám nhóm đặc điểm có trước phơi nhiễm (XD); mô hình DEI thêm
* loại hình và quy mô tổ chức (ORG)
global XD      "agegrp educ sex_birth gmin orientg relstat region industry"
global ORG     "orgtype orgsize"
global ORDERED "agegrp educ orgsize"
global PHQI    "phqi1 phqi2 phqi3 phqi4"
global STIG8   "stig1 stig2 stig3 stig4 stig5 stig6 stig7 stig8"
global STIG_I  "stig1 stig2 stig3"
global STIG_C  "stig4 stig5 stig6"
global STIG_G  "stig7 stig8"
global DEI     "dei1 dei2 dei3 dei4"
global POL     "pol1 pol2 pol3 pol4 pol5"

* -----------------------------------------------------------------------------
* Tìm dữ liệu
* -----------------------------------------------------------------------------
* Tìm trong thư mục làm việc và tối đa ba thư mục phía trên; ở mỗi thư mục, lần
* lượt data/raw/, data/ rồi chính thư mục đó. Chỉ nhận tệp .xlsx có các biến của
* bản xuất khảo sát, nên các tệp Excel khác bị bỏ qua. Thư mục tìm thấy là thư
* mục dự án (ROOT). Không tìm thấy thì Stata mở hộp thoại chọn tệp.
if `"$DATA"' == "" {
    local dir `"`c(pwd)'"'
    local dir : subinstr local dir "\" "/", all
    local found 0
    forvalues up = 0/3 {
        foreach sub in "data/raw" "data" "." {
            local folder = cond("`sub'" == ".", `"`dir'"', `"`dir'/`sub'"')
            local files
            capture local files : dir `"`folder'"' files "*.xlsx", respectcase
            foreach f of local files {
                if substr(`"`f'"', 1, 1) == "~" continue
                capture import excel using `"`folder'/`f'"', firstrow allstring clear
                if _rc continue
                capture confirm variable s1_age18 s2_has_job c17_lgbt_self_id c19_1 c21_1 c23_1
                if !_rc {
                    global DATA `"`folder'/`f'"'
                    global ROOT `"`dir'"'
                    local found 1
                    continue, break
                }
            }
            if `found' continue, break
        }
        if `found' continue, break
        local cut = strrpos(`"`dir'"', "/")
        if `cut' <= 1 continue, break
        local dir = substr(`"`dir'"', 1, `cut' - 1)
    }
    clear
}
if `"$DATA"' == "" & c(mode) != "batch" {
    capture window fopen DATA "Chọn bản xuất khảo sát (.xlsx)" "Excel workbook (*.xlsx)|*.xlsx" xlsx
}
if `"$DATA"' == "" {
    display as error "Không tìm thấy bản xuất khảo sát. Đặt tệp .xlsx vào thư mục dự án hoặc thư mục"
    display as error "data/raw/ của nó, mở Stata bằng cách bấm đúp vào phan_tich_bai_tieng_viet.do (hoặc"
    display as error "đặt thư mục làm việc là thư mục dự án), rồi chạy lại."
    exit 601
}
global DATA : subinstr global DATA "\" "/", all
confirm file `"$DATA"'
if `"$ROOT"' == "" {
    * Dữ liệu được chọn tay hoặc qua hộp thoại: thư mục dự án là thư mục chứa
    * tệp dữ liệu, hoặc thư mục phía trên data/raw/ hay data/
    local cut = strrpos(`"$DATA"', "/")
    if `cut' > 0 local dir = substr(`"$DATA"', 1, `cut' - 1)
    else local dir `"`c(pwd)'"'
    local dir : subinstr local dir "\" "/", all
    if substr(`"`dir'"', -9, .) == "/data/raw" local dir = substr(`"`dir'"', 1, strlen(`"`dir'"') - 9)
    else if substr(`"`dir'"', -5, .) == "/data" local dir = substr(`"`dir'"', 1, strlen(`"`dir'"') - 5)
    global ROOT `"`dir'"'
}
if `"$OUT"' == "" global OUT `"$ROOT/output/results_vi"'
global OUT : subinstr global OUT "\" "/", all
local cut = strrpos(`"$OUT"', "/")
if `cut' > 1 {
    local parent = substr(`"$OUT"', 1, `cut' - 1)
    capture mkdir `"`parent'"'
}
capture mkdir `"$OUT"'
mata: st_local("out_ok", strofreal(direxists(st_global("OUT"))))
if !`out_ok' {
    display as error `"Không tạo được thư mục kết quả $OUT"'
    exit 603
}

capture log close _all
log using `"$OUT/nhat_ky.log"', replace text name(vi)
display "Stata " c(stata_version) ", " c(current_date) " " c(current_time)
display `"Dữ liệu: $DATA"'
display `"Kết quả: $OUT"'

capture erase `"$OUT/ket_qua.xlsx"'
capture confirm file `"$OUT/ket_qua.xlsx"'
if !_rc {
    display as error "Hãy đóng ket_qua.xlsx trong Excel rồi chạy lại."
    exit 608
}

* -----------------------------------------------------------------------------
* Chương trình
* -----------------------------------------------------------------------------

* Mã hóa một biến chuỗi theo danh sách mã; dừng nếu có mã chưa được ánh xạ
capture program drop map_codes
program define map_codes
    syntax varname(string), GENerate(name) FROM(string) TO(numlist)
    local nf : word count `from'
    local nt : word count `to'
    if `nf' != `nt' {
        display as error "map_codes `varlist': from() và to() không cùng độ dài"
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
        display as error "map_codes: `varlist' có mã chưa được ánh xạ"
        tab `varlist' if `varlist' != "" & missing(`generate')
        exit 459
    }
end

* Ghi dữ liệu đang mở vào một sheet của ket_qua.xlsx
capture program drop xl_out
program define xl_out
    args sheet
    capture confirm file `"$OUT/ket_qua.xlsx"'
    if _rc {
        export excel using `"$OUT/ket_qua.xlsx"', sheet("`sheet'") firstrow(variables) replace
    }
    else {
        export excel using `"$OUT/ket_qua.xlsx"', sheet("`sheet'") firstrow(variables) sheetreplace
    }
end

* Ghi một hệ số từ r(table), hoặc từ bản sao đã lưu, vào tệp kết quả. FAM là họ
* kiểm định dùng cho hiệu chỉnh Benjamini-Hochberg (để trống: không thuộc họ nào).
capture program drop post_coef
program define post_coef
    syntax, PART(string) OUTCOME(string) SPEC(string) COEF(string) [FAM(string) NOTE(string) TABLE(name)]
    tempname T
    if "`table'" != "" matrix `T' = `table'
    else matrix `T' = r(table)
    local j = colnumb(`T', "`coef'")
    if missing(`j') {
        display as error "post_coef: không tìm thấy hệ số `coef'"
        exit 111
    }
    post res ("`part'") ("`fam'") ("`outcome'") (`"`spec'"') ("`coef'") (`T'[1,`j']) (`T'[2,`j']) ///
        (`T'[5,`j']) (`T'[6,`j']) (`T'[4,`j']) (e(N)) (`"`note'"')
end

* Ghi các giá trị tính ở nơi khác; tùy chọn để trống được lưu là giá trị thiếu
capture program drop post_val
program define post_val
    syntax, PART(string) OUTCOME(string) SPEC(string) COEF(string) ///
        [FAM(string) EST(string) STDERR(string) LOWER(string) UPPER(string) PVAL(string) NOBS(string) NOTE(string)]
    foreach x in est stderr lower upper pval nobs {
        if `"``x''"' == "" local `x' .
    }
    post res ("`part'") ("`fam'") ("`outcome'") (`"`spec'"') ("`coef'") (`est') (`stderr') (`lower') ///
        (`upper') (`pval') (`nobs') (`"`note'"')
end

* Ghi kết quả của lincom vừa chạy
capture program drop post_lincom
program define post_lincom
    syntax, PART(string) OUTCOME(string) SPEC(string) COEF(string) NOBS(string) [NOTE(string)]
    post_val, part("`part'") outcome("`outcome'") spec(`"`spec'"') coef("`coef'") est(`r(estimate)') ///
        stderr(`r(se)') lower(`r(lb)') upper(`r(ub)') pval(`r(p)') nobs(`nobs') note(`"`note'"')
end

* Hệ số của một mức trong biến phân loại, chỉ báo cáo khi mức đó và mức tham
* chiếu đều có ít nhất MIN_CELL người trong mẫu của mô hình (ma trận RT)
capture program drop post_cat
program define post_cat
    syntax, PART(string) OUTCOME(string) SPEC(string) VAR(name) LEVel(integer) BASE(integer) [FAM(string)]
    quietly count if e(sample) & `var' == `level'
    local n1 = r(N)
    quietly count if e(sample) & `var' == `base'
    local n0 = r(N)
    if `n1' < $MIN_CELL | `n0' < $MIN_CELL {
        post_val, part("`part'") outcome("`outcome'") spec(`"`spec'"') coef("`level'.`var'") nobs(`e(N)') ///
            note("Nhóm dưới $MIN_CELL người: không báo cáo")
    }
    else {
        post_coef, part("`part'") fam("`fam'") outcome("`outcome'") spec(`"`spec'"') coef(`level'.`var') table(RT)
    }
end

* Hiệu chỉnh Benjamini-Hochberg trong từng họ kiểm định
capture program drop padjust
program define padjust
    syntax varname(numeric), GENerate(name) [BY(varname)]
    tempvar grp ord m raw rev
    if "`by'" == "" gen byte `grp' = 1
    else egen `grp' = group(`by'), missing
    bysort `grp' (`varlist'): gen long `ord' = _n if !missing(`varlist')
    by `grp': egen long `m' = count(`varlist')
    gen double `raw' = min(1, `m' / `ord' * `varlist') if !missing(`varlist')
    gen long `rev' = -`ord'
    bysort `grp' (`rev'): replace `raw' = min(`raw', `raw'[_n-1]) ///
        if _n > 1 & !missing(`raw') & !missing(`raw'[_n-1])
    gen double `generate' = `raw'
end

* Hệ số Cronbach's alpha trên những người trả lời đủ mọi câu
capture program drop rel_post
program define rel_post
    syntax varlist [if], NAME(string)
    marksample touse
    quietly alpha `varlist' if `touse'
    local a = r(alpha)
    quietly count if `touse'
    post rel (`"`name'"') (`a') (r(N))
end

* Mức đông nhất của một biến trong mẫu ước lượng
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

* Gộp các mức có dưới min người trong mẫu ước lượng. Biến có thứ tự: gộp vào mức
* kề phía trung vị. Biến định danh: gộp vào nhóm chung. Mã đặc biệt (không muốn
* trả lời, không rõ): gộp vào nhóm chung nếu có, nếu không thì vào mức đông nhất.
* Quy tắc chỉ dùng số đếm (như phan_tich.do).
capture program drop collapse_sparse
program define collapse_sparse
    syntax varname, Touse(varname) Min(integer) Kind(string) Special(numlist) Pooled(integer)
    local v `varlist'
    local guard 0
    while 1 {
        local ++guard
        if `guard' > 50 {
            display as error "collapse_sparse: quá nhiều vòng lặp với `v'"
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
        post lv ("`v'") ("`touse'") (`l') (`target') ("<`min'")
    }
end

* Cờ ẩn ô cho một nhóm ô có chung tổng. Ô từ 1 đến MIN_CELL - 1 bị ẩn. Nếu chỉ
* một ô bị ẩn, ô khác 0 nhỏ nhất còn lại cũng bị ẩn, để không suy ra được ô bị
* ẩn từ tổng.
capture program drop supp_flags
program define supp_flags, rclass
    syntax, COUNTS(numlist min=1)
    local flags
    local ns 0
    foreach k of local counts {
        local f = (`k' > 0 & `k' < $MIN_CELL)
        local flags `flags' `f'
        local ns = `ns' + `f'
    }
    if `ns' == 1 {
        local best 0
        local bestk .
        local i 0
        foreach k of local counts {
            local ++i
            local f : word `i' of `flags'
            if !`f' & `k' > 0 & `k' < `bestk' {
                local bestk = `k'
                local best = `i'
            }
        }
        if `best' > 0 {
            local new
            local i 0
            foreach f of local flags {
                local ++i
                local g = cond(`i' == `best', 1, `f')
                local new `new' `g'
            }
            local flags `new'
        }
    }
    return local flags `flags'
end

* Chuỗi "n (%)" của một ô, hoặc "<10" / "không báo cáo" nếu ô bị ẩn
capture program drop cell_str
program define cell_str, rclass
    args k tot f
    if `f' & `k' < $MIN_CELL return local s "<$MIN_CELL"
    else if `f' return local s "không báo cáo"
    else if `tot' == 0 return local s "0"
    else return local s = string(`k') + " (" + strtrim(string(100 * `k' / `tot', "%5.1f")) + ")"
end

* Bảng tần suất (nhóm, n (%)) của một biến trong một mẫu, có ẩn ô. Danh sách mã
* phải gồm mọi giá trị của biến trong mẫu.
capture program drop freq_table
program define freq_table
    syntax varname, Touse(varname) HANDLE(name) CODES(numlist) LABELS(string asis) [TITLE(string)]
    if `"`title'"' != "" post `handle' (`"`title'"') ("") ("")
    quietly count if `touse' & !missing(`varlist')
    local tot = r(N)
    local counts
    local covered 0
    foreach c of local codes {
        quietly count if `touse' & `varlist' == `c'
        local counts `counts' `r(N)'
        local covered = `covered' + r(N)
    }
    if `covered' != `tot' {
        display as error "freq_table `varlist': danh sách mã chưa đủ"
        exit 459
    }
    supp_flags, counts(`counts')
    local flags `r(flags)'
    local i 0
    foreach c of local codes {
        local ++i
        local lab : word `i' of `labels'
        local k : word `i' of `counts'
        local f : word `i' of `flags'
        cell_str `k' `tot' `f'
        post `handle' ("") (`"`lab'"') ("`r(s)'")
    }
end

* Một dòng của bảng chính sách DEI: có, không, không biết
capture program drop pol_row
program define pol_row
    syntax varname, Touse(varname) LABel(string)
    quietly count if `touse' & !missing(`varlist')
    local tot = r(N)
    local counts
    foreach c in 1 0 8 {
        quietly count if `touse' & `varlist' == `c'
        local counts `counts' `r(N)'
    }
    supp_flags, counts(`counts')
    local flags `r(flags)'
    forvalues i = 1/3 {
        local k : word `i' of `counts'
        local f : word `i' of `flags'
        cell_str `k' `tot' `f'
        local s`i' "`r(s)'"
    }
    post pt (`"`label'"') (`tot') ("`s1'") ("`s2'") ("`s3'")
end

* Một dòng của bảng thực thi: không đồng ý (1-2), trung lập (3), đồng ý (4-5)
capture program drop dei_row
program define dei_row
    syntax varname, Touse(varname) LABel(string)
    quietly count if `touse' & !missing(`varlist')
    local tot = r(N)
    quietly count if `touse' & inrange(`varlist', 1, 2)
    local k1 = r(N)
    quietly count if `touse' & `varlist' == 3
    local k2 = r(N)
    quietly count if `touse' & inrange(`varlist', 4, 5)
    local k3 = r(N)
    supp_flags, counts(`k1' `k2' `k3')
    local flags `r(flags)'
    forvalues i = 1/3 {
        local f : word `i' of `flags'
        cell_str `k`i'' `tot' `f'
        local s`i' "`r(s)'"
    }
    quietly summarize `varlist' if `touse'
    post et (`"`label'"') (`tot') ("`s1'") ("`s2'") ("`s3'") (r(mean)) (r(sd))
end

* Một dòng của bảng khoảng cách: chỉ số Q ở nhóm có, không, không biết của một
* chính sách. Cỡ nhóm được ẩn theo cùng quy tắc với bảng chính sách.
capture program drop gap_row
program define gap_row
    syntax varname, Touse(varname) LABel(string)
    local counts
    foreach c in 1 0 8 {
        quietly count if `touse' & `varlist' == `c'
        local counts `counts' `r(N)'
    }
    supp_flags, counts(`counts')
    local flags `r(flags)'
    local i 0
    foreach c in 1 0 8 {
        local ++i
        local k : word `i' of `counts'
        local f : word `i' of `flags'
        if `f' {
            local n`i' = cond(`k' < $MIN_CELL, "<$MIN_CELL", "không báo cáo")
            local q`i' ""
        }
        else if `k' == 0 {
            local n`i' "0"
            local q`i' ""
        }
        else {
            local n`i' = string(`k')
            quietly summarize Q if `touse' & `varlist' == `c'
            local q`i' = strtrim(string(r(mean), "%5.2f")) + " (" + strtrim(string(r(sd), "%5.2f")) + ")"
        }
    }
    post gp (`"`label'"') ("`n1'") ("`q1'") ("`n2'") ("`q2'") ("`n3'") ("`q3'")
end

* Một dòng của bảng cặp tương ứng: tỷ lệ đồng ý với một phát biểu thực thi ở
* nhóm có, không, không biết của một chính sách. Số người trả lời hợp lệ không được
* in, để không suy ra được số người bỏ trống trong từng nhóm.
capture program drop pair_row
program define pair_row
    syntax, POL(varname) DEI(varname) Touse(varname) LABel(string)
    local counts
    foreach c in 1 0 8 {
        quietly count if `touse' & `pol' == `c'
        local counts `counts' `r(N)'
    }
    supp_flags, counts(`counts')
    local flags `r(flags)'
    local i 0
    foreach c in 1 0 8 {
        local ++i
        local f : word `i' of `flags'
        local k : word `i' of `counts'
        quietly count if `touse' & `pol' == `c' & !missing(`dei')
        local nv = r(N)
        quietly count if `touse' & `pol' == `c' & inrange(`dei', 4, 5)
        local na = r(N)
        local nd = `nv' - `na'
        if `f' local s`i' = cond(`k' < $MIN_CELL, "<$MIN_CELL", "không báo cáo")
        else if `nv' == 0 local s`i' ""
        else if (`na' > 0 & `na' < $MIN_CELL) | (`nd' > 0 & `nd' < $MIN_CELL) local s`i' "không báo cáo"
        else local s`i' = strtrim(string(100 * `na' / `nv', "%5.1f"))
    }
    post pr (`"`label'"') ("`s1'") ("`s2'") ("`s3'")
end

* Một dòng của bảng chính sách theo loại hình nơi làm việc
capture program drop org_row
program define org_row
    syntax, CODE(integer) LABel(string) NCELL(string) Flag(integer) Touse(varname)
    if `flag' | "`ncell'" == "0" {
        local s = cond("`ncell'" == "0", "0", cond(real("`ncell'") < $MIN_CELL, "<$MIN_CELL", "không báo cáo"))
        post og (`"`label'"') ("`s'") (.) (.) ("") (.) (.)
        exit
    }
    quietly summarize npol_co if `touse' & orgtype == `code'
    local m = r(mean)
    local sd = r(sd)
    local k = r(N)
    quietly count if `touse' & orgtype == `code' & npol_co >= 1
    local a = r(N)
    local b = `k' - `a'
    if (`a' > 0 & `a' < $MIN_CELL) | (`b' > 0 & `b' < $MIN_CELL) local s1 "không báo cáo"
    else local s1 = strtrim(string(100 * `a' / `k', "%5.1f"))
    quietly summarize npol_kb if `touse' & orgtype == `code'
    local mk = r(mean)
    quietly summarize Q if `touse' & orgtype == `code'
    post og (`"`label'"') ("`ncell'") (`m') (`sd') ("`s1'") (`mk') (r(mean))
end

* Một dòng của bảng các hình thức kỳ thị: số trả lời hợp lệ, đã gặp ít nhất một
* lần, gặp thường xuyên hoặc rất thường xuyên (3-4), và điểm tần suất trung bình.
* Ô không được báo cáo nếu số đếm của nó, hoặc số suy ra được từ nó, từ 1 đến 9.
capture program drop cell_fmt
program define cell_fmt, rclass
    args k tot other
    if `k' > 0 & `k' < $MIN_CELL {
        return local n "<$MIN_CELL"
        return local pct ""
    }
    else if `other' > 0 & `other' < $MIN_CELL {
        return local n "không báo cáo"
        return local pct ""
    }
    else {
        return local n = string(`k')
        return local pct = strtrim(string(100 * `k' / `tot', "%5.1f"))
    }
end

capture program drop t4_row
program define t4_row
    syntax, LABel(string) SCORE(varname) ANY(varname) OFTEN(varname)
    quietly count if in_xd_main & !missing(`any')
    local nv = r(N)
    quietly count if in_xd_main & `any' == 1
    local na = r(N)
    quietly count if in_xd_main & `often' == 1
    local no = r(N)
    cell_fmt `na' `nv' `=`nv' - `na''
    local n1 "`r(n)'"
    local p1 "`r(pct)'"
    cell_fmt `no' `nv' `=`na' - `no''
    local n2 "`r(n)'"
    local p2 "`r(pct)'"
    quietly summarize `score' if in_xd_main & !missing(`any')
    post t4 (`"`label'"') (`nv') ("`n1'") ("`p1'") ("`n2'") ("`p2'") (r(mean)) (r(sd))
end

* -----------------------------------------------------------------------------
* 1. Nhập và mã hóa
* -----------------------------------------------------------------------------
import excel using `"$DATA"', firstrow allstring clear
foreach v of varlist _all {
    quietly replace `v' = strtrim(`v')
}

* Dữ liệu thực chất: trả lời ít nhất một câu sau hai câu sàng lọc (như phan_tich.do)
egen byte n_answered = rownonmiss(c1_age_group c2_education c3_experience c4_industry c5_position ///
    c6_employment c7_social_insurance c8_employer_type c9_employer_size c10_province c11_relationship ///
    c13_hours c14_sex_assigned c15_gender_identity c16_sexual_orientation c17_lgbt_self_id ///
    c19_* c21_* c22_* c24_*), strok

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
map_codes c4_industry,            gen(industry)  from(tcnh cntt gd yt tmdv sxcn ttmkt dlnhks khac kmtl) to(1 2 3 4 5 6 7 10 11 9)
map_codes c6_employment,          gen(emptype)   from(tt_luong bt_luong thoivu ctv freelancer khac kmtl) to(1 2 3 4 5 7 9)
map_codes c8_employer_type,       gen(orgtype)   from(nn tn_trongnuoc fdi ngo tudoanh khac kmtl) to(1 2 3 4 5 6 9)
map_codes c9_employer_size,       gen(orgsize)   from(duoi50 50199 200499 tu500 kad_kr kmtl) to(1 2 3 4 97 9)
* Câu 20: người gây ảnh hưởng nghiêm trọng nhất (một lựa chọn). Câu trả lời tự
* do của "người khác" (c20_source_other) không được đọc.
map_codes c20_source,             gen(src20)     from(ql_truc_tiep dong_nghiep khach_hang nhan_su khac kmtl) to(1 2 3 4 5 9)
* Câu 23: năm chính sách DEI; "không biết" (8) là một nhóm riêng
forvalues j = 1/5 {
    map_codes c23_`j', gen(pol`j') from(co khong khong_biet) to(1 0 8)
}
* Câu 25 (góp ý mở): chỉ giữ việc có trả lời hay không; văn bản bị bỏ ngay
gen byte c25_any = c25_suggestion != ""

* Các câu PHQ-4: vị trí 1-2 là hai câu GAD-2; trong bảng hỏi, vị trí 3 là
* "buồn bã, chán nản" và vị trí 4 là "ít hứng thú"
destring c21_1, gen(phqi1)
destring c21_2, gen(phqi2)
destring c21_4, gen(phqi3)
destring c21_3, gen(phqi4)
forvalues j = 1/8 {
    destring c19_`j', gen(stig`j')
}
forvalues j = 1/4 {
    destring c24_`j', gen(dei`j')
}

keep n_answered age18 has_job lgbt_self orient gender_id sex_birth agegrp educ relstat region industry ///
    emptype orgtype orgsize src20 c25_any $PHQI $STIG8 $DEI $POL

foreach v of global PHQI {
    assert inrange(`v', 0, 3) | missing(`v')
}
foreach v of global STIG8 {
    assert inrange(`v', 0, 4) | `v' == 9 | missing(`v')
}
foreach v of global DEI {
    assert inrange(`v', 1, 5) | `v' == 9 | missing(`v')
}

label define sex_lb      1 "Nam" 2 "Nữ" 9 "Không muốn trả lời"
label define age_lb      1 "18–24" 2 "25–34" 3 "35–44" 4 "Từ 45 trở lên" 9 "Không muốn trả lời"
label define educ_lb     1 "THPT trở xuống" 2 "Cao đẳng" 3 "Đại học" 4 "Sau đại học" 9 "Không muốn trả lời"
label define rel_lb      1 "Không có bạn đời" 2 "Có bạn đời" 3 "Ly thân, ly hôn hoặc góa" 9 "Không muốn trả lời"
label define region_lb   1 "Hà Nội" 2 "TP. Hồ Chí Minh" 3 "Đà Nẵng" 4 "Nơi khác" 9 "Không muốn trả lời"
label define ind_lb      1 "Tài chính, ngân hàng" 2 "Công nghệ thông tin" 3 "Giáo dục" 4 "Y tế" ///
                         5 "Thương mại, dịch vụ" 6 "Sản xuất" 7 "Truyền thông, marketing" ///
                         10 "Du lịch, nhà hàng, khách sạn" 11 "Khác" 9 "Không muốn trả lời"
label define orgtype_lb  1 "Cơ quan, doanh nghiệp nhà nước" 2 "Doanh nghiệp tư nhân trong nước" ///
                         3 "Doanh nghiệp FDI" 4 "NGO, tổ chức phi lợi nhuận" 5 "Tự doanh, hộ kinh doanh" ///
                         6 "Khác" 9 "Không muốn trả lời"
label define orgsize_lb  1 "Dưới 50 người" 2 "50–199 người" 3 "200–499 người" 4 "Từ 500 người trở lên" ///
                         97 "Không áp dụng hoặc không rõ" 9 "Không muốn trả lời"
label values sex_birth sex_lb
label values agegrp age_lb
label values educ educ_lb
label values relstat rel_lb
label values region region_lb
label values industry ind_lb
label values orgtype orgtype_lb
label values orgsize orgsize_lb

* -----------------------------------------------------------------------------
* 2. Biến dẫn xuất và chỉ báo mẫu
* -----------------------------------------------------------------------------
gen byte substantive = n_answered > 0
gen byte in_base = has_job == 1 & substantive
gen byte lgbt = lgbt_self == 1
gen byte in_lgbt = in_base & lgbt
* Mọi người có dữ liệu thực chất đều đã qua câu sàng lọc tuổi
assert age18 == 1 if in_base

* Tình trạng chuyển giới hoặc đa dạng giới
gen byte gmin = .
replace gmin = 0 if inlist(gender_id, 1, 2)
replace gmin = 1 if inlist(gender_id, 3, 4, 5, 6)
replace gmin = 9 if gender_id == 9

* Nhóm xu hướng tính dục; khác, đang tự xác định và dị tính là một nhóm (98)
gen byte orientg = .
replace orientg = 1 if orient == 2
replace orientg = 2 if orient == 3
replace orientg = 3 if inlist(orient, 4, 5)
replace orientg = 98 if inlist(orient, 1, 6, 7)
replace orientg = 9 if orient == 9

* "Không áp dụng/không muốn trả lời" ở các câu kỳ thị và "không rõ/không áp
* dụng/không muốn trả lời" ở các câu thực thi DEI là giá trị thiếu
foreach v of varlist $STIG8 $DEI {
    replace `v' = . if `v' == 9
}

egen byte phq_n = rownonmiss($PHQI)
gen byte phq4 = phqi1 + phqi2 + phqi3 + phqi4 if phq_n == 4

* Chỉ số kỳ thị S: trung bình tám tình huống, cần ít nhất sáu câu
egen byte S_n = rownonmiss($STIG8)
egen double S_raw = rowmean($STIG8)
gen double S = S_raw if S_n >= 6 & lgbt == 1
egen byte S_count8 = anycount($STIG8), values(1 2 3 4)
replace S_count8 = . if missing(S)

* Ba chỉ số con: giao tiếp (1-3) và nghề nghiệp (4-6), mỗi chỉ số cần ít nhất
* hai câu; thể hiện giới (7-8), cần ít nhất một câu
egen byte Si_n = rownonmiss($STIG_I)
egen double Si_raw = rowmean($STIG_I)
gen double S_int = Si_raw if Si_n >= 2 & lgbt == 1
egen byte Sc_n = rownonmiss($STIG_C)
egen double Sc_raw = rowmean($STIG_C)
gen double S_car = Sc_raw if Sc_n >= 2 & lgbt == 1
egen double Sg_raw = rowmean($STIG_G)
gen double S_gen = Sg_raw if lgbt == 1
drop Si_n Si_raw Sc_n Sc_raw Sg_raw

* Đã gặp ít nhất một lần (any) và gặp thường xuyên hoặc rất thường xuyên (often)
forvalues j = 1/8 {
    gen byte stig`j'_any = stig`j' >= 1 if !missing(stig`j')
    gen byte stig`j'_often = stig`j' >= 3 if !missing(stig`j')
}
gen byte ever_exposed = S > 0 if !missing(S)
egen byte max8 = rowmax($STIG8)
gen byte ever_often = max8 >= 3 if !missing(S)
foreach g in int car gen {
    local items = cond("`g'" == "int", "$STIG_I", cond("`g'" == "car", "$STIG_C", "$STIG_G"))
    egen byte max_`g' = rowmax(`items')
    gen byte `g'_any = S_`g' > 0 if !missing(S_`g')
    gen byte `g'_often = max_`g' >= 3 if !missing(S_`g')
}
drop max8 max_int max_car max_gen

* Chỉ số thực thi DEI được cảm nhận Q: trung bình bốn phát biểu, cần ít nhất ba câu
egen byte Q_n = rownonmiss($DEI)
egen double Q_raw = rowmean($DEI)
gen double Q = Q_raw if Q_n >= 3
drop Q_raw

* Số chính sách DEI được báo là có (npol_co) và số câu "không biết" (npol_kb),
* chỉ tính khi đủ năm câu. Hai cận của độ nhạy: "không biết" là không (npol_lo)
* và "không biết" là có (npol_hi).
egen byte pol_n = rownonmiss($POL)
egen byte npol_co = anycount($POL), values(1)
egen byte npol_kb = anycount($POL), values(8)
replace npol_co = . if pol_n < 5
replace npol_kb = . if pol_n < 5
gen byte npol_lo = npol_co
gen byte npol_hi = npol_co + npol_kb

* Câu 20 trong số người đã gặp ít nhất một tình huống; 0 = không trả lời
gen byte src20c = src20
replace src20c = 0 if missing(src20)

* Mẫu
gen byte in_main = in_lgbt & !missing(phq4) & !missing(S)
egen byte xd_miss = rowmiss($XD)
gen byte in_xd_main = in_main & xd_miss == 0
drop xd_miss
gen byte in_h3 = in_xd_main & !missing(Q)
* Làm việc trong một tổ chức: không phải tự doanh, hộ kinh doanh (Câu 8) và không
* phải freelancer độc lập (Câu 6)
gen byte in_org = !missing(orgtype, emptype) & orgtype != 5 & emptype != 5
gen byte in_dei_all = in_xd_main & pol_n == 5 & !missing(Q) & !missing(orgtype, orgsize)
gen byte in_dei = in_dei_all & in_org

* Kiểm tra: Câu 20 chỉ hiện với người đã gặp ít nhất một tình huống
quietly count if in_xd_main & ever_exposed == 0 & !missing(src20)
display "Người chưa gặp tình huống nào nhưng có trả lời Câu 20 (mẫu chính): " r(N)

* -----------------------------------------------------------------------------
* 3. Luồng mẫu
* -----------------------------------------------------------------------------
tempname F
tempfile flow
postfile `F' str100 buoc long(n ky_vong) using "`flow'", replace
quietly count
post `F' ("Phiếu nhận được") (r(N)) (850)
quietly count if has_job == 1
post `F' ("Có công việc chính tạo thu nhập") (r(N)) (734)
quietly count if in_base
post `F' ("Trả lời ít nhất một câu sau phần sàng lọc") (r(N)) (719)
quietly count if in_lgbt
post `F' ("Tự nhận là LGBT") (r(N)) (300)
quietly count if in_main
post `F' ("Đủ PHQ-4 và chỉ số kỳ thị hợp lệ") (r(N)) (272)
quietly count if in_xd_main
post `F' ("Mẫu chính: đủ tám nhóm biến kiểm soát") (r(N)) (235)
quietly count if in_h3
post `F' ("Mẫu chính có chỉ số thực thi Q hợp lệ (mẫu H3)") (r(N)) (223)
quietly count if in_xd_main & in_org
post `F' ("Mẫu chính, làm việc trong một tổ chức") (r(N)) (.)
quietly count if in_dei
post `F' ("Mẫu DEI: thêm đủ năm câu chính sách, Q hợp lệ, loại hình và quy mô tổ chức") (r(N)) (.)
quietly count if in_dei_all
post `F' ("Mẫu DEI toàn bộ (giữ cả tự doanh và freelancer)") (r(N)) (.)
postclose `F'
preserve
use "`flow'", clear
gen byte khop = n == ky_vong if !missing(ky_vong)
list, noobs abbreviate(20)
xl_out "LuongMau"
quietly count if khop == 0
local nmis = r(N)
restore
if `nmis' > 0 {
    display as error "Luồng mẫu khác các con số đã ghi ở `nmis' bước. Kiểm tra tệp dữ liệu."
    exit 9
}

* Câu 25: số người LGBT trả lời câu hỏi mở (không phân tích nội dung)
quietly count if in_lgbt & c25_any
local k25 = r(N)
quietly count if in_lgbt
local n25 = r(N)
preserve
clear
set obs 1
gen str100 noi_dung = "Người LGBT có viết câu trả lời ở Câu 25"
gen str12 so_nguoi = cond(`k25' > 0 & `k25' < $MIN_CELL, "<$MIN_CELL", string(`k25'))
gen long tren_tong = `n25'
xl_out "Cau25"
restore

* -----------------------------------------------------------------------------
* 4. Thống kê mô tả
* -----------------------------------------------------------------------------
* Nhóm dùng trong bảng đặc điểm mẫu (như bài SRSP): y tế gộp với du lịch và khác
gen byte orient_t2 = orient if inlist(orient, 2, 3, 4, 5)
replace orient_t2 = 0 if missing(orient_t2)
gen byte ind_t2 = industry
replace ind_t2 = 11 if inlist(industry, 4, 10)

* Đặc điểm của mẫu chính, kèm loại hình và quy mô nơi làm việc. Mẫu DEI chỉ được
* mô tả qua cỡ mẫu, để không suy ra được nhóm nhỏ bằng phép trừ giữa hai mẫu.
* Bản dạng giới không được trình bày.
tempfile dcfile
postfile dc str80 dac_diem str100 nhom str24 mau_chinh using "`dcfile'", replace
quietly count if in_xd_main
post dc ("n") ("") ("`r(N)'")
freq_table agegrp,    touse(in_xd_main) handle(dc) title("Nhóm tuổi") codes(1 2 3 4 9) ///
    labels("18–24" "25–34" "35–44" "Từ 45 trở lên" "Không muốn trả lời")
freq_table sex_birth, touse(in_xd_main) handle(dc) title("Giới tính khi sinh") codes(1 2 9) ///
    labels("Nam" "Nữ" "Không muốn trả lời")
freq_table educ,      touse(in_xd_main) handle(dc) title("Học vấn") codes(1 2 3 4 9) ///
    labels("THPT trở xuống" "Cao đẳng" "Đại học" "Sau đại học" "Không muốn trả lời")
freq_table relstat,   touse(in_xd_main) handle(dc) title("Tình trạng quan hệ") codes(1 2 3 9) ///
    labels("Không có bạn đời" "Có bạn đời" "Ly thân, ly hôn hoặc góa" "Không muốn trả lời")
freq_table region,    touse(in_xd_main) handle(dc) title("Địa bàn làm việc") codes(1 2 3 4 9) ///
    labels("Hà Nội" "TP. Hồ Chí Minh" "Đà Nẵng" "Nơi khác" "Không muốn trả lời")
freq_table orient_t2, touse(in_xd_main) handle(dc) title("Xu hướng tính dục") codes(2 3 4 5 0) ///
    labels("Đồng tính nam" "Đồng tính nữ" "Song tính" "Toàn tính" "Khác, đang tự xác định hoặc không nêu")
freq_table ind_t2,    touse(in_xd_main) handle(dc) title("Ngành") codes(1 2 3 5 6 7 11 9) ///
    labels("Tài chính, ngân hàng" "Công nghệ thông tin" "Giáo dục" "Thương mại, dịch vụ" "Sản xuất" ///
    "Truyền thông, marketing" "Y tế, du lịch hoặc khác" "Không muốn trả lời")
freq_table orgtype,   touse(in_xd_main) handle(dc) title("Loại hình nơi làm việc") codes(1 2 3 4 5 6 9) ///
    labels("Cơ quan, doanh nghiệp nhà nước" "Doanh nghiệp tư nhân trong nước" "Doanh nghiệp FDI" ///
    "NGO, tổ chức phi lợi nhuận" "Tự doanh, hộ kinh doanh" "Khác" "Không muốn trả lời")
freq_table orgsize,   touse(in_xd_main) handle(dc) title("Quy mô nơi làm việc") codes(1 2 3 4 97 9) ///
    labels("Dưới 50 người" "50–199 người" "200–499 người" "Từ 500 người trở lên" ///
    "Không áp dụng hoặc không rõ" "Không muốn trả lời")
postclose dc
preserve
use "`dcfile'", clear
xl_out "DacDiemMau"
restore

* Nhãn của năm chính sách và bốn phát biểu thực thi
local plab1 "Chính sách bằng văn bản chống phân biệt đối xử dựa trên SOGIE"
local plab2 "Kênh hoặc quy trình khiếu nại bảo mật"
local plab3 "Đào tạo về DEI cho quản lý hoặc nhân viên"
local plab4 "Phúc lợi cho bạn đời cùng giới hoặc người phụ thuộc"
local plab5 "Hỗ trợ người chuyển giới về tên gọi, đại từ, trang phục, nhà vệ sinh"
local dlab1 "An toàn khi phản ánh phân biệt đối xử hoặc quấy rối"
local dlab2 "Quản lý trực tiếp tôn trọng người LGBT"
local dlab3 "Hành vi nói đùa hoặc xúc phạm người LGBT bị nhắc nhở hoặc xử lý"
local dlab4 "Được dùng tên gọi, đại từ, trang phục phù hợp với bản dạng giới"

* Năm chính sách DEI (mẫu DEI)
tempfile ptfile
postfile pt str120 chinh_sach long n str24(co khong khong_biet) using "`ptfile'", replace
forvalues j = 1/5 {
    pol_row pol`j', touse(in_dei) label("`plab`j''")
}
postclose pt
preserve
use "`ptfile'", clear
xl_out "ChinhSach"
restore

* Phân bố số chính sách có và số câu "không biết"
gen byte npol_co_c = min(npol_co, 3) if !missing(npol_co)
gen byte npol_kb_c = cond(npol_kb == 0, 0, cond(npol_kb <= 2, 1, 2)) if !missing(npol_kb)
tempfile npfile
postfile np str80 bien str24 nhom str24 n_pct using "`npfile'", replace
freq_table npol_co_c, touse(in_dei) handle(np) title("Số chính sách được báo là có") codes(0 1 2 3) ///
    labels("0" "1" "2" "Từ 3 trở lên")
freq_table npol_kb_c, touse(in_dei) handle(np) title("Số câu trả lời không biết") codes(0 1 2) ///
    labels("0" "1–2" "Từ 3 trở lên")
postclose np
preserve
use "`npfile'", clear
xl_out "SoChinhSach"
restore

* Bốn phát biểu thực thi và chỉ số Q (mẫu DEI)
tempfile etfile
postfile et str120 phat_bieu long n str24(khong_dong_y trung_lap dong_y) double(tb dlc) using "`etfile'", replace
forvalues k = 1/4 {
    dei_row dei`k', touse(in_dei) label("`dlab`k''")
}
quietly summarize Q if in_dei
post et ("Chỉ số thực thi Q (trung bình bốn phát biểu)") (r(N)) ("") ("") ("") (r(mean)) (r(sd))
postclose et
preserve
use "`etfile'", clear
xl_out "ThucThi"
restore

* Khoảng cách giữa chính sách và thực thi (mô tả): Q theo nhóm có, không, không biết
tempfile gpfile
postfile gp str120 chinh_sach str24(n_co q_co n_khong q_khong n_kb q_kb) using "`gpfile'", replace
forvalues j = 1/5 {
    gap_row pol`j', touse(in_dei) label("`plab`j''")
}
postclose gp
preserve
use "`gpfile'", clear
xl_out "KhoangCach"
restore

* Ba cặp tương ứng: tỷ lệ đồng ý (%) với phát biểu thực thi theo nhóm của chính sách
tempfile prfile
postfile pr str160 cap str24(co khong khong_biet) using "`prfile'", replace
pair_row, pol(pol2) dei(dei1) touse(in_dei) label("Kênh khiếu nại bảo mật → an toàn khi phản ánh")
pair_row, pol(pol3) dei(dei2) touse(in_dei) label("Đào tạo DEI → quản lý tôn trọng người LGBT")
pair_row, pol(pol5) dei(dei4) touse(in_dei) label("Hỗ trợ người chuyển giới → được dùng tên gọi, đại từ, trang phục")
postclose pr
preserve
use "`prfile'", clear
xl_out "CapTuongUng"
restore

* Chính sách DEI theo loại hình nơi làm việc (mẫu DEI)
tempfile ogfile
postfile og str80 loai_hinh str24 n double(tb_so_chinh_sach dlc_so_chinh_sach) str24 pct_co_it_nhat_1 ///
    double(tb_so_khong_biet tb_Q) using "`ogfile'", replace
local ocodes 1 2 3 4 6 9
local counts
foreach c of local ocodes {
    quietly count if in_dei & orgtype == `c'
    local counts `counts' `r(N)'
}
supp_flags, counts(`counts')
local oflags `r(flags)'
local i 0
foreach c of local ocodes {
    local ++i
    local k : word `i' of `counts'
    local f : word `i' of `oflags'
    local lab : label orgtype_lb `c'
    org_row, code(`c') label("`lab'") ncell("`k'") flag(`f') touse(in_dei)
}
postclose og
preserve
use "`ogfile'", clear
xl_out "TheoLoaiHinh"
restore

* Các hình thức kỳ thị đã gặp trong 12 tháng (mẫu chính)
local lab_all "Bất kỳ tình huống nào (1–8)"
local lab_int "Giao tiếp: bất kỳ tình huống 1–3"
local lab_car "Nghề nghiệp: bất kỳ tình huống 4–6"
local lab_gen "Thể hiện giới: bất kỳ tình huống 7–8"
local lab1 "1 Bị nói đùa, bình luận hoặc gửi nội dung xúc phạm"
local lab2 "2 Bị hỏi những câu riêng tư không mong muốn"
local lab3 "3 Bị tiết lộ hoặc đe dọa tiết lộ khi chưa đồng ý"
local lab4 "4 Bị loại khỏi đào tạo hoặc phát triển nghề nghiệp"
local lab5 "5 Bị đánh giá, trả lương hoặc thăng tiến không công bằng"
local lab6 "6 Bị chuyển ca, phân công hoặc bố trí bất lợi"
local lab7 "7 Bị áp lực theo khuôn mẫu giới"
local lab8 "8 Khó khăn với tên gọi, đại từ, trang phục, nhà vệ sinh"
local sit_int 1 2 3
local sit_car 4 5 6
local sit_gen 7 8
tempfile t4file
postfile t4 str120 hinh_thuc long n_hop_le str24(n_it_nhat_1_lan pct_it_nhat_1_lan n_thuong_xuyen pct_thuong_xuyen) ///
    double(tb_diem dlc_diem) using "`t4file'", replace
t4_row, label("`lab_all'") score(S) any(ever_exposed) often(ever_often)
foreach g in int car gen {
    t4_row, label("`lab_`g''") score(S_`g') any(`g'_any) often(`g'_often)
    foreach j of local sit_`g' {
        t4_row, label("`lab`j''") score(stig`j') any(stig`j'_any) often(stig`j'_often)
    }
}
postclose t4
preserve
use "`t4file'", clear
xl_out "HinhThucKyThi"
restore

tempfile stfile
postfile st str80 bien str24 nhom str24 n_pct using "`stfile'", replace
gen byte S_count8_c = min(S_count8, 3) if !missing(S_count8)
freq_table S_count8_c, touse(in_xd_main) handle(st) title("Số tình huống đã gặp trong tám") codes(0 1 2 3) ///
    labels("0" "1" "2" "Từ 3 trở lên")
postclose st
preserve
use "`stfile'", clear
xl_out "SoTinhHuong"
restore

* Câu 20: người gây ảnh hưởng nghiêm trọng nhất, trong số người đã gặp ít nhất một
* tình huống (mẫu chính) và trong số người đã gặp kỳ thị nghề nghiệp, kỳ thị về thể
* hiện giới. Nhóm giao tiếp không được trình bày vì gần trùng với cột đầu, nên phép
* trừ giữa hai cột sẽ cho ra các ô nhỏ.
local scodes 1 2 3 4 5 9 0
local slabs `""Quản lý trực tiếp" "Đồng nghiệp" "Khách hàng, đối tác" "Bộ phận nhân sự" "Người khác" "Không muốn trả lời" "Không trả lời""'
gen byte grp_all = in_xd_main & ever_exposed == 1
gen byte grp_car = in_xd_main & car_any == 1
gen byte grp_gen = in_xd_main & gen_any == 1
foreach g in all car gen {
    quietly count if grp_`g'
    local tot_`g' = r(N)
    local cnt_`g'
    foreach c of local scodes {
        quietly count if grp_`g' & src20c == `c'
        local cnt_`g' `cnt_`g'' `r(N)'
    }
    supp_flags, counts(`cnt_`g'')
    local flg_`g' `r(flags)'
}
tempfile srcfile
postfile sr str60 nguon str24(tat_ca nghe_nghiep the_hien_gioi) using "`srcfile'", replace
post sr ("n") ("`tot_all'") ("`tot_car'") ("`tot_gen'")
local i 0
foreach c of local scodes {
    local ++i
    local lab : word `i' of `slabs'
    foreach g in all car gen {
        local k : word `i' of `cnt_`g''
        local f : word `i' of `flg_`g''
        cell_str `k' `tot_`g'' `f'
        local s_`g' "`r(s)'"
    }
    post sr ("`lab'") ("`s_all'") ("`s_car'") ("`s_gen'")
}
postclose sr
preserve
use "`srcfile'", clear
xl_out "NguonKyThi"
restore

* Mô tả các biến của mẫu DEI và độ tin cậy
preserve
keep if in_dei
tempname MB
tempfile mbfile
postfile `MB' str16 bien long n double(tb dlc trung_vi nho_nhat lon_nhat) using "`mbfile'", replace
foreach v in phq4 S Q npol_co npol_kb {
    quietly summarize `v', detail
    post `MB' ("`v'") (r(N)) (r(mean)) (r(sd)) (r(p50)) (r(min)) (r(max))
}
postclose `MB'
use "`mbfile'", clear
xl_out "MoTa"
restore

tempfile relfile
postfile rel str100 thang_do double alpha long N using "`relfile'", replace
rel_post $DEI if in_dei, name("Thực thi DEI (bốn phát biểu), mẫu DEI")
rel_post $PHQI if in_dei, name("PHQ-4, mẫu DEI")
postclose rel
preserve
use "`relfile'", clear
xl_out "TinCay"
restore

* -----------------------------------------------------------------------------
* 5. Gộp mức thưa của biến kiểm soát
* -----------------------------------------------------------------------------
* Bản sao cho mẫu DEI (_d) và mẫu DEI toàn bộ (_a), tạo từ mã gốc trước khi gộp
local xdo_d
local xdo_a
foreach v in $XD $ORG {
    clonevar `v'_d = `v'
    clonevar `v'_a = `v'
    local xdo_d `xdo_d' `v'_d
    local xdo_a `xdo_a' `v'_a
}
tempfile lvfile
postfile lv str24 bien str16 mau double(ma_cu ma_moi) str8 n using "`lvfile'", replace
local ordered $ORDERED
foreach v of global XD {
    local isord : list v in ordered
    local kind = cond(`isord', "ordered", "nominal")
    collapse_sparse `v', touse(in_xd_main) min($MIN_LEVEL) kind(`kind') special(9 97) pooled(98)
}
foreach s in d a {
    local touse = cond("`s'" == "d", "in_dei", "in_dei_all")
    foreach v in $XD $ORG {
        local isord : list v in ordered
        local kind = cond(`isord', "ordered", "nominal")
        collapse_sparse `v'_`s', touse(`touse') min($MIN_LEVEL) kind(`kind') special(9 97) pooled(98)
    }
}
postclose lv
preserve
use "`lvfile'", clear
if _N == 0 {
    set obs 1
    replace bien = "Không gộp mức nào"
}
xl_out "GopMuc"
restore

* -----------------------------------------------------------------------------
* 6. Mô hình thăm dò
* -----------------------------------------------------------------------------
* OLS, sai số chuẩn HC3. Họ A: DEI và chỉ số kỳ thị S; họ B: DEI và PHQ-4; họ C:
* điều tiết. Hiệu chỉnh Benjamini-Hochberg trong từng họ (cột fam).
tempfile resfile
postfile res str12 part str4 fam str8 outcome str200 spec str40 term double(b se lb ub p) long N str244 note ///
    using "`resfile'", replace

* Bối cảnh: hệ số của S trong mô hình H1 trên mẫu chính, và trên mẫu DEI
regress phq4 S i.($XD) if in_xd_main, vce(hc3)
post_coef, part("BoiCanh") outcome("phq4") spec("H1, mẫu chính, XD") coef(S)
regress phq4 S i.(`xdo_d') if in_dei, vce(hc3)
post_coef, part("BoiCanh") outcome("phq4") spec("Mẫu DEI, XD + loại hình, quy mô tổ chức") coef(S)

* Họ A: DEI và mức kỳ thị (S)
regress S npol_co npol_kb i.(`xdo_d') if in_dei, vce(hc3)
matrix RT = r(table)
post_coef, part("A1") fam("A") outcome("S") spec("Số chính sách có (điều chỉnh số câu không biết)") coef(npol_co) table(RT)
post_coef, part("A1") outcome("S") spec("Số câu không biết (cùng mô hình)") coef(npol_kb) table(RT)
regress S Q i.(`xdo_d') if in_dei, vce(hc3)
post_coef, part("A2") fam("A") outcome("S") spec("Chỉ số thực thi Q") coef(Q)
forvalues j = 1/5 {
    local k = `j' + 2
    quietly count if in_dei & pol`j' == 0
    if r(N) < $MIN_CELL {
        foreach l in 1 8 {
            post_val, part("A`k'") outcome("S") spec("`plab`j''") coef("`l'.pol`j'") ///
                note("Nhóm tham chiếu dưới $MIN_CELL người: không ước lượng")
        }
        continue
    }
    regress S ib0.pol`j' i.(`xdo_d') if in_dei, vce(hc3)
    matrix RT = r(table)
    post_cat, part("A`k'") fam("A") outcome("S") spec("`plab`j'': có so với không") var(pol`j') level(1) base(0)
    post_cat, part("A`k'") outcome("S") spec("`plab`j'': không biết so với không") var(pol`j') level(8) base(0)
}

* Họ B: DEI và PHQ-4, có và không có S
regress phq4 npol_co npol_kb i.(`xdo_d') if in_dei, vce(hc3)
post_coef, part("B1") fam("B") outcome("phq4") spec("Số chính sách có (điều chỉnh số câu không biết)") coef(npol_co)
regress phq4 npol_co npol_kb S i.(`xdo_d') if in_dei, vce(hc3)
matrix RT = r(table)
post_coef, part("B1s") outcome("phq4") spec("Số chính sách có, thêm S") coef(npol_co) table(RT)
post_coef, part("B1s") outcome("phq4") spec("S, cùng mô hình") coef(S) table(RT)
regress phq4 Q i.(`xdo_d') if in_dei, vce(hc3)
post_coef, part("B2") fam("B") outcome("phq4") spec("Chỉ số thực thi Q") coef(Q)
regress phq4 Q S i.(`xdo_d') if in_dei, vce(hc3)
matrix RT = r(table)
post_coef, part("B2s") outcome("phq4") spec("Chỉ số thực thi Q, thêm S") coef(Q) table(RT)
post_coef, part("B2s") outcome("phq4") spec("S, cùng mô hình") coef(S) table(RT)

* Họ C. C1: S × Q, đúng đặc tả ngày 13/10/2026 (mẫu H3, XD, Q trừ trung bình của mẫu H3)
quietly summarize Q if in_h3
local mQ = r(mean)
local sdQ = r(sd)
local sdQ_s : display %5.3f `sdQ'
gen double Qc = Q - `mQ' if !missing(Q)
regress phq4 c.S##c.Qc i.($XD) if in_h3, vce(hc3)
matrix RT = r(table)
local nT = e(N)
post_coef, part("C1") fam("C") outcome("phq4") spec("S × Q (mẫu H3)") coef(c.S#c.Qc) table(RT)
post_coef, part("C1") outcome("phq4") spec("Q tại S = 0") coef(Qc) table(RT)
lincom S - `sdQ' * c.S#c.Qc
post_lincom, part("C1") outcome("phq4") spec("S tại Q = trung bình − 1 ĐLC") coef("S") nobs(`nT') note("ĐLC của Q = `sdQ_s'")
post_coef, part("C1") outcome("phq4") spec("S tại Q trung bình") coef(S) table(RT) note("ĐLC của Q = `sdQ_s'")
lincom S + `sdQ' * c.S#c.Qc
post_lincom, part("C1") outcome("phq4") spec("S tại Q = trung bình + 1 ĐLC") coef("S") nobs(`nT') note("ĐLC của Q = `sdQ_s'")

* C2: S × số chính sách có (trừ trung bình của mẫu DEI), điều chỉnh số câu không biết
capture program drop mod_count
program define mod_count
    syntax, PART(string) Touse(varname) NPOL(varname) COVARS(string) [KB(varname) LABel(string) FAM(string)]
    quietly summarize `npol' if `touse'
    local mN = r(mean)
    local sdN = r(sd)
    local lowv = max(0, `mN' - `sdN')
    local lo = `mN' - `lowv'
    local nlab : display %4.2f `mN'
    local slab : display %4.2f `sdN'
    local llab : display %4.2f `lowv'
    capture drop npol_c
    gen double npol_c = `npol' - `mN' if !missing(`npol')
    regress phq4 c.S##c.npol_c `kb' i.(`covars') if `touse', vce(hc3)
    matrix RT = r(table)
    local nT = e(N)
    local note "TB = `nlab'; ĐLC = `slab'"
    post_coef, part("`part'") fam("`fam'") outcome("phq4") spec(`"`label'S × số chính sách"') coef(c.S#c.npol_c) table(RT) note("`note'")
    post_coef, part("`part'") outcome("phq4") spec(`"`label'Số chính sách tại S = 0"') coef(npol_c) table(RT) note("`note'")
    lincom S - `lo' * c.S#c.npol_c
    post_lincom, part("`part'") outcome("phq4") spec(`"`label'S tại số chính sách = `llab'"') coef("S") nobs(`nT') note("`note'")
    post_coef, part("`part'") outcome("phq4") spec(`"`label'S tại số chính sách trung bình"') coef(S) table(RT) note("`note'")
    lincom S + `sdN' * c.S#c.npol_c
    post_lincom, part("`part'") outcome("phq4") spec(`"`label'S tại số chính sách = TB + 1 ĐLC"') coef("S") nobs(`nT') note("`note'")
end
mod_count, part("C2") fam("C") touse(in_dei) npol(npol_co) kb(npol_kb) covars(`xdo_d')

* Độ nhạy (không hiệu chỉnh đa kiểm định)
* (i) cận dưới và cận trên của số chính sách, không điều chỉnh số câu không biết
foreach b in lo hi {
    local blab = cond("`b'" == "lo", "Cận dưới (không biết = không)", "Cận trên (không biết = có)")
    regress S npol_`b' i.(`xdo_d') if in_dei, vce(hc3)
    post_coef, part("DN_A1") outcome("S") spec("`blab'") coef(npol_`b')
    regress phq4 npol_`b' i.(`xdo_d') if in_dei, vce(hc3)
    post_coef, part("DN_B1") outcome("phq4") spec("`blab'") coef(npol_`b')
    mod_count, part("DN_C2") touse(in_dei) npol(npol_`b') covars(`xdo_d') label("`blab': ")
}
* (ii) chỉ những người không có câu "không biết" nào (không gộp lại mức thưa)
gen byte in_dei_nokb = in_dei & npol_kb == 0
regress S npol_co i.(`xdo_d') if in_dei_nokb, vce(hc3)
post_coef, part("DN_A1") outcome("S") spec("Không có câu không biết nào") coef(npol_co)
regress phq4 npol_co i.(`xdo_d') if in_dei_nokb, vce(hc3)
post_coef, part("DN_B1") outcome("phq4") spec("Không có câu không biết nào") coef(npol_co)
mod_count, part("DN_C2") touse(in_dei_nokb) npol(npol_co) covars(`xdo_d') label("Không có câu không biết nào: ")
* (iii) mẫu DEI toàn bộ, giữ cả tự doanh và freelancer
regress S npol_co npol_kb i.(`xdo_a') if in_dei_all, vce(hc3)
post_coef, part("DN_A1") outcome("S") spec("Mẫu DEI toàn bộ") coef(npol_co)
regress S Q i.(`xdo_a') if in_dei_all, vce(hc3)
post_coef, part("DN_A2") outcome("S") spec("Mẫu DEI toàn bộ") coef(Q)
regress phq4 npol_co npol_kb i.(`xdo_a') if in_dei_all, vce(hc3)
post_coef, part("DN_B1") outcome("phq4") spec("Mẫu DEI toàn bộ") coef(npol_co)
regress phq4 Q i.(`xdo_a') if in_dei_all, vce(hc3)
post_coef, part("DN_B2") outcome("phq4") spec("Mẫu DEI toàn bộ") coef(Q)
mod_count, part("DN_C2") touse(in_dei_all) npol(npol_co) kb(npol_kb) covars(`xdo_a') label("Mẫu DEI toàn bộ: ")
* (iv) C1 trên mẫu DEI, với biến kiểm soát của mô hình DEI
quietly summarize Q if in_dei
gen double Qc_d = Q - r(mean) if !missing(Q)
regress phq4 c.S##c.Qc_d i.(`xdo_d') if in_dei, vce(hc3)
post_coef, part("DN_C1") outcome("phq4") spec("S × Q trên mẫu DEI, XD + loại hình, quy mô tổ chức") coef(c.S#c.Qc_d)

postclose res

* -----------------------------------------------------------------------------
* 7. Hiệu chỉnh đa kiểm định và xuất kết quả
* -----------------------------------------------------------------------------
preserve
use "`resfile'", clear
gen long row_id = _n
gen double p_fam = p if fam != ""
padjust p_fam, generate(p_bh) by(fam)
replace p_bh = . if fam == ""
drop p_fam
sort row_id
drop row_id
order part fam outcome spec term b se lb ub p p_bh N note
tempfile allres
save "`allres'"
xl_out "KetQua"
foreach h in A B C {
    use if fam == "`h'" | (substr(part, 1, 1) == "`h'" & fam == "" & part != "BoiCanh") using "`allres'", clear
    xl_out "Ho`h'"
}
use if substr(part, 1, 3) == "DN_" using "`allres'", clear
xl_out "DoNhay"
use if part == "BoiCanh" using "`allres'", clear
xl_out "BoiCanh"
restore

display as result `"Xong: $OUT/ket_qua.xlsx, $OUT/nhat_ky.log"'
log close vi

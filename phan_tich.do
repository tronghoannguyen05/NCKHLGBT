* =============================================================================
* Pathology or Prejudice? A Within-Group Test of Workplace Stigma and Anxiety
* and Depressive Symptoms among LGBT Workers in Vietnam
*
* Replication code for all tables and figures of the article.
*
* Requirements  Stata 17 or later. User-written packages sensemakr and boottest
*               (installed from SSC on the first run if missing).
* Input         Survey export (.xlsx) as downloaded from the survey platform.
*               Set its path in DATA below. The data contain sensitive personal
*               information and are not public. Only the variables used in the
*               analysis are kept after import.
* Output (OUT)  results.xlsx   one sheet per table of the article
*               figure2.png    specification curve (Figure 2)
*               analysis.log   full log; Table S3 (sensemakr) is printed here
* =============================================================================

version 17
clear all
set more off
set varabbrev off
set linesize 120

* -----------------------------------------------------------------------------
* 0. Settings
* -----------------------------------------------------------------------------
global DATA "D:/NCKH chủ đề LGBT/Kỳ_thị_tại_nơi_làm_việc_và_bất_lợi_thu_nhập_-_Khảo_sát_người_lao_động_tại_Việt_Nam_n850.xlsx"
global OUT  "D:/NCKH chủ đề LGBT/ket_qua"

* 1 = full analysis; 0 = data preparation, sample flow and descriptive tables
global RUN_MODELS 1

global SEED      20260928    // wild bootstrap, multiple imputation
global MIN_CELL  10          // disclosure control: smallest reportable cell
global MIN_LEVEL 5           // covariate categories below this size are merged
global SESOI     1.0         // smallest effect size of interest, PHQ-4 points per unit of S
global MI_M      20
global WILD_REPS 9999

* Covariates of the main model (XD) and other job characteristics (XJ)
global XD      "agegrp educ sex_birth gmin orientg relstat region industry"
global XJ      "exper position emptype orgtype orgsize socins hours"
global ORDERED "agegrp educ exper orgsize hours"
global PHQI    "phqi1 phqi2 phqi3 phqi4"
global STIG7   "stig1 stig2 stig3 stig4 stig5 stig6 stig7"
global STIG8   "stig1 stig2 stig3 stig4 stig5 stig6 stig7 stig8"
global STIG_I  "stig1 stig2 stig3"
global STIG_C  "stig4 stig5 stig6"
global STIG_G  "stig7 stig8"
global RQ1     "S_int S_car S_gen"
* The two other Likert scales of the questionnaire, used only for the response-quality flag
global CONC    "conc1 conc2 conc3 conc4"
global DEI     "dei1 dei2 dei3 dei4"

capture mkdir "$OUT"
capture log close _all
log using "$OUT/analysis.log", replace text name(main)
display "Stata " c(stata_version) ", " c(current_date) " " c(current_time)

confirm file "$DATA"

foreach p in sensemakr boottest {
    capture which `p'
    if _rc capture noisily ssc install `p'
    capture noisily which `p'
}

capture erase "$OUT/results.xlsx"
capture confirm file "$OUT/results.xlsx"
if !_rc {
    display as error "Close results.xlsx in Excel and run again."
    exit 608
}

* -----------------------------------------------------------------------------
* Programs
* -----------------------------------------------------------------------------

* Recode a string variable through a list of codes; stops on any unmapped value
capture program drop map_codes
program define map_codes
    syntax varname(string), GENerate(name) FROM(string) TO(numlist)
    local nf : word count `from'
    local nt : word count `to'
    if `nf' != `nt' {
        display as error "map_codes `varlist': from() and to() differ in length"
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
        display as error "map_codes: `varlist' has unmapped values"
        tab `varlist' if `varlist' != "" & missing(`generate')
        exit 459
    }
end

* Write the data in memory to one sheet of results.xlsx
capture program drop xl_out
program define xl_out
    args sheet
    capture confirm file "$OUT/results.xlsx"
    if _rc {
        export excel using "$OUT/results.xlsx", sheet("`sheet'") firstrow(variables) replace
    }
    else {
        export excel using "$OUT/results.xlsx", sheet("`sheet'") firstrow(variables) sheetreplace
    }
end

* Post one coefficient from r(table), or from a stored copy of it, to the results file
capture program drop post_coef
program define post_coef
    syntax, PART(string) OUTCOME(string) SPEC(string) COEF(string) [NOTE(string) TABLE(name)]
    tempname T
    if "`table'" != "" matrix `T' = `table'
    else matrix `T' = r(table)
    local j = colnumb(`T', "`coef'")
    if missing(`j') {
        display as error "post_coef: coefficient `coef' not found"
        exit 111
    }
    post res ("`part'") ("`outcome'") ("`spec'") ("`coef'") (`T'[1,`j']) (`T'[2,`j']) ///
        (`T'[5,`j']) (`T'[6,`j']) (`T'[4,`j']) (e(N)) (`"`note'"')
end

* Post values computed elsewhere; empty options are stored as missing
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

* Benjamini-Hochberg adjustment within families of tests
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

* Rows of Table 2 for one characteristic of the estimation sample. Cells below
* MIN_CELL are suppressed. Stops if a single suppressed cell could be
* recovered from the total.
capture program drop t2_rows
program define t2_rows
    syntax varname, CODES(numlist)
    local title : variable label `varlist'
    post t2 (`"`title'"') ("") ("")
    quietly count if in_xd_main
    local tot = r(N)
    local shown 0
    local nsupp 0
    foreach c of local codes {
        local lab : label (`varlist') `c'
        quietly count if in_xd_main & `varlist' == `c'
        local n = r(N)
        local shown = `shown' + `n'
        if `n' > 0 & `n' < $MIN_CELL {
            local cell "<$MIN_CELL"
            local ++nsupp
        }
        else local cell = string(`n') + " (" + strtrim(string(100 * `n' / `tot', "%5.1f")) + ")"
        post t2 ("") (`"`lab'"') ("`cell'")
    }
    if `nsupp' == 1 & `shown' == `tot' {
        display as error "Table 2, `varlist': a suppressed cell can be recovered from the total"
        exit 459
    }
end

* Cronbach's alpha on respondents who answered every item
capture program drop rel_post
program define rel_post
    syntax varlist [if], NAME(string)
    marksample touse
    quietly alpha `varlist' if `touse'
    local a = r(alpha)
    quietly count if `touse'
    post rel ("`name'") (`a') (r(N))
end

* Largest category of a variable in the estimation sample
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

* Merge categories with fewer than min respondents in the estimation sample.
* Ordered variables: adjacent category nearer the median. Nominal variables:
* pooled category. Special codes (prefer not to answer): pooled category if it
* exists, otherwise the largest category. Decisions use counts only.
capture program drop collapse_sparse
program define collapse_sparse
    syntax varname, Touse(varname) Min(integer) Kind(string) Special(numlist) Pooled(integer)
    local v `varlist'
    local guard 0
    while 1 {
        local ++guard
        if `guard' > 50 {
            display as error "collapse_sparse: too many iterations for `v'"
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
            capture label define `lbl' `pooled' "Other (pooled)", add
        }
    }
end

* Count and percentage of one table cell. The cell is not reported if its
* count, or a count that a reader could derive from it (other), is between 1
* and MIN_CELL - 1.
capture program drop cell_fmt
program define cell_fmt, rclass
    args k tot other
    if `k' > 0 & `k' < $MIN_CELL {
        return local n "<$MIN_CELL"
        return local pct ""
    }
    else if `other' > 0 & `other' < $MIN_CELL {
        return local n "not reported"
        return local pct ""
    }
    else {
        return local n = string(`k')
        return local pct = strtrim(string(100 * `k' / `tot', "%5.1f"))
    }
end

* One row of Table 4: respondents with a valid score, respondents who
* experienced the form at least once, and respondents who experienced it often
* or very often (3-4), with the mean frequency score
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

* One row of Table 5: PHQ-4 among respondents who experienced the form and
* among those who did not (descriptive, unadjusted). The row is not reported
* if either group has fewer than MIN_CELL respondents.
capture program drop t5_row
program define t5_row
    syntax, LABel(string) ANY(varname)
    quietly count if in_xd_main & `any' == 1
    local ne = r(N)
    quietly count if in_xd_main & `any' == 0
    local nu = r(N)
    if `ne' < $MIN_CELL | `nu' < $MIN_CELL {
        local se = cond(`ne' < $MIN_CELL, "<$MIN_CELL", "not reported")
        local su = cond(`nu' < $MIN_CELL, "<$MIN_CELL", "not reported")
        post t5 (`"`label'"') ("`se'") ("`su'") (.) (.) (.) (.) (.) ("") ("")
        exit
    }
    quietly summarize phq4 if in_xd_main & `any' == 1
    local me = r(mean)
    local sde = r(sd)
    quietly summarize phq4 if in_xd_main & `any' == 0
    local mu = r(mean)
    local sdu = r(sd)
    quietly count if in_xd_main & `any' == 1 & phq4 >= 6
    local ke = r(N)
    quietly count if in_xd_main & `any' == 0 & phq4 >= 6
    local ku = r(N)
    cell_fmt `ke' `ne' `=`ne' - `ke''
    local pe "`r(pct)'"
    cell_fmt `ku' `nu' `=`nu' - `ku''
    local pu "`r(pct)'"
    post t5 (`"`label'"') ("`ne'") ("`nu'") (`me') (`sde') (`mu') (`sdu') (`me' - `mu') ("`pe'") ("`pu'")
end

* Rows of a frequency table (category, n, %) for one variable of the estimation
* sample. Stops if a single suppressed cell could be recovered from the total.
capture program drop freq_rows
program define freq_rows
    syntax varname, HANDLE(name) CODES(numlist) LABELS(string asis)
    quietly count if in_xd_main & !missing(`varlist')
    local tot = r(N)
    local nsupp 0
    local i 0
    foreach c of local codes {
        local ++i
        local lab : word `i' of `labels'
        quietly count if in_xd_main & `varlist' == `c'
        cell_fmt `r(N)' `tot' 0
        if "`r(pct)'" == "" & "`r(n)'" != "0" local ++nsupp
        post `handle' (`"`lab'"') ("`r(n)'") ("`r(pct)'")
    }
    if `nsupp' == 1 {
        display as error "`varlist': a suppressed cell can be recovered from the total"
        exit 459
    }
end

* Generalized variance inflation factors for groups of dummies (Fox & Monette, 1992)
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
* 1. Import and coding
* -----------------------------------------------------------------------------
import excel using "$DATA", firstrow allstring clear
foreach v of varlist _all {
    quietly replace `v' = strtrim(`v')
}

* Substantive data: at least one answer after the two screening questions
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
map_codes c3_experience,          gen(exper)     from(duoi1 13 35 510 tu10 kmtl) to(1 2 3 4 5 9)
map_codes c4_industry,            gen(industry)  from(tcnh cntt gd yt tmdv sxcn ttmkt dlnhks khac kmtl) to(1 2 3 4 5 6 7 10 11 9)
map_codes c5_position,            gen(position)  from(nv tn_gs qlct qlcc kad_khac kmtl) to(1 2 3 4 6 9)
map_codes c6_employment,          gen(emptype)   from(tt_luong bt_luong thoivu ctv freelancer khac kmtl) to(1 2 3 4 5 7 9)
map_codes c8_employer_type,       gen(orgtype)   from(nn tn_trongnuoc fdi ngo tudoanh khac kmtl) to(1 2 3 4 5 6 9)
map_codes c9_employer_size,       gen(orgsize)   from(duoi50 50199 200499 tu500 kad_kr kmtl) to(1 2 3 4 97 9)
map_codes c7_social_insurance,    gen(socins)    from(co khong kad kr kmtl) to(1 2 3 4 9)
map_codes c13_hours,              gen(hours)     from(duoi20 2035 3545 4555 tu55 kxd_kmtl) to(1 2 3 4 5 9)
map_codes c18_disclosure,         gen(disclose)  from(chua_ck vai_dn dn_va_ql rong_rai kad_kmtl) to(1 2 4 5 9)

* PHQ-4 items: positions 1-2 are the GAD-2 items; in the questionnaire,
* position 3 is "feeling down" and position 4 is "little interest"
destring c21_1, gen(phqi1)
destring c21_2, gen(phqi2)
destring c21_4, gen(phqi3)
destring c21_3, gen(phqi4)
forvalues j = 1/8 {
    destring c19_`j', gen(stig`j')
}
* Items of the two other Likert scales, read only for the response-quality flag
forvalues j = 1/4 {
    destring c22_`j', gen(conc`j')
    destring c24_`j', gen(dei`j')
}

keep n_answered age18 has_job lgbt_self orient gender_id sex_birth agegrp educ relstat region industry disclose ///
    $XJ $PHQI $STIG8 $CONC $DEI

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

label define yesno_lb    0 "No" 1 "Yes"
label define lgbtself_lb 0 "No" 1 "Yes" 8 "Unsure" 9 "Prefer not to answer"
label define orient_lb   1 "Heterosexual" 2 "Gay" 3 "Lesbian" 4 "Bisexual" 5 "Pansexual" ///
                         6 "Other" 7 "Questioning" 9 "Prefer not to answer"
label define gender_lb   1 "Man" 2 "Woman" 3 "Transgender man" 4 "Transgender woman" 5 "Nonbinary" ///
                         6 "Other" 9 "Prefer not to answer"
label define sex_lb      1 "Male" 2 "Female" 9 "Prefer not to answer"
label define age_lb      1 "18-24" 2 "25-34" 3 "35-44" 4 "45 or older" 9 "Prefer not to answer"
label define educ_lb     1 "Upper secondary or below" 2 "College" 3 "University" 4 "Postgraduate" ///
                         9 "Prefer not to answer"
label define rel_lb      1 "No partner" 2 "Partner" 3 "Separated, divorced, or widowed" 9 "Prefer not to answer"
label define region_lb   1 "Hanoi" 2 "Ho Chi Minh City" 3 "Da Nang" 4 "Elsewhere" 9 "Prefer not to answer"
label define disc_lb     1 "Not disclosed at work" 2 "A few close colleagues" 3 "Some colleagues, not the manager" ///
                         4 "Colleagues and direct manager" 5 "Widely disclosed" 9 "Not applicable or prefer not to answer"
label values age18 has_job yesno_lb
label values lgbt_self lgbtself_lb
label values orient orient_lb
label values gender_id gender_lb
label values sex_birth sex_lb
label values agegrp age_lb
label values educ educ_lb
label values relstat rel_lb
label values region region_lb
label define ind_lb      1 "Finance and banking" 2 "Information technology" 3 "Education" 4 "Health care" ///
                         5 "Trade and services" 6 "Manufacturing" 7 "Media and marketing" ///
                         10 "Tourism and hospitality" 11 "Other" 9 "Prefer not to answer"
label values disclose disc_lb
label values industry ind_lb
label variable agegrp    "Age group"
label variable sex_birth "Sex assigned at birth"
label variable educ      "Education"
label variable relstat   "Relationship status"
label variable region    "Region of work"
label variable disclose  "Disclosure at work"
label variable industry  "Industry"

* -----------------------------------------------------------------------------
* 2. Derived variables and sample indicators
* -----------------------------------------------------------------------------
gen byte substantive = n_answered > 0
gen byte in_base = has_job == 1 & substantive
gen byte lgbt = lgbt_self == 1
gen byte in_lgbt = in_base & lgbt
* No respondent with substantive data failed the age screening question
assert age18 == 1 if in_base

* Gender minority status: transgender man or woman, nonbinary, other gender identity
gen byte gmin = .
replace gmin = 0 if inlist(gender_id, 1, 2)
replace gmin = 1 if inlist(gender_id, 3, 4, 5, 6)
replace gmin = 9 if gender_id == 9
label define gmin_lb 0 "Man or woman" 1 "Transgender, nonbinary, or other" 9 "Prefer not to answer"
label values gmin gmin_lb
label variable gmin "Gender minority status"

* Sexual orientation group; other identities and questioning form one group (98)
gen byte orientg = .
replace orientg = 1 if orient == 2
replace orientg = 2 if orient == 3
replace orientg = 3 if inlist(orient, 4, 5)
replace orientg = 98 if inlist(orient, 1, 6, 7)
replace orientg = 9 if orient == 9
label define orientg_lb 1 "Gay" 2 "Lesbian" 3 "Bisexual or pansexual" 98 "Other or questioning" 9 "Prefer not to answer"
label values orientg orientg_lb
label variable orientg "Sexual orientation group"

* "Not applicable or prefer not to answer" on the stigma items (and on the
* items of the quality flag) is missing
foreach v of varlist $STIG8 $DEI {
    replace `v' = . if `v' == 9
}
* Alternative rule: "prefer not to answer" on a covariate is missing
foreach v of global XD {
    gen `v'_alt = `v'
    replace `v'_alt = . if `v' == 9
}

egen byte phq_n = rownonmiss($PHQI)
gen byte phq4 = phqi1 + phqi2 + phqi3 + phqi4 if phq_n == 4
gen double phq4_frac = phq4 / 12
gen byte phq4_zero = phq4 == 0 if !missing(phq4)

* Stigma index S: mean of the eight situations, at least six answered.
* S7 (situations 1-7, at least four answered), the count of situations
* experienced and the complete-case mean are alternatives in Figure 2.
egen byte S_n = rownonmiss($STIG8)
egen double S_raw = rowmean($STIG8)
gen double S = S_raw if S_n >= 6 & lgbt == 1
egen byte S7_n = rownonmiss($STIG7)
egen double S7_raw = rowmean($STIG7)
gen double S7 = S7_raw if S7_n >= 4 & lgbt == 1
egen byte S_count8 = anycount($STIG8), values(1 2 3 4)
replace S_count8 = . if missing(S)
gen double S_complete8 = S if S_n == 8

* Stigma sub-indices (RQ1): interpersonal (situations 1-3) and career-related
* (4-6), each with at least two answered; gender expression (7-8), at least
* one answered
egen byte Si_n = rownonmiss($STIG_I)
egen double Si_raw = rowmean($STIG_I)
gen double S_int = Si_raw if Si_n >= 2 & lgbt == 1
egen byte Sc_n = rownonmiss($STIG_C)
egen double Sc_raw = rowmean($STIG_C)
gen double S_car = Sc_raw if Sc_n >= 2 & lgbt == 1
egen double Sg_raw = rowmean($STIG_G)
gen double S_gen = Sg_raw if lgbt == 1
drop Si_n Si_raw Sc_n Sc_raw Sg_raw

* Experienced at least once (any) and often or very often (often), for each
* situation, each group of situations and any of the eight. A group counts as
* experienced when its sub-index is above zero.
forvalues j = 1/8 {
    gen byte stig`j'_any = stig`j' >= 1 if !missing(stig`j')
    gen byte stig`j'_often = stig`j' >= 3 if !missing(stig`j')
}
gen byte ever_exposed = S > 0 if !missing(S)
gen double S_exposed = cond(ever_exposed == 1, S, 0) if !missing(S)
egen byte max8 = rowmax($STIG8)
gen byte ever_often = max8 >= 3 if !missing(S)
foreach g in int car gen {
    local items = cond("`g'" == "int", "$STIG_I", cond("`g'" == "car", "$STIG_C", "$STIG_G"))
    egen byte max_`g' = rowmax(`items')
    gen byte `g'_any = S_`g' > 0 if !missing(S_`g')
    gen byte `g'_often = max_`g' >= 3 if !missing(S_`g')
}
drop max8 max_int max_car max_gen

* PHQ-4 severity categories (Kroenke et al., 2009)
gen byte phq4_cat = cond(phq4 <= 2, 1, cond(phq4 <= 5, 2, cond(phq4 <= 8, 3, 4))) if !missing(phq4)

* Response quality: identical answers on all three Likert scales of the
* questionnaire (PHQ-4 and the two other scales), or contradictory answers
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

gen byte in_main = in_lgbt & !missing(phq4) & !missing(S)
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
gen byte in_rq1     = in_xd_main & !missing(S_int, S_car, S_gen)
drop xd_miss xda_miss xj_miss

* Levels of exposure: cut at the median of S among exposed respondents of the estimation sample
quietly summarize S if in_xd_main & S > 0, detail
scalar S_med_exposed = r(p50)
gen byte S3 = .
replace S3 = 0 if S == 0
replace S3 = 1 if S > 0 & S <= S_med_exposed & !missing(S)
replace S3 = 2 if S > S_med_exposed & !missing(S)
label define S3_lb 0 "None" 1 "Low" 2 "High"
label values S3 S3_lb

gen byte lgbt_consistent = lgbt == 1 & (inrange(orient, 2, 6) | gmin == 1)

* -----------------------------------------------------------------------------
* 3. Sample flow (Table 1)
* -----------------------------------------------------------------------------
tempname F
tempfile flow
postfile `F' str80 step long(n expected) using "`flow'", replace
quietly count
post `F' ("Responses received") (r(N)) (850)
quietly count if has_job == 1
post `F' ("Reported a main income-generating job") (r(N)) (734)
quietly count if in_base
post `F' ("Substantive data: at least one answer after the screening questions") (r(N)) (719)
quietly count if in_lgbt
post `F' ("Self-identified LGBT") (r(N)) (300)
quietly count if in_main
post `F' ("Complete PHQ-4 and valid stigma index (at least six of eight situations)") (r(N)) (272)
quietly count if in_xd_main
post `F' ("Estimation sample: complete covariates, main rule") (r(N)) (235)
quietly count if in_xd_alt
post `F' ("Complete covariates, prefer not to answer as missing") (r(N)) (226)
quietly count if in_rq1
post `F' ("Estimation sample with valid scores on the three stigma sub-indices (RQ1)") (r(N)) (233)
postclose `F'
preserve
use "`flow'", clear
gen byte match = n == expected
list, noobs abbreviate(20)
xl_out "Table1"
quietly count if !match
local nmis = r(N)
restore
if `nmis' > 0 {
    display as error "Sample flow differs from the documented counts at `nmis' step(s). Check the input file."
    exit 9
}

* -----------------------------------------------------------------------------
* 4. Descriptive statistics
* -----------------------------------------------------------------------------

* Table 2: characteristics of the estimation sample. Health care is shown
* with other industries because it has fewer than MIN_CELL respondents.
gen byte orient_t2 = orient if inlist(orient, 2, 3, 4, 5)
replace orient_t2 = 0 if missing(orient_t2)
label define orient_t2_lb 2 "Gay" 3 "Lesbian" 4 "Bisexual" 5 "Pansexual" 0 "Other, questioning, or not stated"
label values orient_t2 orient_t2_lb
label variable orient_t2 "Sexual orientation"
gen byte ind_t2 = industry
replace ind_t2 = 11 if inlist(industry, 4, 10)
label define ind_t2_lb 1 "Finance and banking" 2 "Information technology" 3 "Education" 5 "Trade and services" ///
    6 "Manufacturing" 7 "Media and marketing" 11 "Health care, tourism, or other"
label values ind_t2 ind_t2_lb
label variable ind_t2 "Industry"

tempfile t2file
postfile t2 str60 characteristic str60 category str24 main_sample using "`t2file'", replace
quietly count if in_xd_main
post t2 ("n") ("") ("`r(N)'")
t2_rows agegrp,    codes(1 2 3 4)
t2_rows sex_birth, codes(1 2)
t2_rows educ,      codes(1 2 3 4)
t2_rows relstat,   codes(1 2 3 9)
t2_rows region,    codes(1 2 3 4)
t2_rows orient_t2, codes(2 3 4 5 0)
t2_rows ind_t2,    codes(1 2 3 5 6 7 11)
postclose t2
preserve
use "`t2file'", clear
xl_out "Table2"
restore

* PHQ-4 scores in the estimation sample (Methods)
preserve
keep if in_xd_main
collapse (mean) mean_phq4=phq4 (sd) sd_phq4=phq4 (count) n=phq4 (mean) share_zero=phq4_zero
xl_out "Symptoms"
restore

* Reliability in the estimation sample (Methods)
tempfile relfile
postfile rel str40 scale double alpha long N using "`relfile'", replace
rel_post $PHQI if in_xd_main, name("PHQ-4")
rel_post $STIG8 if in_xd_main, name("Stigma, situations 1-8")
rel_post $STIG_I if in_xd_main, name("Interpersonal stigma, situations 1-3")
rel_post $STIG_C if in_xd_main, name("Career-related stigma, situations 4-6")
rel_post $STIG_G if in_xd_main, name("Gender-expression stigma, situations 7-8")
postclose rel
preserve
use "`relfile'", clear
xl_out "Reliability"
restore

* Labels of the eight situations and the three groups (Tables 4 and 5)
local lab_all "Any of situations 1-8"
local lab_int "Interpersonal: any of situations 1-3"
local lab_car "Career-related: any of situations 4-6"
local lab_gen "Gender expression: any of situations 7-8"
local lab1 "1 Offensive jokes or comments"
local lab2 "2 Unwanted personal questions"
local lab3 "3 Disclosure or threatened disclosure without consent"
local lab4 "4 Exclusion from training or career development"
local lab5 "5 Unfair evaluation, pay, or promotion"
local lab6 "6 Unfavourable work assignments"
local lab7 "7 Pressure to conform to gender stereotypes"
local lab8 "8 Difficulty with name, pronouns, dress, or restrooms"
local sit_int 1 2 3
local sit_car 4 5 6
local sit_gen 7 8

* Table 4: forms of workplace stigma experienced in the previous 12 months
tempfile t4file
postfile t4 str56 form long n_valid str12(n_once pct_once n_often pct_often) double(mean_score sd_score) ///
    using "`t4file'", replace
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
xl_out "Table4"
restore

* Table 4 (continued): number of the eight situations experienced
tempfile t4nfile
postfile t4n str24 situations str12(n pct) using "`t4nfile'", replace
gen byte S_count8_c = min(S_count8, 3) if !missing(S_count8)
freq_rows S_count8_c, handle(t4n) codes(0 1 2 3) labels("0" "1" "2" "3 or more")
drop S_count8_c
postclose t4n
preserve
use "`t4nfile'", clear
xl_out "Table4_Number"
restore

* Table 5: PHQ-4 by experience of each form of stigma (descriptive, unadjusted)
tempfile t5file
postfile t5 str56 form str12(n_exposed n_unexposed) double(mean_exposed sd_exposed mean_unexposed ///
    sd_unexposed difference) str8(pct6_exposed pct6_unexposed) using "`t5file'", replace
t5_row, label("`lab_all'") any(ever_exposed)
foreach g in int car gen {
    t5_row, label("`lab_`g''") any(`g'_any)
    foreach j of local sit_`g' {
        t5_row, label("`lab`j''") any(stig`j'_any)
    }
}
postclose t5
preserve
use "`t5file'", clear
xl_out "Table5"
restore

* Table 3: study variables in the estimation sample, with PHQ-4 severity categories
tempfile sevfile
postfile sev str24 category str12(n pct) using "`sevfile'", replace
freq_rows phq4_cat, handle(sev) codes(1 2 3 4) labels("0-2 (none)" "3-5 (mild)" "6-8 (moderate)" "9-12 (severe)")
postclose sev
preserve
use "`sevfile'", clear
xl_out "Table3_Severity"
restore

preserve
keep if in_xd_main
tempname MB
tempfile mbfile
postfile `MB' str16 variable long n double(mean sd median min max) using "`mbfile'", replace
foreach v in phq4 S $RQ1 {
    quietly summarize `v', detail
    post `MB' ("`v'") (r(N)) (r(mean)) (r(sd)) (r(p50)) (r(min)) (r(max))
}
quietly count if S > 0
post `MB' ("pct S > 0") (r(N)) (100 * r(N) / _N) (.) (.) (.) (.)
quietly count if phq4 >= 6
post `MB' ("pct PHQ-4 >= 6") (r(N)) (100 * r(N) / _N) (.) (.) (.) (.)
postclose `MB'
quietly pwcorr phq4 S $RQ1
matrix TQ = r(C)
use "`mbfile'", clear
xl_out "Table3_Descriptives"
clear
svmat TQ, names(col)
gen str8 variable = ""
local i 0
foreach v in phq4 S $RQ1 {
    local ++i
    quietly replace variable = "`v'" in `i'
}
order variable
xl_out "Table3_Correlations"
restore

* Respondents with and without complete data (Results)
preserve
keep if in_lgbt
gen byte has_phq4 = !missing(phq4)
collapse (mean) mean_S=S (count) n_S=S n=lgbt, by(has_phq4)
gen comparison = "LGBT respondents: with / without PHQ-4"
tempfile mis1
save "`mis1'"
restore
preserve
keep if in_main
collapse (mean) mean_phq4=phq4 mean_S=S (sd) sd_phq4=phq4 sd_S=S (count) n=phq4, by(in_xd_main)
gen comparison = "Valid PHQ-4 and stigma index: with / without complete covariates"
append using "`mis1'"
order comparison
xl_out "MissingData"
restore

* -----------------------------------------------------------------------------
* 5. Merging sparse covariate categories
* -----------------------------------------------------------------------------
tempfile lvfile
postfile lv str24 variable double(old_code new_code) str8 n using "`lvfile'", replace

* Copies for the post hoc sensitivity analyses (Table S6), merged in their own samples
clonevar exper_s7 = exper
clonevar disclose_s7 = disclose
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
gen byte s7_exper = in_xd_main & !missing(exper_s7)
gen byte s7_disc  = in_xd_main & !missing(disclose_s7)
collapse_sparse exper_s7,    touse(s7_exper) min($MIN_LEVEL) kind(ordered) special(9 97) pooled(98)
collapse_sparse disclose_s7, touse(s7_disc)  min($MIN_LEVEL) kind(ordered) special(9 97) pooled(98)
postclose lv
preserve
use "`lvfile'", clear
if _N == 0 {
    set obs 1
    replace variable = "No category merged"
}
xl_out "MergedCategories"
restore

* Table S1: PHQ-4 by the covariates. Categories with fewer than MIN_CELL
* respondents, and gender minority status, are estimated but not reported.
tempfile resfile
postfile res str20 part str16 outcome str60 spec str40 term double(b se lb ub p) long N str244 note ///
    using "`resfile'", replace
regress phq4 i.($XD) if in_xd_main, vce(hc3)
matrix RT = r(table)
local cn : colnames RT
foreach c of local cn {
    if "`c'" == "_cons" | strpos("`c'", "b.") | strpos("`c'", "o.") continue
    local lev = substr("`c'", 1, strpos("`c'", ".") - 1)
    local var = substr("`c'", strpos("`c'", ".") + 1, .)
    quietly count if e(sample) & `var' == `lev'
    if "`var'" == "gmin" {
        post_val, part("TableS1") outcome("phq4") spec("XD") coef("`c'") note("Gender minority status: not reported")
    }
    else if r(N) < $MIN_CELL {
        post_val, part("TableS1") outcome("phq4") spec("XD") coef("`c'") note("Fewer than $MIN_CELL respondents: not reported")
    }
    else {
        post_coef, part("TableS1") outcome("phq4") spec("XD") coef(`c') table(RT)
    }
}

if $RUN_MODELS == 0 {
    postclose res
    preserve
    use "`resfile'", clear
    xl_out "TableS1"
    restore
    display as result "Data preparation and descriptive tables finished: $OUT/results.xlsx"
    log close main
    exit
}

* -----------------------------------------------------------------------------
* 6. H1: stigma and PHQ-4 (Table 6)
* -----------------------------------------------------------------------------
regress phq4 S i.($XD) if in_xd_main, vce(hc3)
matrix RT = r(table)
local mde = string(2.8 * _se[S], "%5.2f")
post_coef, part("H1") outcome("phq4") spec("XD") coef(S) table(RT) note("MDE approx. `mde'")

* The same estimate per standard deviation of S, and fully standardized
local nH = e(N)
local j = colnumb(RT, "S")
quietly summarize S if e(sample)
local sdS = r(sd)
quietly summarize phq4 if e(sample)
local sdY = r(sd)
local sdS_s : display %5.3f `sdS'
local std_s : display %5.3f RT[1,`j'] * `sdS' / `sdY'
post_val, part("PerSD") outcome("phq4") spec("XD, per SD of S") coef("S") ///
    est(`=RT[1,`j'] * `sdS'') stderr(`=RT[2,`j'] * `sdS'') lower(`=RT[5,`j'] * `sdS'') ///
    upper(`=RT[6,`j'] * `sdS'') pval(`=RT[4,`j']') nobs(`nH') ///
    note("SD of S = `sdS_s'; standardized coefficient = `std_s'")

* Two one-sided tests against the smallest effect size of interest
local df = e(df_r)
local bS = _b[S]
local seS = _se[S]
local lo90 = `bS' - invttail(`df', 0.05) * `seS'
local hi90 = `bS' + invttail(`df', 0.05) * `seS'
local p1 = ttail(`df', (`bS' + $SESOI) / `seS')
local p2 = 1 - ttail(`df', (`bS' - $SESOI) / `seS')
local ptost = max(`p1', `p2')
local eq = cond(`lo90' > -$SESOI & `hi90' < $SESOI, "yes", "no")
post_val, part("H1_TOST") outcome("phq4") spec("XD, 90% CI") coef("S") est(`bS') stderr(`seS') ///
    lower(`lo90') upper(`hi90') pval(`ptost') nobs(`nH') note("SESOI +/-$SESOI; equivalence: `eq'")

regress phq4 S i.($XD) i.($XJ) if in_xj, vce(hc3)
post_coef, part("H1") outcome("phq4") spec("XD + XJ") coef(S)
regress phq4 S i.(`xdalt') if in_xd_alt, vce(hc3)
post_coef, part("H1") outcome("phq4") spec("XD, prefer not to answer as missing") coef(S)

* -----------------------------------------------------------------------------
* 7. RQ1: forms of stigma (three groups of situations) and PHQ-4, exploratory (Table 7)
* -----------------------------------------------------------------------------
* All RQ1 models use the respondents with valid scores on the three
* sub-indices. Each sub-index is standardized in that sample, so estimates
* are PHQ-4 points per SD.
local zs
foreach v of global RQ1 {
    quietly summarize `v' if in_rq1
    local sd_`v' : display %5.3f r(sd)
    gen double z_`v' = (`v' - r(mean)) / r(sd) if in_rq1
    local zs `zs' z_`v'
}

* One model per sub-index
foreach v of global RQ1 {
    regress phq4 z_`v' i.($XD) if in_rq1, vce(hc3)
    post_coef, part("RQ1") outcome("phq4") spec("separate") coef(z_`v') note("SD of `v' = `sd_`v''")
}

* The three sub-indices together, and the pairwise differences
regress phq4 `zs' i.($XD) if in_rq1, vce(hc3)
matrix RT = r(table)
local nJ = e(N)
foreach v of global RQ1 {
    post_coef, part("RQ1") outcome("phq4") spec("joint") coef(z_`v') table(RT)
}
local nz : word count `zs'
forvalues a = 1/`=`nz' - 1' {
    forvalues b = `=`a' + 1'/`nz' {
        local za : word `a' of `zs'
        local zb : word `b' of `zs'
        lincom `za' - `zb'
        post_val, part("RQ1") outcome("phq4") spec("joint, difference") coef("`za' - `zb'") ///
            est(`r(estimate)') stderr(`r(se)') lower(`r(lb)') upper(`r(ub)') pval(`r(p)') nobs(`nJ')
    }
}
drop `zs'

* -----------------------------------------------------------------------------
* 8. Supplementary exploratory analyses (Table S4)
* -----------------------------------------------------------------------------

* One model per situation; not estimated if fewer than MIN_CELL respondents
* experienced it or did not experience it
forvalues j = 1/8 {
    quietly count if in_xd_main & stig`j'_any == 1
    local nexp = r(N)
    quietly count if in_xd_main & stig`j'_any == 0
    local nun = r(N)
    if `nexp' < $MIN_CELL | `nun' < $MIN_CELL {
        post_val, part("Situation_notest") outcome("phq4") spec("situation `j'") coef("1.stig`j'_any") ///
            note("Fewer than $MIN_CELL respondents in one group")
        continue
    }
    regress phq4 i.stig`j'_any i.($XD) if in_xd_main, vce(hc3)
    post_coef, part("Situation") outcome("phq4") spec("situation `j'") coef(1.stig`j'_any)
}

* Three levels of exposure
regress phq4 i.S3 i.($XD) if in_xd_main, vce(hc3)
matrix RT = r(table)
post_coef, part("Levels") outcome("phq4") spec("low vs. none") coef(1.S3) table(RT)
post_coef, part("Levels") outcome("phq4") spec("high vs. none") coef(2.S3) table(RT)

* -----------------------------------------------------------------------------
* 9. Diagnostics of the main model, descriptive only (Table S2)
* -----------------------------------------------------------------------------
tempname D
tempfile diag
postfile `D' str40 diagnostic double(statistic df p) str60 note using "`diag'", replace
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
post `D' ("Cook's distance > 4/n") (r(N)) (.) (.) ("")
quietly count if flag_lev == 1
post `D' ("Leverage > 2k/n") (r(N)) (.) (.) ("")
quietly summarize lev
post `D' ("Largest leverage") (r(max)) (.) (.) ("")

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
xl_out "TableS2"
restore

* -----------------------------------------------------------------------------
* 10. Robustness checks (Table 8) and sensitivity analysis (Table S3)
* -----------------------------------------------------------------------------

* Any exposure and intensity among exposed respondents
regress phq4 i.ever_exposed S_exposed i.($XD) if in_xd_main, vce(hc3)
matrix RT = r(table)
post_coef, part("Robust") outcome("phq4") spec("any exposure") coef(1.ever_exposed) table(RT)
post_coef, part("Robust") outcome("phq4") spec("intensity among exposed") coef(S_exposed) table(RT)

* Restricted cubic spline, knots at the 10th, 50th and 90th percentiles among exposed
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
    post_coef, part("Robust") outcome("phq4") spec("restricted cubic spline") coef(Ssp1) table(RT) ///
        note("test of nonlinearity: p = `pnl'")
}
else {
    post_val, part("Robust") outcome("phq4") spec("restricted cubic spline") coef("-") note("knots coincide")
}

* Fractional logit for PHQ-4/12; average marginal effect rescaled to PHQ-4 points
fracreg logit phq4_frac S i.($XD) if in_xd_main
local nF = e(N)
margins, dydx(S) post
nlcom (ame12: _b[S] * 12), post
post_val, part("Robust") outcome("phq4") spec("fractional logit, AME x 12") coef("S") ///
    est(`=_b[ame12]') stderr(`=_se[ame12]') lower(`=_b[ame12] - invnormal(0.975) * _se[ame12]') ///
    upper(`=_b[ame12] + invnormal(0.975) * _se[ame12]') pval(`=2 * normal(-abs(_b[ame12] / _se[ame12]))') nobs(`nF')

regress phq4 S i.($XD) if in_xd_main & flag_quality == 0, vce(hc3)
post_coef, part("Robust") outcome("phq4") spec("excluding flagged responses") coef(S)

regress phq4 S i.($XD) if in_xd_main & flag_cook != 1, vce(hc3)
post_coef, part("Robust") outcome("phq4") spec("excluding Cook's distance > 4/n") coef(S)

* Restricted wild bootstrap with Webb weights
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
    post_val, part("Robust") outcome("phq4") spec("restricted wild bootstrap, Webb") coef("S") ///
        est(`bW') lower(`loW') upper(`hiW') pval(`pW') nobs(`nW') note("$WILD_REPS replications")
}
else {
    post_val, part("Robust") outcome("phq4") spec("restricted wild bootstrap, Webb") coef("S") note("Stata error `=_rc'")
}

* Industry left out of the covariates
local xd_all $XD
local ind_one industry
local xd_noind : list xd_all - ind_one
regress phq4 S i.(`xd_noind') if in_xd_main, vce(hc3)
post_coef, part("Robust") outcome("phq4") spec("covariates without industry") coef(S)

* Multiple imputation by chained equations among the LGBT respondents
preserve
keep if in_lgbt
capture noisily {
    mi set wide
    mi register imputed phq4 S $XD
    mi impute chained (pmm, knn(5)) phq4 S (mlogit, augment) $XD, add($MI_M) rseed($SEED)
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
    post_val, part("Robust") outcome("phq4") spec("multiple imputation, m = $MI_M") coef("S") ///
        est(`bM') stderr(`seM') lower(`=`bM' - invttail(`dfS', 0.025) * `seM'') ///
        upper(`=`bM' + invttail(`dfS', 0.025) * `seM'') pval(`=2 * ttail(`dfS', abs(`bM' / `seM'))') ///
        nobs(`nM') note("df = `dfS_s'")
}
else {
    post_val, part("Robust") outcome("phq4") spec("multiple imputation, m = $MI_M") coef("S") note("Stata error `rc'")
}

* Sensitivity to unmeasured confounding (Table S3, printed in the log).
* Benchmarks: sex assigned at birth and education. gbenchmark() needs at least
* two variables, so a single dummy is passed to benchmark().
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
    local ngb : word count `gb'
    if `ngb' > 1 local bopt "gbenchmark(`gb') gname(`g')"
    else local bopt "benchmark(`gb')"
    display as text _n "{hline 60}" _n "Table S3: sensemakr, benchmark `g'" _n "{hline 60}"
    capture noisily sensemakr phq4 S `xd_dum', treat(S) `bopt' kd(1 2 3)
}
restore

* -----------------------------------------------------------------------------
* 11. Post hoc sensitivity analyses, specified after the main results (Table S6)
* -----------------------------------------------------------------------------
regress phq4 S if in_xd_main, vce(hc3)
post_coef, part("PostHoc") outcome("phq4") spec("unadjusted") coef(S)

regress phq4 S i.($XD) i.disclose_s7 if s7_disc, vce(hc3)
post_coef, part("PostHoc") outcome("phq4") spec("adding disclosure at work") coef(S)

regress phq4 S i.($XD) i.exper_s7 if s7_exper, vce(hc3)
post_coef, part("PostHoc") outcome("phq4") spec("adding work experience") coef(S)

local rel_reg relstat region
local xd_norr : list xd_all - rel_reg
regress phq4 S i.(`xd_norr') if in_xd_main, vce(hc3)
post_coef, part("PostHoc") outcome("phq4") spec("XD without relationship status and region") coef(S)

* -----------------------------------------------------------------------------
* 12. Specification curve (Figure 2; Table S5)
* -----------------------------------------------------------------------------
tempname SP
tempfile specfile
postfile `SP' str40 spec double(b se lb ub p sd_index) long N using "`specfile'", replace
foreach idx in S S7 S_count8 S_complete8 {
foreach ctl in XD XDXJ {
foreach def in self consistent {
foreach tg in keep drop {
    local cond "in_lgbt & !missing(phq4) & !missing(`idx')"
    if "`def'" == "self"       local cond "`cond' & lgbt == 1"
    if "`def'" == "consistent" local cond "`cond' & lgbt_consistent == 1"
    if "`tg'" == "drop"        local cond "`cond' & gmin != 1"
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
gen double b_sd  = b * sd_index
gen double lb_sd = lb * sd_index
gen double ub_sd = ub * sd_index
gen byte main = spec == "S|XD|self|keep"
split spec, parse("|") gen(choice)
sort b_sd
gen rank = _n

* Estimates in the upper part and the choices of each specification in the
* lower part share one plot region, so that the columns line up
quietly summarize lb_sd
local lo = min(r(min), 0)
quietly summarize ub_sd
local hi = ceil(2 * r(max)) / 2
local sep = `lo' - 0.25
local step 0.3
local rl1 "Index: 8-situation mean"
local rl2 "Index: 7-situation mean"
local rl3 "Index: count of situations"
local rl4 "Index: complete 8 only"
local rl5 "Covariates: X{sup:D} + X{sup:J}"
local rl6 "LGBT: self-identification + SOGI"
local rl7 "Transgender/nonbinary excluded"
local ylab
local grid
foreach v of numlist 0(0.5)`hi' {
    local vl = cond(`v' == floor(`v'), string(`v'), string(`v', "%3.1f"))
    local ylab `"`ylab' `v' "`vl'""'
    if `v' > 0 local grid `grid' `v'
}
forvalues k = 1/7 {
    local pos`k' = `sep' - `step' * `k'
    local ylab `"`ylab' `pos`k'' "`rl`k''""'
}
local ymin = `pos7' - `step' / 2
gen double y1 = `pos1' if choice1 == "S"
gen double y2 = `pos2' if choice1 == "S7"
gen double y3 = `pos3' if choice1 == "S_count8"
gen double y4 = `pos4' if choice1 == "S_complete8"
gen double y5 = `pos5' if choice2 == "XDXJ"
gen double y6 = `pos6' if choice3 == "consistent"
gen double y7 = `pos7' if choice4 == "drop"
twoway (rcap lb_sd ub_sd rank, lcolor(gs10)) ///
       (scatter b_sd rank if !main, mcolor(navy) msize(small)) ///
       (scatter b_sd rank if main, mcolor(cranberry) msymbol(D)) ///
       (scatter y1 y2 y3 y4 y5 y6 y7 rank, msymbol(S S S S S S S) ///
           mcolor(navy navy navy navy navy navy navy) msize(vsmall vsmall vsmall vsmall vsmall vsmall vsmall)), ///
       yline(`grid', lcolor(gs14) lwidth(vthin)) yline(0, lpattern(dash) lcolor(gs8)) ///
       yline(`sep', lcolor(black) lwidth(thin)) ///
       ylabel(`ylab', angle(0) labsize(small) nogrid) yscale(range(`ymin' `hi')) ytitle("") ///
       xlabel(1 8 16 24 32) xscale(range(0.5 32.5)) xtitle("Specification (ranked by estimate)") ///
       title("PHQ-4 difference per SD of the stigma index (95% CI)", size(medsmall) position(11) span) ///
       legend(order(2 "Other specifications" 3 "Main specification") position(6) rows(1) region(lstyle(none))) ///
       graphregion(color(white)) xsize(10) ysize(7)
graph export "$OUT/figure2.png", replace width(2400)
drop y1-y7 choice1-choice4 rank main
xl_out "TableS5"
restore

* -----------------------------------------------------------------------------
* 13. Multiple-testing adjustment and export
* -----------------------------------------------------------------------------
postclose res
preserve
use "`resfile'", clear
gen long row_id = _n

* H1 is the single hypothesis test. Benjamini-Hochberg within the separate
* RQ1 models and within the situations.
gen str10 fam_bh = ""
replace fam_bh = "RQ1" if part == "RQ1" & spec == "separate"
replace fam_bh = "Situation" if part == "Situation"
gen double p_tmp = p if fam_bh != ""
padjust p_tmp, gen(p_bh) by(fam_bh)
drop p_tmp fam_bh

gen str10 paper_table = ""
replace paper_table = "Table S1" if part == "TableS1"
replace paper_table = "Table 6"  if inlist(part, "H1", "H1_TOST", "PerSD")
replace paper_table = "Table 7"  if part == "RQ1"
replace paper_table = "Table 8"  if part == "Robust"
replace paper_table = "Table S4" if inlist(part, "Situation", "Situation_notest", "Levels")
replace paper_table = "Table S6" if part == "PostHoc"

sort row_id
drop row_id
order paper_table part outcome spec term b se lb ub p p_bh N note
tempfile allres
save "`allres'"
xl_out "AllResults"
foreach t in "Table 6" "Table 7" "Table 8" "Table S1" "Table S4" "Table S6" {
    local sheet : subinstr local t " " "", all
    use if paper_table == "`t'" using "`allres'", clear
    xl_out "`sheet'"
}
restore

display as result "Finished: $OUT/results.xlsx, $OUT/figure2.png, $OUT/analysis.log"
log close main

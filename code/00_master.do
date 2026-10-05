* =============================================================================
* 00_master.do — chạy toàn bộ pipeline
* Cách dùng: trong Stata 17, cd tới thư mục gốc của repo, rồi: do code/00_master.do
* =============================================================================
version 17
clear all
set more off
set varabbrev off

capture confirm file "config/settings.do"
if _rc {
    di as error "Hãy cd tới thư mục gốc của repo trước khi chạy (không thấy config/settings.do)."
    exit 601
}

do "config/settings.do"
foreach d in "$DERIVED" "$TAB" "$FIG" "$LOGS" {
    capture mkdir "`d'"
}

capture log close _all
log using "$LOGS/master_`c(current_date)'.log", replace text name(master)

* Gói ngoài cần có (cài một lần, cần Internet):
*   ssc install sensemakr
capture which sensemakr
if _rc di as text "Cảnh báo: chưa cài sensemakr (ssc install sensemakr); 09_robustness sẽ bỏ qua phần độ nhạy."
*   ssc install boottest
capture which boottest
if _rc di as text "Cảnh báo: chưa cài boottest (ssc install boottest); 09_robustness sẽ bỏ qua wild bootstrap."

do "code/lib/programs.do"

do "code/01_import_clean.do"
do "code/02_build_indices.do"
do "code/03_sample_flow.do"
do "code/04_descriptives.do"
do "code/04b_collapse_levels.do"
do "code/05_main_models.do"
do "code/06_path_H3.do"
do "code/07_exploratory.do"
do "code/08_diagnostics.do"
do "code/09_robustness.do"
do "code/10_spec_curve.do"
do "code/11_tables.do"

di as result "Xong. Bảng ở $TAB, hình ở $FIG."
log close master


********************************************************************************
* 01_construct_msa_data.do
* ------------------------------------------------------------------------------
* Purpose:
*   Build the 2019 MSA-level mobility dataset used in Figures 1–3 and
*   Supplementary Figures 1 & 3.
*   Imports area, HHI (Herfindahl index), FAR density, region, and mobility metrics; filters,
*   collapses, merges, and exports both .dta and .csv outputs.
*
* Usage:
*   In Stata 16 or higher, run:
*     do 01-Clean-Data-MSA-Level.do
*
* Requirements:
*   • Stata 16+ (tested on 17)
*   • Files in folder structure:
*       └─ data/
*          ├─ msa/cbsa_area.csv # CBSA land area from US Census 
*          ├─ msa/cbsa_density.csv # FAR density output from 00-Construct-Density-Outcomes.R
*          ├─ msa/cbsa_region.csv # Region from US Census 
*          ├─ mobility/2019_metrics_cbsa_allfilters.csv
*          └─ herfindahl/herfindahl.csv
*
* Output:
*   • data/clean/2019_clean_msa-<filter>.dta
*   • data/clean/2019_clean_msa-<filter>.csv
*   • data/clean/cbsa_list.csv
********************************************************************************

version 16.1, clear  // Requires Stata 16.1 or newer
quietly set more off
set scheme s1color, perm

* Change working directory to replication root
cd "/Users/arianna/YSE Dropbox/Arianna Salazar Miranda/projects/Marchetti/_scripts/replication"


*-----------------------------
* 1. USER SETTINGS
*-----------------------------
local DATA_PATH "`c(pwd)'/data"
* Choose filter:
*  1: active_days > 7 & distinct_locations > 2 (Reported in Main paper)
*  2: hours_per_day >= 6 & pings_per_day >= 50 & days >= 7
*  3: hours_per_day >= 12 & pings_per_day >= 100 & days >= 14
*  4: hours_per_day >= 18 & pings_per_day >= 150 & days >= 28
local FILTER = 1  // Choose filter: 1, 2, 3, or 4

*-----------------------------
* 2. CITY SIZE
*-----------------------------
import delimited "`DATA_PATH'/msa/cbsa_area.csv", clear
keep geoid name area_km
rename geoid home_cbsa_id

tempfile city_size
save `city_size', replace


*-----------------------------
* 3. HHI
*-----------------------------
import delimited "`DATA_PATH'/herfindahl/herfindahl.csv", clear
duplicates drop home_cbsa_id, force

tempfile hhi
save `hhi', replace

*-----------------------------
* 4. FAR DENSITY
*-----------------------------
import delimited "`DATA_PATH'/msa/cbsa_density.csv", clear
rename cbsa_geoid home_cbsa_id
keep cbsa_avg_far_alt_mts home_cbsa_id

tempfile density
save `density', replace

*-----------------------------
* 5. REGION
*-----------------------------
import delimited "`DATA_PATH'/msa/cbsa_region.csv", clear
rename geoid home_cbsa_id
keep home_cbsa_id regionce
rename regionce region

gen region_name = ""
replace region_name = "Northeast" if region == 1
replace region_name = "Midwest"   if region == 2
replace region_name = "South"     if region == 3
replace region_name = "West"      if region == 4


tempfile region
save `region', replace



*-----------------------------
* 6. MOBILITY METRICS & FILTER
*-----------------------------
import delimited "`DATA_PATH'/mobility/2019_metrics_cbsa_allfilters.csv", clear
keep if f==`FILTER'
bysort home_cbsa_id: assert _N == 12  // Ensure 12 months per MSA



*-----------------------------
* 7. COLLAPSE TO ANNUAL
*-----------------------------
collapse (firstnm) msa_population=ct_population msa_no_devices_homework=no_devices_homework (mean) avg_*  [w=no_devices_homework], by(home_cbsa_id)


*-----------------------------
* 8. MERGE DATA
*-----------------------------
merge 1:1 home_cbsa_id using `city_size', keep(match master) nogenerate
merge 1:1 home_cbsa_id using `hhi',       keep(match master) nogenerate
merge 1:1 home_cbsa_id using `region',    keep(match master) nogenerate
merge 1:1 home_cbsa_id using `density',   keep(match master) nogenerate




*-----------------------------
* 9. CLEAN & FILTER
*-----------------------------
split name, p(",")
rename name1 city
rename name2 state 
drop if state == " PR"  // Continental US

*-----------------------------
* 10. EXPORT
*-----------------------------
save "`DATA_PATH'/clean/2019_clean_msa-`FILTER'.dta", replace
export delimited using "`DATA_PATH'/clean/2019_clean_msa-`FILTER'.csv", replace

keep home_cbsa_id
export delimited using "`DATA_PATH'/clean/cbsa_list.csv", replace 

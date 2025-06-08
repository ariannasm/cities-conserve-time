********************************************************************************
* Figure-3.do
* ------------------------------------------------------------------------------
* Purpose:
*   Generate Figure 3: travel time scaling analysis for non-U.S. Functional Urban Areas
*   across four countries (Indonesia (id), India (in), Mexico (mx), Nigeria (ng)).
*   Panel A shows semi-elasticity of total travel time per person vs log-population.
*   Panel B shows elasticity of log-transformed travel time vs log-population.
*
* Usage:
*   In Stata 16 or higher, run:
*     do Figure-3.do
*
* Requirements:
*   • Stata 16+ (tested on 17)
*   • Cleaned non-US mobility CSVs in data/mobility/:
*       metrics_id.csv, metrics_in.csv, metrics_mx.csv, metrics_ng.csv
*
* Outputs:
*   • figures/fig3.png
********************************************************************************

version 16.1, clear  // Requires Stata 16.1 or newer
quietly set more off
set scheme s1color, perm

* Change working directory to replication root
cd "/Users/arianna/YSE Dropbox/Arianna Salazar Miranda/projects/Marchetti/_scripts/replication"


*-----------------------------
* 1. STACK NON-US DATA
*-----------------------------

clear
// Initialize empty master dataset
tempname all_data
save `all_data', emptyok replace

local cities "id in mx ng"

// Load, filter, compute metrics, and append for each country
foreach c in `cities' {
    di as text "Processing country: `c'"
    import delimited "/Users/arianna/YSE Dropbox/Arianna Salazar Miranda/projects/Marchetti/_data/_clean/metrics_nonus/metrics_`c'.csv", clear
    
    // Apply sample filter
	keep if f==1
	
    // Aggregate monthly to annual by FUA
    collapse (firstnm) fua_population=fua_population (mean) avg_* [w=no_devices_home], by(home_fua_id)

    // Compute travel metrics
    gen time_for_speed_km = avg_time_a_pd_f3_95/60
    gen dist_for_speed_m = avg_euc_dist_a_pd_95/1000
    gen speed = dist_for_speed_m / time_for_speed_km
    gen speedvar = log10(speed)
    gen timevar = log10(time_for_speed_km)
    gen distvar = log10(dist_for_speed_m)
    
    // Population variables
    gen popvar = fua_population
    gen log_popvar = log10(fua_population)
	
    // Tag country and append
    gen country = "`c'"
    append using `all_data'
    save `all_data', replace
}

* Reload the full dataset
use `all_data', clear




*-----------------------------
* 2. PANEL A STATS
*-----------------------------
// Compute semi-elasticity regression stats by country
foreach c in `cities' {
	
	// Regress absolute travel time on log population
    reg time_for_speed_km log_popvar if country == "`c'"
    
    // Store R², β, and SE
    matrix b_`c' = e(b)
    matrix V_`c' = e(V)
    scalar R2_`c' = e(r2)
    scalar slope_`c' = b_`c'[1,1]
    scalar se_slope_`c' = sqrt(V_`c'[1,1])
    local R2_val_`c' : display %6.2f R2_`c'
    local slope_val_`c' : display %6.2f slope_`c'
    local se_val_`c' : display %6.2f se_slope_`c'
    
    // Prepare legend label
    local label_`c' "`=upper("`c'")' (R²=`R2_val_`c'') β=`slope_val_`c'' {&plusmn}`se_val_`c''"
}

summarize time_for_speed_km
local max_y = r(max) + -10
local max_y_b = r(max) + -2

*-----------------------------
* 3. PANEL A PLOT
*-----------------------------
// Plot scatter and fit for semi-elasticity

twoway ///
    (scatter time_for_speed_km log_popvar if country == "id", msymbol(circle) msize(1.1) mcolor("119 194 215%80") mlcolor("119 194 215%60")) ///
    (scatter time_for_speed_km log_popvar if country == "in", msymbol(triangle) msize(1.1) mcolor("231 224 63%80") mlcolor("231 224 63%60")) ///
    (scatter time_for_speed_km log_popvar if country == "mx", msymbol(square) msize(1.1) mcolor("236 159 54%80") mlcolor("236 159 54%60")) ///
    (scatter time_for_speed_km log_popvar if country == "ng", msymbol(diamond) msize(1.1) mcolor("203 91 102%80") mlcolor("203 91 102%60")) ///
    (lfit time_for_speed_km log_popvar if country == "id", lcolor("119 194 215") lwidth(0.8)) ///
    (lfit time_for_speed_km log_popvar if country == "in", lcolor("231 224 63") lwidth(0.8)) ///
    (lfit time_for_speed_km log_popvar if country == "mx", lcolor("236 159 54") lwidth(0.8)) ///
    (lfit time_for_speed_km log_popvar if country == "ng", lcolor("203 91 102") lwidth(0.8)), ///
    graphregion(color(white)) bgcolor(white) ///
    plotregion(lcolor(black) lwidth(thin)) ///
    title("{bf:A}", justification(left) position(11) size(6) span) ///
    ylabel(0(40)200, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
    xlabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
    ytitle("Total travel time per person (min)", size(5)) ///
    xtitle("Log{subscript:10}(population)", size(5)) ///
    xsize(6.5) ysize(5) scale(1) ///
    legend(order(1 "`label_id'" 2 "`label_in'" 3 "`label_mx'" 4 "`label_ng'") ///
        ring(0) position(11) cols(1) region(lc(none)) keygap(*.5) rowgap(*.1) size(medium) subtitle("") just(left)) ///
    name(f_1, replace)
	
	
	
*-----------------------------
* 4. PANEL B STATS
*-----------------------------
// Prepare ltotal time variable
capture drop timevar_total
gen timevar_total = timevar + log10(popvar)

local cities "id in mx ng"

// Compute elasticity regression stats by country
foreach c in `cities' {
    
    // Regress total travel time on log population
    reg timevar_total log_popvar if country == "`c'"

    // Store β and SE
    matrix b_`c' = e(b)
    matrix V_`c' = e(V)
    scalar R2_`c' = e(r2)
    scalar slope_`c' = b_`c'[1,1]
    scalar se_slope_`c' = sqrt(V_`c'[1,1])
    local R2_val_`c' : display %6.2f R2_`c'
    local slope_val_`c' : display %6.2f slope_`c'
    local se_val_`c' : display %6.3f se_slope_`c'
    
    // Prepare legend label
    local label_`c' "`=upper("`c'")' (R²=`R2_val_`c'') β=`slope_val_`c'' {&plusmn}`se_val_`c''"
}

summarize timevar_total
local max_y = r(max) + -10
local max_y_b = r(max) + -2


// Compute perfect-scaling reference line (β = 1)
summarize time_for_speed_km, meanonly
local invariant = r(mean)
gen perfect_line = log10(`invariant') + log_popvar

*-----------------------------
* 5. PANEL B PLOT
*-----------------------------
// Plot scatter, fit, and reference for elasticity
twoway ///
    (scatter timevar_total log_popvar if country == "id", msymbol(circle) msize(1.1) mcolor("119 194 215%80") mlcolor("119 194 215%60")) ///
    (scatter timevar_total log_popvar if country == "in", msymbol(triangle) msize(1.1) mcolor("231 224 63%80") mlcolor("231 224 63%60")) ///
    (scatter timevar_total log_popvar if country == "mx", msymbol(square) msize(1.1) mcolor("236 159 54%80") mlcolor("236 159 54%60")) ///
    (scatter timevar_total log_popvar if country == "ng", msymbol(diamond) msize(1.1) mcolor("203 91 102%80") mlcolor("203 91 102%60")) ///
    (lfit timevar_total log_popvar if country == "id", lcolor("119 194 215") lwidth(0.8)) ///
    (lfit timevar_total log_popvar if country == "in", lcolor("231 224 63") lwidth(0.8)) ///
    (lfit timevar_total log_popvar if country == "mx", lcolor("236 159 54") lwidth(0.8)) ///
    (lfit timevar_total log_popvar if country == "ng", lcolor("203 91 102") lwidth(0.8)) ///
	(line perfect_line log_popvar, sort lcolor(black) lpattern(dash)) , ///     
    graphregion(color(white)) bgcolor(white) ///
    plotregion(lcolor(black) lwidth(thin)) ///
    title("{bf:B}", justification(left) position(11) size(6) span) ///
    ylabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
    xlabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
    ytitle("Log{subscript:10}(Total travel time)", size(5)) ///
    xtitle("Log{subscript:10}(population)", size(5)) ///
    xsize(6.5) ysize(5) scale(1) ///
    legend(order(1 "`label_id'" 2 "`label_in'" 3 "`label_mx'" 4 "`label_ng'" 9 "Invariant scaling (β = 1)") ///
        ring(0) position(11) cols(1) region(lc(none)) keygap(*.5) rowgap(*.1) size(medium) subtitle("") just(left)) ///
    name(f_2, replace)

*-----------------------------
* 6. COMBINE & EXPORT
*-----------------------------
gr combine f_1 f_2, graphregion(color(white)) plotregion(fcolor(white)) rows(1) cols(2) name(combined, replace)
graph display combined, xsize(8)

graph export "figures/fig3.png", as(png) replace

********************************************************************************
* Figure-2.do
* ------------------------------------------------------------------------------
* Purpose:
*   Generate Figure 2 (panels A & B) illustrating how total travel time scales
*   with city population using the MSA-level mobility data.
*
* Usage:
*   In Stata 16 or higher, run:
*     do Figure-2.do
*
* Requirements:
*   • Stata 16+ (tested on 17)
*   • Output from 01_construct_msa_data.do:
*       data/clean/2019_clean_msa-<filter>.dta
*   • Directory for saving figures:
*       figures/fig1.png
*
* Outputs:
*   • figures/fig2.png
*
* Note:
*   This script uses the same filter number (<filter>) defined in
*   01_construct_msa_data.do.
********************************************************************************

version 16.1, clear  // Requires Stata 16.1 or newer
quietly set more off
set scheme s1color, perm

* Change working directory to replication root
cd "/Users/arianna/YSE Dropbox/Arianna Salazar Miranda/projects/Marchetti/_scripts/replication"

*-----------------------------
* 1. USER SETTINGS
*-----------------------------
local FILTER   = 1
local INPUT_DTA  = "data/clean/2019_clean_msa-`FILTER'.dta"
local OUTPUT_PNG = "figures/fig2.png"

*-----------------------------
* 2. LOAD DATA
*-----------------------------
use "`INPUT_DTA'", clear


*-----------------------------
* 3. VARIABLE CREATION
*-----------------------------
// Convert units
gen time_for_speed_km = avg_time_a_pd_f3_95/60
gen dist_for_speed_m = avg_euc_dist_a_pd_95/1000

// Derive travel speed
gen speed = dist_for_speed_m / time_for_speed_km

// Construct population variable
gen popvar = msa_population

// Log-transform variables
gen speedvar = log10(speed)
gen timevar = log10(time_for_speed_km)
gen distvar = log10(dist_for_speed_m)
gen log_popvar = log10(msa_population)


*-----------------------------
* 4. VARIABLE LABELS
*-----------------------------
local ltit "Log{subscript:10}(population)"


*-----------------------------
* 4. PANEL A: SEMI-ELASTICITY
*-----------------------------

// Regress travel time on population
reg time_for_speed_km log_popvar

// Extract regression coefficients and statistics
matrix b = e(b)
matrix V = e(V)
scalar R2 = e(r2)
scalar slope = b[1,1]
scalar se_slope = sqrt(V[1,1])

// Format values for annotation
local R2_val : display %6.2f R2
local slope_val : display %6.2f slope
local se_val : display %6.2f se_slope

// Determine plot annotation positions
summarize time_for_speed_km
local max_y = r(max) + 53
local max_y_b = r(max) + 60


// Create scatter + fitted line plot
twoway (scatter time_for_speed_km log_popvar if region_name == "Northeast", msymbol(circle) msize(1.1) mcolor("119 194 215%80") mlcolor("119 194 215%60")) ///
       (scatter time_for_speed_km log_popvar if region_name == "Midwest", msymbol(triangle) msize(1.1) mcolor("231 224 63%80") mlcolor("231 224 63%60")) ///
       (scatter time_for_speed_km log_popvar if region_name == "West", msymbol(square) msize(1.1) mcolor("236 159 54%80") mlcolor("236 159 54%60")) ///
       (scatter time_for_speed_km log_popvar if region_name == "South", msymbol(diamond) msize(1.1) mcolor("203 91 102%80") mlcolor("203 91 102%60")) ///
       (lfit time_for_speed_km log_popvar, lcolor(black) lwidth(0.8)), ///
       graphregion(color(white)) bgcolor(white) ///
       plotregion(lcolor(black) lwidth(thin)) ///
	   title("{bf:A}", justification(left) position(11) size(6) span) ///
       ylabel(0(20)160, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
       xlabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
       text(`max_y' 5.2 "R{superscript:2} = `R2_val'", size(4)) ///
       text(`max_y_b' 5.35 "{&beta} = `slope_val' {&plusmn}`se_val'", size(4)) ///
       ytitle("Total travel time per person (min)", size(5)) ///
       xtitle("`ltit'", size(5)) ///
       xsize(6.5) ysize(5) scale(1) ///
       legend(order(1 "Northeast" 2 "Midwest" 3 "West" 4 "South") ring(0) position(11) rows(2) region(lc(none)) keygap(*.5) rowgap(*.1) size(medium) subtitle("") just(left)) ///
	   name(f_1, replace)

	

*-----------------------------
* 5. PANEL B: ELASTICITY
*-----------------------------

// Compute travel time variable for regression
gen timevar_total = timevar + log10(msa_population)


// Regress travel time on log-population
reg timevar_total log_popvar

// Extract regression results
matrix b = e(b)
matrix V = e(V)
scalar R2 = e(r2)
scalar slope = b[1,1]
scalar se_slope = sqrt(V[1,1])

local R2_val : display %6.2f R2
local slope_val : display %6.2f slope
local se_val : display %6.3f se_slope

// Annotation positions for panel B
summarize timevar_total
local max_y = r(mean) + 1.31
local max_y_b = r(mean) + 1.43

// Compute invariant reference line for perfect scaling (β=1)
summarize time_for_speed_km, meanonly
local invariant = r(mean)
gen perfect_line = log10(`invariant') + log_popvar


// Create scatter + fitted line plot
twoway (scatter timevar_total log_popvar if region_name == "Northeast", msymbol(circle) msize(1.1) mcolor("119 194 215%80") mlcolor("119 194 215%60")) ///
       (scatter timevar_total log_popvar if region_name == "Midwest", msymbol(triangle) msize(1.1) mcolor("231 224 63%80") mlcolor("231 224 63%60")) ///
       (scatter timevar_total log_popvar if region_name == "West", msymbol(square) msize(1.1) mcolor("236 159 54%80") mlcolor("236 159 54%60")) ///
       (scatter timevar_total log_popvar if region_name == "South", msymbol(diamond) msize(1.1) mcolor("203 91 102%80") mlcolor("203 91 102%60")) ///
       (lfit timevar_total log_popvar, lcolor(black) lwidth(0.8)) ///
       (line perfect_line log_popvar, sort lcolor(black) lpattern(dash) legend(label(5 "Perfect scaling (β = 1)"))) , ///     
	   graphregion(color(white)) bgcolor(white) ///
       plotregion(lcolor(black) lwidth(thin)) ///
	   title("{bf:B}", justification(left) position(11) size(6) span) ///
       ylabel(6.5(.5)9, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
       xlabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
       text(`max_y' 5.18 "R{superscript:2} = `R2_val'", size(4)) ///
       text(`max_y_b' 5.35 "{&beta} = `slope_val' {&plusmn}`se_val'", size(4)) ///
       ytitle("Log{subscript:10}(Total travel time)", size(5)) ///
       xtitle("`ltit'", size(5)) ///
       xsize(6.5) ysize(5) scale(1) ///
       legend(order(1 "Northeast" 2 "Midwest" 3 "West" 4 "South") ring(0) position(11) rows(2) region(lc(none)) keygap(*.5) rowgap(*.1) size(medium) subtitle("") just(left)) ///	
	   name(f_2, replace)
	

*-----------------------------
* 6. COMBINE & EXPORT
*-----------------------------
// Combine panels and export final figure
gr combine f_1 f_2,  graphregion(color(white)) plotregion(fcolor(white)) rows(1) cols(2) name(combined, replace)
graph display combined, xsize(8) 

graph export "`OUTPUT_PNG'", as(png) replace





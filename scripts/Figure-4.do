********************************************************************************
* Figure-4.do
* ------------------------------------------------------------------------------
* Purpose:
*   Generate Figure 4:
*   Panel A: effective number of centers vs population.
*   Panel B: building density vs population.
*   Panel C: travel speed vs population.
*
* Usage:
*   In Stata 16 or higher, run:
*     do Figure-4.do
*
* Requirements:
*   • Stata 16+ (tested on 17)
*   • Output from 01_construct_msa_data.do:
*       data/clean/2019_clean_msa-<filter>.dta
*
* Outputs:
*   • figures/fig4.png
********************************************************************************

version 16.1, clear                
quietly set more off                
set scheme s1color, perm            
cd "/Users/arianna/YSE Dropbox/Arianna Salazar Miranda/projects/Marchetti/_scripts/replication"


*-----------------------------
* 1. USER SETTINGS & LOAD DATA
*-----------------------------
// Choose filter number (1–4) matching Clean Data script
local FILTER = 1

// Load the pre-processed MSA-level dataset
use "data/clean/2019_clean_msa-`FILTER'.dta", clear


*-----------------------------
* 2. VARIABLE CREATION
*-----------------------------
// Compute travel time (min) and distance (km)
gen time_for_speed_km = avg_time_a_pd_f3_95/60
gen dist_for_speed_m = avg_euc_dist_a_pd_95/1000

// Derive speed and log-transform metrics
gen speed = dist_for_speed_m / time_for_speed_km
gen speedvar = log10(speed)
gen timevar = log10(time_for_speed_km)
gen distvar = log10(dist_for_speed_m)


// Population and density variables
gen popvar = msa_population
gen log_popvar = log10(msa_population)
gen log_densvar = log10(cbsa_avg_far_alt_mts)

// Effective number of centers (polycentricity)
gen log_eff_number = log10(hhi_2^(-2))

// Axis label for population
local ltit "Log{subscript:10}(population)"


*-----------------------------
* 3. PANEL A: POLYCENTRICITY
*-----------------------------
// Regression: effective centers against log-population
reg log_eff_number log_popvar

// Extract R², β, and SE
matrix b = e(b)
matrix V = e(V)
scalar R2 = e(r2)
scalar slope = b[1,1]
scalar se_slope = sqrt(V[1,1])

// Formatting for annotations
local R2_val : display %6.2f R2
local slope_val : display %6.2f slope
local se_val : display %6.2f se_slope

// Annotation positions
summarize log_eff_number
local max_y = r(max) -0.16
local max_y_b = r(max) -0.07

// Plot Panel A
twoway (scatter log_eff_number log_popvar, msymbol(circle) msize(1.3) mcolor("203 91 102%80") mlcolor("203 91 102%80")) ///
(lfit log_eff_number log_popvar, lcolor(black) lwidth(0.8)), ///
graphregion(color(white)) bgcolor(white) ///
plotregion(lcolor(black) lwidth(thin)) ///
title("{bf:A}", justification(left) position(11) size(6) span) ///
ylabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
xlabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
text(`max_y' 5.2 "R{superscript:2} = `R2_val'", size(4)) ///
text(`max_y_b' 5.4 "{&beta} = `slope_val' {&plusmn}`se_val'", size(4)) ///
ytitle("Log{subscript:10}(Effective # of centers)", size(5)) ///
xtitle("`ltit'", size(5)) ///
xsize(6.5) ysize(5) scale(1) ///
legend(off) ///
name(f_1, replace)


*-----------------------------
* 4. PANEL B: BUILDING DENSITY
*-----------------------------
// Regression: log-density against log-population
reg log_densvar log_popvar

// Extract R², β, and SE
matrix b = e(b)
matrix V = e(V)
scalar R2 = e(r2)
scalar slope = b[1,1]
scalar se_slope = sqrt(V[1,1])

// Formatting for annotations
local R2_val : display %6.2f R2
local slope_val : display %6.2f slope
local se_val : display %6.2f se_slope

// Annotation positions
summarize log_densvar
local max_y = r(max) +1.8
local max_y_b = r(max) +2.1

// Plot Panel B
twoway (scatter log_densvar log_popvar, msymbol(circle) msize(1.3) mcolor("203 91 102%80") mlcolor("203 91 102%80")) ///
(lfit log_densvar log_popvar, lcolor(black) lwidth(0.8)), ///
graphregion(color(white)) bgcolor(white) ///
plotregion(lcolor(black) lwidth(thin)) ///
title("{bf:B}", justification(left) position(11) size(6) span) ///
ylabel(3(1)-3, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
xlabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
text(`max_y' 5.2 "R{superscript:2} = `R2_val'", size(4)) ///
text(`max_y_b' 5.4 "{&beta} = `slope_val' {&plusmn}`se_val'", size(4)) ///
ytitle("Log{subscript:10}(Building density)", size(5)) ///
xtitle("`ltit'", size(5)) ///
xsize(6.5) ysize(5) scale(1) ///
legend(off) ///
name(f_2, replace)


*-----------------------------
* 5. PANEL C: TRAVEL SPEED
*-----------------------------
// Regression: log-speed against log-population
reg speedvar log_popvar

// Extract R², β, and SE
matrix b = e(b)
matrix V = e(V)
scalar R2 = e(r2)
scalar slope = b[1,1]
scalar se_slope = sqrt(V[1,1])

// Formatting for annotations
local R2_val : display %6.2f R2
local slope_val : display %6.2f slope
local se_val : display %6.2f se_slope

// Annotation positions
summarize speedvar
local max_y = r(max) +0.28
local max_y_b = r(max) +0.33

// Plot Panel C
twoway (scatter speedvar log_popvar, msymbol(circle) msize(1.3) mcolor("203 91 102%80") mlcolor("203 91 102%80")) ///
(lfit speedvar log_popvar, lcolor(black) lwidth(0.8)), ///
graphregion(color(white)) bgcolor(white) ///
plotregion(lcolor(black) lwidth(thin)) ///
title("{bf:C}", justification(left) position(11) size(6) span) ///
ylabel(-1(.25)0, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
xlabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
text(`max_y' 5.2 "R{superscript:2} = `R2_val'", size(4)) ///
text(`max_y_b' 5.4 "{&beta} = `slope_val' {&plusmn}`se_val'", size(4)) ///
ytitle("Log{subscript:10}(Travel Speed)", size(5)) ///
xtitle("`ltit'", size(5)) ///
xsize(6.5) ysize(5) scale(1) ///
legend(off) ///
name(f_3, replace)



*-----------------------------
* 6. COMBINE & EXPORT
*-----------------------------
// Combine all panels into one figure and export
gr combine f_2 f_1 f_3,  graphregion(color(white)) plotregion(fcolor(white)) rows(1) cols(3) name(combined, replace)
graph display combined, xsize(10) 

graph export "figures/fig4.png", as(png) replace


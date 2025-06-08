********************************************************************************
* Figure-SI6.do
* ------------------------------------------------------------------------------
* Purpose:
*   Variation of Figure 4 Panel B: plot Herfindahl index vs city population
*   in place of the effective number of centers.
*
* Usage:
*   In Stata 16 or higher, run:
*     do Figure-SI6.do
*
* Requirements:
*   • Stata 16+ (tested on 17)
*   • Output from 01_construct_msa_data.do:
*       data/clean/2019_clean_msa-<filter>.dta
*
* Outputs:
*   • figures/figSI6.png
********************************************************************************

version 16.1, clear                
quietly set more off                
set scheme s1color, perm            
cd "/Users/arianna/YSE Dropbox/Arianna Salazar Miranda/projects/Marchetti/_scripts/replication"
 
*-----------------------------
* 1. USER SETTINGS & LOAD DATA
*-----------------------------
// Choose the same filter as in 01_construct_msa_data.do
local FILTER = 1
// Load the annual MSA-level dataset
use "data/clean/2019_clean_msa-`FILTER'.dta", clear

*-----------------------------
* 2. VARIABLE CREATION
*-----------------------------
// Compute Herfindahl index
gen log_hhi_inv = log10(1 / hhi)

// Log-transformed population
gen log_popvar = log10(msa_population)

// Axis label for population
local ltit "Log{subscript:10}(population)"


*-----------------------------
* 3. PANEL: HERFINDAHL INDEX vs POPULATION
*-----------------------------
// Regress Herfindahl index on log-population
reg log_hhi_inv log_popvar

// Extract R², β, and standard error
matrix b = e(b)
matrix V = e(V)
scalar R2 = e(r2)
scalar slope = b[1,1]
scalar se_slope = sqrt(V[1,1])

// Format values for annotations
local R2_val : display %6.2f R2
local slope_val : display %6.2f slope
local se_val : display %6.2f se_slope

// Determine annotation positions
summarize log_hhi_inv
local max_y = r(max) -0.16
local max_y_b = r(max) -0.04

// Create scatter + fitted line plot
twoway (scatter log_hhi_inv log_popvar, msymbol(circle) msize(1.3) mcolor("203 91 102%80") mlcolor("203 91 102%80")) ///
(lfit log_hhi_inv log_popvar, lcolor(black) lwidth(0.8)), ///
graphregion(color(white)) bgcolor(white) ///
plotregion(lcolor(black) lwidth(thin)) ///
title("{bf:A}", justification(left) position(11) size(6) span) ///
ylabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
xlabel(, labsize(large) tlcolor("black") glcolor("145 168 208")) ///
text(`max_y' 5.2 "R{superscript:2} = `R2_val'", size(4)) ///
text(`max_y_b' 5.4 "{&beta} = `slope_val' {&plusmn}`se_val'", size(4)) ///
ytitle("Log{subscript:10}(Herfindahl Index)", size(5)) ///
xtitle("`ltit'", size(5)) ///
xsize(5) ysize(5) scale(1) ///
legend(off) ///
name(f_1, replace)

*-----------------------------
* 4. EXPORT
*-----------------------------
// Save supplemental figure SI6
graph export "figures/figSI6.png", as(png) replace

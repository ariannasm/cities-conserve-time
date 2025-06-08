#!/usr/bin/env Rscript
#
# -----------------------------------------------------------------------------
# Purpose:
#   Generate `cbsa_density.csv` containing the average alternative FAR (FAR_alt_mts)
#   for each CBSA, based on raw building‐level land‐use CSVs. Only the FAR_alt_mts
#   metric is retained.
#
# Usage:
#   Rscript make_cbsa_density.R
#
# Requirements:
#   - R version >= 4.1.0
#   - Packages:
#       • dplyr
#       • purrr
#       • stringr
#       • readr (>= 2.0)
#       • DescTools
#
# Inputs:
#   Raw CBSA CSVs in:
#     /Users/arianna/Dropbox (Personal)/Zoning/_data/_raw/landuse/clean/cbsa
#
# Output:
#   /Users/arianna/Dropbox (YSE)/projects/Marchetti/_data/_clean/cbsa_density.csv
# -----------------------------------------------------------------------------

# 1. DEPENDENCIES ------------------------------------------------------------
library(dplyr)       # data manipulation
library(purrr)       # map_dfr over file lists
library(stringr)     # str_split for parsing filenames
library(readr)       # fast CSV reading/writing & col_select
library(DescTools)   # Winsorize to cap outliers

# 2. USER SETTINGS -----------------------------------------------------------
# This script expects the Regrid raw land‐use CSVs
raw_dir     <- "."  
output_path <- "/Users/arianna/YSE Dropbox/Arianna Salazar Miranda/projects/Marchetti/_scripts/replication/data/msa/cbsa_density.csv"

setwd(raw_dir)
all_files <- list.files(pattern = "\\.csv$")

# Extract unique CBSA GEOIDs
cbsa_list <- all_files %>% 
  map_chr(~ str_split(.x, "_")[[1]][3]) %>% 
  unique()

# Prepare accumulator
metrics_df <- tibble(cbsa_GEOID = character(), cbsa_avg_FAR_alt_mts = double())

# 3. PROCESS EACH CBSA ------------------------------------------------------
for (cbsa_geoid in cbsa_list) {
  message("Processing CBSA: ", cbsa_geoid)
  
  # Identify files for this CBSA
  pattern    <- paste0(".*_", cbsa_geoid, "_.*\\.csv$")
  cbsa_files <- grep(pattern, all_files, value = TRUE)
  
  # Read only the columns we need:
  #   ll_uuid, bldg_ID, area_bldg_mts, area_plot_mts, height_mod, height
  df_cbsa <- map_dfr(cbsa_files, ~ read_csv(
    file        = .x,
    show_col_types = FALSE,
    col_select  = c(ll_uuid, bldg_ID, area_bldg_mts, area_plot_mts, height_mod, height)
  ) %>%
    mutate(
      cbsa_GEOID     = cbsa_geoid,
      unique_bldg_id = paste(ll_uuid, bldg_ID, sep = "_")
    )
  )
  
  # One record per building footprint
  df_cbsa <- distinct(df_cbsa, unique_bldg_id, .keep_all = TRUE)
  
  # Clean & compute FAR
  df_cbsa <- df_cbsa %>%
    mutate(
      # If building footprint > plot area, use the smaller plot area
      area_bldg_mts_adjusted = if_else(area_bldg_mts > area_plot_mts,
                                       area_plot_mts, area_bldg_mts),
      # Cap top 1% of heights and areas for drawing errors
      height_mod_adjusted    = Winsorize(height_mod,    probs = c(0, 0.99), na.rm = TRUE),
      area_plot_mts_adjusted = Winsorize(area_plot_mts, probs = c(0, 0.99), na.rm = TRUE),
      area_bldg_mts_adjusted = Winsorize(area_bldg_mts, probs = c(0, 0.99), na.rm = TRUE),
      # Compute built area using adjusted height
      total_area_built_alt_mts = area_bldg_mts_adjusted * height_mod,
      # Compute FAR_alt_mts
      FAR_alt_mts = total_area_built_alt_mts / area_plot_mts
    )
  
  # Summarize average FAR by CBSA
  cbsa_avg <- df_cbsa %>%
    summarise(
      cbsa_avg_FAR_alt_mts = mean(FAR_alt_mts, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(cbsa_GEOID = cbsa_geoid)
  
  # Append to master data frame
  metrics_df <- bind_rows(metrics_df, cbsa_avg)
}

# 4. WRITE OUTPUT ------------------------------------------------------------
write_csv(metrics_df, output_path)

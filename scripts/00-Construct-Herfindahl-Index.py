#!/usr/bin/env python3
"""
------------------------------------------------------------------------------
Purpose:
    Compute the Herfindahl–Hirschman Index (HHI) for each home_cbsa_id using mobiltiy data. 

Usage:
    1. Install dependencies:
         pip install pandas sqlalchemy trino sqlalchemy-trino retrying PyYAML keplergl hvplot
    2. Set your Trino connection parameters below.
    3. Run:
         python make_hhi.py

Requirements:
    - Python >= 3.7
    - Packages:
        • pandas
        • sqlalchemy
        • trino
        • retrying
        • PyYAML
        • shapely, geopandas 
        • hvplot, keplergl 
Inputs:
    - Trino table `temp_traj_all`

Outputs:
    - `intermediate_hhi_results.csv`: partial HHI results as each CBSA is processed
    - `final_hhi_results.csv`: complete HHI results for all home_cbsa_ids
------------------------------------------------------------------------------
"""

# 1. DEPENDENCIES & SETUP
import yaml
from datetime import datetime, date
from dateutil.parser import parse
import numpy as np
from shapely import wkt
import geopandas as gpd
import hvplot.pandas
from keplergl import KeplerGl
import pandas as pd
from retrying import retry
from snowflake.snowpark.context import get_active_session

# 2. SNOWFLAKE CONNECTION
session = get_active_session()


# 3. IDENTIFY HOME CBSAS
query_home_cbsa_ids = """
SELECT DISTINCT home_cbsa_id
FROM temp_traj_all
WHERE end_cbsa_id = home_cbsa_id
"""
home_cbsa_ids_df = pd.DataFrame(session.sql(query_home_cbsa_ids).collect())
home_cbsa_ids = home_cbsa_ids_df['home_cbsa_id'].tolist()
print(f"Found {len(home_cbsa_ids)} home_cbsa_ids.")

# 4. PREPARE FOR LOOP
final_hhi_df = pd.DataFrame()

# 5. LOOP & COMPUTE HHI
for home_cbsa_id in home_cbsa_ids:
    print(f"Processing home_cbsa_id: {home_cbsa_id}")

    # 5a) Filter trips for this CBSA
    query_filtered_trips = f"""
    SELECT 
        home_cbsa_id, 
        SUBSTRING(end_geohash, 1, 5) AS end_geohash
    FROM 
        temp_traj_all
    WHERE 
        end_cbsa_id = home_cbsa_id
        AND home_cbsa_id = '{home_cbsa_id}'
    """
    filtered_df =pd.DataFrame(session.sql(query_filtered_trips).collect())

    # 5b) Compute trip counts and shares
    total_trip_count = filtered_df.shape[0]
    query_trip_shares = f"""
    SELECT
        tc.home_cbsa_id,
        tc.end_geohash,
        tc.trip_count,
        CAST(tc.trip_count AS DOUBLE) / {total_trip_count} AS share
    FROM (
        SELECT 
            home_cbsa_id,
            SUBSTRING(end_geohash, 1, 5) AS end_geohash,
            COUNT(*) AS trip_count
        FROM 
            ({query_filtered_trips})
        GROUP BY 
            home_cbsa_id, 
            SUBSTRING(end_geohash, 1, 5)
    ) AS tc
    """
    trip_shares_df = pd.DataFrame(session.sql(query_trip_shares.collect()))
    print(trip_shares_df.head())

    # 5c) Compute HHI = sum(share^2)
    hhi_value = (trip_shares_df['share'] ** 2).sum()
    hhi_df = pd.DataFrame({
        'home_cbsa_id': [home_cbsa_id],
        'hhi': [hhi_value]
    })
    print(f"Computed HHI {hhi_value:.4f} for {home_cbsa_id}.")

    # 5d) Append & save intermediate results
    final_hhi_df = pd.concat([final_hhi_df, hhi_df], ignore_index=True)
    final_hhi_df.to_csv('intermediate_hhi_results.csv', index=False)
    print("Saved intermediate_hhi_results.csv\n")

# 6. FINAL OUTPUT
print("Final HHI DataFrame:\n", final_hhi_df)
final_hhi_df.to_csv('final_hhi_results.csv', index=False)
print("Saved final_hhi_results.csv successfully.")
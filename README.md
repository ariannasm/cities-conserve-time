# cities-conserve-time

Instructions for reproducing all figures using the .do and .ipynb files in the replication package, as well as software requirements and necessary inputs, are below. Figure-[1-4].do and Figure-SI6.do have been tested on Stata 16 and 17, while the remaining .ipynb files have been tested in Jupyter running  Python 3.10.14. Each of these scripts should take no more than 10 seconds to run.

The replication package also contains scripts in the folder “spectus_scripts”, which were run on Spectus’s platform and created various inputs for our .do and .ipynb files. While these will not run as-is, they would run on Spectus’s platform if anyone wishing to replicate the study has access.

## Figure-2.do

**Purpose**  
Generate Figure 2 (panels A & B) illustrating how total travel time scales with city population using the MSA-level mobility data.

**Usage**  
In Stata 16 or higher, run: do Figure-2.do
**Requirements**  
Stata 16+ (tested on 17)
Output from 01_construct_msa_data.do: 
- data/clean/2019_clean_msa-<filter>.dta

Directory for saving figures:
- figures/fig1.png

**Outputs**
figures/fig2.png

Note:
This script uses the same filter number (<filter>) defined in 01_construct_msa_data.do.

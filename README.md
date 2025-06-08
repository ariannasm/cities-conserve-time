# cities-conserve-time

Instructions for reproducing all figures using the .do and .ipynb files in the replication package, as well as software requirements and necessary inputs, are below. Figure-[1-4].do and Figure-SI6.do have been tested on Stata 16 and 17, while the remaining .ipynb files have been tested in Jupyter running  Python 3.10.14. Each of these scripts should take no more than 10 seconds to run.

The replication package also contains scripts in the folder “spectus_scripts”, which were run on Spectus’s platform and created various inputs for our .do and .ipynb files. While these will not run as-is, they would run on Spectus’s platform if anyone wishing to replicate the study has access.


Figure-2.do  
------------------------------------------------------------------------------  
Purpose:  
  Generate Figure 2 (panels A & B) illustrating how total travel time scales  
  with city population using the MSA-level mobility data.  

Figure-3.do  
------------------------------------------------------------------------------  
Purpose:  
  Generate Figure 3: travel time scaling analysis for non-U.S. Functional Urban Areas  
  across four countries (Indonesia (id), India (in), Mexico (mx), Nigeria (ng)).  
  Panel A shows semi-elasticity of total travel time per person vs log-population.  
  Panel B shows elasticity of log-transformed travel time vs log-population.  

Figure-4.do  
------------------------------------------------------------------------------  
Purpose:  
  Generate Figure 4:  
  Panel A: effective number of centers vs population.  
  Panel B: building density vs population.  
  Panel C: travel speed vs population.  

Figure-5.ipynb  
------------------------------------------------------------------------------  
- Figure 5 (panels A & B) illustrating sample representativeness across months and CBSAs.  

Figure-6.ipynb  
------------------------------------------------------------------------------  
- Figure 6 (panels A - D) illustrating data quality for our US sample (pings per trip, pings per day, time between pings, trips per day).  

Figure-SI1.ipynb  
------------------------------------------------------------------------------   
- Figure SI1 (panels A - D) illustrating sample representativeness by month across countries.  

Figure-SI2.ipynb  
------------------------------------------------------------------------------  
- Figure SI2 (panels A & B) illustrating sample representativeness across countries/functional urban areas.  

Figure-SI3.ipynb  
------------------------------------------------------------------------------  
- Figure SI3 (panels A - D) illustrating data quality across countries.  

Figure-SI4.ipynb  
------------------------------------------------------------------------------ 
- Figure SI4 (panels A & B) illustrating representativeness across CBSA and month by various filters.  

Figure-SI5.ipynb  
------------------------------------------------------------------------------   
- Figure SI5 (panels A & D) illustrating data quality for our US sample (pings per trip, pings per day, time between pings, trips per day), by our various filters.  

Figure-SI6.do  
------------------------------------------------------------------------------  
- Figure SI6 plots the Herfindahl index vs city population in place of the effective number of centers (Figure 4 Panel B).  

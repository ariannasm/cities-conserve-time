# cities-conserve-time

Instructions for reproducing all figures in the paper *Cities Adapt to Conserve Travel Time* by Arianna Salazar-Miranda, Cate Heine, Lei Dong, Paolo Santi, and Carlo Ratti. Software requirements and necessary inputs are listed below.

- The Stata scripts (`Figure-1.do` through `Figure-4.do` and `Figure-SI6.do`) have been tested on Stata 17.  
- The Jupyter notebooks (`.ipynb`) have been tested on Python 3.10.14 in Jupyter.  
- Each script executes in under 10 seconds.

The replication package also includes a `spectus_scripts` folder containing scripts that run on Spectus’s platform to generate inputs for our `.do` and `.ipynb` files. Access to the raw Cuebiq mobility data via the Spectus platform is required to run these scripts.  

Figure-2.do  
------------------------------------------------------------------------------  
- Figure 2 (panels A & B) illustrating how total travel time scales with city population using the MSA-level mobility data.  

Figure-3.do  
------------------------------------------------------------------------------  
- Figure 3: travel time scaling analysis for non-U.S. Functional Urban Areas across four countries (Indonesia (id), India (in), Mexico (mx), Nigeria (ng)). Panel A shows semi-elasticity of total travel time per person vs log-population. Panel B shows elasticity of log-transformed travel time vs log-population.  

Figure-4.do  
------------------------------------------------------------------------------  
- Figure 4: Panel A: effective number of centers vs population. Panel B: building density vs population.Panel C: travel speed vs population.  

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

# Processing of Medal Data for Olympics 

## Overview
This repository processes Olympic medal data from the Summer Olympic Games 2004–2024,combining with population estimates for each National Olympic Comittee (NOC) that competed. It uses the **R `{targets}`** framework to try and make the pipeline easy to reproduce and follow.  

The primary objective is to:
- Count medals per athlete and country, accounting for both individual and team events.  
- Identify multi-medal athletes (single, double, triple, etc.) by Games.  
- Combine these counts with United Nations population estimates for corresponding years.  
- Export structured medal summary files for each Summer Games from Athens 2004 to Paris 2024.

Discrepancies in certain Games (e.g., London 2012, Beijing 2008) are noted and likely reflect post-event medal redistributions due to doping disqualifications.

---

## Data Sources
| Dataset | File | Description |
|----------|------|--------------|
| Medal winners | `0_data/0_raw/medallists_1896-2024.csv` | Individual and team medal records (cleaned). |
| Population estimates | `0_data/0_raw/un_population_estimates_1950-2024.csv` | UN total population estimates by country and year. |
| NOC participation | `0_data/0_raw/nocs_2000-2024.csv` | Countries participating in each summer Games from 2000 - 2024. (Data would need to be obtained for this for winter olympics should one wish to carry this out in that regard)|

Output files are written to `0_data/1_output/`.

---

## Core R Workflow
The pipeline is defined in `_targets.R`.  
Main stages:

1. **Load raw data** (`tar_target` for each input file).  
2. **Process medals** via custom functions in `R/utils.R`.  
   - `medal_counter()` counts team and individual medals in each edition of teh olympics 
   - `tidy_medal_n()` merges medal, NOC, and population data for 2004 -2024; standardizes country codes. This function will need to be edited for different competions such as older summer olympics and all winter Olypics as I haven't yet generalised this to work across the board. 
4. **Save output** produce output CSVs for each Olympic Games (2004–2024).

To run locally:
```r
library(targets)
tar_make()

#tar_visnetwork() #allows visualisation of pipeline - as this is fairly straightforward here probably not necessary
```
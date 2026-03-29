# DHZW-ABM 

This repository contains the code for my Computing Science Project as part of a BSc Computing Science Degree at the University of Aberdeen.
The title of my project is: "XXXXXXXXXXXXXXXXX"

In this repository you'll find two main things:
1. A targets pipeline written in R that processes statistics and spatial data into a synthetic population for use by an ABM simulation
2. A 2APL-based ABM where agents use a Multinomial Logit to select transport modes with the highest utility. 

### Pipeline
The pipeline was built using targets.

Load targets with:
```R
library(targets)
```

Make the pipeline with: 
```R
tar_make()
```
The pipeline is configured in `config.yaml`. No environment variables etc are used, just the file.
The pipeline is defined in `_targets.R`. The final stage of routing took around 2 hours per mode on my machine- these may have been commented out! Double check!

Data:
Since the synthetic population was compiled into the output folder, I felt no need to re-compile it. However, the following data files are required and are approximately 3GB, so are a little too big to include in the GitHub repo. I made an external folder `dhzw-data`, inside are the following folders:
```ps
2024-cbs_pc4_2021_vol
2024-cbs_pc5_2021_vol
2024-cbs_pc6_2021_vol
2025-cbs_pc4_2022_vol
adressendenhaag
DUO_Onderwijslocaties
odin-ovin
otp
|- graphs
   |- graph.obj
   |- gtfs.zip
   |- netherlands-260301.osm.pbf
|- otp-2.2.0-shaded.jar
schoolgebouwen
```

- CBS Postcode data [source](https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische-data/gegevens-per-postcode):
    - 2024-cbs_pc4_2021_vol
    - 2024-cbs_pc5_2021_vol
    - 2024-cbs_pc6_2021_vol
    - 2025-cbs_pc4_2022_vol
- adressendenhaag [source](https://denhaag.dataplatform.nl/#/data/3fa6081c-95f9-4067-91f0-2de659115485)
- DUO_Onderwijslocaties [source](maps.arcgis.com/home/item.html?id=b1ffef22b3d8427992498e55ff7dc2b9)
- odin-ovin: Contains the ODiN/OViN files.  Prepared by Centraal Bureau voor de Statistiek (CBS) / Rijkswaterstaat (RWS), and published by DANS Data Station Social Sciences and Humanities. Some of the earlier datasets were republished, so the most up-to date publications were used:
    - 2010 [source](https://doi.org/10.17026/DANS-ZHS-GHWG)
    - 2011 [source](https://doi.org/10.17026/DANS-XV2-HAPB)
    - 2012 [source](https://doi.org/10.17026/DANS-2BS-Q7U2)
    - 2013 [source](https://doi.org/10.17026/DANS-X9H-DSDG)
    - 2014 [source](https://doi.org/10.17026/DANS-X95-5P7Y)
    - 2015 [source](https://doi.org/10.17026/DANS-Z2V-C39P)
    - 2016 [source](https://doi.org/10.17026/DANS-293-WVF7)
    - 2017 [source](https://doi.org/10.17026/DANS-XXT-9D28)
    - 2018 [source](https://doi.org/10.17026/DANS-XN4-Q9KS)
    - 2019 [source](https://doi.org/10.17026/DANS-XPV-MWPG)
    - 2023 [source](https://doi.org/10.17026/SS/FNXJEU)
- otp
   - GTFS [source](https://www.transit.land/feeds/f-u-nl) [specifically this version](https://www.transit.land/feeds/f-u-nl/versions/a7ecf2adad90283f0834ba1828d0d05f98e2f1ff), but any version will do as long as you update the routing data in the routing script.
   - netherlands-260301.osm.pbf [source](https://download.geofabrik.de/europe/netherlands.html). You won't need this exact version as OpenTripPlanner will pickup the version you have. 

- schoolgebouwen [source](https://denhaag.dataplatform.nl/#/data/7a2df8e1-366c-4707-b276-4de79b99ad6d)

Should you need to debug a section, you can load the variables into memory using the commands:
```R
tar_load()

tar_workspace(synthetic_activities_csv)
```
I appologise- it was the first targets pipeline I built, so there are lots of inconsistencies- especially at the start. Something I should have done is renamed the variables that consume the CSVs for easier debugging, so you don't have to manually assign them again as many functions have different argument names to that defined in `_targets.csv. Also note that targets has a global namespace- therefore two functions can't share the same name! 



## License & credits

This repository is licensed under the GNU General Public License v3.0 (GPL-3.0). For more details, see the [LICENSE](LICENSE) file.

This monorepo consolidates previous work completed by the hard work from:
-   Marco Pellegrino (Author)
-   Jan de Mooij
-   Tabea Sonnenschein
-   Mehdi Dastani
-   Dick Ettema
-   Brian Logan
-   Judith A. Verstegen

And combines the git repos (in no particular order):
 - https://github.com/marcopellegrinoit/DHZW_shapefiles
 - https://github.com/marcopellegrinoit/DHZW_assign_locations
 - https://github.com/marcopellegrinoit/DHZW_assign-activities
 - https://github.com/marcopellegrinoit/DHZW_synthetic-population
 - https://github.com/marcopellegrinoit/DHZW_routing
 - https://github.com/marcopellegrinoit/DHZW_synthetic_population_to_Sim2APL
 - https://github.com/marcopellegrinoit/DHZW_locations
 - https://github.com/marcopellegrinoit/DHZW_sensitivity_analysis
 - https://github.com/marcopellegrinoit/DHZW-simulation_Sim-2APL
 

**NOTE:**
All readme files made without guarantee: this repo has been inherited- there are some aspects that were never fully understood and short turnaround time prevented complete investigation- therefore, you may find inconsistencies in the readme files. Always use good judgement, as some information contained in them may be inconsistent. 


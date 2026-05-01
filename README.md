# DHZW-ABM 

This repository contains the code for my Computing Science Project as part of a BSc Computing Science Degree at the University of Aberdeen.
The title of my project is: "Refining an Agent-Based transport model for the Southwest of The Hague"

In this repository you'll find two main things:
1. A targets pipeline written in R that processes statistics and spatial data into a synthetic population into a synthetic activity schedule for use by an ABM simulation
2. A 2APL-based ABM where agents use a Multinomial Logit to select transport modes with the highest utility, and the associated sensitivity analysis and calibration scripts. 

## Overview

The repository is structured as follows (Programming language used in brackets):

```
0-shapefiles (R)
0-synthetic-population (R)
1-trips (R)
2-assign-locations (R)
3-locations (R)
4-assign-locations (R)
5-synthetic-population-to-Sim2APL (R)
6-routing (R)
7-simulation-Sim-2APL (Java)
8-sensitivity-analysis (Jupyter notebook)
9-calibration (Jupyter notebook)
10-other-analysis (R)
```

The modules are prefixed with a number denoting the order of execution. Scripts 0-6 are run as part of the pipeline, so do not need to be run manually (See the section "Synthetic Activity Schedule Pipeline" below). After the pipeline is run, the outputs can be used by the simulation. The specific location of the activity schedules can be defined in the simulation's `.toml` file,  however, at a high level, take the results of the pipeline from the `output/<<experiment-id>>/final_output/` and input it to the simulation in the following folder (the base-pop folder is used as an example.):  

```
7-simulation-Sim-2APL/src/main/resources
|- base-pop
   |- DHZW_full
       |- DHZW_activities_locations.csv
       |- DHZW_households.csv
       |- DHZW_synthetic_population.csv
   |- routing
       |- beeline_distance.csv
       |- bike_time_distance.csv
       |- car_time_distance.csv
       |- routing_bus.csv
       |- routing_train.csv
       |- walk_time_distance.csv
```

The output of the previous pipeline was uploaded to zenodo, [here](https://zenodo.org/records/19680970), however I believe the ODiN and OViN files cannot be in the public domain, so it is restricted. Try and get in touch with me if you want to download it. 

#### 8-sensitivity-analysis
Sections 8-sensitivity-analysis should be run after the datasets have been compiled and any structural modifications to the simulation in the folder `7-simulation-Sim-2APL` have been made. 
Run the scripts in this order:
1. data_preparation.ipynb
2. run_simulations.ipynb
3. analysis_plots.ipynb

#### 9-calibration
Once you have run the sensitivity analysis and are happy the model is behaving as expected, you can run the calibration. This went throught many refinements, so feel free to delete any notebooks that you don't need. However, look at `rq1-calibration.ipynb` for the structure. The notebooks call the functions written in `simulation_functions.py`, which may benefit from refactoring by using a dictionary to pass the parameters instead of by name as it is quite clunky at the moment, but works fine enough.

#### 10-other-analysis.

Here you will find an assortment of scripts that were used to validate various parts of the simulation. There is probably very little of useful value here. However, you may wish to look at the `ODIN-Analysis/dhzw_by_year.R` script as this performs a very basic analysis of the national travel surveys, which may help you to understand the targets pipeline. 


### Synthetic Activity Schedule Pipeline
The pipeline was built using targets. It takes the OViN and ODiN national travel surveys as input, along with a broad range of statistics to synthesise an activity schedule for the residents in the synthetic population.  

Load targets with:
```R
library(targets)
```

Make the pipeline with: 
```R
tar_make()
```
The pipeline is configured in `config.yaml`. All configuration is in this file and there are no environment variables. Below is a commented example of the configuration file. This file cannot be used, because `.yaml` files do not support comments.

```
project_root: "." #<-- This sets the location of the output folder relative to this file. Use '.' to put the output folder in this folder. 
experiment_id: "synth_pop" #<--One of ["synth_pop", "vanilla"]- these are defined in the "configuration" key below

modules: #These modules define the name of the module in the output folder location. They simply exist so I can rename the modules if I got the ordering wrong.
  shapefiles: "0-shapefiles"
  synthetic_population: "0-synthetic-population"
  trips: "1-trips"
  assign_activities: "2-assign_activities"
  locations: "3-locations"
  assign_locations: "4-assign_locations"
  synthetic_population_to_sim: "5-synthetic_population_to_Sim2APL"
  routing : "6-routing"


#For each experiment_id, you need to define which synthetic population is used,
#and which households:
configuration:
  vanilla: 
    module_dir: "0-synthetic-population/output/synthetic-population-households"
    population: "synthetic_population_DHZW_2019.csv"
    households: "df_households_DHZW_2019.csv"
  synth_pop:
    module_dir: "0-synthetic-population/output/gen-synth-pop"
    population:  "synthetic_population_the_hague_south_west.csv"
    households: "synthetic_households_the_hague_south_west.csv"
    
```

The pipeline is defined in `_targets.R`. The final stage of routing took around 2 hours per mode on my machine- these may have been commented out! Double check! The  `_targets.R` is the best file to understand the order the files need to be executed in. 


#### Data:
The following data files are required and are approximately 3GB, so are a little too big to include in the GitHub repo. I made an external folder `dhzw-data`, inside are the following folders:
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

#### Dataset sources

The datasets will need to be downloaded separately The datasets are sourced from:

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

tar_workspace(<<Your module name here>>)
```
A much more comprehensive guide is available at: https://books.ropensci.org/targets/debugging.html


I appologise- it was the first targets pipeline I built, so there are lots of inconsistencies- especially at the start. Something I should have done is renamed the variables that consume the CSVs for easier debugging, so you don't have to manually assign them again as many functions have different argument names to that defined in `_targets.csv.` Also note that targets has a global namespace- therefore two functions can't share the same name! My conventions also fell apart. In the beginning I started using  a `main.R` entrypoint for each module, but slowly found out that putting most of the code in `_targets.R` made it a lot easier to debug! If I were to do this again, I would *not* use `main.R` again!

## Simulation-Sim-2APL
This contains the ABM simulation code. Currently, the `pom.xml` is configured to use version `2.0.3-SNAPSHOT` of the `Sim-2APL` library. You will need to compile this version locally, and the source is in the `Sim-2APL` folder. Install with the following command.

```mvn install:install-file -Dfile='sim2apl-matrix-2.0.3-SNAPSHOT' -DgroupId='nl.uu.iss.ga' -DartifactId=sim2apl-matrix -Dversion='2.0.3-SNAPSHOT' -Dpackaging=jar```

Alternatively, the program will work without this specific version, so you can follow the instructions below, just modify the `pom.xml` in the `simulation-Sim2APl` folder to use version `2.0.0-SNAPSHOT`. Note that this version will not include error logging.

### Invoking program

Call --help when running the application for command line arguments.

The JAR file is automatically generated and placed in the `target` directory.  
In order to use the JAR file, make sure to use the Java version also used by Maven, and call

```plaintext
$ java -jar sim2apl-dhzw-simulation-1.0-SNAPSHOT-jar-with-dependencies.jar [args]
```

The file [`args_example.txt`](src/main/resources/args_example.txt) contains the arguments to launch the simulation.

#### Build instructions

This section describes how to set up the code in your own development environment.

#### Prerequisites

This manual assumes Maven is installed for easy package management

Prerequisites:

*   Java 11+ (not tested with lower versions)
*   [Sim-2APL](https://github.com/A-Practical-Agent-Programming-Language/Sim-2APL)
*   (Maven)

##### Sim-2APL

Download [Sim-2APL](https://github.com/A-Practical-Agent-Programming-Language/Sim-2APL) from Github,  
and, to ensure compatibility, checkout the `v2.0.0` version tag.

```plaintext
$ git clone https://github.com/A-Practical-Agent-Programming-Language/Sim-2APL.git sim-2apl
$ cd sim-2apl
$ git checkout v2.0.0
```

Install the package using Maven:

```plaintext
$ mvn -U clean install
```

or download from the artefacts tab on the 2APL repo, and source using:

```bash
mvn install:install-file -Dfile='sim2apl-matrix-2.0.0-SNAPSHOT.jar' -DgroupId='nl.uu.iss.ga' -DartifactId=sim2apl-matrix -Dversion='2.0.0-SNAPSHOT' -Dpackaging=jar
```

This will automatically add the library to your local Maven repository, so no further action is required here.

### This library

Clone the master branch of this library and install with Maven, or open in an IDE with Maven support (e.g. VSCode, Idea Intellij, Eclipse or NetBeans) and let the IDE set up the project.

```plaintext
$ git clone https://github.com/marcopellegrinoit/DHZW-simulation_Sim-2APL.git
$ cd DHZW-simulation_Sim-2APL
$ mvn -U clean install
```


The application requires various arguments, either when invoked from the command line or when used in an IDE.  
Invoke the program with the argument `--help`

In the [resource](src/main/resources/) directory, an example [configuration](src/main/resources/config_full.toml) TOML file is given.

The command to run the simulation is:
```bash
java -cp target/sim2apl-dhzw-simulation-1.0-SNAPSHOT-jar-with-dependencies.jar main.java.nl.uu.iss.ga.Simulation \\
--config src/main/resources/config_DHZW_full.toml \\
--output_file src/main/resources/baseline_parameterset/output-proportions.csv \\
--parameter_file src/main/resources/baseline_parameterset/vot_parameterset.csv\\ 
--parameterset_index 1\\
--use_random_seed true
```
You will need to ensure that the configuration files are setup as expected 


### Sim-2APL
This is not the simulation. It contains the Sim-2APL code.

Because 2APL didn't have good error logging (making it near impossible to explain why agents went missing because the debugger wouldn't attach to the threads), I've included version 2.0.0 of 2APL, which has been tweaked to log errors. It has version `2.0.3-SNAPSHOT` and should be installed using the maven command: `mvn clean install` in the root of the folder.  The only change was in the `DeliberationRunnable.java` to add `Platform.getLogger().log(getClass(),Level.SEVERE, exception);`

Then consume in DHZW-simulation. 

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


![GitHub](https://img.shields.io/badge/license-GPL--3.0-blue)

## Extracting Subareas and Centroids from CBS Postcode Shapefiles

## Table of Contents

1.  [Description](#description)
1.  [Data](#data)
2.  [Usage](#usage)
3.  [Project Structure](#project-structure)
6.  [Contributors](#contributors)
7.  [License](#license)

## Description

This repository contains scripts to manage national CBS postcode shapefiles. Tools can extract vectorial subareas of selected postcodes and calculate their centroids. The code is generic for any subareas and it is applied to the case-study area of the district of Den Haag Zuid-West (DHZW).

## Data

Vectorial shapefiles can be retrieved from the [CBS portal](https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische-data/gegevens-per-postcode).

## Usage

[`PC4_centroids.R`](PC4_centroids.R) extract centroids as a shapefile and CSV dataframe of coordinates for postcodes PC4

[`PC5_centroids.R`](PC5_centroids.R) extract centroids as a shapefile and CSV dataframe of coordinate for postcodes PC5

[`PC6_centroids.R`](PC6_centroids.R) extract centroids as a shapefile and CSV dataframe of coordinates for postcodes PC6

[`PC5_DHZW.R`](PC5_DHZW.R) extract the shapefile of PC5 postcodes for the district of The Hague Zuid West, based on the district PC4s

[`PC6_DHZW.R`](PC6_DHZW.R) extract the shapefile of PC6 postcodes for the district of The Hague Zuid West, based on the district PC4s

[`PC6_DHZW_Moerwijk.R`](PC6_DHZW_Moerwijk.R) extract the shapefile of PC6 postcodes where the train station Moerwijk is located. Such postcodes are used when retrieving routing information for train trips.

## Project structure

*   root: R scripts
*   [`/data`](/data)
    *   [`/codes`](/data/codes): includes PC4 codes of the subarea, neighbourhood codes of the subarea and PC4 with the same urbanization index as the case-study subarea
    *   `/processed`
    *   `/csv`: CSV formatted output
    *   `/shapefiles`: shapefile formatted output
    *   `/raw`: input shapefile postcode data from CBS
    
## Contributors

This project was made possible thanks to the hard work and contributions from:

*   Marco Pellegrino (Author)
*   Jan de Mooij
*   Tabea Sonnenschein
*   Mehdi Dastani
*   Dick Ettema
*   Brian Logan
*   Judith A. Verstegen

## License

This repository is licensed under the GNU General Public License v3.0 (GPL-3.0). For more details, see the [LICENSE](LICENSE) file.
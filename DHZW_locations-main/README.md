![GitHub](https://img.shields.io/badge/license-GPL--3.0-blue)

# Extracting and Scraping Buildings from Cadastre Data and FourSquare

## Table of Contents

1.  [Description](#description)
2.  [Data Sources](#data-sources)
3.  [Usage](#usage)
4.  [Contributors](#contributors)
5.  [License](#license)

## Description

This repository contains scripts for formatting and extracting buildings from cadastre data, with a focus on the district of Den Haag Zuid-West (DHZW). This project was undertaken at Utrecht University, The Netherlands, during 2022-2023 by Marco Pellegrino and a team of contributors.

## Data Sources

Locations of offices, retailers, and sports facilities are obtained from the cadastre ["Basisregistratie Adressen en Gebouwen" (BAG)](https://denhaag.dataplatform.nl/#/data/5788bca4-e0e3-4c47-9107-5482d526880f), which contains addresses of buildings in The Hague categorized by different types.

School buildings are not retrieved from BAG due to unreliable building classification practices. BAG often categorises buildings as schools, even if they are not necessarily traditional educational institutions. As a result, schools within the DHZW area are obtained from the following sources:

* [Den Haag Open Data](https://denhaag.dataplatform.nl/#/data/cc1362f7-d847-4141-9361-d106b3f497ec) for daycare ("BO-Voorschool") buildings
* [ESRI Living Atlas](https://livingatlas-dcdev.opendata.arcgis.com/datasets/esrinl-content::onderwijslocaties-adres/explore?filters=eyJQUk9WSU5DSUUiOlsiWnVpZC1Ib2xsYW5kIl0sIkdFTUVFTlRFTkFBTSI6WyJTIEdSQVZFTkhBR0UiXX0%3D&location=52.051828%2C4.326155%2C13.82) dataset for primary education ("BO") and high-school ("VBO/MAVO") buildings.

## Usage

* [`format_BAG_work_retail_sport.R`](format_BAG_work_retail_sport.R): This script extracts work, shop, and sports buildings from the BAG dataset.
* [`format_schools.R`](format_schools.R): This script extracts educational buildings from the above-mentioned datasets.
* [`format_households.R`](format_households.R): This script assigns coordinates (PC6 centroid) to the households of the synthetic population.
* [`merge_locations.R`](merge_locations.R): This script merges all the extracted buildings into one dataset.

**Note**: [`foursquare_tool`](/foursquare_tool/) is an additional tool that was developed but not used for the purpose of this project. The initial idea was to scrape buildings from FourSquare, but the BAG dataset was found later, which already contains official buildings, making it the preferred choice. However, it is worth noting the capabilities of this tool: it can scrape locations of a selected category within a determined bounding box and then filter the locations specifically within an area (using shapefiles). The tool overcomes the issue of FourSquare's query limit per area by partitioning the query area into multiple sub-areas where queries are run independently. Finally, the results are merged together.

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
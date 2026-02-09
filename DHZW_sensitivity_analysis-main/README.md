![GitHub](https://img.shields.io/badge/license-GPL--3.0-blue)

# Sensitivity Analysis for Transport Usage Predictive Model

## Table of Contents

1.  [Description](#description)
2.  [Usage](#usage)
3.  [Contributors](#contributors)
4.  [License](#license)

## Description

This repository contains scripts for sensitivity analysis of an agent-based model within a project focusing on the mobility of Den Haag Zuid-West (DHZW) district. This project was undertaken at Utrecht University, The Netherlands, during 2022-2023 by Marco Pellegrino and a team of contributors.

## Usage

1. [`data_preparation`](data_preparation.ipynb): This script prepares the parameter sets that the simulation needs to run.
2. [`run_simulations`](run_simulations.ipynb): This script iteratively executes the simulations with the required parameter sets.
3. [`analysis_plots`](analysis_plots.ipynb): This script produces a plot showing the output proportions for each parameter value for each mode choice, along with linear regressions to better understand the parameters' impact.

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

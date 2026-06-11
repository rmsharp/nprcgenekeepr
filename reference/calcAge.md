# Calculate animal ages.

Part of Pedigree Curation

## Usage

``` r
calcAge(birth, exit)
```

## Arguments

- birth:

  Date vector of birth dates

- exit:

  Date vector of exit dates.

## Value

A numeric vector (`NA` allowed) indicating age in decimal years from
"birth" to "exit" or the current date if "exit" is NA.

## Details

Given vectors of birth and exit dates, calculate an individuals age. If
no exit date is provided, the calculation is based on the current date.

## Examples

``` r
library(nprcgenekeepr)
qcPed <- nprcgenekeepr::qcPed
originalAge <- qcPed$age ## ages calculated at time of data collection
currentAge <- calcAge(qcPed$birth, qcPed$exit) ## assumes no changes in
## colony
```

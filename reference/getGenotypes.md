# Get genotypes from file

Get genotypes from file

## Usage

``` r
getGenotypes(fileName, sep = ",")
```

## Arguments

- fileName:

  character vector of temporary file path.

- sep:

  column separator in CSV file

## Value

A genotype file compatible with others in this package.

## Examples

``` r
library(nprcgenekeepr)
pedCsv <- getGenotypes(fileName = system.file("testdata", "qcPed.csv",
  package = "nprcgenekeepr"
))
```

# Get pedigree from file

Get pedigree from file

## Usage

``` r
getPedigree(fileName, sep = ",")
```

## Arguments

- fileName:

  character vector of temporary file path.

- sep:

  column separator in CSV file

## Value

A pedigree file compatible with others in this package.

## Examples

``` r
library(nprcgenekeepr)
ped <- getPedigree(fileName = system.file("testdata", "qcPed.csv",
  package = "nprcgenekeepr"
))
```

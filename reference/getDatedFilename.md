# Prepend the date and time to a file name

Prepend the date and time to a file name

## Usage

``` r
getDatedFilename(filename)
```

## Arguments

- filename:

  character vector with name to use in file name

## Value

A character string with a file name prepended with the date and time in
YYYY-MM-DD_hh_mm_ss_basename format.

## Examples

``` r
library(nprcgenekeepr)
getDatedFilename("testName")
#> [1] "2026-07-08_02_12_26.576127_testName"
```

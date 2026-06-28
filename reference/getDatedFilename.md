# Returns a character vector with an file name having the date prepended

Returns a character vector with an file name having the date prepended

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
#> [1] "2026-06-28_04_09_30.364076_testName"
```

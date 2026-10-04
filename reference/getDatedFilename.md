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

A character string with `filename` prepended with the current date and
time. The prefix is
[`as.character()`](https://rdrr.io/r/base/character.html) of the current
time with spaces and colons replaced by underscores; it can include
fractional seconds, for example `2026-10-01_15_39_25.959408_testName`.

## Examples

``` r
library(nprcgenekeepr)
getDatedFilename("testName")
#> [1] "2026-10-04_23_19_10.680205_testName"
```

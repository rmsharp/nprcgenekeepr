# Filter a genetic value report to selected animals

Filter a genetic value report to selected animals

## Usage

``` r
filterReport(ids, rpt)
```

## Arguments

- ids:

  character vector of animal IDs

- rpt:

  a dataframe with the required colname `id`, such as the data.frame of
  results from a genetic value analysis. Only `id` is used; all other
  columns are returned unchanged.

## Value

A copy of report specific to the specified animals.

## Examples

``` r
library(nprcgenekeepr)
rpt <- nprcgenekeepr::pedWithGenotypeReport$report
rpt1 <- filterReport(c("GHH9LB", "BD41WW"), rpt)
```

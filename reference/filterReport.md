# Filters a genetic value report down to only the specified animals

Filters a genetic value report down to only the specified animals

## Usage

``` r
filterReport(ids, rpt)
```

## Arguments

- ids:

  character vector of animal IDs

- rpt:

  a dataframe with required colnames `id`, `gu`, `zScores`, `import`,
  `totalOffspring`, which is a data.frame of results from a genetic
  value analysis.

## Value

A copy of report specific to the specified animals.

## Examples

``` r
library(nprcgenekeepr)
rpt <- nprcgenekeepr::pedWithGenotypeReport$report
rpt1 <- filterReport(c("GHH9LB", "BD41WW"), rpt)
```

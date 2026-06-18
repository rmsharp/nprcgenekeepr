# Ranks animals based on genetic value

Part of Genetic Value Analysis Adds a column to `rpt` containing
integers from 1 to nrow, and provides a value designation for each
animal of "high value" or "low value"

## Usage

``` r
rankSubjects(rpt)
```

## Arguments

- rpt:

  a list of data.frame (req. colnames: value) containing genetic value
  data for the population. Dataframes separate out those animals that
  are imports, those that have high genome uniqueness (gu \> 10%), those
  that have low mean kinship (mk \< 0.25), and the remainder.

## Value

A list of dataframes with value and ranking information added.

## Examples

``` r
library(nprcgenekeepr)
finalRpt <- nprcgenekeepr::finalRpt
rpt <- rankSubjects(nprcgenekeepr::finalRpt)
rpt[["highGu"]][1, "value"]
#> [1] "High Value"
rpt[["highGu"]][1, "rank"]
#> [1] 1
rpt[["lowMk"]][1, "value"]
#> [1] "High Value"
rpt[["lowMk"]][1, "rank"]
#> [1] 122
rpt[["lowVal"]][1, "value"]
#> [1] "Low Value"
rpt[["lowVal"]][1, "rank"]
#> [1] 190
```

# Rank animals by genetic value

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

## References

Vinson, A. and Raboin, M.J. (2015) "A Practical Approach for Designing
Breeding Groups to Maximize Genetic Diversity in a Large Colony of
Captive Rhesus Macaques (*Macaca mulatta*)" *Journal of the American
Association for Laboratory Animal Science*, 2015 Nov, Vol.54(6),
pp.700-707.

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

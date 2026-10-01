# Rank animals by genetic value

Part of Genetic Value Analysis

## Usage

``` r
rankSubjects(rpt)
```

## Arguments

- rpt:

  a named list of data.frames containing genetic value data for the
  population, as made by the report ordering step. The element names
  decide the designation: `lowVal` and `noParentage` as described above,
  and every other element (for example `imports`, `lowMk` and `highGu`)
  is “High Value”. The tiers separate out the animals that are imports,
  those with low mean kinship (a mean-kinship z-score at or below
  `zScoreCutoff`), those with high genome uniqueness (`gu` above
  `guCutoff`), and the remainder; see
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md).

## Value

A list of dataframes with value and ranking information added. Elements
with no rows are returned unchanged.

## Details

Adds a `rank` column to each data.frame in `rpt`: integers from 1 to the
total number of ranked animals, running on from one tier to the next in
the order of the list. Animals in the `noParentage` element get an `NA`
rank. Adds a `value` column designating each animal `"High Value"`,
`"Low Value"` (the `lowVal` element) or `"Undetermined"` (the
`noParentage` element).

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

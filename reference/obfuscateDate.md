# Obfuscate dates with a random day offset

Get the `baseDate` and add a random number of days taken from a uniform
distribution bounded by -`maxDelta` and `maxDelta`. Insure the resulting
date is as least as large as the `minDate`.

## Usage

``` r
obfuscateDate(baseDate, minDate, maxDelta = 30L)
```

## Arguments

- baseDate:

  vector of Date values with dates to be obfuscated

- minDate:

  optional vector of Date values, the same length as `baseDate`, that
  has the lower bound of resulting obfuscated dates. When missing, the
  lower bound is each `baseDate` minus its `maxDelta`, so the bound
  never binds.

- maxDelta:

  integer vector of length 1 or the same length as `baseDate` that is
  used to create min and max arguments to `runif`
  (`runif(n, min = 0, max = 1)`)

## Value

A vector of dates that have be obfuscated.

## See also

Other obfuscation:
[`mapIdsToObfuscated()`](https://github.com/rmsharp/nprcgenekeepr/reference/mapIdsToObfuscated.md),
[`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md),
[`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md),
[`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md),
[`obfuscateLdBlocks()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md),
[`obfuscateMhcHaplotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateMhcHaplotypes.md),
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md),
[`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)

## Examples

``` r
library(nprcgenekeepr)
someDates <- rep(
  as.Date(c("2009-2-16", "2016-2-16"), format = "%Y-%m-%d"),
  10
)
minBirthDate <- rep(as.Date("2009-2-16", format = "%Y-%m-%d"), 20)
obfuscateDate(someDates, minBirthDate, 30L)
#>  [1] "2009-03-03" "2016-01-29" "2009-02-28" "2016-01-24" "2009-02-24"
#>  [6] "2016-03-09" "2009-03-04" "2016-03-04" "2009-03-06" "2016-02-22"
#> [11] "2009-02-25" "2016-02-07" "2009-03-17" "2016-02-24" "2009-03-13"
#> [16] "2016-02-21" "2009-03-16" "2016-02-29" "2009-02-28" "2016-01-23"
```

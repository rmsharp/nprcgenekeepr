# Obfuscate dates with a random day offset

Get the base_date add a random number of days taken from a uniform
distribution bounded by -max_delta and max_delta. Insure the resulting
date is as least as large as the min_date.

## Usage

``` r
obfuscateDate(baseDate, minDate, maxDelta = 30L)
```

## Arguments

- baseDate:

  list of Date objects with dates to be obfuscated

- minDate:

  list object of Date objects that has the lower bound of resulting
  obfuscated dates

- maxDelta:

  integer vector that is used to create min and max arguments to `runif`
  (`runif(n, min = 0, max = 1)`)

## Value

A vector of dates that have be obfuscated.

## See also

Other obfuscation:
[`mapIdsToObfuscated()`](https://github.com/rmsharp/nprcgenekeepr/reference/mapIdsToObfuscated.md),
[`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md),
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)

## Examples

``` r
library(nprcgenekeepr)
someDates <- rep(
  as.Date(c("2009-2-16", "2016-2-16"), format = "%Y-%m-%d"),
  10
)
minBirthDate <- rep(as.Date("2009-2-16", format = "%Y-%m-%d"), 20)
obfuscateDate(someDates, minBirthDate, 30L)
#>  [1] "2009-02-24" "2016-01-29" "2009-03-13" "2016-02-21" "2009-03-16"
#>  [6] "2016-02-29" "2009-02-28" "2016-01-23" "2009-02-24" "2016-03-16"
#> [11] "2009-03-03" "2016-02-13" "2009-02-16" "2016-01-29" "2009-02-21"
#> [16] "2016-02-20" "2009-02-24" "2016-03-12" "2009-02-21" "2016-02-19"
```

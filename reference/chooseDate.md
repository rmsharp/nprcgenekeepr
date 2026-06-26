# Choose date based on `earlier` flag

Part of Pedigree Curation

## Usage

``` r
chooseDate(d1, d2, earlier = TRUE)
```

## Arguments

- d1:

  `Date` vector with the first of two dates to compare.

- d2:

  `Date` vector with the second of two dates to compare.

- earlier:

  logical variable with `TRUE` if the earlier of the two dates is to be
  returned, otherwise the later is returned. Default is `TRUE`.

## Value

`Date` vector of chosen dates or `NA` where neither is provided

## Details

Given two dates, one is selected to be returned based on whether it
occurred earlier or later than the other. `NAs` are ignored if possible.

## Examples

``` r
library(nprcgenekeepr)
someDates <- lubridate::mdy(paste0(
  sample(1:12, 2, replace = TRUE), "-",
  sample(1:28, 2, replace = TRUE), "-",
  sample(seq(0, 15, by = 3), 2,
    replace = TRUE
  ) + 2000
))
someDates
#> [1] "2015-04-14" "2009-01-19"
chooseDate(someDates[1], someDates[2], earlier = TRUE)
#> [1] "2009-01-19"
chooseDate(someDates[1], someDates[2], earlier = FALSE)
#> [1] "2015-04-14"
```

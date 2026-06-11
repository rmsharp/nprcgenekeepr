# Get integer within a range

Assures that what is returned is an integer within the specified range.
Real values are truncated. Non-numerics are forced to minimum without
warning.

## Usage

``` r
withinIntegerRange(int = 0L, minimum = 0L, maximum = 0L, na = "min")
```

## Arguments

- int:

  value to be forced within a range

- minimum:

  minimum integer value.

- maximum:

  maximum integer value

- na:

  if "min" then non-numerics are forced to the minimum in the range If
  "max" then non-numerics are forced to the maximum in the range. If not
  either "min" or "max" it is forced to "min".

## Value

A vector of integers forced to be within the specified range.

## Examples

``` r
library(nprcgenekeepr)
withinIntegerRange()
#> [1] 0
withinIntegerRange(, 0, 10)
#> [1] 0
withinIntegerRange(NA, 0, 10, na = "max")
#> [1] 10
withinIntegerRange(, 0, 10, na = "max") # no argument is not NA
#> [1] 0
withinIntegerRange(LETTERS, 0, 10)
#>  [1] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
withinIntegerRange(2.6, 1, 5)
#> [1] 2
withinIntegerRange(2.6, 0, 2)
#> [1] 2
withinIntegerRange(c(0, 2.6, -1), 0, 2)
#> [1] 0 2 0
withinIntegerRange(c(0, 2.6, -1, NA), 0, 2)
#> [1] 0 2 0 0
withinIntegerRange(c(0, 2.6, -1, NA), 0, 2, na = "max")
#> [1] 0 2 0 2
withinIntegerRange(c(0, 2.6, -1, NA), 0, 2, na = "min")
#> [1] 0 2 0 0
```

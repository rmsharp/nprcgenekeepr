# checkChangedColsLst examines list for non-empty fields

checkChangedColsLst examines list for non-empty fields

## Usage

``` r
checkChangedColsLst(changedCols)
```

## Arguments

- changedCols:

  list with fields for each type of column change `qcStudbook`.

## Value

Returns `NULL` if all fields are empty else the entire list is returned.

## Examples

``` r
library(nprcgenekeepr)
library(lubridate)
#> 
#> Attaching package: ‘lubridate’
#> The following objects are masked from ‘package:base’:
#> 
#>     date, intersect, setdiff, union
pedOne <- data.frame(
  ego_id = c(
    "s1", "d1", "s2", "d2", "o1", "o2", "o3",
    "o4"
  ),
  `si re` = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
  dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
  sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
  birth_date = mdy(
    paste0(
      sample(1:12, 8, replace = TRUE), "-",
      sample(1:28, 8, replace = TRUE), "-",
      sample(seq(0, 15, by = 3), 8, replace = TRUE) +
        2000
    )
  ),
  stringsAsFactors = FALSE, check.names = FALSE
)

errorLst <- qcStudbook(pedOne, reportErrors = TRUE, reportChanges = TRUE)
checkChangedColsLst(errorLst$changedCols)
#> [1] TRUE
```

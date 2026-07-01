# Convert character date columns to Date type

Part of Pedigree Curation

## Usage

``` r
convertDate(ped, timeOrigin = as.Date("1970-01-01"), reportErrors = FALSE)
```

## Arguments

- ped:

  a dataframe of pedigree information that may contain birth, death,
  departure, or exit dates. The fields are optional, but will be used if
  present.(optional fields: birth, death, departure, and exit).

- timeOrigin:

  date object used by `as.Date` to set `origin`.

- reportErrors:

  logical value if TRUE will scan the entire file and make a list of all
  errors found. The errors will be returned in a list of list where each
  sublist is a type of error found.

## Value

A dataframe with an updated table with date columns converted from
`character` data type to `Date` data type. Values that do not conform to
the format %Y%m%d are set to NA. NA values are left as NA.

## Examples

``` r
library(lubridate)
set_seed(10)
someBirthDates <- paste0(
  sample(seq(0, 15, by = 3), 10,
    replace = TRUE
  ) + 2000, "-",
  sample(1:12, 10, replace = TRUE), "-",
  sample(1:28, 10, replace = TRUE)
)
someBadBirthDates <- paste0(
  sample(1:12, 10, replace = TRUE), "-",
  sample(1:28, 10, replace = TRUE), "-",
  sample(seq(0, 15, by = 3), 10,
    replace = TRUE
  ) + 2000
)
someDeathDates <- sample(someBirthDates, length(someBirthDates),
  replace = FALSE
)
someDepartureDates <- sample(someBirthDates, length(someBirthDates),
  replace = FALSE
)
ped1 <- data.frame(
  birth = someBadBirthDates, death = someDeathDates,
  departure = someDepartureDates
)
someDates <- ymd(someBirthDates)
ped2 <- data.frame(
  birth = someDates, death = someDeathDates,
  departure = someDepartureDates
)
ped3 <- data.frame(
  birth = someBirthDates, death = someDeathDates,
  departure = someDepartureDates
)
someNADeathDates <- someDeathDates
someNADeathDates[c(1, 3, 5)] <- ""
someNABirthDates <- someDates
someNABirthDates[c(2, 4, 6)] <- NA
ped4 <- data.frame(
  birth = someNABirthDates, death = someNADeathDates,
  departure = someDepartureDates
)

## convertDate identifies bad dates
result <- tryCatch(
  {
    convertDate(ped1)
  },
  warning = function(w) {
    print("Warning in date")
  },
  error = function(e) {
    print("Error in date")
  }
)
#> [1] "Error in date"

## convertDate with error flag returns error list and not an error
convertDate(ped1, reportErrors = TRUE)
#>  [1] "1"  "2"  "3"  "4"  "5"  "6"  "7"  "8"  "9"  "10"

## convertDate recognizes good dates
all(is.Date(convertDate(ped2)$birth))
#> [1] TRUE
all(is.Date(convertDate(ped3)$birth))
#> [1] TRUE

## convertDate handles NA and empty character string values correctly
convertDate(ped4)
#>         birth      death  departure
#> 1  2009-08-25       <NA> 2009-08-25
#> 2        <NA> 2003-07-18 2000-05-12
#> 3  2006-02-22       <NA> 2003-06-20
#> 4        <NA> 2006-02-22 2012-08-10
#> 5  2000-05-12       <NA> 2006-11-10
#> 6        <NA> 2003-04-07 2006-02-22
#> 7  2003-01-24 2003-01-24 2003-07-18
#> 8  2003-04-07 2009-05-22 2009-05-22
#> 9  2009-05-22 2006-11-10 2003-04-07
#> 10 2006-11-10 2000-05-12 2003-01-24
```

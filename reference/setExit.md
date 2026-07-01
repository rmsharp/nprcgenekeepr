# Set the exit date when no exit column exists

Part of Pedigree Curation

## Usage

``` r
setExit(ped, timeOrigin = as.Date("1970-01-01"))
```

## Arguments

- ped:

  dataframe of pedigree and demographic information potentially
  containing columns indicating the birth and death dates of an
  individual. The table may also contain dates of sale (departure).
  Optional columns are `birth`, `death`, and `departure`.

- timeOrigin:

  date object used by `as.Date` to set `origin`.

## Value

A dataframe with an updated pedigree with exit dates specified based on
date information that was available.

## Examples

``` r
library(lubridate)
library(nprcgenekeepr)
death <- mdy(paste0(
  sample(1:12, 10, replace = TRUE), "-",
  sample(1:28, 10, replace = TRUE), "-",
  sample(seq(0, 15, by = 3), 10, replace = TRUE) + 2000
))
departure <- as.Date(rep(NA, 10), origin = as.Date("1970-01-01"))
departure[c(1, 3, 6)] <- as.Date(death[c(1, 3, 6)],
  origin = as.Date("1970-01-01")
)
death[c(1, 3, 5)] <- NA
death[6] <- death[6] + days(1)
ped <- data.frame(
  id = paste0(100 + 1:10),
  birth = mdy(paste0(
    sample(1:12, 10, replace = TRUE), "-",
    sample(1:28, 10, replace = TRUE), "-",
    sample(seq(0, 20, by = 3), 10, replace = TRUE) + 1980
  )),
  death = death,
  departure = departure,
  stringsAsFactors = FALSE
)
pedWithExit <- setExit(ped)
```

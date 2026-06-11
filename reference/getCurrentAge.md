# Age in years using the provided birthdate.

Assumes current date for calculating age.

## Usage

``` r
getCurrentAge(birth)
```

## Arguments

- birth:

  birth date(s)

## Value

Age in years using the provided birthdate.

## Examples

``` r
library(nprcgenekeepr)
age <- getCurrentAge(birth = as.Date("06/02/2000", format = "%m/%d/%Y"))
```

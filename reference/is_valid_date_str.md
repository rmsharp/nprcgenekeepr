# Test whether a string is a valid date

Taken from github.com/rmsharp/rmsutilityr

## Usage

``` r
is_valid_date_str(
  date_str,
  format = "%d-%m-%Y %H:%M:%S",
  optional = FALSE
)
```

## Arguments

- date_str:

  character vector with 0 or more dates

- format:

  character vector of length one. Retained for backward compatibility;
  the current implementation validates dates with `anytime()` and does
  not use `format`.

- optional:

  logical value indicating that NA should be returned instead of `FALSE`
  for strings that are not valid dates. Defaults to FALSE.

## Value

A logical value or `NA` indicating whether or not the provided character
vector represented a valid date string.

## Examples

``` r
is_valid_date_str(c(
  "13-21-1995", "20-13-98", "5-28-1014",
  "1-21-15", "2-13-2098", "25-28-2014"
), format = "%m-%d-%y")
#> [1] FALSE FALSE  TRUE  TRUE  TRUE FALSE
```

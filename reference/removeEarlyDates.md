# removeEarlyDates removes dates before a specified year

Dates before a specified year are set to NA. This is often used for
dates formed from malformed character representations such as a date in
%m-%d-%Y format being read by %Y-%m-%d format

## Usage

``` r
removeEarlyDates(dates, firstYear)
```

## Arguments

- dates:

  vector of dates

- firstYear:

  integer value of first (earliest) year in the allowed date range.

## Value

A vector of dates after the year indicated by the numeric value of
`firstYear`.

## Details

NA values are ignored and not changed.

## Examples

``` r
dates <- structure(c(
  12361, 14400, 15413, NA, 11189, NA, 13224, 10971,
  -432000, 13262
), class = "Date")
cleanedDates <- removeEarlyDates(dates, firstYear = 1000)
dates
#>  [1] "2003-11-05" "2009-06-05" "2012-03-14" NA           "2000-08-20"
#>  [6] NA           "2006-03-17" "2000-01-15" "787-03-24"  "2006-04-24"
cleanedDates
#>  [1] "2003-11-05" "2009-06-05" "2012-03-14" NA           "2000-08-20"
#>  [6] NA           "2006-03-17" "2000-01-15" NA           "2006-04-24"
```

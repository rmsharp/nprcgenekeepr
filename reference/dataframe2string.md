# Convert a data frame to a character vector

Adapted from print.data.frame

## Usage

``` r
dataframe2string(object, ..., digits = NULL, addRowNames = TRUE)
```

## Arguments

- object:

  dataframe Rows are joined with newline characters, so the result is
  one string.

- ...:

  currently unused; accepted for compatibility with print methods.

- digits:

  the minimum number of significant digits to be used: see
  print.default.

- addRowNames:

  single logical value. If `TRUE` (the default), the row names of the
  data frame are printed. Any other value, including a character vector,
  is treated as `FALSE`.

## Value

A character vector of length one holding the text representation of the
data.frame provided to the function, with rows separated by newline
characters.

## Examples

``` r
library(nprcgenekeepr)
dataframe2string(nprcgenekeepr::pedOne)
#> [1] " ego_idsire.iddam_idsexbirth_date\n1  s1    NA     NA   F 2000-07-18\n2  d1    NA     NA   M 2003-04-13\n3  s2    NA     NA   M 2006-06-19\n4  d2    NA     NA   F 2015-09-16\n5  o1    s1     d1   F 2015-02-04\n6  o2    s1     d2   F 2009-03-17\n7  o3    s2     d2   F 2012-04-11\n8  o4    s2     d2   M 2006-04-13"
```

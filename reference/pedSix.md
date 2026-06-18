# Raw pedigree-file fragment for testing (7 columns)

A loadable version of a pedigree file fragment used for testing and
demonstration.

## Usage

``` r
data(pedSix)
```

## Format

An object of class `data.frame` with 8 rows and 7 columns.

## Examples

``` r
library(nprcgenekeepr)
data("pedSix")
head(pedSix)
#>   Ego Id Sire Id  Dam Sex Birth Date  Departure      Death
#> 1     s1    <NA> <NA>   F 1983-05-10 2009-08-02 2012-07-24
#> 2     d1      s0   d0   F 1983-10-01 2003-08-18 2003-06-10
#> 3     s2      s4   d4   M 1980-11-17 2006-08-12 2006-08-12
#> 4     d2    <NA> <NA>   F 1992-03-26 2000-02-25 2003-08-18
#> 5     o1      s1   d1   F 2003-10-24 2003-06-10 2009-08-02
#> 6     o2      s1   d2   F 2000-05-27 2003-06-08 2003-05-22
```

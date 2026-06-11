# pedOne is a loadable version of a pedigree file fragment used for testing and demonstration

This is used for testing and demonstration.

## Usage

``` r
pedOne
```

## Format

An object of class `data.frame` with 8 rows and 5 columns.

## Examples

``` r
library(nprcgenekeepr)
data("pedOne")
head(pedOne)
#>   ego_id si re dam_id sex birth_date
#> 1     s1  <NA>   <NA>   F 2000-07-18
#> 2     d1  <NA>   <NA>   M 2003-04-13
#> 3     s2  <NA>   <NA>   M 2006-06-19
#> 4     d2  <NA>   <NA>   F 2015-09-16
#> 5     o1    s1     d1   F 2015-02-04
#> 6     o2    s1     d2   F 2009-03-17
```

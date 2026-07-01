# Make the initial grpNum list

Make the initial grpNum list

## Usage

``` r
makeGroupNum(numGp)
```

## Arguments

- numGp:

  integer value indicating the number of groups that should be formed
  from the list of IDs. Default is 1.

## Value

Initial grpNum list

## Examples

``` r
library(nprcgenekeepr)
## Create the initial grpNum list for three groups
grpNum <- makeGroupNum(numGp = 3L)
grpNum
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] 2
#> 
#> [[3]]
#> [1] 3
#> 
```

# Remove potential sires from a list of IDs

Remove potential sires from a list of IDs

## Usage

``` r
removePotentialSires(ids, minAge, ped)
```

## Arguments

- ids:

  character vector of animal IDs

- minAge:

  integer value indicating the minimum age to consider in group
  formation. Pairwise kinships involving an animal of this age or
  younger will be ignored. Default is 1 year.

- ped:

  dataframe that is the `Pedigree`. It contains pedigree information
  including the IDs listed in `candidates`.

## Value

character vector of Ids with any potential sire Ids removed.

## Examples

``` r
library(nprcgenekeepr)
qcBreeders <- nprcgenekeepr::qcBreeders
pedWithGenotype <- nprcgenekeepr::pedWithGenotype
noSires <- removePotentialSires(
  ids = qcBreeders, minAge = 2,
  ped = pedWithGenotype
)
sires <- getPotentialSires(qcBreeders, ped = pedWithGenotype, minAge = 2)
pedWithGenotype[pedWithGenotype$id %in% noSires, c("sex", "age")]
#>     sex  age
#> 161   F 14.3
#> 197   F  3.3
#> 178   F  6.0
#> 186   F  4.4
#> 188   F  4.4
#> 191   F  4.4
#> 195   F  3.8
#> 174   F  7.0
#> 175   F  6.4
#> 176   F  6.3
#> 177   F  6.1
#> 179   F  6.0
#> 180   F  6.0
#> 182   F  5.9
#> 184   F  5.2
#> 185   F  4.4
#> 187   F  4.4
#> 189   F  4.3
#> 190   F  4.4
#> 192   F  4.2
#> 193   F  4.1
#> 194   F  3.8
#> 198   F  3.1
#> 181   F  6.1
#> 183   F  5.4
#> 196   F  3.7
pedWithGenotype[pedWithGenotype$id %in% sires, c("sex", "age")]
#>     sex  age
#> 52    M 18.4
#> 165   M 13.4
#> 169   M 12.2
```

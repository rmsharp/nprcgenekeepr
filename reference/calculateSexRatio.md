# Calculate the sex ratio of a set of animals

The Males are counted when the `ped$sex` value is `"M"`. Females are
counted when the `ped$sex` value is not `"M"`. This means animals with
ambiguous sex are counted with the females.

## Usage

``` r
calculateSexRatio(ids, ped, additionalMales = 0L, additionalFemales = 0L)
```

## Arguments

- ids:

  character vector of animal IDs

- ped:

  dataframe that is the `Pedigree`. It contains pedigree information
  including the IDs listed in `ids`.

- additionalMales:

  Integer value of males to add to those within the group when
  calculating the ratio. The additions always count, except when `ids`
  has no animals or no males: with no males, the ratio is `Inf` unless
  `additionalMales` is greater than 0 (then `additionalFemales` still
  counts); with no animals, see *Value*. Default is 0.

- additionalFemales:

  Integer value of females to add to those within the group when
  calculating the ratio. The additions always count, except as described
  for `additionalMales`. Default is 0.

## Value

Numeric value of the sex ratio of the animals provided, expressed as the
number of non-males per male. It is `Inf` when there are no males (and
no males are added) but at least one non-male; `0` when `ids` is empty,
no females are added and males are added; and `NA` when `ids` is empty
and nothing is added.

## Examples

``` r
library(nprcgenekeepr)
data("qcBreeders")
data("pedWithGenotype")
available <- c(
  "JGPN6K", "8KM1MP", "I9TQ0T", "Q0RGP7", "VFS0XB", "CQC133",
  "2KULR3", "HOYW0S", "FHV13N", "OUM6QF", "6Z7MD9", "CFPEEU",
  "HLI95R", "RI0O7F", "7M51X5", "DR5GXB", "170ZTZ", "C1ICXL"
)
nonMales <- c(
  "JGPN6K", "8KM1MP", "I9TQ0T", "Q0RGP7", "CQC133",
  "2KULR3", "HOYW0S", "FHV13N", "OUM6QF", "6Z7MD9", "CFPEEU",
  "HLI95R", "RI0O7F", "7M51X5", "DR5GXB", "170ZTZ", "C1ICXL"
)
male <- "VFS0XB"
calculateSexRatio(ids = male, ped = pedWithGenotype)
#> [1] 0
calculateSexRatio(ids = nonMales, ped = pedWithGenotype)
#> [1] Inf
calculateSexRatio(ids = available, ped = pedWithGenotype)
#> [1] 17
calculateSexRatio(
  ids = available, ped = pedWithGenotype,
  additionalMales = 1L
)
#> [1] 8.5
calculateSexRatio(
  ids = available, ped = pedWithGenotype,
  additionalFemales = 1L
)
#> [1] 18
calculateSexRatio(
  ids = available, ped = pedWithGenotype,
  additionalMales = 1, additionalFemales = 1L
)
#> [1] 9
calculateSexRatio(
  ids = nonMales, ped = pedWithGenotype,
  additionalMales = 1, additionalFemales = 0L
)
#> [1] 17
calculateSexRatio(
  ids = character(0), ped = pedWithGenotype,
  additionalMales = 1, additionalFemales = 0L
)
#> [1] 0
```

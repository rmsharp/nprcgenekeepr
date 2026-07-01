# Get potential parents for animals with unknown parents

**\[experimental\]**

## Usage

``` r
getPotentialParents(
  ped,
  minParentAge,
  maxGestationalPeriod = NULL,
  gestationTable = NULL
)
```

## Arguments

- ped:

  the pedigree information in data.frame format. Pedigree (req. fields:
  id, sire, dam, gen, population). This requires complete pedigree
  information.

- minParentAge:

  numeric values to set the minimum age in years for an animal to have
  an offspring. Defaults to 2 years. The check is not performed for
  animals with missing birth dates.

- maxGestationalPeriod:

  integer maximum number of days between conception and birth for the
  species being analyzed (a conservative upper bound, e.g. 210 for
  rhesus whose typical gestation is about 165 days). When `NULL` (the
  default) the window is looked up per animal from the `species` column
  of `ped` via
  [`getSpeciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md),
  falling back to 210 days for animals whose species is missing or
  unrecognized; supply an explicit integer to use one fixed window for
  every animal. It is used two ways: (1) a sire who exited the colony
  between conception (birth - maxGestationalPeriod) and birth is still
  retained as a candidate; and (2) a female who delivered another
  offspring within maxGestationalPeriod days of the focal birth is
  excluded as a candidate dam, because a female bears one offspring at a
  time. The sire check uses presence at conception while the dam check
  uses presence at birth; this asymmetry is intentional – a sire need
  only be present to conceive, whereas a dam must be present through the
  pregnancy to give birth.

- gestationTable:

  optional data.frame (columns `species`, `gestation`) passed to
  [`getSpeciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md)
  for the per-animal lookup when `maxGestationalPeriod` is `NULL`.
  Defaults to `NULL`, which uses the bundled
  [`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)
  table.

## Value

a list of list with each internal list being made up of an animal id
(`id`), a vector of possible sires (`sire`) and a vector of possible
dams (`dam`). The `id` must be defined while the vectors `sire` and
`dam` can be empty.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::rhesusPedigree
## getPotentialParents needs a logical fromCenter column flagging
## colony-born animals; add one if your pedigree lacks it.
ped$fromCenter <- TRUE
potentialParents <- getPotentialParents(
  ped = ped, minParentAge = 2.0, maxGestationalPeriod = 210L
)
## Each element pairs a focal id with candidate sires and dams.
potentialParents[[1L]]
#> $id
#> [1] "BRI2MW"
#> 
#> $sires
#>  [1] "HKTQ40" "MY1AEU" "QWUKUY" "1X40V5" "WDBGPF" "6MGJYG" "8LWCAD" "SLN0TF"
#>  [9] "Q7F87W" "IQLWH8" "M0YNUR" "RYP77M" "8LKBV9" "D0Z114" "1W4GNT" "D1WP48"
#> [17] "CAN12C" "KUENM8" "QP1WMJ" "WCPXHD" "DKMJ2Z" "1Y8P15" "4F3ASD" "DKDP5B"
#> [25] "XL7AVE" "YPHFHF" "A3UZAN" "7U5NJD" "ELGVC6" "L07M06" "4U7JTW" "270UK6"
#> [33] "LUPGF8" "S0ZHJP" "WWZRCW" "H16EC4" "81MJXH" "K9TMQP" "GA204Z" "V1X2X3"
#> [41] "P49ZD1" "KY4G8M" "9JC6RF" "M5DJVP" "HJLX2B" "SPHGC9" "62PLX3" "QQ24T8"
#> [49] "9LZVTE" "VTZFWZ"
#> 
#> $dams
#> [1] "HR70BU" "I2G9D6" "J8XZ81" "HV7LZ3" "IMF6BL"
#> 
```

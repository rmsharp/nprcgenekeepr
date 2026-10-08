# Build a group data frame with ID, sex, and age

Build a group data frame with ID, sex, and age

## Usage

``` r
addSexAndAgeToGroup(ids, ped)
```

## Arguments

- ids:

  character vector of animal IDs

- ped:

  The pedigree information in data.frame format

## Value

A data frame with columns `ids`, `sex` and `age` (current age). Every id
must occur exactly once in `ped$id`; an id that is missing from or
duplicated in `ped` causes an error rather than an `NA`.

## Details

An empty `ids` vector yields a zero-row data frame that still contains
all three columns (`ids`, `sex`, `age`), with `sex` an empty factor, so
the returned schema does not depend on the number of ids supplied.

## Examples

``` r
library(nprcgenekeepr)
data("qcBreeders")
data("qcPed")
df <- addSexAndAgeToGroup(ids = qcBreeders, ped = qcPed)
head(df)
#>           ids sex      age
#> Q0RGP7 Q0RGP7   F 21.65092
#> C1ICXL C1ICXL   F 10.62834
#> J3D3N5 J3D3N5   M 25.70021
#> VFS0XB VFS0XB   M 20.69541
#> HP3E04 HP3E04   M 19.54278
#> 2KULR3 2KULR3   F 13.30595
```

# Build a group data frame with ID, sex, and age

Build a group data frame with ID, sex, and age

## Usage

``` r
addSexAndAgeToGroup(ids, ped)
```

## Arguments

- ids:

  character vector of animal Ids

- ped:

  datatable that is the `Pedigree`. It contains pedigree information.

## Value

Dataframe with Id, Sex, and Current Age

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
#> Q0RGP7 Q0RGP7   F 21.37988
#> C1ICXL C1ICXL   F 10.35729
#> J3D3N5 J3D3N5   M 25.42916
#> VFS0XB VFS0XB   M 20.42437
#> HP3E04 HP3E04   M 19.27173
#> 2KULR3 2KULR3   F 13.03491
```

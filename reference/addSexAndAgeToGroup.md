# Forms a dataframe with Id, Sex, and current Age given a list of Ids and a pedigree

Forms a dataframe with Id, Sex, and current Age given a list of Ids and
a pedigree

## Usage

``` r
addSexAndAgeToGroup(ids, ped)
```

## Arguments

- ids:

  character vector of animal Ids

- ped:

  datatable that is the `Pedigree`. It contains pedigree information
  including the IDs listed in `candidates`.

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
#> Q0RGP7 Q0RGP7   F 21.35797
#> C1ICXL C1ICXL   F 10.33539
#> J3D3N5 J3D3N5   M 25.40726
#> VFS0XB VFS0XB   M 20.40246
#> HP3E04 HP3E04   M 19.24983
#> 2KULR3 2KULR3   F 13.01300
```

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

## Examples

``` r
library(nprcgenekeepr)
data("qcBreeders")
data("qcPed")
df <- addSexAndAgeToGroup(ids = qcBreeders, ped = qcPed)
head(df)
#>           ids sex      age
#> Q0RGP7 Q0RGP7   F 21.32512
#> C1ICXL C1ICXL   F 10.30253
#> J3D3N5 J3D3N5   M 25.37440
#> VFS0XB VFS0XB   M 20.36961
#> HP3E04 HP3E04   M 19.21697
#> 2KULR3 2KULR3   F 12.98015
```

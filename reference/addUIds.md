# Eliminates partial parentage situations by adding unique placeholder IDs for the unknown parent.

This must be run prior to `addParents` since the IDs made herein are
used by `addParents`

## Usage

``` r
addUIds(ped, format = getAutoIdFormat())
```

## Arguments

- ped:

  datatable that is the `Pedigree`. It contains pedigree information.
  The fields `sire` and `dam` are required.

- format:

  `sprintf` template for the generated placeholder IDs; defaults to
  [`getAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md)
  (`"U%04d"`).

## Value

The updated pedigree with partial parentage removed.

## Details

The generated placeholder IDs default to the form `Unnnn` (a leading "U"
plus a zero-padded integer), so they are alphanumeric and never contain
a period ("."), honoring the ID rule enforced at data input by
[`qcStudbook`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md).
The format is configurable via
[`setAutoIdFormat`](https://github.com/rmsharp/nprcgenekeepr/reference/setAutoIdFormat.md)
(default `"U%04d"`).

## Examples

``` r
pedTwo <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
  stringsAsFactors = FALSE
)
newPed <- addUIds(pedTwo)
newPed[newPed$id == "s1", ]
#>   id  sire dam sex
#> 1 s1 U0001  d0   M
pedThree <-
  data.frame(
    id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
    sire = c("s0", "s0", "s4", NA, "s1", "s1", "s2", "s2"),
    dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
    sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
    stringsAsFactors = FALSE
  )
newPed <- addUIds(pedThree)
newPed[newPed$id == "s1", ]
#>   id sire   dam sex
#> 1 s1   s0 U0001   M
```

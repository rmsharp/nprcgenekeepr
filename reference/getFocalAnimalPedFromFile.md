# Get a focal-animal pedigree from a pedigree file

File-sourced sibling of
[`getFocalAnimalPed`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md):
reads a list of focal animal Ids from `fileName` (the first column,
exactly as
[`getFocalAnimalPed`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
does), then builds the focal animals' full connected pedigree component
from a SEPARATE pedigree file via
[`getFileDirectRelatives`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md).
This lets the focal-animal workflow run entirely offline – no LabKey /
EHR connection is required.

## Usage

``` r
getFocalAnimalPedFromFile(fileName, pedigreeFileName = NULL, sep = ",")
```

## Arguments

- fileName:

  character path to a file (CSV, delimited text, or Excel) whose first
  column is the list of focal animal Ids.

- pedigreeFileName:

  character path to the pedigree file (CSV, delimited text, or Excel)
  read via
  [`getPedigree`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md);
  it must provide at least `id`, `sire`, and `dam` columns.

- sep:

  column separator passed to the file readers for delimited text files
  (default `","`); ignored for Excel files.

## Value

On success, a data.frame with the focal animals' full connected pedigree
component (ancestors, descendants, and collaterals), as returned by
[`getFileDirectRelatives`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md).
On any failure this function does NOT throw: it returns a classed
`nprcgenekeeprFileErr` object (a list with a `message` element) naming
WHY the read failed – an unreadable focal-id list file; a missing,
not-found, unreadable, or wrong-column pedigree file; or no focal IDs
present in the pedigree. The application surfaces `message` as the "File
Read Error" detail (distinct from the LabKey path, which returns an
`nprcgenekeeprErr`).

## Details

The underlying file source errors loudly on a bad pedigree file, but
this function is the application boundary, so it is fail-soft: it
returns `NULL` when the pedigree file is missing, does not exist, or
lacks the `id`, `sire`, and `dam` columns. (This mirrors how the app's
other file inputs behave – a `NULL` surfaces a "File Read Error" – and
is distinct from the LabKey path, which returns an `nprcgenekeeprErr`.)

## Examples

``` r
library(nprcgenekeepr)
## A focal-id file and a pedigree file, then build the pedigree offline.
ped <- data.frame(
  id = c("A", "B", "C"), sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
  stringsAsFactors = FALSE
)
pedFile <- tempfile(fileext = ".csv")
write.csv(ped, pedFile, row.names = FALSE)
focalFile <- tempfile(fileext = ".csv")
write.csv(data.frame(id = "C"), focalFile, row.names = FALSE)
getFocalAnimalPedFromFile(focalFile, pedFile)
#>   id sire  dam
#> 1  A <NA> <NA>
#> 2  B <NA> <NA>
#> 3  C    A    B
unlink(c(pedFile, focalFile))
```

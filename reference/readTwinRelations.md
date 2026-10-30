# Read a twin/zygosity relations table from a file

Reads a user-supplied twin-relations sidecar table into a data frame for
[`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md).
The expected form is `id1`, `id2`, `code`, with a header row (see
[`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)
for the accepted `code` values). Excel (`.xls`/`.xlsx`) and delimited
text (`.csv`/ `.txt`) files are both accepted, mirroring
[`readKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/readKinshipOverrides.md)
– the closest existing precedent for a validated, pairwise sidecar
upload (issue \#137 D1/D5,
`docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md`).

## Usage

``` r
readTwinRelations(fileName, sep = ",")
```

## Arguments

- fileName:

  character vector of length one; path to the twin -relations file
  (typically the temporary `datapath` from a Shiny file upload).

- sep:

  column separator for delimited text files (default `","`). Ignored for
  Excel files.

## Value

A data frame of the rows read from `fileName` (typically with columns
`id1`, `id2`, and `code`). Validate it with
[`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)
before use.

## Details

This reader does not validate structure or domain – that is
[`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)'s
job.

## Examples

``` r
ped <- data.frame(
  id = c("F1", "F2", "S1", "S2"),
  sire = c(NA, NA, "F1", "F1"),
  dam = c(NA, NA, "F2", "F2"),
  sex = c("M", "F", "F", "F"),
  stringsAsFactors = FALSE
)
csvFile <- tempfile(fileext = ".csv")
writeLines(c("id1,id2,code", "S1,S2,MZ twin"), csvFile)
twinRelations <- readTwinRelations(fileName = csvFile)
twinRelations <- checkTwinRelations(ped, twinRelations)
twinRelations
#>   id1 id2    code
#> 1  S1  S2 MZ twin
unlink(csvFile)
```

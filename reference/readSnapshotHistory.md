# Read a colony snapshot-history table from a file

Reads a user-maintained longitudinal colony snapshot history (issue
\#167) from a file into a data frame for
[`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md).
The history is the single CSV a colony manager keeps between analyses:
one row per recorded snapshot in the 27-column version-1 schema (see
[`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md)
for the column groups). Excel (`.xls`/`.xlsx`) and delimited text
(`.csv`/`.txt`) files are both accepted, mirroring
[`readKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/readKinshipOverrides.md).
Excel files are read with every column as text and then the numeric
columns (e.g. `schemaVersion`) are converted to numbers, so an Excel
file and a delimited text file of the same table give the same result. A
numeric column that holds a value that is not a number is left as text
and
[`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md)
stops, naming it.

## Usage

``` r
readSnapshotHistory(fileName, sep = ",")
```

## Arguments

- fileName:

  character vector of length one; path to the snapshot history file
  (typically the temporary `datapath` from a Shiny file upload, or a
  path the user's own scripts maintain).

- sep:

  column separator for delimited text files (default `","`). Ignored for
  Excel files.

## Value

A data frame of the rows read from `fileName`. Validate it with
[`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md)
before use.

## Details

This reader does not validate structure or domain — that is
[`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md)'s
job, matching the reader/validator sibling-pair convention.

## Examples

``` r
history <- readSnapshotHistory(system.file("extdata", "examples",
  "example_snapshot_history.csv",
  package = "nprcgenekeepr"
))
history <- checkSnapshotHistory(history)
```

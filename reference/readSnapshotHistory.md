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

  column separator for delimited text files (default `","`).

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

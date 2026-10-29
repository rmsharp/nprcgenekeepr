# Append a colony snapshot to a snapshot history

Pure merge for the longitudinal colony snapshot workflow (issue \#167):
takes a validated snapshot history (or `NULL` / a zero-row history for a
first snapshot) and one new snapshot row, and returns the merged,
date-ordered history. It writes nothing — script users persist the
result themselves (e.g. `write.csv(..., row.names = FALSE)`), and the
Shiny application writes only through a user-initiated download.

## Usage

``` r
appendColonySnapshot(history, snapshot)
```

## Arguments

- history:

  validated snapshot history data.frame (see
  [`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md)),
  or `NULL` / a zero-row history when recording the first snapshot.

- snapshot:

  one-row data.frame holding the new snapshot, in the same schema as the
  history. The row count and columns are not checked; rows are bound to
  the history as given.

## Value

The merged history, ordered by `snapshotDate`.

## Details

The new snapshot must carry the same `schemaVersion` as the history, and
its (`snapshotDate`, `membershipRule`) pair must not already be present
— the pair identifies a snapshot uniquely. The same date under a
different membership rule is legal.

## Examples

``` r
history <- checkSnapshotHistory(readSnapshotHistory(system.file(
  "extdata", "examples", "example_snapshot_history.csv",
  package = "nprcgenekeepr"
)))
snapshot <- history[3L, ]
snapshot$snapshotDate <- as.Date("2026-07-15")
appendColonySnapshot(history, snapshot)
#>   schemaVersion snapshotDate packageVersion  membershipRule guIter guThresh
#> 1             1   2025-01-15          1.0.5   wholePedigree   5000        3
#> 2             1   2025-07-15          2.0.0   wholePedigree   5000        3
#> 3             1   2026-01-15     2.0.0.9000   wholePedigree  10000        3
#> 4             1   2026-01-15     2.0.0.9000 focalPopulation  10000        3
#> 5             1   2026-07-15     2.0.0.9000   wholePedigree  10000        3
#>   nAnimals nMales nFemales   fe  fg fgSE   neGD neSexRatio neVariance
#> 1      360    120      240 14.2 8.6 0.21 0.9419      213.3      187.4
#> 2      372    124      248 14.5 8.8 0.20 0.9432      220.6      191.2
#> 3      381    127      254 14.7 9.0 0.14 0.9444      226.9      195.0
#> 4      145     48       97  9.8 6.2 0.18 0.9194      128.5      110.7
#> 5      381    127      254 14.7 9.0 0.14 0.9444      226.9      195.0
#>   nMaleFounders nFemaleFounders nFounders meanIndivMeanKin medianIndivMeanKin
#> 1            12              24        36           0.0812             0.0794
#> 2            12              24        36           0.0805             0.0788
#> 3            12              24        36           0.0801             0.0785
#> 4            10              20        30           0.0910             0.0895
#> 5            12              24        36           0.0801             0.0785
#>   skewnessIndivMeanKin kurtosisIndivMeanKin meanGu medianGu meanGuSE skewnessGu
#> 1                 0.42                 -0.1   21.3     20.5     0.41       0.35
#> 2                 0.40                 -0.2   21.9     21.1     0.40       0.33
#> 3                 0.39                 -0.2   22.4     21.6     0.28       0.31
#> 4                 0.48                  0.2   19.8     19.2     0.33       0.38
#> 5                 0.39                 -0.2   22.4     21.6     0.28       0.31
#>   kurtosisGu
#> 1        0.1
#> 2        0.0
#> 3        0.0
#> 4        0.1
#> 5        0.0
```

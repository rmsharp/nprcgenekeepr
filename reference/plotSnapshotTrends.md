# Plot colony genetic-health trends from a snapshot history

Draws the longitudinal trend view of a colony snapshot history (issue
\#167): one `ggplot` object faceted per metric (free y scales), with
`snapshotDate` on the x axis and one colored series per
`membershipRule`, so successive snapshots are compared like with like.
Sampling-uncertainty ribbons are drawn exactly where the schema carries
a standard error: `fg` (`fgSE`) and `meanGu` (`meanGuSE`) — the Monte
Carlo gene-drop uncertainty is surfaced, never hidden.

## Usage

``` r
plotSnapshotTrends(history, metrics = NULL)
```

## Arguments

- history:

  data.frame holding the snapshot history in the 27-column version-1
  schema; validated internally with
  [`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md).
  A trend needs at least two snapshots.

- metrics:

  character vector naming the metric columns to facet. The default
  `NULL` plots the 18 metric columns (the
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  colony scalars and the Summary Statistics aggregates); the composition
  counts (`nAnimals`, `nMales`, `nFemales`) may be requested to make
  membership churn visible.

## Value

A `ggplot` object.

## Details

Snapshots whose provenance (`guIter`, `guThresh`, or `packageVersion`)
changed relative to the same rule's previous snapshot are drawn with a
distinct point shape, and the plot carries a caption naming the changed
fields: mixed-provenance series are flagged, not refused.

## Examples

``` r
history <- checkSnapshotHistory(readSnapshotHistory(system.file("extdata",
  "examples", "example_snapshot_history.csv",
  package = "nprcgenekeepr"
)))
p <- plotSnapshotTrends(history, metrics = c("fe", "fg", "meanGu"))
```

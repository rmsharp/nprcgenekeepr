# Plot colony genetic-health trends from a snapshot history

Draws the longitudinal trend view of a colony snapshot history (issue
\#167): one `ggplot` object faceted per metric (free y scales), with
`snapshotDate` on the x axis and one colored series per
`membershipRule`, so successive snapshots are compared like with like.
Sampling-uncertainty ribbons are drawn exactly where the schema carries
a standard error: `fg` (`fgSE`) and `meanGu` (`meanGuSE`) — the Monte
Carlo gene-drop uncertainty is surfaced, never hidden. Date labels that
would overlap on a narrow panel are dropped instead of drawn over one
another.

## Usage

``` r
plotSnapshotTrends(history, metrics = NULL, ncol = NULL)
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

- ncol:

  single positive whole number: how many columns of panels to draw. The
  default `NULL` leaves the grid to `ggplot2` (5 columns for the 18
  default metrics). A narrow figure needs fewer columns, so each panel
  stays wide enough for its title; the Genetic-Health Trends tab picks
  the number from the width of its plot. A number above the count of
  panels draws one column for each panel.

## Value

A `ggplot` object.

## Details

Snapshots whose provenance (`guIter`, `guThresh`, or `packageVersion`)
changed relative to the same rule's previous snapshot are drawn with a
distinct point shape, and the plot carries a caption naming the changed
fields: mixed-provenance series are flagged, not refused.

Snapshots rebuilt from studbook dates by
[`backfillColonySnapshots`](https://github.com/rmsharp/nprcgenekeepr/reference/backfillColonySnapshots.md)
are filed under the rule `"reconstructedLiving"` (issue \#170). That
series is drawn as a dashed line, the recorded rules stay solid, and the
caption says the dashed lines are rebuilt and were not recorded at the
time.

## Examples

``` r
history <- checkSnapshotHistory(readSnapshotHistory(system.file("extdata",
  "examples", "example_snapshot_history.csv",
  package = "nprcgenekeepr"
)))
p <- plotSnapshotTrends(history, metrics = c("fe", "fg", "meanGu"))
```

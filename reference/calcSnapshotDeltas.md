# Compare two colony snapshots metric by metric

Computes per-metric deltas between two snapshots of a longitudinal
colony snapshot history (issue \#167). The two snapshots must belong to
the same membership-rule series: a snapshot is identified by its
(`snapshotDate`, `membershipRule`) pair, and trend comparisons are only
meaningful like with like. The result carries one row per numeric schema
column — the 18 metric columns plus the 3 composition counts
(`nAnimals`, `nMales`, `nFemales`), whose deltas make membership churn
between the two snapshots visible.

## Usage

``` r
calcSnapshotDeltas(history, from, to, membershipRule = NULL)
```

## Arguments

- history:

  data.frame holding the snapshot history in the 27-column version-1
  schema; validated internally with
  [`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md).

- from:

  character or `Date`; the `snapshotDate` of the baseline snapshot.

- to:

  character or `Date`; the `snapshotDate` of the comparison snapshot.

- membershipRule:

  character; the membership-rule series the two dates belong to. The
  default `NULL` resolves automatically when the history holds a single
  rule and [`stop()`](https://rdrr.io/r/base/stop.html)s, naming the
  rules present, when it holds several.

## Value

A data.frame with columns `metric`, `from`, `to`, `delta` (`to - from`),
and `comparabilityFlag`, one row per numeric schema column in schema
order.

## Details

The `comparabilityFlag` column surfaces provenance differences between
the two snapshots rather than refusing them: it is `NA_character_` when
the snapshots are comparable and otherwise names each differing
provenance field with both values. A `guIter` difference flags the
gene-drop-derived metrics (`fg`, `fgSE`, `neGD`, and the `gu`
aggregates); a `guThresh` difference flags only the `gu` aggregates (the
threshold reaches only the genome-uniqueness computation); a
`packageVersion` difference flags every row.

## Examples

``` r
history <- checkSnapshotHistory(readSnapshotHistory(system.file("extdata",
  "examples", "example_snapshot_history.csv",
  package = "nprcgenekeepr"
)))
deltas <- calcSnapshotDeltas(history,
  from = "2025-01-15", to = "2025-07-15",
  membershipRule = "wholePedigree"
)
```

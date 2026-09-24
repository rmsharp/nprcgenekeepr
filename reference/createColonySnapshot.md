# Create a colony snapshot row from a genetic value report

Turns one
[`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
result into a one-row data.frame in the 27-column snapshot-history
schema (issue \#167, schema version 1), ready for
[`appendColonySnapshot`](https://github.com/rmsharp/nprcgenekeepr/reference/appendColonySnapshot.md).
Every metric field is a value the `nprcgenekeeprGV` object already
carries, or a Summary Statistics aggregate
(`mean`/`median`/[`calcSkewness`](https://github.com/rmsharp/nprcgenekeepr/reference/calcSkewness.md)/
[`calcKurtosis`](https://github.com/rmsharp/nprcgenekeepr/reference/calcKurtosis.md),
`NA` removed) of its per-animal `indivMeanKin`/`gu`/`guSE` report
columns, stored at full precision — no estimator is recomputed or
duplicated.

## Usage

``` r
createColonySnapshot(
  ped,
  geneticValue,
  membershipRule,
  guIter,
  guThresh,
  snapshotDate = Sys.Date()
)
```

## Arguments

- ped:

  The pedigree data.frame the `reportGV` analysis was run on, carrying
  at least an `id` column (plus the logical `population` column when
  `membershipRule` is `"focalPopulation"`).

- geneticValue:

  An object of class `nprcgenekeeprGV` as returned by
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md).

- membershipRule:

  Single string naming how the analysis population was assembled; one of
  `"wholePedigree"` or `"focalPopulation"`.

- guIter:

  Single positive whole number: the `guIter` value the `reportGV` call
  used. Required — there is no default.

- guThresh:

  Single positive whole number: the `guThresh` value the `reportGV` call
  used. Required — there is no default.

- snapshotDate:

  The snapshot's date: a `Date` or an ISO-8601 (YYYY-MM-DD) string.
  Defaults to [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html).

## Value

A one-row data.frame in the 27-column snapshot-history schema; it passes
[`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md)
unchanged.

## Details

`guIter` and `guThresh` are required because the `reportGV` return
object does not carry them, and they are comparability provenance the
snapshot must record truthfully: pass exactly the values the `reportGV`
call used (its defaults are `1000L` and `1L`).

The claimed `membershipRule` is verified against `ped` and the report,
and a contradiction stops:

- `"wholePedigree"`:

  the report covers exactly the animals in `ped`.

- `"focalPopulation"`:

  `ped` carries the logical `population` column (see
  [`setPopulation`](https://github.com/rmsharp/nprcgenekeepr/reference/setPopulation.md))
  and the report covers exactly `ped$id[ped$population]`. Pass the same
  population-designated pedigree the `reportGV` call analyzed.

## Examples

``` r
ped <- nprcgenekeepr::qcPed
gv <- reportGV(ped, guIter = 10L)
snapshot <- createColonySnapshot(ped, gv, "wholePedigree",
  guIter = 10L, guThresh = 1L
)
history <- appendColonySnapshot(NULL, snapshot)
```

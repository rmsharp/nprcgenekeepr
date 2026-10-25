# Count what each date of a rebuilt series rests on, before building it

Returns the `support` table that
[`backfillColonySnapshots`](https://github.com/rmsharp/nprcgenekeepr/reference/backfillColonySnapshots.md)
reports for the same dates, without the gene drop, so the counts are
there in a moment and a start year can be chosen knowingly before
minutes of analysis are spent (issue \#170). The Genetic-Health Trends
tab shows this same table before its "Build earlier snapshots" button is
used.

## Usage

``` r
previewBackfillSupport(
  ped,
  dates = NULL,
  from = NULL,
  to = NULL,
  by = "year",
  minAnimals = 2L
)
```

## Arguments

- ped:

  A quality-controlled pedigree data.frame (see
  [`qcStudbook`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md))
  holding at least `id`, `sire`, `dam`, `sex`, `gen`, `birth` and `exit`
  (the last two as `Date` columns), and a `status` column when the
  studbook has one. Pass the full pedigree, not one already trimmed to a
  focal list of animals.

- dates:

  The dates to count: `Date` values or ISO-8601 (YYYY-MM-DD) strings, at
  least one, with no missing or duplicated value. Leave it out (`NULL`)
  to use the series described by `from`, `to` and `by`; it cannot be
  combined with them.

- from:

  The first date of the series: a `Date` or an ISO-8601 string. The
  default is the first 1 January with at least `minAnimals` living
  animals.

- to:

  The last date of the series, as `from`. The default is the last 1
  January on or before the latest birth or exit date in `ped`.

- by:

  The step of the series: a string for
  [`seq.Date`](https://rdrr.io/r/base/seq.Date.html), such as `"year"`
  (the default), `"6 months"` or `"quarter"`.

- minAnimals:

  Single whole number, at least 2: the fewest living animals a 1 January
  needs to start the default series. Default 2.

## Value

A data.frame with one row for each date, in date order, and the columns
of the `support` table of
[`backfillColonySnapshots`](https://github.com/rmsharp/nprcgenekeepr/reference/backfillColonySnapshots.md):
`snapshotDate`, `nLiving` (the animals counted), `nPlacedByOffspring`
(of those, the ones with no birth date), `nPossiblyAlive` (animals with
no birth date that are not counted and had not left), `pctSireKnown` and
`pctDamKnown` (the percentage of the living animals whose sire or dam is
recorded, that is neither blank nor a generated stand-in; `NA` when
nobody was alive).

## Details

The dates are laid out exactly as `backfillColonySnapshots` lays them
out: give `dates`, or leave it out for a series of `by` steps (one year
by default) from `from` to `to`. Unless you give them, the series starts
at the first 1 January with at least `minAnimals` living animals and
ends at the last 1 January on or before the latest birth or exit date in
the pedigree. `minAnimals` only moves that default start: a date you
name, in `dates` or as `from`, is never refused for having few animals.

An animal is counted on a date by the rules of
[`backfillColonySnapshots`](https://github.com/rmsharp/nprcgenekeepr/reference/backfillColonySnapshots.md):
alive from its birth date, or, with no birth date, from the birth of its
first offspring that has a date, until its exit date; an animal with no
exit date counts only when the studbook lists it as living. No threshold
refuses a date; read the counts beside the trend.

## See also

[`backfillColonySnapshots`](https://github.com/rmsharp/nprcgenekeepr/reference/backfillColonySnapshots.md)

## Examples

``` r
ped <- nprcgenekeepr::qcPed
previewBackfillSupport(ped,
  dates = as.Date(c("2005-01-01", "2010-01-01"))
)
#>   snapshotDate nLiving nPlacedByOffspring nPossiblyAlive pctSireKnown
#> 1   2005-01-01      86                  0              0     56.97674
#> 2   2010-01-01      63                  0              0     68.25397
#>   pctDamKnown
#> 1    89.53488
#> 2    90.47619

## the default series, and a later start when the early years rest on little
head(previewBackfillSupport(ped), 3L)
#>   snapshotDate nLiving nPlacedByOffspring nPossiblyAlive pctSireKnown
#> 1   1961-01-01       2                  0              2            0
#> 2   1962-01-01       3                  0              2            0
#> 3   1963-01-01       3                  0              2            0
#>   pctDamKnown
#> 1           0
#> 2           0
#> 3           0
head(previewBackfillSupport(ped, minAnimals = 30L), 3L)
#>   snapshotDate nLiving nPlacedByOffspring nPossiblyAlive pctSireKnown
#> 1   1970-01-01      39                  0              2     2.564103
#> 2   1971-01-01      52                  0              2     1.923077
#> 3   1972-01-01      54                  0              2     1.851852
#>   pctDamKnown
#> 1    2.564103
#> 2    1.923077
#> 3    1.851852
```

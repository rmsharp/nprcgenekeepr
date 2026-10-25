# Rebuild earlier colony snapshots from a pedigree's birth and exit dates

Builds one Genetic-Health Trends snapshot for each past date from the
birth and exit dates already in a pedigree, so a trend can be drawn
without waiting seasons for recorded snapshots (issue \#170). Each row
is the same 27-column row
[`createColonySnapshot`](https://github.com/rmsharp/nprcgenekeepr/reference/createColonySnapshot.md)
makes and passes
[`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md),
filed under its own membership rule, `"reconstructedLiving"`, so rebuilt
rows form a line of their own and never mix with recorded ones.

## Usage

``` r
backfillColonySnapshots(
  ped,
  dates = NULL,
  guIter,
  guThresh,
  from = NULL,
  to = NULL,
  by = "year",
  existingHistory = NULL,
  minAnimals = 2L,
  updateProgress = NULL,
  ...
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

  The dates to rebuild: `Date` values or ISO-8601 (YYYY-MM-DD) strings,
  at least one, with no missing or duplicated value. Leave it out
  (`NULL`) to build the series described by `from`, `to` and `by`; it
  cannot be combined with them.

- guIter:

  Single positive whole number: the number of gene-drop iterations,
  recorded in each row. Required — there is no default, so the recorded
  settings cannot silently differ from the ones used.

- guThresh:

  Single positive whole number: the genetic uniqueness threshold,
  recorded in each row. Required.

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

- existingHistory:

  A snapshot history to add to (see
  [`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md)),
  or `NULL` for none. Its rows are kept as they are, with any extra
  columns, and a date whose `"reconstructedLiving"` row is already there
  is not rebuilt. A row of another membership rule on the same date does
  not count as already there.

- minAnimals:

  Single whole number, at least 2 (the least
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  can analyze): the fewest living animals a 1 January needs to start the
  default series. Default 2.

- updateProgress:

  Function or `NULL`. If it is a function, it is called once for each
  date, after the date has been rebuilt, skipped or has failed, with the
  arguments `n` (the number of dates in the run), `value` (how many are
  done) and `detail` (the date as text), to update a
  [`shiny::Progress`](https://rdrr.io/pkg/shiny/man/Progress.html)
  object. It is not passed on to `reportGV`.

- ...:

  Further arguments passed to
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  (for example `kinshipOverrides` or `twinRelations`, the latter cut to
  each date as described above).

## Value

A list of three data.frames. `history`: the rebuilt snapshots (and the
rows of `existingHistory`, if given), in date order, in the 27-column
snapshot-history schema. `support`: one row for each date in the run,
with `snapshotDate`, `nLiving` (the animals counted),
`nPlacedByOffspring` (of those, the ones with no birth date),
`nPossiblyAlive`, `pctSireKnown` and `pctDamKnown` (the percentage of
the living animals whose sire or dam is recorded, that is neither blank
nor a generated stand-in; `NA` when nobody was alive). `skipped`: the
dates not rebuilt, with `snapshotDate` and `reason`.

## Details

**The dates.** Give `dates`, or leave it out for a series of `by` steps
(one year by default) from `from` to `to`. Unless you give them, the
series starts at the first 1 January with at least `minAnimals` living
animals and ends at the last 1 January on or before the latest birth or
exit date in the pedigree. `minAnimals` only moves that default start: a
date you name, in `dates` or as `from`, is never refused for having few
animals.

**Who was alive.** For each date the pedigree is copied and every exit
date after that date is blanked, because the demographic effective-size
estimators read the exit column as it stands (see
[`calcNeSexRatio`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md)):
without the blanking an animal that was alive on the date but has left
since would not count as a living breeder. The population is the real
animals alive on the date. An animal is alive from its birth date; one
with no birth date is alive from the birth of its first offspring that
has a date (it was born before that offspring). It is alive until its
exit date. An animal with no exit date counts only when the studbook
lists it as living, the test the application applies today (status
`ALIVE`, or no exit date when the pedigree has no `status` column), so
an animal whose status is `UNKNOWN` never counts. Generated stand-in
parents never enter the population. The pedigree is trimmed to that
population and its ancestors
([`trimPedigree`](https://github.com/rmsharp/nprcgenekeepr/reference/trimPedigree.md)),
analyzed with
[`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md),
and summarized with
[`createColonySnapshot`](https://github.com/rmsharp/nprcgenekeepr/reference/createColonySnapshot.md).
For the date a pedigree was exported, the row equals the snapshot the
application records for that pedigree.

**What each date rests on.** The `support` table says how many animals
were counted, how many of them were placed through an offspring, how
many more the studbook does not rule out (animals with no birth date
that are not counted and had not left), and how much of the parentage is
recorded. No threshold refuses a date; read these figures beside the
trend. Where few sires are recorded the sex-ratio effective size reads
low because of the missing records, not because of the colony.

**Dates that fail.** A date that cannot be analyzed (for example one on
which fewer than two animals were alive) does not stop the others. It is
listed in `skipped` with the message of the error, and one warning says
how many dates failed. When no date can be built, the function stops and
names the dates. A date whose `"reconstructedLiving"` row is already in
`existingHistory` is not rebuilt; it is listed in `skipped` without a
warning.

**Twin pairs.** A `twinRelations` table (see
[`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md))
is used on each date as far as that date's animals allow. Declared
identical (`"MZ twin"`) animals form groups, as in
[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md),
so the pairs A-B and B-C make the group A, B and C. On a date the groups
are cut to the animals in that date's pedigree, which holds the animals
alive then and their ancestors; a group left with two or more animals is
applied and the others are left out. An animal missing from the pedigree
on a date cannot change anyone's kinship that day, so a twin born later,
or one who left and has no descendants, no longer makes the date fail.
An identifier that is in no pedigree at all is a mistake and stops the
function before any date is built.

Limits: today's parentage and today's genotypes are used for every date,
so a parent identified later is treated as known earlier; the effective
sizes follow the definition of a living breeder in
[`calcNeSexRatio`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md);
and two close dates can differ only by gene-drop sampling.

## See also

[`createColonySnapshot`](https://github.com/rmsharp/nprcgenekeepr/reference/createColonySnapshot.md),
[`appendColonySnapshot`](https://github.com/rmsharp/nprcgenekeepr/reference/appendColonySnapshot.md),
[`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md)

## Examples

``` r
ped <- nprcgenekeepr::qcPed
result <- backfillColonySnapshots(ped,
  dates = as.Date(c("2005-01-01", "2010-01-01")),
  guIter = 10L, guThresh = 1L
)
#> Warning: Founder genome equivalents undefined: founder(s) with positive contribution were retained in 0 of the gene-drop iterations; raise the number of iterations (K).
#> Warning: Founder genome equivalents undefined: founder(s) with positive contribution were retained in 0 of the gene-drop iterations; raise the number of iterations (K).
result$history[, c("snapshotDate", "membershipRule", "nAnimals")]
#>   snapshotDate      membershipRule nAnimals
#> 1   2005-01-01 reconstructedLiving       86
#> 2   2010-01-01 reconstructedLiving       63
result$support
#>   snapshotDate nLiving nPlacedByOffspring nPossiblyAlive pctSireKnown
#> 1   2005-01-01      86                  0              0     56.97674
#> 2   2010-01-01      63                  0              0     68.25397
#>   pctDamKnown
#> 1    89.53488
#> 2    90.47619

## a yearly series, added to the history above: the dates already there
## are not rebuilt
series <- backfillColonySnapshots(ped,
  from = "2005-01-01", to = "2008-01-01",
  guIter = 10L, guThresh = 1L, existingHistory = result$history
)
#> Warning: Founder genome equivalents undefined: founder(s) with positive contribution were retained in 0 of the gene-drop iterations; raise the number of iterations (K).
#> Warning: Founder genome equivalents undefined: founder(s) with positive contribution were retained in 0 of the gene-drop iterations; raise the number of iterations (K).
series$history[, c("snapshotDate", "nAnimals")]
#>   snapshotDate nAnimals
#> 1   2005-01-01       86
#> 2   2006-01-01       86
#> 3   2007-01-01       83
#> 4   2008-01-01       79
#> 5   2010-01-01       63
series$skipped
#>   snapshotDate                                                        reason
#> 1   2005-01-01 already in existingHistory under the reconstructedLiving rule
```

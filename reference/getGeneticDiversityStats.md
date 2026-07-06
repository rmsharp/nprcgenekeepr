# Assemble breeding-group genetic diversity heat-map statistics

Assemble breeding-group genetic diversity heat-map statistics

## Usage

``` r
getGeneticDiversityStats(
  groups,
  ped,
  geneticValues,
  kmat,
  housing = "shelter_pens",
  currentDate = Sys.Date()
)
```

## Arguments

- groups:

  List of character vectors of animal IDs, one per breeding group (for
  example the `groups` returned by `modBreedingGroupsServer`). If the
  list is named, the names become the group row labels; otherwise labels
  are `"Group 1"`, `"Group 2"`, and so on.

- ped:

  Dataframe that is the `Pedigree`. The `id`, `dam`, `sex`, `birth`, and
  `exit` columns are required; an optional `ancestry` column enables the
  Origin metric.

- geneticValues:

  Dataframe of the genetic value report (for example
  `reportGV(ped)$report`). The `id` and `value` columns are required;
  `value` holds the labels produced by `rankSubjects` (`"Low Value"`,
  `"High Value"`, `"Undetermined"`).

- kmat:

  Square kinship matrix whose row and column names are animal IDs and
  that covers every member of every group (for example the matrix
  returned by
  [`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)).

- housing:

  Character housing type passed to `getProductionStatus`, either
  `"shelter_pens"` or `"corral"`. Length 1 (applied to every group) or
  one value per group. Defaults to `"shelter_pens"`.

- currentDate:

  Date used to derive age and the production birth window. Defaults to
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html).

## Value

A data frame with one row per group: the first column `group` holds the
group label and each remaining column (`Value`, `Origin` when available,
`Production`, `Inbreeding`) holds an integer color index in
`c(1, 2, 3)`.

## Details

For each breeding group this builds the heat-map color indices by
calling the per-group providers: Value from `getProportionLow`, Origin
from `getIndianOriginStatus`, Production from `getProductionStatus`, and
Inbreeding from `getKinshipWithMaleStatus`. The result is the
group-by-metric data frame consumed by
[`makeGeneticDiversityHeatmap`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticDiversityHeatmap.md):
the first column holds the group label and each remaining column holds a
color index (1 red, 2 yellow, 3 green).

Age is derived from each member's birth date using `currentDate` rather
than read from a possibly-absent `age` column, so the age filters and
the production birth window share one reference date. Genetic-value
labels of `"Undetermined"` are dropped before the Value proportion is
taken. A group with no assessed value, and a group whose Inbreeding
metric is undefined (no breeding-age females), are both scored red so
that missing data is surfaced rather than shown as healthy green. When
the pedigree has no `ancestry` column the Origin metric cannot be
computed and its column is omitted.

# Collect every cross-center identity-mapping problem, without stopping

The "show every problem at once" companion to
[`resolveCrossCenterIds`](https://github.com/rmsharp/nprcgenekeepr/reference/resolveCrossCenterIds.md)
(issue \#149 Slice 1), sharing its four validation checks – id
existence, mapping uniqueness, undeclared id collisions, and conflicting
recorded parents – via the same internal helpers (D2,
`docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md`
section 3).
[`resolveCrossCenterIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/resolveCrossCenterIds.md)
[`stop()`](https://rdrr.io/r/base/stop.html)s on the first problem it
finds; `checkCrossCenterMapping()` never
[`stop()`](https://rdrr.io/r/base/stop.html)s on a domain problem –
every one found becomes a row in the returned data.frame instead, so a
curator can see and fix every issue at once rather than one at a time. A
structural problem (a required column missing from any of the three
inputs) still [`stop()`](https://rdrr.io/r/base/stop.html)s immediately,
matching every other `checkXxx()` function in this package
([`checkKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/checkKinshipOverrides.md),
[`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)).

## Usage

``` r
checkCrossCenterMapping(pedA, pedB, mapping)
```

## Arguments

- pedA:

  a pedigree data.frame for the first center, with (at least) columns
  `id`, `sire`, and `dam`.

- pedB:

  a pedigree data.frame for the second center, with (at least) columns
  `id`, `sire`, and `dam`.

- mapping:

  a data.frame with columns `idA` and `idB`: one row per
  curator-proposed cross-center identity link.

## Value

A data.frame of every domain problem found, with columns `type`
(`"existence"`, `"uniqueness"`, `"collision"`, or `"conflict"`), `ids`
(the offending id(s), as a single comma-separated string), and `message`
(a human-readable description). Zero rows means the mapping is clean,
and
[`resolveCrossCenterIds`](https://github.com/rmsharp/nprcgenekeepr/reference/resolveCrossCenterIds.md)
can be called on the same inputs without error.

## Details

Existence and uniqueness problems (tier A) are checked first; if either
is present, only those are returned and collision/conflict checks (tier
B) are skipped entirely, since a mapped id that does not resolve to a
real pedigree row makes those checks meaningless. Tier B – and both of
its checks, across every mapped pair – runs only once tier A is clean.

## See also

[`resolveCrossCenterIds`](https://github.com/rmsharp/nprcgenekeepr/reference/resolveCrossCenterIds.md)

## Examples

``` r
library(nprcgenekeepr)
pedA <- data.frame(
  id = c("P1", "P2", "T1"), sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
  stringsAsFactors = FALSE
)
pedB <- data.frame(
  id = c("X9", "O1"), sire = c(NA, "X9"), dam = c(NA, NA),
  stringsAsFactors = FALSE
)
mapping <- data.frame(idA = "T1", idB = "X9", stringsAsFactors = FALSE)
checkCrossCenterMapping(pedA, pedB, mapping) # zero rows: clean
#> [1] type    ids     message
#> <0 rows> (or 0-length row.names)
```

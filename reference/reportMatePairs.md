# Report eligible individual mate pairs with kinship and genetic-value context

Issue \#151 Slice 1: composes the existing pair-eligibility pipeline
([`kinMatrix2LongForm`](https://github.com/rmsharp/nprcgenekeepr/reference/kinMatrix2LongForm.md),
[`filterPairs`](https://github.com/rmsharp/nprcgenekeepr/reference/filterPairs.md),
`filterAge()`,
[`filterKinMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/filterKinMatrix.md)
– all unmodified) into a report of opposite-sex, minimum-age-eligible
mate-pair candidates, each row optionally enriched with marker-based
kinship
([`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md))
and per-parent genetic-value context
([`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)'s
`indivMeanKin`/`gu`) when available. No composite/blended ranking score
is computed – callers sort/filter the raw columns themselves (see
`docs/planning/issue151-individual-mate-pair-analysis-plan.md` Section
3, decision D3).

## Usage

``` r
reportMatePairs(
  ped,
  kmat,
  markerKmat = NULL,
  geneticValues = NULL,
  minAge = 1L,
  populationIds = NULL,
  exclude = character(0L),
  ancestryRules = NULL,
  overriddenRules = NULL
)
```

## Arguments

- ped:

  Pedigree data.frame with at least `id`, `sire`, `dam`, `sex`, and
  `age` columns.

- kmat:

  Pedigree kinship matrix (e.g. as returned by
  [`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)),
  `id` x `id`, covering every id considered.

- markerKmat:

  Optional genotype-only KING-robust kinship matrix (e.g. as returned by
  [`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)),
  `id` x `id`, which may cover only a subset of `ped$id` (not every
  animal is genotyped). `NULL` (the default) leaves `markerKinship` as
  `NA` for every pair.

- geneticValues:

  Optional
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)-shaped
  list (only `$report`, with `id`, `indivMeanKin`, and `gu` columns, is
  used). `NULL` (the default) leaves the four per-parent genetic-value
  columns `NA` for every pair.

- minAge:

  Numeric scalar, the minimum age (in the same units as `ped$age`) for
  an individual to be pair-eligible. Default `1`, mirroring Breeding
  Groups' own scalar convention. A missing (`NA`) age passes this screen
  (see Details) – use `populationIds` to actually bound the candidate
  population.

- populationIds:

  Optional character vector of ids to which the analysis is scoped,
  applied before the pair-reshape (D4, see Details). `NULL` (the
  default) performs no scoping; `character(0)` scopes to nobody and
  returns a zero-row result.

- exclude:

  Character vector of ids to drop entirely, regardless of any other
  eligibility screen. Default `character(0)` (no caller-supplied
  exclusions).

- ancestryRules:

  Optional data frame of ancestry compatibility rules in
  [`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md)'s
  shape (`ancestry1`, `ancestry2`, `severity`); validated here. `ped`
  must then carry an `ancestry` column, or the call stops. `NULL` (the
  default) applies no ancestry screen. A valid zero-rule table is
  accepted: the result then has the ancestry columns, with nothing
  moved.

- overriddenRules:

  Optional data frame with `ancestry1` and `ancestry2` columns naming
  `block` rules to override for this call (unordered, case-insensitive
  match, as in
  [`reportAncestryViolations`](https://github.com/rmsharp/nprcgenekeepr/reference/reportAncestryViolations.md));
  a `reason` column is accepted and ignored. An override naming no rule
  in `ancestryRules`, a `flag` rule, or the same rule twice is an error,
  as is giving overrides without `ancestryRules`. `NULL` or zero rows:
  none.

## Value

A list with two data.frames (three when `ancestryRules` is given):

- pairs:

  One row per eligible opposite-sex pair surviving every screen:
  `sireId`, `damId`, `kinship`, `markerKinship` (`NA` if unavailable),
  `sireIndivMeanKin`, `sireGu`, `damIndivMeanKin`, `damGu` (the latter
  four `NA` if `geneticValues` is not supplied or the parent is absent
  from its report). With `ancestryRules`, three columns follow:
  `ancestryRule` (the matched rule as a sorted `"LEVEL-LEVEL"` string),
  `ancestrySeverity` (`"flag"` or `"block"`) and `ancestryStatus`
  (`"violation"`, or `"overridden"` for an overridden block rule), all
  `NA` for a pair no rule matches.

- excluded:

  One row per pair dropped by the age, user-exclude or ancestry screen:
  `sireId`, `damId`, `reason` (`"under minimum age"`, `"user-excluded"`
  or, with `ancestryRules`, `"ancestry rule"`). With `ancestryRules` an
  `ancestryRule` column follows: the matched rule for an ancestry
  exclusion, `NA` otherwise.

- ancestryCoverage:

  Only with `ancestryRules`: one row per standardized ancestry level
  (CHINESE, INDIAN, HYBRID, JAPANESE, OTHER, UNKNOWN) with `ancestry`,
  `n` (distinct animals at that level in `pairs` and `excluded`) and
  `covered` (`TRUE` when a rule names the level), so a level no rule
  covers is visible.

## Details

**Population scoping (D4).** `minAge` alone does not bound the
candidate-pair table on real, imperfectly-curated data: a missing age
*passes* `filterAge()`'s screen rather than being excluded by it (see
that function's own semantics), so long-retired or never-dated
individuals can still appear. `populationIds`, applied via
[`filterKinMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/filterKinMatrix.md)
*before* the pair-reshape, is the mechanism that actually bounds both
correctness and table size; the default `NULL` performs no scoping
(every individual in `kmat` is a candidate). An explicit `character(0)`
is a valid, distinct input – "scope to nobody" – and returns a zero-row
`pairs` frame with the full column shape, not an error.

**Exclusion transparency (D5).** Two independent screens produce
`excluded` rows: the age screen (`"under minimum age"`) and the
caller-supplied `exclude` id list (`"user-excluded"`). A pair failing
the age screen is reported with that reason and never reaches the
user-exclude screen, so each dropped pair carries exactly one reason
from this closed, enumerable vocabulary.

**Graceful degradation.** `markerKmat` and `geneticValues` are both
`NULL`-safe: when absent (or when a specific pair is not covered by
them), the corresponding columns are `NA` for that row – the pair itself
is never dropped or the call errored, mirroring
`modMarkerGeneticsServer`'s own "not yet uploaded" contract.

**Ancestry rules (issue \#169).** `ancestryRules` applies the same
center-configurable rules table as the Breeding Groups ancestry
guardrails
([`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md))
to individual pairs; a rule matches a pair whichever animal is the sire
and whichever the dam. A `block` rule moves the matching pair out of
`pairs` and into `excluded` with the reason `"ancestry rule"` (here
"block" means "not listed as eligible", not "never placed together"); a
`flag` rule keeps the pair in `pairs` and annotates it. Naming a block
rule in `overriddenRules` keeps its pairs in `pairs`, marked
`"overridden"` – never silently absent. The ancestry screen runs last: a
pair that already failed the age or user-exclude screen keeps that
reason. Rules only move and label pairs; every pair is either in `pairs`
or in `excluded`, with or without rules. An animal whose ancestry no
rule names, or is missing, matches nothing. With `ancestryRules = NULL`
(the default) the result is unchanged, and `ped` needs no `ancestry`
column.

## Examples

``` r
library(nprcgenekeepr)
ped <- data.frame(
  id = c("S1", "D1", "A", "B"),
  sire = c(NA, NA, "S1", NA),
  dam = c(NA, NA, "D1", NA),
  sex = c("M", "F", "M", "F"),
  age = c(10, 10, 5, 5),
  stringsAsFactors = FALSE
)
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
result <- reportMatePairs(ped, kmat, minAge = 1)
result$pairs
#>   sireId damId kinship markerKinship sireIndivMeanKin sireGu damIndivMeanKin
#> 1     S1    D1    0.00            NA               NA     NA              NA
#> 2     S1     B    0.00            NA               NA     NA              NA
#> 3      A    D1    0.25            NA               NA     NA              NA
#> 4      A     B    0.00            NA               NA     NA              NA
#>   damGu
#> 1    NA
#> 2    NA
#> 3    NA
#> 4    NA

# Ancestry rules (issue #169): the example rules block INDIAN x CHINESE
# and INDIAN x HYBRID pairs and flag INDIAN x UNKNOWN / INDIAN x OTHER
ancPed <- qcStudbook(
  read.csv(
    system.file("extdata", "examples", "example_ancestry_pedigree.csv",
      package = "nprcgenekeepr"
    ),
    stringsAsFactors = FALSE, na.strings = c("", "NA")
  ),
  minSireAge = 2, minDamAge = 2, reportChanges = FALSE,
  reportErrors = FALSE
)
ancPed$gen <- findGeneration(ancPed$id, ancPed$sire, ancPed$dam)
ancKmat <- kinship(ancPed$id, ancPed$sire, ancPed$dam, ancPed$gen)
rules <- checkAncestryRules(readAncestryRules(
  system.file("extdata", "examples", "example_ancestry_rules.csv",
    package = "nprcgenekeepr"
  )
))
ancResult <- reportMatePairs(ancPed, ancKmat, ancestryRules = rules)
ancResult$excluded
#>   sireId damId        reason   ancestryRule
#> 1     C1    I2 ancestry rule CHINESE-INDIAN
#> 2     I1    C2 ancestry rule CHINESE-INDIAN
#> 3     A1    C2 ancestry rule CHINESE-INDIAN
#> 4     I1    H1 ancestry rule  HYBRID-INDIAN
#> 5     A1    H1 ancestry rule  HYBRID-INDIAN
ancResult$ancestryCoverage
#>   ancestry n covered
#> 1  CHINESE 2    TRUE
#> 2   INDIAN 3    TRUE
#> 3   HYBRID 1    TRUE
#> 4 JAPANESE 2   FALSE
#> 5    OTHER 1    TRUE
#> 6  UNKNOWN 1    TRUE
# overriding one block rule keeps its pairs listed, marked "overridden"
overridden <- reportMatePairs(ancPed, ancKmat,
  ancestryRules = rules,
  overriddenRules = data.frame(ancestry1 = "CHINESE", ancestry2 = "INDIAN")
)
overridden$pairs[
  which(overridden$pairs$ancestryStatus == "overridden"),
  c("sireId", "damId", "ancestryRule", "ancestryStatus")
]
#>   sireId damId   ancestryRule ancestryStatus
#> 2     C1    I2 CHINESE-INDIAN     overridden
#> 6     I1    C2 CHINESE-INDIAN     overridden
#> 9     A1    C2 CHINESE-INDIAN     overridden
```

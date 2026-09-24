# Validate a colony snapshot-history table

Checks the structure and domain of a longitudinal colony snapshot
history (issue \#167): one row per recorded snapshot, in the 27-column
version-1 schema. It mirrors
[`checkKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/checkKinshipOverrides.md):
it [`stop()`](https://rdrr.io/r/base/stop.html)s with a specific message
on structural or domain errors and returns the coerced history when the
input is acceptable.

## Usage

``` r
checkSnapshotHistory(history)
```

## Arguments

- history:

  data.frame holding the snapshot history, typically from
  [`readSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/readSnapshotHistory.md);
  one row per snapshot.

## Value

The validated history with `snapshotDate` coerced to `Date`,
`packageVersion` and `membershipRule` coerced to character, and
`schemaVersion` and the count columns coerced to integer.

## Details

The schema has three groups of nine columns:

- Provenance / comparability:

  `schemaVersion`, `snapshotDate`, `packageVersion`, `membershipRule`,
  `guIter`, `guThresh`, `nAnimals`, `nMales`, `nFemales`. These let
  successive snapshots be compared like with like: snapshots generated
  under different membership rules, `guIter` settings, or package
  versions are comparable only with care, and trend displays flag such
  mixed-provenance series rather than hiding them.

- Colony scalars:

  `fe`, `fg`, `fgSE`, `neGD`, `neSexRatio`, `neVariance`,
  `nMaleFounders`, `nFemaleFounders`, `nFounders` — verbatim from
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md).

- Colony aggregates:

  `meanIndivMeanKin`, `medianIndivMeanKin`, `skewnessIndivMeanKin`,
  `kurtosisIndivMeanKin`, `meanGu`, `medianGu`, `meanGuSE`,
  `skewnessGu`, `kurtosisGu` — the Summary Statistics definitions
  applied to the per-animal `indivMeanKin` and `gu` report columns.

Violations rejected: missing columns, non-numeric metric or count
fields, an unrecognized `schemaVersion`, a duplicated (`snapshotDate`,
`membershipRule`) pair, and malformed (non ISO-8601) dates. The
`membershipRule` field is an open string — no enumeration is enforced,
so new rule names are additive. Extra columns are ignored, matching the
sibling validators.

## Examples

``` r
history <- readSnapshotHistory(system.file("extdata", "examples",
  "example_snapshot_history.csv",
  package = "nprcgenekeepr"
))
history <- checkSnapshotHistory(history)
```

# Genetic-Health Trends Module - Server Function

Genetic-Health Trends Module - Server Function

## Usage

``` r
modSnapshotTrendsServer(id, snapshotSource)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- snapshotSource:

  reactive returning `list(ped, geneticValue, guIter, guThresh)` from
  the most recent Genetic Value Analysis run (see
  [`modGeneticValueServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md)'s
  `snapshotSource` return element), or erroring (shiny `req()`
  semantics) before any run has happened.

## Value

A list with reactive components:

- `history` - the current validated snapshot history (or `NULL` before
  any upload or generation).

- `deltas` - the current delta comparison (see
  [`calcSnapshotDeltas`](https://github.com/rmsharp/nprcgenekeepr/reference/calcSnapshotDeltas.md)),
  keyed off the sidebar's rule/from/ to selectors.

- `isReady` - logical: is a non-empty history loaded.

The generated snapshot's `membershipRule` is auto-derived from
`snapshotSource()$ped$population` (issue \#167 Slice 4, S760 owner
decision): `"focalPopulation"` when the analyzed pedigree's population
column excludes any animal, `"wholePedigree"` otherwise – truthful by
construction from what
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
actually analyzed, never a user-set dropdown that could contradict the
data and hit
[`createColonySnapshot`](https://github.com/rmsharp/nprcgenekeepr/reference/createColonySnapshot.md)'s
[`stop()`](https://rdrr.io/r/base/stop.html). The delta comparison keeps
a user-facing rule selector, populated from the uploaded/generated
history's own `membershipRule` values.

A
[`checkSnapshotHistory`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md)
violation on a malformed history upload surfaces as a notification
(module-contract rule 5: this is not the same seam as inter-module
malleability – the specific violation is shown, not disguised as "no
data yet") and leaves the current history unchanged.

## See also

[`modSnapshotTrendsUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modSnapshotTrendsUI.md)
for the user interface.

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
[`modCrossCenterIdentityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modCrossCenterIdentityServer.md),
[`modCrossCenterIdentityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modCrossCenterIdentityUI.md),
[`modDeidentifiedExportServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modDeidentifiedExportServer.md),
[`modDeidentifiedExportUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modDeidentifiedExportUI.md),
[`modGeneticDiversityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityServer.md),
[`modGeneticDiversityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityUI.md),
[`modGeneticValueServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md),
[`modGeneticValueUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md),
[`modGvAndBgDescServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescServer.md),
[`modGvAndBgDescUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescUI.md),
[`modInputServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md),
[`modInputUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md),
[`modMarkerGeneticsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsServer.md),
[`modMarkerGeneticsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsUI.md),
[`modMatePairServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairServer.md),
[`modMatePairUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairUI.md),
[`modORIPReportingServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingServer.md),
[`modORIPReportingUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingUI.md),
[`modPedigreeServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md),
[`modPedigreeUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeUI.md),
[`modPotentialParentsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsServer.md),
[`modPotentialParentsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md),
[`modPyramidServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidServer.md),
[`modPyramidUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidUI.md),
[`modSnapshotTrendsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSnapshotTrendsUI.md),
[`modSummaryStatsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md),
[`modSummaryStatsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)

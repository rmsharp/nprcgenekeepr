# Breeding Groups Module - Server Function

Server logic for breeding group formation using the groupAddAssign
algorithm. This module integrates with the kinship-based maximal
independent set (MIS) algorithm to form optimal breeding groups that
minimize relatedness within groups while maximizing group sizes.

## Usage

``` r
modBreedingGroupsServer(
  id,
  pedigree,
  geneticValues = NULL,
  kinshipMatrix = NULL,
  kinshipOverrides = NULL,
  twinRelations = NULL
)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- pedigree:

  reactive returning pedigree data frame with columns: id, sire, dam,
  sex, and optionally birth, exit, gen.

- geneticValues:

  optional reactive returning genetic value results from
  [`modGeneticValueServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md).
  Used to source the `topRanked` animal-source candidate list and, with
  any animal source, for the "Genetic-value floor" inclusion criterion,
  which drops "Low Value" animals and IDs absent from the report. Group
  formation halts until it is available in either of those cases.
  Unrelated to kinship.

- kinshipMatrix:

  optional reactive returning a kinship matrix, typically a
  full-pedigree matrix shared with
  [`modSummaryStatsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md)
  (e.g. from `appServer`) rather than independently recomputed. If NULL,
  the module calculates kinship from the pedigree.

- kinshipOverrides:

  optional reactive returning a validated outside-information
  kinship-override data frame (`id1`, `id2`, `kinship`); see
  [`applyKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/applyKinshipOverrides.md).
  When the module recomputes kinship from the pedigree (the shared
  `kinshipMatrix` is unavailable), the overrides are applied to that
  matrix so group formation reflects them regardless of tab order.
  `NULL` (the default) is a no-op. A provided `kinshipMatrix` is
  expected to already carry overrides applied at its source.

- twinRelations:

  optional reactive returning a validated twin/zygosity sidecar
  data.frame (`id1`, `id2`, `code`); see
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md).
  When the module recomputes kinship from the pedigree (the shared
  `kinshipMatrix` is unavailable), it is passed straight through to
  [`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  so group formation reflects a declared MZ-twin pair's corrected
  identity regardless of tab order (BL-N Slice 3). `NULL` (the default)
  is a no-op. A provided `kinshipMatrix` is expected to already reflect
  it at its source.

## Value

List with reactive components:

- `groups` - List with one character vector of animal IDs per formed
  group; when candidates remain unplaced a final "Unused" element is
  appended

- `nGroups` - Number of elements of `groups`, counting the "Unused"
  element when present

- `score` - Optimization score from groupAddAssign (minimum group size)

- `unassigned` - Character vector of candidate IDs that appear in no
  element of `groups`; leftovers are collected in the trailing "Unused"
  element, so this is normally empty

- `groupKinship` - List of kinship matrices per group when the "Include
  kinship in display of groups" box is checked (default unchecked);
  `NULL` otherwise

- `ancestryRules` - The validated ancestry rules table loaded through
  the Ancestry Guardrails upload (see
  [`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md)),
  or `NULL` when no usable file is loaded. It is the table as loaded,
  whether or not the pedigree has an `ancestry` column: each consumer
  (formation here,
  [`modMatePairServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairServer.md))
  applies its own column check

## Details

The module supports multiple configuration options:

- **Animal source**: "Top ranked", "Upload list" or "All available".
  "Upload list" has no upload control and currently behaves exactly like
  "All available"

- **Living animals only**: Every source draws only on animals that are
  alive: those with a `status` of `ALIVE` when the pedigree has a
  `status` column, otherwise those with no `exit` date, and every animal
  when it has neither column. The cut to the top N animals or the
  genetic-value floor comes after this, so "Top ranked" takes the
  best-ranked living animals. When no animal in the source is alive the
  tab shows an error notice and forms no groups. Animals typed into a
  seed group are not drawn from this pool and are accepted as typed

- **Inclusion criterion**: Include animals by "Top N ranked" (with the
  number of top animals) or "Genetic-value floor"

- **Group counts and ages**: The number of groups and the minimum
  breeding age

- **Simulations and exhaustive mode**: The number of simulations;
  "Exhaustive enumeration mode" is offered only when the number of
  groups is 1 and the sex ratio is "none"

- **Seed groups**: Optionally seed groups with specific animals

- **Kinship threshold**: Maximum allowed kinship within groups

- **Harem mode**: Form groups with exactly one male each

- **Sex ratio**: Target female-to-male ratio in groups

- **Ancestry guardrails**: Optional uploaded ancestry rules (see
  [`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md))
  enforced during group formation; inactive when the pedigree has no
  `ancestry` column. A block rule can be overridden for the session
  through a confirm gate requiring a stated reason; the "Ancestry"
  results tab reports each run's rule violations (overridden rules stay
  visible, marked `overridden` – see
  [`reportAncestryViolations`](https://github.com/rmsharp/nprcgenekeepr/reference/reportAncestryViolations.md))
  and offers the run's downloadable audit manifest

Up to `maxCandidates` (the "Candidates to retain" input; default 5,
range 1-50) distinct candidate groupings are formed per run (issue
\#125); fewer are returned when the run finds fewer distinct ones. A
"Candidate grouping" selector lets the user switch among them without
re-running
[`groupAddAssign`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md).
All reactive components below reflect the currently-selected candidate,
defaulting to the best-scoring one – identical to the single-solution
behavior prior to issue \#125.

The results are shown on the Groups, Statistics, Group Detail and
Ancestry tabs.

## See also

[`modBreedingGroupsUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md)
for the UI component

[`groupAddAssign`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
for the underlying MIS algorithm

[`modGeneticValueServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md)
for genetic value analysis

[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
for kinship matrix calculation

Other Shiny modules:
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
[`modSnapshotTrendsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSnapshotTrendsServer.md),
[`modSnapshotTrendsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSnapshotTrendsUI.md),
[`modSummaryStatsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md),
[`modSummaryStatsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)

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
  kinshipOverrides = NULL
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
  If provided and contains a kinship matrix, it will be used instead of
  calculating one.

- kinshipOverrides:

  optional reactive returning a validated outside-information
  kinship-override data frame (`id1`, `id2`, `kinship`); see
  [`applyKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/applyKinshipOverrides.md).
  When the module recomputes kinship from the pedigree (no genetic value
  output), the overrides are applied to that matrix so group formation
  reflects them regardless of tab order. `NULL` (the default) is a
  no-op. The genetic-value-output path already carries overrides.

## Value

List with reactive components:

- `groups` - List of character vectors with animal IDs per group

- `nGroups` - Number of groups formed

- `score` - Optimization score from groupAddAssign (minimum group size)

- `unassigned` - Character vector of candidate IDs not placed in groups

- `groupKinship` - List of kinship matrices per group (if withKin=TRUE)

## Details

The module supports multiple configuration options:

- **Animal source**: Select top-ranked animals or all available

- **Kinship threshold**: Maximum allowed kinship within groups

- **Harem mode**: Form groups with exactly one male each

- **Sex ratio**: Target female-to-male ratio in groups

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
[`modGeneticDiversityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityServer.md),
[`modGeneticDiversityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityUI.md),
[`modGeneticValueServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md),
[`modGeneticValueUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md),
[`modGvAndBgDescServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescServer.md),
[`modGvAndBgDescUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescUI.md),
[`modInputServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md),
[`modInputUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md),
[`modORIPReportingServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingServer.md),
[`modORIPReportingUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingUI.md),
[`modPedigreeServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md),
[`modPedigreeUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeUI.md),
[`modPotentialParentsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsServer.md),
[`modPotentialParentsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md),
[`modPyramidServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidServer.md),
[`modPyramidUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidUI.md),
[`modSummaryStatsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md),
[`modSummaryStatsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)

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
  [`applyKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/applyKinshipOverrides.md)
  (issue \#13). When the module recomputes kinship from the pedigree (no
  genetic value output), the overrides are applied to that matrix so
  group formation reflects them regardless of tab order. `NULL` (the
  default) is a no-op. The genetic-value-output path already carries
  overrides.

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

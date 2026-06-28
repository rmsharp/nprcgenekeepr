# Summary Statistics Module - Server Function

Server logic for summary statistics module displaying genetic analysis
results including kinship statistics, histograms, box plots, and
relationship designation analysis.

## Usage

``` r
modSummaryStatsServer(
  id,
  geneticValues,
  pedigree,
  kinshipMatrix = NULL,
  founderStats = NULL,
  kinshipOverrides = NULL
)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- geneticValues:

  reactive returning genetic value analysis results. Must be a data
  frame with columns `id`, `meanKinship`, and `genomeUniqueness`.
  Optional `zScore` column enables z-score plots.

- pedigree:

  reactive returning pedigree data frame with columns `id`, `sire`,
  `dam`, and `sex`. Optionally `gen`.

- kinshipMatrix:

  optional reactive returning kinship matrix. If NULL, the module will
  calculate kinship from the pedigree.

- founderStats:

  optional reactive returning a list of founder statistics (`fe`, `fg`,
  `total`, `nMaleFounders`, `nFemaleFounders`). When supplied, a founder
  summary table is rendered on the Summary Statistics tab (monolith
  parity). If NULL, it is omitted.

- kinshipOverrides:

  optional reactive returning a validated outside-information
  kinship-override data frame (`id1`, `id2`, `kinship`); see
  [`applyKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/applyKinshipOverrides.md)
  (issue \#13). When the module recomputes kinship from the pedigree
  (the usual path), the overrides are applied to that matrix, so the
  relationship table and the kinship CSV export reflect the supplied
  values regardless of tab order. The override moves the kinship *value*
  only; the `relation` *label* stays pedigree-derived (it is computed
  from pedigree structure, not from the kinship value). Overridden pairs
  are flagged with a logical `overridden` column in the relationship
  table (issue \#13 item-3). `NULL` (the default) is a no-op.

## Value

A list with reactive components:

- `summaryData` - Summary statistics (nAnimals, meanMK, meanGU)

- `relationships` - Pairwise relationship designations from
  [`convertRelationships()`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md).
  When `kinshipOverrides` are supplied, a logical `overridden` column
  flags the pairs whose kinship value came from an override (issue \#13
  item-3).

- `relationClasses` - Relationship class frequency table from
  [`makeRelationClassesTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeRelationClassesTable.md)

- `firstOrderCounts` - First-order relative counts per animal from
  [`countFirstOrder()`](https://github.com/rmsharp/nprcgenekeepr/reference/countFirstOrder.md)

- `mkSummary` - Six-number summary of mean kinship

- `guSummary` - Six-number summary of genome uniqueness

## Details

This module provides:

- Summary statistics (counts, mean kinship, genome uniqueness)

- Histograms and box plots for genetic value distributions

- Relationship classification using
  [`convertRelationships()`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md)

- Relationship class frequency tables using
  [`makeRelationClassesTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeRelationClassesTable.md)

- First-order relative counts using
  [`countFirstOrder()`](https://github.com/rmsharp/nprcgenekeepr/reference/countFirstOrder.md)

- Export functionality for kinship matrix, founders, and relationships

## See also

[`modSummaryStatsUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)
for the user interface

[`convertRelationships`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md)
for relationship classification

[`makeRelationClassesTable`](https://github.com/rmsharp/nprcgenekeepr/reference/makeRelationClassesTable.md)
for relationship class summary

[`countFirstOrder`](https://github.com/rmsharp/nprcgenekeepr/reference/countFirstOrder.md)
for first-order relative counting

[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
for kinship matrix calculation

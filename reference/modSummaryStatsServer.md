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
  founderStats = NULL
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

## Value

A list with reactive components:

- `summaryData` - Summary statistics (nAnimals, meanMK, meanGU)

- `relationships` - Pairwise relationship designations from
  [`convertRelationships()`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md)

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

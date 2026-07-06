# Genetic Diversity Module - Server Function

Assembles the live breeding-group, genetic-value, and kinship reactive
inputs into the per-group heat-map statistics (via
[`getGeneticDiversityStats`](https://github.com/rmsharp/nprcgenekeepr/reference/getGeneticDiversityStats.md))
and renders the red/yellow/green heat map (via
[`makeGeneticDiversityHeatmap`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticDiversityHeatmap.md)).
When breeding groups have not been formed or the genetic value analysis
has not been run, the module shows guidance instead of an empty plot.

## Usage

``` r
modGeneticDiversityServer(
  id,
  groups,
  pedigree,
  geneticValues,
  kinshipMatrix,
  currentDate = Sys.Date()
)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- groups:

  reactive returning a list of character vectors of animal IDs, one per
  breeding group (the `groups` returned by
  [`modBreedingGroupsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md)).

- pedigree:

  reactive returning the quality-controlled pedigree data frame.

- geneticValues:

  reactive returning the genetic value report data frame (with `id` and
  `value` columns).

- kinshipMatrix:

  reactive returning the full kinship matrix (row and column names are
  animal IDs).

- currentDate:

  Date used to derive age and the production birth window. Defaults to
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html).

## Value

A list with two reactive elements: `stats`, the per-group metric data
frame (or `NULL` when data are not ready), and `heatmap`, the `ggplot`
heat map (or `NULL`).

## See also

[`modGeneticDiversityUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityUI.md)

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
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

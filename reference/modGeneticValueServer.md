# Genetic Value Analysis Module - Server Function

Genetic Value Analysis Module - Server Function

## Usage

``` r
modGeneticValueServer(id, pedigree, speciesOverrides = reactive(NULL))
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- pedigree:

  reactive returning pedigree data frame.

- speciesOverrides:

  reactive returning the user-configurable species overrides loaded at
  boot by
  [`loadSpeciesOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSpeciesOverrides.md)
  (a list with `breedingTable`, `gestationTable`, `breedingAgeDefault`,
  `gestationDefault`), or `NULL`. Threaded into
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md).
  Defaults to `reactive(NULL)` so no config file means bundled behavior.

## Value

List with `geneticValues`, `topAnimals`, `nAnalyzed`, `kinshipMatrix`,
`founderStats`, `maleFounders`, and `femaleFounders`.

## References

Lacy, R.C. (1989) *Zoo Biology*, **8**, 111-123.

## See also

[`modGeneticValueUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md)

[`modBreedingGroupsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md)
for using results.

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
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

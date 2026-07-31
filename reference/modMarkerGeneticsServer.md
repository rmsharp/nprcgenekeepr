# Marker Genetics Module - Server Function

Reads an uploaded long-format marker genotype file (D1 format: `id`,
`locus`, `allele1`, `allele2`), validates and pivots it
([`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md)),
estimates marker-based kinship independent of pedigree
([`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)),
and surfaces a per-animal comparison of pedigree-based mean kinship
(`indivMeanKin`, already computed upstream and passed in via
`kinshipMatrix`) alongside the new marker-based mean kinship
(`markerMeanKin`) – an independent check on the pedigree-implied
relatedness, not a replacement for it. A second tab surfaces the
heterozygosity diagnostic: per-animal observed heterozygosity
([`markerObservedHeterozygosity`](https://github.com/rmsharp/nprcgenekeepr/reference/markerObservedHeterozygosity.md))
alongside population-level expected heterozygosity
([`markerExpectedHeterozygosity`](https://github.com/rmsharp/nprcgenekeepr/reference/markerExpectedHeterozygosity.md)).

## Usage

``` r
modMarkerGeneticsServer(id, kinshipMatrix)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- kinshipMatrix:

  reactive returning the full pedigree-based kinship matrix (row and
  column names are animal IDs), or `NULL` while upstream analysis has
  not yet been run.

## Value

A list with five reactive elements: `markerGenotype`, the raw uploaded
genotype data frame (or `NULL` before upload); `markerKinshipMatrix`,
the marker-based `id` x `id` kinship matrix (or `NULL`);
`comparisonTable`, the per-animal `indivMeanKin`/`markerMeanKin`
comparison data frame (or `NULL`); `heterozygosityTable`, the per-animal
`ho`/`he` heterozygosity data frame (`he` is the population-wide mean
expected heterozygosity, repeated per row) (or `NULL`); and `isReady`,
`TRUE` once `comparisonTable` has a value.

## Details

This module never touches the existing single-locus genotype path
(`checkGenotypeFile`/`addGenotype`/`hasGenotype`/
`getGVGenotype`/`geneDrop`) – the D1 long-format schema is a new,
sibling concern.

## See also

[`modMarkerGeneticsUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsUI.md)

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
[`modGeneticDiversityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityServer.md),
[`modGeneticDiversityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityUI.md),
[`modGeneticValueServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md),
[`modGeneticValueUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md),
[`modGvAndBgDescServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescServer.md),
[`modGvAndBgDescUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescUI.md),
[`modInputServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md),
[`modInputUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md),
[`modMarkerGeneticsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsUI.md),
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
